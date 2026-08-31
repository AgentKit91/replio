import {describe,expect,it} from "vitest";
import {benchmarkEvidence} from "./benchmark";

describe("benchmark evidence gate",()=>{
  it("withholds weak cells",()=>expect(benchmarkEvidence(4)).toEqual({eligible:false,strength:"insufficient"}));
  it("allows only cells meeting the configured minimum",()=>expect(benchmarkEvidence(5)).toEqual({eligible:true,strength:"emerging"}));
  it("labels deeper cells strong",()=>expect(benchmarkEvidence(20)).toEqual({eligible:true,strength:"strong"}));
});
