import { timingSafeEqual } from "node:crypto";
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { refreshGmailAccessToken } from "@/features/gmail/api";
import { decryptRefreshToken } from "@/features/gmail/crypto";
import { syncChangedGmailThreads } from "@/features/gmail/sync";
import { serverEnv } from "@/lib/env.server";
import { createAdminClient } from "@/lib/supabase/admin";

const jobSchema = z.object({
  queue_message_id: z.number(), event_id: z.uuid(), gmail_connection_id: z.uuid(), workspace_id: z.uuid(),
  gmail_email_address: z.email(), replio_label_id: z.string(), last_history_id: z.string().regex(/^\d+$/),
  encrypted_refresh_token: z.string(), encryption_iv: z.string(), encryption_auth_tag: z.string(), key_version: z.string(),
});

function authorized(request: NextRequest) {
  const expected = serverEnv.INTERNAL_JOB_SECRET;
  const supplied = request.headers.get("authorization")?.replace(/^Bearer\s+/i, "");
  if (!expected || !supplied) return false;
  const left = Buffer.from(expected); const right = Buffer.from(supplied);
  return left.length === right.length && timingSafeEqual(left, right);
}

export async function POST(request: NextRequest) {
  if (!authorized(request)) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  if (!serverEnv.GOOGLE_CLIENT_ID || !serverEnv.GOOGLE_CLIENT_SECRET || !serverEnv.GMAIL_TOKEN_ENCRYPTION_KEY) return NextResponse.json({ error: "Worker is not configured" }, { status: 503 });
  const admin = createAdminClient();
  const { data, error: claimError } = await admin.rpc("claim_gmail_sync");
  if (claimError) return NextResponse.json({ error: "Queue claim failed" }, { status: 500 });
  if (!data) return new NextResponse(null, { status: 204 });
  const job = jobSchema.parse(data);
  try {
    const refreshToken = decryptRefreshToken({ ciphertext: job.encrypted_refresh_token, iv: job.encryption_iv, authTag: job.encryption_auth_tag }, serverEnv.GMAIL_TOKEN_ENCRYPTION_KEY);
    const access = await refreshGmailAccessToken({ refreshToken, clientId: serverEnv.GOOGLE_CLIENT_ID, clientSecret: serverEnv.GOOGLE_CLIENT_SECRET });
    const latestHistoryId = await syncChangedGmailThreads({
      accessToken: access.access_token, startHistoryId: job.last_history_id, replioLabelId: job.replio_label_id, gmailAddress: job.gmail_email_address,
      isKnownThread: async (threadId) => {
        const { count, error } = await admin.from("deal_threads").select("id", { count: "exact", head: true }).eq("workspace_id", job.workspace_id).eq("provider_thread_id", threadId);
        if (error) throw error; return (count ?? 0) > 0;
      },
      persistThread: async (thread) => {
        const { error } = await admin.rpc("persist_gmail_thread", { p_workspace_id: job.workspace_id, p_gmail_connection_id: job.gmail_connection_id, p_provider_thread_id: thread.threadId, p_title: thread.title, p_messages: thread.messages });
        if (error) throw error;
      },
    });
    const { error } = await admin.rpc("finish_gmail_sync", { p_queue_message_id: job.queue_message_id, p_event_id: job.event_id, p_history_id: latestHistoryId });
    if (error) throw error;
    return NextResponse.json({ processed: true });
  } catch (error) {
    const code = error instanceof Error ? error.message.replace(/[^a-zA-Z0-9 _()-]/g, "").slice(0, 80) : "unknown_sync_error";
    await admin.rpc("fail_gmail_sync", { p_event_id: job.event_id, p_error_code: code });
    return NextResponse.json({ error: "Gmail sync failed and will retry" }, { status: 503 });
  }
}
