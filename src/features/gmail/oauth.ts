import "server-only";
import { createHash, randomBytes } from "node:crypto";
import { GMAIL_SCOPE } from "./constants";

export function createPkce() {
  const verifier = randomBytes(32).toString("base64url");
  const challenge = createHash("sha256").update(verifier).digest("base64url");
  return { verifier, challenge };
}

export function createOAuthState() { return randomBytes(24).toString("base64url"); }

export function buildGoogleAuthorizationUrl(config: { clientId: string; redirectUri: string; state: string; challenge: string }) {
  const url = new URL("https://accounts.google.com/o/oauth2/v2/auth");
  url.search = new URLSearchParams({ client_id: config.clientId, redirect_uri: config.redirectUri, response_type: "code", scope: GMAIL_SCOPE, access_type: "offline", prompt: "consent", include_granted_scopes: "true", state: config.state, code_challenge: config.challenge, code_challenge_method: "S256" }).toString();
  return url;
}
