import "server-only";
import { createRemoteJWKSet, jwtVerify } from "jose";
export { parsePubSubEnvelope } from "./pubsub-payload";

const googleJwks = createRemoteJWKSet(new URL("https://www.googleapis.com/oauth2/v3/certs"));

export async function verifyPubSubBearer(header: string | null, audience: string, expectedEmail: string) {
  if (!header?.startsWith("Bearer ")) throw new Error("Missing bearer token");
  const { payload } = await jwtVerify(header.slice(7), googleJwks, { audience, issuer: ["https://accounts.google.com", "accounts.google.com"] });
  if (payload.email !== expectedEmail || payload.email_verified !== true) throw new Error("Unexpected Pub/Sub identity");
}
