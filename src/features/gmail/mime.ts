import sanitizeHtml from "sanitize-html";

export type GmailPart = { mimeType?: string; filename?: string; headers?: { name?: string; value?: string }[]; body?: { data?: string; attachmentId?: string; size?: number }; parts?: GmailPart[] };

function decode(data?: string) { return data ? Buffer.from(data, "base64url").toString("utf8") : ""; }

export function normalizeGmailPayload(payload: GmailPart) {
  const text: string[] = [];
  const html: string[] = [];
  const attachments: { providerAttachmentId: string; filename: string; mimeType: string; sizeBytes?: number }[] = [];
  function visit(part: GmailPart) {
    if (part.filename && part.body?.attachmentId) attachments.push({ providerAttachmentId: part.body.attachmentId, filename: part.filename, mimeType: part.mimeType || "application/octet-stream", sizeBytes: part.body.size });
    else if (part.mimeType === "text/plain") text.push(decode(part.body?.data));
    else if (part.mimeType === "text/html") html.push(decode(part.body?.data));
    part.parts?.forEach(visit);
  }
  visit(payload);
  const sanitizedHtml = html.length ? sanitizeHtml(html.join("\n"), { allowedTags: ["p", "br", "div", "span", "strong", "b", "em", "i", "u", "blockquote", "ul", "ol", "li", "a"], allowedAttributes: { a: ["href", "title"] }, allowedSchemes: ["http", "https", "mailto"], disallowedTagsMode: "discard" }) : null;
  return { bodyText: text.join("\n").trim() || (sanitizedHtml ? sanitizeHtml(sanitizedHtml, { allowedTags: [], allowedAttributes: {} }).trim() : ""), bodyHtmlSanitized: sanitizedHtml, attachments };
}
