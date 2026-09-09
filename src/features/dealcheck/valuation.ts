import type {DealCheckInput,ExtractedDeal,WrittenResult} from "./contracts";

export const DEALCHECK_INTELLIGENCE_VERSION="uk_shortform_v1_2026_09_08";
type Range={low:number;high:number};
const bands=[
  {min:1000,max:9999,tiktok:{low:100,high:300},instagram:{low:120,high:350}},
  {min:10000,max:24999,tiktok:{low:200,high:450},instagram:{low:250,high:500}},
  {min:25000,max:49999,tiktok:{low:350,high:650},instagram:{low:400,high:750}},
  {min:50000,max:99999,tiktok:{low:500,high:900},instagram:{low:600,high:1000}},
  {min:100000,max:249999,tiktok:{low:800,high:1500},instagram:{low:900,high:1700}},
  {min:250000,max:499999,tiktok:{low:1300,high:2500},instagram:{low:1500,high:3000}},
  {min:500000,max:999999,tiktok:{low:2000,high:4000},instagram:{low:2500,high:5000}},
] as const;
const clamp=(n:number,min:number,max:number)=>Math.min(max,Math.max(min,n));
const low25=(n:number)=>Math.floor(n/25)*25, high25=(n:number)=>Math.ceil(n/25)*25, high50=(n:number)=>Math.ceil(n/50)*50;

export interface Valuation {
  version:string; baseline:Range; viewMultiplier:number|null; engagementMultiplier:number|null; performanceMultiplier:number;
  primaryMultiplier:number; storyFramesPriced:number; contentSubtotal:Range;
  modifiers:{paidOrAmplificationRate:number;usageMonthsPriced:number;exclusivityRate:number;exclusivityMonthsPriced:number;rawFootageRate:number;rushRate:number;revisionsRate:number};
  rawRange:Range; fairRange:Range; recommendedCounter:number; recommendedCounterText:string; offerRatio:number; score:number; label:"Low offer"|"Needs negotiation"|"Reasonable"|"Strong offer"; caveats:string[]; flags:string[];
}

