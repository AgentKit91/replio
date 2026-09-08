import {describe,expect,it} from "vitest";
import {bareAddress,commercialMessageFingerprint,extractForwardedSender,managedReplyTarget} from "./normalization";
describe("provider-neutral email normalization",()=>{
  it("normalizes named addresses",()=>expect(bareAddress("Brand Person <PARTNER@Brand.example> ")).toBe("partner@brand.example"));
  it("extracts exactly one forwarded sender",()=>expect(extractForwardedSender("---------- Forwarded message ---------\nFrom: Brand <partner@brand.example>\nDate: now\n\nHello")).toEqual({isForwarded:true,originalSender:"partner@brand.example"}));
  it("fails closed for ambiguous forwarded headers",()=>expect(extractForwardedSender("--- Forwarded message ---\nFrom: one@brand.example\nFrom: two@brand.example\n\nHello").originalSender).toBeNull());
  it("never falls back to the forwarding creator",()=>expect(managedReplyTarget({from:"creator@example.test",forwarded:{isForwarded:true,originalSender:null},replyTo:[]})).toBeNull());
  it("fails closed for conflicting reply-to recipients",()=>expect(managedReplyTarget({from:"brand@example.test",forwarded:{isForwarded:false,originalSender:null},replyTo:["one@example.test","two@example.test"]})).toBeNull());
  it("deduplicates equivalent cross-provider messages",()=>{const a=commercialMessageFingerprint({from:"Brand <A@brand.example>",to:["creator@example.test"],subject:"Re: Campaign",body:"Hello   there",receivedAt:"2026-09-08T10:10:10Z"});const b=commercialMessageFingerprint({from:"a@brand.example",to:["creator@example.test"],subject:"Campaign",body:"Hello there",receivedAt:"2026-09-08T10:10:55Z"});expect(a).toBe(b);});
});

