import type { z } from "zod";
import type { commercialExtractorOutput } from "./contracts";

type Extraction = z.infer<typeof commercialExtractorOutput>;

export function extractionFactRows(extraction: Extraction, scope: { workspaceId: string; snapshotId: string; dealId: string }) {
  const base = { workspace_id: scope.workspaceId, snapshot_id: scope.snapshotId, deal_id: scope.dealId, source_owner: "ai_extraction" as const };
  return [
    ...extraction.offers.map((offer) => ({ ...base, fact_type: "offer", normalized_value: offer, display_value: `${offer.currency} ${offer.amount_minor}`, fact_state: "confirmed", confidence: extraction.confidence, evidence: offer.evidence })),
    ...extraction.deliverables.map((deliverable) => ({ ...base, fact_type: "deliverable", normalized_value: deliverable, display_value: `${deliverable.quantity} × ${deliverable.deliverable_type}`, fact_state: "confirmed", confidence: extraction.confidence, evidence: deliverable.evidence })),
    ...extraction.terms.map((term) => ({ ...base, fact_type: `term:${term.type}`, normalized_value: term.value, display_value: term.display_value, fact_state: term.state, confidence: term.confidence, evidence: term.evidence })),
    ...extraction.missing_material_terms.map((term) => ({ ...base, fact_type: `term:${term}`, normalized_value: { term }, display_value: term, fact_state: "missing", confidence: extraction.confidence, evidence: [] })),
  ];
}
