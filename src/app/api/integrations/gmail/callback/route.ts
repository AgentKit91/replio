import { cookies } from "next/headers";
import { NextRequest, NextResponse } from "next/server";
import { encryptRefreshToken } from "@/features/gmail/crypto";
import { exchangeAuthorizationCode, findOrCreateReplioLabel, getGmailProfile, startGmailWatch } from "@/features/gmail/api";
import { GMAIL_SCOPE } from "@/features/gmail/constants";
import { requireGmailServerEnv } from "@/lib/env.server";
import { createAdminClient } from "@/lib/supabase/admin";
import { createClient } from "@/lib/supabase/server";

function settingsRedirect(request: NextRequest, result: string) { return NextResponse.redirect(new URL(`/settings?gmail=${result}`, request.url)); }

export async function GET(request: NextRequest) {
  const cookieStore = await cookies();
  const stateCookie = cookieStore.get("replio_gmail_oauth_state")?.value;
  const verifier = cookieStore.get("replio_gmail_pkce")?.value;
  cookieStore.delete("replio_gmail_oauth_state");
  cookieStore.delete("replio_gmail_pkce");
  const code = request.nextUrl.searchParams.get("code");
  const state = request.nextUrl.searchParams.get("state");
  if (!code || !state || !stateCookie || state !== stateCookie || !verifier) return settingsRedirect(request, "invalid_state");

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.redirect(new URL("/login", request.url));
  const { data: membership } = await supabase.from("workspace_members").select("workspace_id").eq("user_id", user.id).single();
  if (!membership) return settingsRedirect(request, "workspace_missing");

  try {
    const env = requireGmailServerEnv();
    const token = await exchangeAuthorizationCode({ code, verifier, clientId: env.GOOGLE_CLIENT_ID, clientSecret: env.GOOGLE_CLIENT_SECRET, redirectUri: env.GOOGLE_OAUTH_REDIRECT_URI });
    if (!token.refresh_token) throw new Error("Google did not return an offline refresh token");
    const [profile, label] = await Promise.all([getGmailProfile(token.access_token), findOrCreateReplioLabel(token.access_token)]);
    const watch = await startGmailWatch(token.access_token, label.id, env.GOOGLE_PUBSUB_TOPIC);
    const encrypted = encryptRefreshToken(token.refresh_token, env.GMAIL_TOKEN_ENCRYPTION_KEY);
    const { error } = await createAdminClient().rpc("complete_gmail_connection", {
      p_workspace_id: membership.workspace_id, p_user_id: user.id, p_email: profile.emailAddress,
      p_scopes: token.scope?.split(" ").filter(Boolean) ?? [GMAIL_SCOPE], p_label_id: label.id,
      p_history_id: watch.historyId || profile.historyId, p_watch_expiration: new Date(Number(watch.expiration)).toISOString(),
      p_encrypted_refresh_token: encrypted.ciphertext, p_encryption_iv: encrypted.iv,
      p_encryption_auth_tag: encrypted.authTag, p_key_version: env.GMAIL_TOKEN_ENCRYPTION_KEY_VERSION,
    });
    if (error) throw error;
    return settingsRedirect(request, "connected");
  } catch {
    return settingsRedirect(request, "failed");
  }
}
