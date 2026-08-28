import { describe, expect, it } from "vitest";
import { changedThreadCandidates } from "./sync-candidates";

describe("changedThreadCandidates", () => {
  it("deduplicates repeated notifications for the same selected thread", () => {
    const candidates = changedThreadCandidates([
      { id: "1", messagesAdded: [{ message: { id: "m1", threadId: "t1", labelIds: ["REPLIO"] } }] },
      { id: "2", labelsAdded: [{ message: { id: "m1", threadId: "t1" }, labelIds: ["REPLIO"] }] },
    ], "REPLIO");
    expect([...candidates]).toEqual([["t1", true]]);
  });

  it("marks unlabelled changes so only already-known threads may continue", () => {
    const candidates = changedThreadCandidates([{ id: "3", messagesAdded: [{ message: { id: "m2", threadId: "t2", labelIds: ["INBOX"] } }] }], "REPLIO");
    expect([...candidates]).toEqual([["t2", false]]);
  });
});
