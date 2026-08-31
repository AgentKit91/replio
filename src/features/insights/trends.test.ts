import {describe,expect,it} from "vitest";
import {calculatePersonalTrends} from "./trends";

describe("calculatePersonalTrends",()=>{
  it("keeps money separated by currency and calculates honest medians",()=>{
    const result=calculatePersonalTrends([
      {outcome:"success",currency:"GBP",final_amount_minor:10000,estimated_additional_earnings_minor:3000,negotiation_rounds:2},
      {outcome:"lost",currency:"GBP",final_amount_minor:0,estimated_additional_earnings_minor:0,negotiation_rounds:1},
      {outcome:"success",currency:"USD",final_amount_minor:20000,estimated_additional_earnings_minor:5000,negotiation_rounds:null}
    ]);
    expect(result).toMatchObject({completed:3,successes:2,medianUpliftMinor:3000,medianRounds:1.5});
    expect(result.successRate).toBeCloseTo(200/3);
    expect(result.byCurrency).toEqual([
      {currency:"GBP",count:2,finalMinor:10000,eaeMinor:3000},
      {currency:"USD",count:1,finalMinor:20000,eaeMinor:5000}
    ]);
  });
  it("does not imply a rate or median without evidence",()=>expect(calculatePersonalTrends([])).toMatchObject({completed:0,successRate:null,medianUpliftMinor:null,medianRounds:null,byCurrency:[]}));
});
