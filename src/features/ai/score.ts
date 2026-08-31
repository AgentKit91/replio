import { z } from "zod";
import { commercialExtractorOutput, pricingOutput, riskOutput } from "./contracts";

export const scoreConfigSchema = z.object({ components: z.object({ commercial_value: z.number().positive(), term_completeness: z.number().positive(), risk: z.number().positive(), creator_fit: z.number().positive() }) });
type Extraction = z.infer<typeof commercialExtractorOutput>;
type Pricing = z.infer<typeof pricingOutput>;
type Risks = z.infer<typeof riskOutput>;

export function calculateDealScore(configInput: unknown, extraction: Extraction, pricing: Pricing, risks: Risks) {
  const config=scoreConfigSchema.parse(configInput); const weights=config.components; const totalWeight=Object.values(weights).reduce((sum,value)=>sum+value,0);
  const confirmedTerms=extraction.terms.filter((term)=>term.state==="confirmed").length;
  const missingTerms=new Set([...extraction.missing_material_terms,...extraction.terms.filter((term)=>term.state==="missing").map((term)=>term.type)]);
  const termTotal=Math.max(1,confirmedTerms+missingTerms.size);
  const highRisks=risks.risks.filter((risk)=>risk.severity==="high").length; const mediumRisks=risks.risks.filter((risk)=>risk.severity==="medium").length;
  const ratios={
    commercial_value: extraction.offers.length>0 && pricing.ideal_ask_minor>=pricing.expected_settlement_minor ? 1 : extraction.offers.length>0 ? .6 : .2,
    term_completeness: confirmedTerms/termTotal,
    risk: Math.max(0,1-highRisks*.35-mediumRisks*.15),
    creator_fit: .5,
  };
  const components=Object.fromEntries(Object.entries(ratios).map(([name,ratio])=>[name,{score:Math.round(ratio*100),weight:weights[name as keyof typeof weights]}]));
  const score=Math.round(Object.entries(ratios).reduce((sum,[name,ratio])=>sum+ratio*weights[name as keyof typeof weights],0)/totalWeight*100);
  const improvementActions=[...missingTerms].map((term)=>`Clarify ${term}`);
  if(highRisks) improvementActions.push("Resolve the highest-priority commercial risks");
  improvementActions.push("Add creator goals and non-negotiables to improve fit guidance");
  return {score,components,improvementActions:[...new Set(improvementActions)]};
}
