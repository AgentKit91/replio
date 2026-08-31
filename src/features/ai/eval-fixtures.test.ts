import { describe,expect,it } from "vitest";
import { commercialExtractorOutput,pricingOutput,replyOutput,riskOutput,strategyOutput } from "./contracts";

const messageId="00000000-0000-4000-8000-000000000099";
const evidence={message_id:messageId,locator:"body:0-18",excerpt:"£350 for 2 reels"};
const extractionBase={brand:{name:null,domain:null,confidence:.4},campaign_type:"sponsored social",platforms:["instagram"],deliverables:[{platform:"instagram",deliverable_type:"reel",quantity:2,evidence:[evidence]}],offers:[{offered_by:"brand" as const,amount_minor:35000,currency:"GBP",offer_type:"initial" as const,evidence:[evidence]}],terms:[{type:"usage_duration",state:"missing" as const,value:{},display_value:"Not stated",confidence:1,evidence:[]}],missing_material_terms:["usage_duration","territory"],confidence:.8};

describe("synthetic M4 commercial safety evals",()=>{
  const cases=[
    ["supported extraction",commercialExtractorOutput,extractionBase,true],
    ["confirmed term without evidence",commercialExtractorOutput,{...extractionBase,terms:[{...extractionBase.terms[0],state:"confirmed",display_value:"3 months"}]},false],
    ["deliverable without evidence",commercialExtractorOutput,{...extractionBase,deliverables:[{...extractionBase.deliverables[0],evidence:[]}]},false],
    ["offer without evidence",commercialExtractorOutput,{...extractionBase,offers:[{...extractionBase.offers[0],evidence:[]}]},false],
    ["ordered pricing",pricingOutput,{ideal_ask_minor:60000,expected_settlement_minor:50000,minimum_worthwhile_minor:40000,currency:"GBP",rationale:"Synthetic fixture",evidence_categories:["confirmed offer"],missing_material_facts:["territory"],confidence:.6},true],
    ["inverted pricing",pricingOutput,{ideal_ask_minor:40000,expected_settlement_minor:50000,minimum_worthwhile_minor:60000,currency:"GBP",rationale:"Invalid fixture",evidence_categories:[],missing_material_facts:[],confidence:.6},false],
    ["material risk",riskOutput,{risks:[{category:"usage",severity:"high",summary:"Usage duration is absent",clarification:"Ask for duration and channels",evidence:[]}],confidence:.8},true],
    ["strategy sequence",strategyOutput,{primary_objective:"Clarify rights before price",sequence:["Ask for usage scope","Counter after scope is known"],terms_to_clarify:["usage_duration"],acceptable_concessions:[],respectful_challenge:null,confidence:.7},true],
    ["strategy-preserving reply",replyOutput,{subject:"Re: Collaboration",body:"Thanks—could you confirm usage duration and territory?",strategy_preserved:true,facts_used:["offer:GBP350"],confidence:.7},true],
    ["reply weakens strategy",replyOutput,{subject:"Re: Collaboration",body:"Accepted.",strategy_preserved:false,facts_used:[],confidence:.7},false],
  ] as const;
  for(const [name,schema,value,valid] of cases) it(name,()=>expect(schema.safeParse(value).success).toBe(valid));
});
