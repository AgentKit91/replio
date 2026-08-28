import "server-only";
import { REPLIO_LABEL_NAME } from "./constants";

type TokenResponse = { access_token: string; refresh_token?: string; scope: string; expires_in: number; token_type: string };
type Label = { id: string; name: string; type?: string };

async function googleJson<T>(url: string, init: RequestInit, accessToken?: string): Promise<T> {
  const response = await fetch(url, { ...init, headers: { ...(init.body ? { "content-type": "application/json" } : {}), ...(accessToken ? { authorization: `Bearer ${accessToken}` } : {}), ...init.headers }, cache: "no-store" });
  if (!response.ok) throw new Error(`Google API request failed (${response.status})`);
  return response.json() as Promise<T>;
}

export async function exchangeAuthorizationCode(config: { code: string; verifier: string; clientId: string; clientSecret: string; redirectUri: string }) {
  const response = await fetch("https://oauth2.googleapis.com/token", { method: "POST", headers: { "content-type": "application/x-www-form-urlencoded" }, body: new URLSearchParams({ code: config.code, code_verifier: config.verifier, client_id: config.clientId, client_secret: config.clientSecret, redirect_uri: config.redirectUri, grant_type: "authorization_code" }), cache: "no-store" });
  if (!response.ok) throw new Error(`Google token exchange failed (${response.status})`);
  return response.json() as Promise<TokenResponse>;
}

export async function getGmailProfile(accessToken: string) { return googleJson<{ emailAddress: string; historyId: string }>("https://gmail.googleapis.com/gmail/v1/users/me/profile", { method: "GET" }, accessToken); }

export async function findOrCreateReplioLabel(accessToken: string) {
  const { labels = [] } = await googleJson<{ labels?: Label[] }>("https://gmail.googleapis.com/gmail/v1/users/me/labels", { method: "GET" }, accessToken);
  const matches = labels.filter((label) => label.type === "user" && label.name.localeCompare(REPLIO_LABEL_NAME, undefined, { sensitivity: "accent" }) === 0);
  if (matches.length > 1) throw new Error("Multiple Gmail labels match Replio; rename duplicates and reconnect");
  if (matches[0]) return matches[0];
  return googleJson<Label>("https://gmail.googleapis.com/gmail/v1/users/me/labels", { method: "POST", body: JSON.stringify({ name: REPLIO_LABEL_NAME, labelListVisibility: "labelShow", messageListVisibility: "show" }) }, accessToken);
}

export async function startGmailWatch(accessToken: string, labelId: string, topicName: string) {
  return googleJson<{ historyId: string; expiration: string }>("https://gmail.googleapis.com/gmail/v1/users/me/watch", { method: "POST", body: JSON.stringify({ topicName, labelIds: [labelId], labelFilterBehavior: "INCLUDE" }) }, accessToken);
}

export async function refreshGmailAccessToken(config: { refreshToken: string; clientId: string; clientSecret: string }) {
  const response = await fetch("https://oauth2.googleapis.com/token", { method: "POST", headers: { "content-type": "application/x-www-form-urlencoded" }, body: new URLSearchParams({ refresh_token: config.refreshToken, client_id: config.clientId, client_secret: config.clientSecret, grant_type: "refresh_token" }), cache: "no-store" });
  if (!response.ok) throw new Error(`Google refresh failed (${response.status})`);
  return response.json() as Promise<{ access_token: string; expires_in: number; scope?: string; token_type: string }>;
}

export type GmailHistory = { id: string; messagesAdded?: { message: { id: string; threadId: string; labelIds?: string[] } }[]; labelsAdded?: { message: { id: string; threadId: string; labelIds?: string[] }; labelIds?: string[] }[] };
export type GmailMessage = { id: string; threadId: string; labelIds?: string[]; historyId?: string; internalDate: string; payload: import("./mime").GmailPart };

export async function listGmailHistory(accessToken: string, startHistoryId: string) {
  const history: GmailHistory[] = [];
  let pageToken: string | undefined;
  let latestHistoryId = startHistoryId;
  do {
    const url = new URL("https://gmail.googleapis.com/gmail/v1/users/me/history");
    url.searchParams.set("startHistoryId", startHistoryId);
    url.searchParams.set("maxResults", "500");
    if (pageToken) url.searchParams.set("pageToken", pageToken);
    const page = await googleJson<{ history?: GmailHistory[]; historyId: string; nextPageToken?: string }>(url.toString(), { method: "GET" }, accessToken);
    history.push(...(page.history ?? []));
    latestHistoryId = page.historyId ?? latestHistoryId;
    pageToken = page.nextPageToken;
  } while (pageToken);
  return { history, latestHistoryId };
}

export async function getGmailThread(accessToken: string, threadId: string) {
  return googleJson<{ id: string; historyId?: string; messages?: GmailMessage[] }>(`https://gmail.googleapis.com/gmail/v1/users/me/threads/${encodeURIComponent(threadId)}?format=full`, { method: "GET" }, accessToken);
}
