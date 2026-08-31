import { describe, expect, it } from "vitest";
import { commercialExtractorOutput, pricingOutput, replyRewriteOutput, workerContracts } from "./contracts";

describe("fixed AI worker contracts", () => {
  it("defines exactly five workers", () => expect(Object.keys(workerContracts)).toEqual(["commercial_extractor","pricing_engine","risk_engine","strategy_engine","reply_engine"]));
  it("rejects a fabricated confirmed term without evidence", () => expect(commercialExtractorOutput.safeParse({ brand:{name:null,domain:null,confidence:.5},campaign_type:null,platforms:[],deliverables:[],offers:[],terms:[{type:"usage_duration",state:"confirmed",value:{months:3},display_value:"3 months",confidence:.8,evidence:[{message_id:"bad",locator:"x",excerpt:"x"}]}],missing_material_terms:[],confidence:.7 }).success).toBe(false));
  it("keeps the three pricing values distinct and typed", () => expect(pricingOutput.parse({ ideal_ask_minor:60000,expected_settlement_minor:50000,minimum_worthwhile_minor:40000,currency:"GBP",rationale:"Fixture only",evidence_categories:["fixture"],missing_material_facts:[],confidence:.6 }).ideal_ask_minor).toBe(60000));
  it("requires targeted rewrites to preserve strategy",()=>{
    expect(replyRewriteOutput.safeParse({body:"Updated",strategy_preserved:true,changes_applied:["shortened"],confidence:.9}).success).toBe(true);
    expect(replyRewriteOutput.safeParse({body:"Updated",strategy_preserved:false,changes_applied:[],confidence:.9}).success).toBe(false);
  });
});
