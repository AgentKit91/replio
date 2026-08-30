import { z } from "zod";

const envelopeSchema = z.object({ message: z.object({ data: z.string().min(1), messageId: z.string().min(1) }), subscription: z.string().optional() });
const notificationSchema = z.object({ emailAddress: z.email() });

export function parsePubSubEnvelope(value: unknown) {
  const envelope = envelopeSchema.parse(value);
  const decoded = Buffer.from(envelope.message.data, "base64").toString("utf8");
  const notification = notificationSchema.parse(JSON.parse(decoded));
  const historyIdMatch = /"historyId"\s*:\s*(?:"(\d+)"|(\d+))/.exec(decoded);
  const historyId = historyIdMatch?.[1] ?? historyIdMatch?.[2];
  if (!historyId) throw new Error("Missing Gmail history ID");
  return { messageId: envelope.message.messageId, notification: { ...notification, historyId } };
}
