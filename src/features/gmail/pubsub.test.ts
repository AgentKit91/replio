import { describe, expect, it } from "vitest";
import { parsePubSubEnvelope } from "./pubsub-payload";

function envelope(notification: string) {
  return { message: { data: Buffer.from(notification).toString("base64"), messageId: "message-1" } };
}

describe("parsePubSubEnvelope", () => {
  it("preserves an unquoted 64-bit Gmail history ID without number coercion", () => {
    const parsed = parsePubSubEnvelope(envelope('{"emailAddress":"creator@example.com","historyId":18446744073709551615}'));
    expect(parsed.notification.historyId).toBe("18446744073709551615");
  });

  it("accepts the quoted history ID representation", () => {
    const parsed = parsePubSubEnvelope(envelope('{"emailAddress":"creator@example.com","historyId":"9876543210"}'));
    expect(parsed.notification.historyId).toBe("9876543210");
  });
});
