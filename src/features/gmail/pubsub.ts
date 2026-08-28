import "server-only";
import { createRemoteJWKSet, jwtVerify } from "jose";
import { z } from "zod";

const googleJwks = createRemoteJWKSet(new URL("https://www.googleapis.com/oauth2/v3/certs"));
const envelopeSchema = z.object({ message: z.object({ data: z.string().min(1), messageId: z.string().min(1) }), subscription: z.string().optional() });
const notificationSchema = z.object({ emailAddress: z.email(), historyId: z.string().regex(/^\d+$/) });

export async function verifyPubSubBearer(header: string | null, audience: string, expectedEmail: string) {
  if (!header?.startsWith("Bearer ")) throw new Error("Missing bearer token");
  const { payload } = await jwtVerify(header.slice(7), googleJwks, { audience, issuer: ["https://accounts.google.com", "accounts.google.com"] });
  if (payload.email !== expectedEmail || payload.email_verified !== true) throw new Error("Unexpected Pub/Sub identity");
}

export function parsePubSubEnvelope(value: unknown) {
  const envelope = envelopeSchema.parse(value);
  const decoded = Buffer.from(envelope.message.data, "base64").toString("utf8");
  return { messageId: envelope.message.messageId, notification: notificationSchema.parse(JSON.parse(decoded)) };
}
