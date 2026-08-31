function safeHeader(value:string){if(/[\r\n]/.test(value))throw new Error("Email header contains a newline");return value.trim();}
function wrapBase64(value:string){return Buffer.from(value,"utf8").toString("base64").match(/.{1,76}/g)?.join("\r\n")??"";}

export function buildThreadedReply(config:{from:string;to:string;subject:string;body:string;threadId:string;messageId:string;inReplyTo:string;references?:string}){
  const headers=[`From: ${safeHeader(config.from)}`,`To: ${safeHeader(config.to)}`,`Subject: ${safeHeader(config.subject)}`,`Message-ID: ${safeHeader(config.messageId)}`,`In-Reply-To: ${safeHeader(config.inReplyTo)}`,`References: ${safeHeader([config.references,config.inReplyTo].filter(Boolean).join(" "))}`,"MIME-Version: 1.0","Content-Type: text/plain; charset=UTF-8","Content-Transfer-Encoding: base64"];
  const mime=`${headers.join("\r\n")}\r\n\r\n${wrapBase64(config.body)}\r\n`;
  return {threadId:config.threadId,raw:Buffer.from(mime,"utf8").toString("base64url")};
}
