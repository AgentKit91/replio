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
};

function countByStatus(rows: Array<{ status: string }> | null, status: string) {
  return rows?.filter((row) => row.status === status).length ?? 0;
}

export async function loadFounderDashboard(): Promise<FounderDashboard> {
  const { userId } = await requireUser();
  const admin = createAdminClient();
  const { data: founder } = await admin.schema("private").from("founder_users").select("user_id").eq("user_id", userId).maybeSingle();
  if (!founder) notFound();

  const [subscriptions, gmail, aiJobs, sendJobs, workerRuns, grants, incidents] = await Promise.all([
    admin.from("subscriptions").select("status"),
    admin.from("gmail_connections").select("watch_status,watch_expiration"),
    admin.schema("private").from("ai_analysis_jobs").select("status,last_error_class,created_at"),
    admin.schema("private").from("gmail_send_jobs").select("status,last_error_class,created_at"),
    admin.from("ai_worker_runs").select("estimated_cost_usd,status").gte("started_at", new Date(Date.now() - 30 * 86_400_000).toISOString()),
    admin.from("support_access_grants").select("id,expires_at,revoked_at").is("revoked_at", null).gt("expires_at", new Date().toISOString()),
    admin.schema("private").from("system_incidents").select("id,severity,title,summary,recommended_action").neq("status", "resolved").order("opened_at", { ascending: false }).limit(20),
  ]);

  const failures = [subscriptions.error, gmail.error, aiJobs.error, sendJobs.error, workerRuns.error, grants.error, incidents.error].filter(Boolean);
  if (failures.length) throw new Error("Founder operational read model is unavailable");

  const now = Date.now();
  const unhealthyGmail = gmail.data?.filter((row) => row.watch_status !== "active" || !row.watch_expiration || Date.parse(row.watch_expiration) <= now).length ?? 0;
  const actionItems: FounderActionItem[] = (incidents.data ?? []).map((row) => ({
    id: row.id,
    severity: row.severity,
    title: row.title,
    context: row.summary,
    nextStep: row.recommended_action ?? "Review the component health and choose the safest recovery action.",
  }));

  const failedAi = countByStatus(aiJobs.data, "failed");
  const failedSends = countByStatus(sendJobs.data, "failed");
  if (unhealthyGmail) actionItems.push({ id: "gmail-health", severity: "warning", title: `${unhealthyGmail} Gmail connection${unhealthyGmail === 1 ? " needs" : "s need"} attention`, context: "A watch is inactive, expired or missing an expiry.", nextStep: "Ask the creator to reconnect when authorization is invalid; otherwise renew the watch." });
  if (failedAi) actionItems.push({ id: "ai-failures", severity: "warning", title: `${failedAi} AI analysis job${failedAi === 1 ? " has" : "s have"} failed`, context: "Private deal content remains hidden in this operational view.", nextStep: "Inspect the safe error class, then retry only transient failures." });
  if (failedSends) actionItems.push({ id: "send-failures", severity: "critical", title: `${failedSends} Gmail send job${failedSends === 1 ? " has" : "s have"} failed`, context: "No message body or negotiation content is exposed here.", nextStep: "Reconcile provider state before retrying to avoid duplicate sends." });

  const costRows = workerRuns.data ?? [];
  const aiCostUsd = costRows.some((row) => row.estimated_cost_usd == null)
    ? null
    : costRows.reduce((total, row) => total + Number(row.estimated_cost_usd), 0);

  return {
    trials: countByStatus(subscriptions.data, "trialing"),
    activeSubscriptions: countByStatus(subscriptions.data, "active"),
    pastDueSubscriptions: countByStatus(subscriptions.data, "past_due") + countByStatus(subscriptions.data, "unpaid"),
    connectedGmail: gmail.data?.filter((row) => row.watch_status === "active" && row.watch_expiration && Date.parse(row.watch_expiration) > now).length ?? 0,
    unhealthyGmail,
    queuedAi: countByStatus(aiJobs.data, "queued") + countByStatus(aiJobs.data, "processing"),
    failedAi,
    queuedSends: countByStatus(sendJobs.data, "queued") + countByStatus(sendJobs.data, "processing"),
    failedSends,
    aiCostUsd,
    openSupportGrants: grants.data?.length ?? 0,
    actionItems,
  };
}

