import type { z } from "zod";
import type { commercialExtractorOutput,replyOutput } from "./contracts";

type Extraction=z.infer<typeof commercialExtractorOutput>;
type Reply=z.infer<typeof replyOutput>;
export type EvalMessage={id:string;body:string};

function normalized(value:string){return value.replace(/\s+/g," ").trim().toLocaleLowerCase();}

export function evidenceIsGrounded(extraction:Extraction,messages:EvalMessage[]){const byId=new Map(messages.map(message=>[message.id,normalized(message.body)]));const evidence=[...extraction.deliverables.flatMap(item=>item.evidence),...extraction.offers.flatMap(item=>item.evidence),...extraction.terms.flatMap(item=>item.evidence)];return evidence.every(item=>{const body=byId.get(item.message_id);return Boolean(body&&body.includes(normalized(item.excerpt)));});}

export function confirmedFactsHaveEvidence(extraction:Extraction){return extraction.deliverables.every(item=>item.evidence.length>0)&&extraction.offers.every(item=>item.evidence.length>0)&&extraction.terms.filter(term=>term.state==="confirmed").every(term=>term.evidence.length>0);}

export function replyUsesOnlyAllowedFacts(reply:Reply,allowedFacts:Set<string>){return reply.facts_used.every(fact=>allowedFacts.has(fact));}