function performance(input:DealCheckInput){
  const view=input.averageViews===null?null:(input.averageViews/input.followers<.15?.85:input.averageViews/input.followers<.35?1:input.averageViews/input.followers<.75?1.1:input.averageViews/input.followers<1.25?1.2:1.3);
  const engagement=input.engagementRate===null?null:(input.engagementRate<1?.9:input.engagementRate<3?1:input.engagementRate<6?1.08:1.15);
  return {view,engagement,combined:clamp(view!==null&&engagement!==null?(view+engagement)/2:view??engagement??1,.85,1.25)};
}
export function calculateValuation(input:DealCheckInput,deal:ExtractedDeal):Valuation{
  const band=bands.find(item=>input.followers>=item.min&&input.followers<=item.max); if(!band)throw new Error("UNSUPPORTED_FOLLOWERS");
  const baseline:Range={...band[input.platform]}; const perf=performance(input); const primaryMultiplier=1+.85*(deal.primaryDeliverableCount-1);
  if(deal.primaryDeliverableCount<1||deal.primaryDeliverableCount>3)throw new Error("UNSUPPORTED_DELIVERABLE_COUNT");
  const single={low:baseline.low*perf.combined,high:baseline.high*perf.combined}; const frames=input.platform==="instagram"?Math.min(deal.storyFrames,6):0;
  const contentSubtotal={low:single.low*primaryMultiplier+single.low*.08*frames,high:single.high*primaryMultiplier+single.high*.08*frames};
  const usageMonths=deal.paidUsage||deal.whitelisting||deal.perpetualRights?Math.min(deal.usageMonths??(deal.perpetualRights?6:1),6):0;
  const paidRate=deal.whitelisting?.25:deal.paidUsage||deal.perpetualRights?.15:0; const exclusivityMonths=deal.exclusivity?Math.min(deal.exclusivityMonths??1,6):0;
  const revisionsRate=deal.unlimitedRevisions?0:Math.min(Math.max((deal.revisionRounds??1)-1,0)*.1,.3);
  const modifiers={paidOrAmplificationRate:paidRate,usageMonthsPriced:usageMonths,exclusivityRate:deal.exclusivity?.1:0,exclusivityMonthsPriced:exclusivityMonths,rawFootageRate:deal.rawFootage?.15:0,rushRate:deal.turnaroundHours!==null&&deal.turnaroundHours<=72?.2:0,revisionsRate};
  const totalRate=paidRate*usageMonths+modifiers.exclusivityRate*exclusivityMonths+modifiers.rawFootageRate+modifiers.rushRate+revisionsRate;
  const rawRange={low:contentSubtotal.low*(1+totalRate),high:contentSubtotal.high*(1+totalRate)}; const fairRange={low:Math.max(0,low25(rawRange.low)),high:Math.max(0,high25(rawRange.high))};
  const midpoint=(fairRange.low+fairRange.high)/2; const offer=deal.monetaryOfferGbp??0; const offerRatio=midpoint?offer/midpoint:0;
  let score=offerRatio<.4?20:offerRatio<.6?35:offerRatio<.8?55:offerRatio<1?70:offerRatio<1.2?85:95;
  const flags=[...deal.unclearTerms]; const caveats:string[]=[];
  if(input.averageViews===null)caveats.push("Average views were not provided, so the estimate uses follower bands without a performance adjustment.");
  if(input.followers>=500000)caveats.push("Public benchmark bands are wider at this creator size, so this estimate is more directional.");
  if(deal.storyFrames>6)caveats.push("Story value is capped at six frames in V1.");
  if(deal.perpetualRights){score-=10;flags.push("Perpetual or unlimited commercial rights are requested; this range is only a six-month floor, not a buyout valuation.");}
  if((deal.paidUsage||deal.whitelisting)&&deal.usageMonths===null){score-=5;flags.push("Paid usage duration is missing; one month is priced provisionally.");}
  if(deal.exclusivity&&deal.exclusivityMonths===null){score-=5;flags.push("Exclusivity duration is missing; one month is priced provisionally.");}
  if(deal.unlimitedRevisions){score-=5;flags.push("Unlimited revisions should be replaced with a clear revision limit.");}
  if(deal.conflictingPlatform)flags.push("The offer mentions a different platform; this check uses your selected platform.");
  score=clamp(score,0,100); const label=score<40?"Low offer":score<60?"Needs negotiation":score<80?"Reasonable":"Strong offer"; const recommendedCounter=high50(fairRange.high*1.05);
  return {version:DEALCHECK_INTELLIGENCE_VERSION,baseline,viewMultiplier:perf.view,engagementMultiplier:perf.engagement,performanceMultiplier:perf.combined,primaryMultiplier,storyFramesPriced:frames,contentSubtotal,modifiers,rawRange,fairRange,recommendedCounter,recommendedCounterText:deal.perpetualRights?`£${recommendedCounter.toLocaleString("en-GB")} with paid usage limited to 3 months`:`£${recommendedCounter.toLocaleString("en-GB")}`,offerRatio,score,label,caveats,flags:[...new Set(flags)].slice(0,5)};
}

export function fallbackWriting(input:DealCheckInput,deal:ExtractedDeal,v:Valuation):WrittenResult{
  const scope=`${deal.primaryDeliverableCount} ${input.platform==="tiktok"?"TikTok video":"Instagram Reel"}${deal.primaryDeliverableCount===1?"":"s"}`;
  const rights=deal.whitelisting?"creator-handle paid amplification":deal.paidUsage||deal.perpetualRights?"paid usage":deal.exclusivity?"category exclusivity":"organic posting only";
  const clarification=[deal.usageMonths===null&&(deal.paidUsage||deal.whitelisting)?"paid usage duration":null,deal.exclusivity&&deal.exclusivityMonths===null?"exclusivity duration":null,deal.unlimitedRevisions?"a fixed revision limit":null].filter(Boolean).join(", ");
  return {feeExplanation:`The £${deal.monetaryOfferGbp?.toLocaleString("en-GB")} offer is compared with a directional £${v.fairRange.low.toLocaleString("en-GB")}–£${v.fairRange.high.toLocaleString("en-GB")} range for ${scope}, including the stated scope.`,rightsExplanation:`The calculation treats the rights as ${rights}. ${deal.perpetualRights?"The range is a limited-term floor and does not price a perpetual buyout.":"Only terms stated in the offer are priced."}`,watchOuts:v.flags,recommendation:`Counter at ${v.recommendedCounterText}${clarification?` and ask the brand to confirm ${clarification}`:""}. If budget is fixed, reduce the rights or deliverable scope.`,suggestedReply:`Thanks for sharing the offer — I’m interested in the campaign. For ${scope} and the rights outlined, my fee would be ${v.recommendedCounterText}.${clarification?` Could you also confirm ${clarification}?`:""} If the budget is fixed, I’d be happy to discuss reducing the usage rights or scope to find a workable option. Best,`};
}
