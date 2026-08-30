import { NextRequest, NextResponse } from "next/server";
import { parsePubSubEnvelope, verifyPubSubBearer } from "@/features/gmail/pubsub";
import { serverEnv } from "@/lib/env.server";
import { createAdminClient } from "@/lib/supabase/admin";

export async function POST(request: NextRequest) {
  const audience = serverEnv.GOOGLE_PUBSUB_AUDIENCE;
  const serviceAccount = serverEnv.GOOGLE_PUBSUB_PUSH_SERVICE_ACCOUNT_EMAIL;
  if (!audience || !serviceAccount) return NextResponse.json({ error: "Webhook is not configured" }, { status: 503 });

  try {
    await verifyPubSubBearer(request.headers.get("authorization"), audience, serviceAccount);
  } catch (error) {
    console.warn("gmail_pubsub_rejected", { stage: "identity", reason: error instanceof Error ? error.name : "unknown" });
    return NextResponse.json({ error: "Invalid push notification" }, { status: 400 });
  }

  let parsed: ReturnType<typeof parsePubSubEnvelope>;
  try {
    parsed = parsePubSubEnvelope(await request.json());
  } catch (error) {
    console.warn("gmail_pubsub_rejected", { stage: "payload", reason: error instanceof Error ? error.name : "unknown" });
    return NextResponse.json({ error: "Invalid push notification" }, { status: 400 });
  }

  const { error } = await createAdminClient().rpc("enqueue_gmail_sync", {
    p_email: parsed.notification.emailAddress,
    p_history_id: parsed.notification.historyId,
    p_pubsub_message_id: parsed.messageId,
  });
  if (error) {
    console.error("gmail_pubsub_enqueue_failed", { code: error.code ?? "unknown" });
    return NextResponse.json({ error: "Unable to enqueue notification" }, { status: 503 });
  }

  return new NextResponse(null, { status: 204 });
}
