import { describe,expect,it } from "vitest";
import { calculateDealScore } from "./score";

const evidence=[{message_id:"00000000-0000-4000-8000-000000000001",locator:"body",excerpt:"£500 for one video"}];
const config={components:{commercial_value:30,term_completeness:25,risk:25,creator_fit:20}};
const extraction={brand:{name:"Synthetic",domain:"example.test",confidence:1},campaign_type:"sponsored",platforms:["video"],deliverables:[{platform:"video",deliverable_type:"short",quantity:1,evidence}],offers:[{offered_by:"brand" as const,amount_minor:50000,currency:"GBP",offer_type:"initial" as const,evidence}],terms:[{type:"payment_timing",state:"confirmed" as const,value:{days:30},display_value:"30 days",confidence:1,evidence}],missing_material_terms:[],confidence:1};
const pricing={ideal_ask_minor:70000,expected_settlement_minor:60000,minimum_worthwhile_minor:50000,currency:"GBP",rationale:"Synthetic fixture",evidence_categories:["offer"],missing_material_facts:[],confidence:1};

describe("versioned Replio Score mechanism",()=>{
  it("scores complete, low-risk fixture higher than one with missing terms and high risk",()=>{
    const strong=calculateDealScore(config,extraction,pricing,{risks:[],confidence:1});
    const weak=calculateDealScore(config,{...extraction,terms:[],missing_material_terms:["usage duration","exclusivity"]},pricing,{risks:[{category:"usage",severity:"high",summary:"Unbounded usage",clarification:"Confirm duration",evidence}],confidence:1});
    expect(strong.score).toBeGreaterThan(weak.score); expect(weak.improvementActions).toContain("Clarify usage duration");
  });
  it("keeps creator fit provisional until profile strategy exists",()=>expect(calculateDealScore(config,extraction,pricing,{risks:[],confidence:1}).components.creator_fit.score).toBe(50));
});
