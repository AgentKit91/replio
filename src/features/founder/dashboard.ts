import "server-only";
import { notFound } from "next/navigation";
import { requireUser } from "@/features/auth/require-user";
import { createAdminClient } from "@/lib/supabase/admin";

export type FounderActionItem = {
  id: string;
  severity: "info" | "warning" | "critical";
  title: string;
  context: string;
  nextStep: string;
};

export type FounderDashboard = {
  trials: number;
  activeSubscriptions: number;
  pastDueSubscriptions: number;
  connectedGmail: number;
  unhealthyGmail: number;
  queuedAi: number;
  failedAi: number;
  queuedSends: number;
  failedSends: number;
  aiCostUsd: number | null;
  openSupportGrants: number;
  actionItems: FounderActionItem[];
  customers: FounderCustomer[];
  workerControls: FounderWorkerControl[];
};

export type FounderWorkerControl = { key: "ai_worker_enabled" | "gmail_send_enabled"; enabled: boolean; description: string; version: number; updatedAt: string };

export type FounderCustomer = {
  userId: string; email: string; name: string; signedUpAt: string; lastActivityAt: string | null;
  plan: string | null; subscriptionStatus: string | null; gmailStatus: string | null; gmailWatchExpiresAt: string | null;
  analysedDeals: number; failedJobs: number; supportGrantActive: boolean;
};

type Snapshot = Omit<FounderDashboard, "actionItems" | "workerControls"> & { incidents: FounderActionItem[] };

export async function loadFounderDashboard(): Promise<FounderDashboard> {
  const { userId } = await requireUser();
  const admin = createAdminClient();
  const [snapshotResult, controlsResult] = await Promise.all([admin.rpc("founder_operational_snapshot", { p_founder_user_id: userId }), admin.rpc("founder_worker_controls", { p_founder_user_id: userId })]);
  const { data, error } = snapshotResult;
  if (error || controlsResult.error) throw new Error("Founder operational read model is unavailable");
  if (!data) notFound();
  const snapshot = data as Snapshot;
  const actionItems = [...snapshot.incidents];
  if (snapshot.unhealthyGmail) actionItems.push({ id: "gmail-health", severity: "warning", title: `${snapshot.unhealthyGmail} Gmail connection${snapshot.unhealthyGmail === 1 ? " needs" : "s need"} attention`, context: "A watch is inactive, expired or missing an expiry.", nextStep: "Ask the creator to reconnect when authorization is invalid; otherwise renew the watch." });
  if (snapshot.failedAi) actionItems.push({ id: "ai-failures", severity: "warning", title: `${snapshot.failedAi} AI analysis job${snapshot.failedAi === 1 ? " has" : "s have"} failed`, context: "Private deal content remains hidden in this operational view.", nextStep: "Inspect the safe error class, then retry only transient failures." });
  if (snapshot.failedSends) actionItems.push({ id: "send-failures", severity: "critical", title: `${snapshot.failedSends} Gmail send job${snapshot.failedSends === 1 ? " has" : "s have"} failed`, context: "No message body or negotiation content is exposed here.", nextStep: "Reconcile provider state before retrying to avoid duplicate sends." });
  return { ...snapshot, actionItems, workerControls: controlsResult.data as FounderWorkerControl[] };
}

