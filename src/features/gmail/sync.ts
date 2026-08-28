import "server-only";
import { getGmailThread, listGmailHistory, type GmailMessage } from "./api";
import { normalizeGmailPayload } from "./mime";
import { changedThreadCandidates } from "./sync-candidates";

function header(message: GmailMessage, name: string) { return message.payload.headers?.find((item) => item.name?.toLowerCase() === name.toLowerCase())?.value ?? ""; }
function addresses(value: string) { return value.split(",").map((item) => item.trim()).filter(Boolean); }

export function normalizeGmailMessage(message: GmailMessage, gmailAddress: string) {
  const content = normalizeGmailPayload(message.payload);
  const from = header(message, "from");
  return {
    provider_message_id: message.id, provider_history_id: message.historyId ?? "", internal_date: new Date(Number(message.internalDate)).toISOString(),
    direction: from.toLowerCase().includes(gmailAddress.toLowerCase()) ? "outbound" : "inbound", from_address: from,
    to_addresses: addresses(header(message, "to")), cc_addresses: addresses(header(message, "cc")), subject: header(message, "subject"),
    body_text: content.bodyText, body_html_sanitized: content.bodyHtmlSanitized, provider_label_ids: message.labelIds ?? [],
    raw_headers: Object.fromEntries((message.payload.headers ?? []).filter((item) => item.name && item.value).map((item) => [item.name!, item.value!])),
    attachments: content.attachments.map((item) => ({ provider_attachment_id: item.providerAttachmentId, filename: item.filename, mime_type: item.mimeType, size_bytes: item.sizeBytes })),
  };
}

export async function syncChangedGmailThreads(config: {
  accessToken: string; startHistoryId: string; replioLabelId: string; gmailAddress: string;
  isKnownThread: (threadId: string) => Promise<boolean>;
  persistThread: (thread: { threadId: string; title: string; messages: ReturnType<typeof normalizeGmailMessage>[] }) => Promise<void>;
}) {
  const { history, latestHistoryId } = await listGmailHistory(config.accessToken, config.startHistoryId);
  for (const [threadId, selectedByLabel] of changedThreadCandidates(history, config.replioLabelId)) {
    if (!selectedByLabel && !(await config.isKnownThread(threadId))) continue;
    const thread = await getGmailThread(config.accessToken, threadId);
    const messages = (thread.messages ?? []).map((message) => normalizeGmailMessage(message, config.gmailAddress));
    const title = messages.find((message) => message.subject)?.subject ?? "Untitled Gmail conversation";
    await config.persistThread({ threadId, title, messages });
  }
  return latestHistoryId;
}
