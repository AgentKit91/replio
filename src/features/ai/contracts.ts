import { z } from "zod";

export const evidenceSchema = z.object({ message_id: z.uuid(), locator: z.string().max(200), excerpt: z.string().max(280) });
const confidence = z.number().min(0).max(1);
export const commercialExtractorOutput = z.object({
  brand: z.object({ name: z.string().nullable(), domain: z.string().nullable(), confidence }),
  campaign_type: z.string().nullable(), platforms: z.array(z.string()),
  deliverables: z.array(z.object({ platform: z.string().nullable(), deliverable_type: z.string(), quantity: z.number().int().positive(), evidence: z.array(evidenceSchema).min(1) })),
  offers: z.array(z.object({ offered_by: z.enum(["brand","creator"]), amount_minor: z.number().int().nonnegative(), currency: z.string().length(3), offer_type: z.enum(["initial","counter","revised","final"]), evidence: z.array(evidenceSchema).min(1) })),
  terms: z.array(z.object({ type: z.string(), state: z.enum(["confirmed","missing","inferred"]), value: z.record(z.string(), z.unknown()), display_value: z.string(), confidence, evidence: z.array(evidenceSchema) }).superRefine((term,ctx)=>{if(term.state==="confirmed"&&term.evidence.length===0)ctx.addIssue({code:"custom",message:"Confirmed terms require evidence",path:["evidence"]});})),
  missing_material_terms: z.array(z.string()), confidence,
});
export const pricingOutput = z.object({ ideal_ask_minor: z.number().int().nonnegative(), expected_settlement_minor: z.number().int().nonnegative(), minimum_worthwhile_minor: z.number().int().nonnegative(), currency: z.string().length(3), rationale: z.string(), evidence_categories: z.array(z.string()), missing_material_facts: z.array(z.string()), confidence }).superRefine((value,ctx)=>{if(!(value.ideal_ask_minor>=value.expected_settlement_minor&&value.expected_settlement_minor>=value.minimum_worthwhile_minor))ctx.addIssue({code:"custom",message:"Pricing recommendations must descend from ideal to minimum"});});
export const riskOutput = z.object({ risks: z.array(z.object({ category: z.string(), severity: z.enum(["low","medium","high"]), summary: z.string(), clarification: z.string().nullable(), evidence: z.array(evidenceSchema) })), confidence });
export const strategyOutput = z.object({ primary_objective: z.string(), sequence: z.array(z.string()), terms_to_clarify: z.array(z.string()), acceptable_concessions: z.array(z.string()), respectful_challenge: z.string().nullable(), confidence });
export const replyOutput = z.object({ subject: z.string(), body: z.string(), strategy_preserved: z.literal(true), facts_used: z.array(z.string()), confidence });

export const workerContracts = { commercial_extractor: commercialExtractorOutput, pricing_engine: pricingOutput, risk_engine: riskOutput, strategy_engine: strategyOutput, reply_engine: replyOutput } as const;
export type WorkerName = keyof typeof workerContracts;
