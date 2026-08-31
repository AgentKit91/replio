import {describe,expect,it} from "vitest";
import {buildThreadedReply} from "./reply-message";

const fixture={from:"creator@example.test",to:"brand@example.test",subject:"Synthetic partnership",body:"Thanks — this is a synthetic reply.",threadId:"thread-1",messageId:"<replio-draft-v2@replio.app>",inReplyTo:"<brand-message@example.test>"};
describe("threaded Gmail reply MIME",()=>{
  it("sets deterministic threading headers and base64url payload",()=>{const message=buildThreadedReply(fixture);const raw=Buffer.from(message.raw,"base64url").toString("utf8");expect(message.threadId).toBe("thread-1");expect(raw).toContain("In-Reply-To: <brand-message@example.test>");expect(raw).toContain("Message-ID: <replio-draft-v2@replio.app>");expect(raw).not.toContain(fixture.body);});
  it("rejects header injection",()=>expect(()=>buildThreadedReply({...fixture,to:"brand@example.test\r\nBcc: attacker@example.test"})).toThrow("newline"));
});
