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
    const { messageId, notification } = parsePubSubEnvelope(await request.json());
    const { error } = await createAdminClient().rpc("enqueue_gmail_sync", { p_email: notification.emailAddress, p_history_id: notification.historyId, p_pubsub_message_id: messageId });
    if (error) throw error;
    return new NextResponse(null, { status: 204 });
  } catch {
    return NextResponse.json({ error: "Invalid push notification" }, { status: 400 });
  }
}
