import {describe,expect,it} from "vitest";
import {calculateEstimatedAdditionalEarnings,EAE_METHOD_VERSION} from "./eae";

describe("estimated additional earnings",()=>{
  it("attributes only positive negotiated uplift",()=>expect(calculateEstimatedAdditionalEarnings(50000,125000)).toEqual({estimatedAdditionalEarningsMinor:75000,upliftPercent:150,methodVersion:EAE_METHOD_VERSION,inputs:{initialOfferMinor:50000,finalAmountMinor:125000}}));
  it("never presents a negative outcome as earnings",()=>expect(calculateEstimatedAdditionalEarnings(125000,90000).estimatedAdditionalEarningsMinor).toBe(0));
  it("does not invent a percentage from a zero opening offer",()=>expect(calculateEstimatedAdditionalEarnings(0,50000).upliftPercent).toBeNull());
});
