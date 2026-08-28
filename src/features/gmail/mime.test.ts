import { describe, expect, it } from "vitest";
import { normalizeGmailPayload } from "./mime";

const encoded = (value: string) => Buffer.from(value).toString("base64url");

describe("normalizeGmailPayload", () => {
  it("extracts text and attachment references without copying attachment bytes", () => {
    const result = normalizeGmailPayload({ mimeType: "multipart/mixed", parts: [
      { mimeType: "text/plain", body: { data: encoded("Hello creator") } },
      { mimeType: "application/pdf", filename: "brief.pdf", body: { attachmentId: "att-1", size: 123 } },
    ] });
    expect(result.bodyText).toBe("Hello creator");
    expect(result.attachments).toEqual([{ providerAttachmentId: "att-1", filename: "brief.pdf", mimeType: "application/pdf", sizeBytes: 123 }]);
  });

  it("removes scripts, event handlers and remote images", () => {
    const result = normalizeGmailPayload({ mimeType: "text/html", body: { data: encoded('<p onclick="steal()">Hi</p><script>bad()</script><img src="https://tracker.test/pixel">') } });
    expect(result.bodyHtmlSanitized).toBe("<p>Hi</p>");
    expect(result.bodyText).toBe("Hi");
  });
});
