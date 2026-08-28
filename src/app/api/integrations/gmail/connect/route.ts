import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { requireUser } from "@/features/auth/require-user";
import { buildGoogleAuthorizationUrl, createOAuthState, createPkce } from "@/features/gmail/oauth";
import { requireGmailServerEnv } from "@/lib/env.server";

export async function GET() {
  await requireUser();
  const env = requireGmailServerEnv();
  const state = createOAuthState();
  const { verifier, challenge } = createPkce();
  const cookieStore = await cookies();
  const options = { httpOnly: true, secure: env.APP_ENV !== "development", sameSite: "lax" as const, path: "/api/integrations/gmail/callback", maxAge: 600 };
  cookieStore.set("replio_gmail_oauth_state", state, options);
  cookieStore.set("replio_gmail_pkce", verifier, options);
  return NextResponse.redirect(buildGoogleAuthorizationUrl({ clientId: env.GOOGLE_CLIENT_ID, redirectUri: env.GOOGLE_OAUTH_REDIRECT_URI, state, challenge }));
}
