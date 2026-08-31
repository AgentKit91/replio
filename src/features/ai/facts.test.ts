import { describe, expect, it } from "vitest";
import { extractionFactRows } from "./facts";

describe("analysis evidence ledger", () => {
  it("retains evidence and explicitly records missing material terms", () => {
    const evidence = [{ message_id: "00000000-0000-4000-8000-000000000001", locator: "body", excerpt: "Budget is GBP 500." }];
    const rows = extractionFactRows({
      brand: { name: "Synthetic Brand", domain: "example.test", confidence: 1 }, campaign_type: "sponsored", platforms: ["video"],
      deliverables: [{ platform: "video", deliverable_type: "short", quantity: 1, evidence }],
      offers: [{ offered_by: "brand", amount_minor: 50000, currency: "GBP", offer_type: "initial", evidence }],
      terms: [{ type: "usage", state: "confirmed", value: { duration_days: 30 }, display_value: "30 days", confidence: .9, evidence }],
      missing_material_terms: ["exclusivity"], confidence: .9,
    }, { workspaceId: "w", snapshotId: "s", dealId: "d" });
    expect(rows).toHaveLength(4);
    expect(rows.find((row) => row.fact_type === "offer")?.evidence).toEqual(evidence);
    expect(rows.find((row) => row.fact_type === "term:exclusivity")?.fact_state).toBe("missing");
  });
});
