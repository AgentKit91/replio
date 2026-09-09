import {describe,expect,it} from "vitest";
import {isDealCheckReturnPath,safeRelativeReturnPath} from "./return-path";

describe("safeRelativeReturnPath",()=>{
  it("accepts a same-origin relative path",()=>expect(safeRelativeReturnPath("/dealcheck/resume?from=auth")).toBe("/dealcheck/resume?from=auth"));
  it.each(["https://evil.test","//evil.test","/\\evil.test","javascript:alert(1)","/ok\nLocation:https://evil.test"])("rejects unsafe return %s",value=>expect(safeRelativeReturnPath(value)).toBeNull());
  it("only identifies the DealCheck resume boundary",()=>{expect(isDealCheckReturnPath("/dealcheck/resume")).toBe(true);expect(isDealCheckReturnPath("/dashboard")).toBe(false);});
});
