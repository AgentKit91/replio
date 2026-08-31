import { describe, expect, it } from "vitest";
import { syntheticKnowledgeFixture } from "./synthetic-knowledge";

describe("synthetic Knowledge Library corpus", () => {
  it("cannot be mistaken for production-approved knowledge", () => {
    expect(syntheticKnowledgeFixture.trust_tier).toBe("fixture");
    expect(syntheticKnowledgeFixture.is_production_approved).toBe(false);
    expect(syntheticKnowledgeFixture.source_url).toBeNull();
  });
});
