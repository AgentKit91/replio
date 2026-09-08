import {createHash} from "node:crypto";

const emailPattern=/^[^\s<>@]+@[^\s<>@]+\.[^\s<>@]+$/i;
export function bareAddress(value:string){const bracket=value.match(/<([^<>]+)>/);const address=(bracket?.[1]??value).trim().toLowerCase();return emailPattern.test(address)?address:null;}

export function extractForwardedSender(body:string){
  const marker=/^-{2,}\s*(?:forwarded|original) message\s*-{2,}$/gim;const matches=[...body.matchAll(marker)];
  if(matches.length!==1)return {isForwarded:matches.length>0,originalSender:null};
  const headerBlock=body.slice((matches[0].index??0)+matches[0][0].length).split(/\r?\n\r?\n/,1)[0];
  const senders=[...headerBlock.matchAll(/^From:\s*(.+)$/gim)].map(match=>bareAddress(match[1])).filter((value):value is string=>Boolean(value));
  return {isForwarded:true,originalSender:new Set(senders).size===1?senders[0]:null};
}

export function commercialMessageFingerprint(input:{from:string;to:string[];subject:string;body:string;receivedAt:string}){
  const minute=new Date(input.receivedAt).toISOString().slice(0,16);const normalized=[bareAddress(input.from)??input.from.trim().toLowerCase(),[...input.to].map(value=>bareAddress(value)??value.trim().toLowerCase()).sort().join(","),input.subject.trim().toLowerCase().replace(/^((re|fwd?):\s*)+/i,""),input.body.replace(/\s+/g," ").trim(),minute].join("\n");
  return createHash("sha256").update(normalized).digest("hex");
}

export function managedReplyTarget(input:{from:string;forwarded:{isForwarded:boolean;originalSender:string|null};replyTo:string[]}){
  if(input.forwarded.isForwarded)return input.forwarded.originalSender;
  const replyTargets=input.replyTo.map(bareAddress).filter((value):value is string=>Boolean(value));if(new Set(replyTargets).size>1)return null;
  return replyTargets[0]??bareAddress(input.from);
}

