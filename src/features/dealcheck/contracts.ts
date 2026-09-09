import {z} from "zod";

export const dealCheckInputSchema=z.object({
  clientRequestId:z.uuid(),
  rawOffer:z.string().trim().min(1,"Paste the offer for DealCheck to assess it.").max(12000),
  platform:z.enum(["tiktok","instagram"]),
  followers:z.coerce.number().int().min(1000).max(999999),
  averageViews:z.preprocess(value=>value===""||value===undefined?null:value,z.coerce.number().int().nonnegative().nullable()),
  engagementRate:z.preprocess(value=>value===""||value===undefined?null:value,z.coerce.number().min(0).max(100).nullable()),
});
export type DealCheckInput=z.infer<typeof dealCheckInputSchema>;

export const extractedDealSchema=z.object({
  brandName:z.string().trim().max(120).nullable(), monetaryOfferGbp:z.number().nonnegative().nullable(), currency:z.string().trim().max(8).nullable(),
  primaryDeliverableCount:z.number().int().min(0).max(20), primaryDeliverableType:z.enum(["tiktok_video","instagram_reel","other","unclear"]),
  storyFrames:z.number().int().min(0).max(100), organicUsage:z.boolean(), paidUsage:z.boolean(), whitelisting:z.boolean(),
  usageMonths:z.number().int().positive().max(120).nullable(), exclusivity:z.boolean(), exclusivityMonths:z.number().int().positive().max(120).nullable(),
  rawFootage:z.boolean(), revisionRounds:z.number().int().min(0).max(50).nullable(), unlimitedRevisions:z.boolean(), turnaroundHours:z.number().int().positive().max(8760).nullable(),
  perpetualRights:z.boolean(), conflictingPlatform:z.boolean(), unsupportedReasons:z.array(z.string().trim().max(160)).max(8), unclearTerms:z.array(z.string().trim().max(160)).max(8),
});
export type ExtractedDeal=z.infer<typeof extractedDealSchema>;

export const writtenResultSchema=z.object({
  feeExplanation:z.string().trim().min(1).max(900), rightsExplanation:z.string().trim().min(1).max(900),
  watchOuts:z.array(z.string().trim().min(1).max(220)).max(5), recommendation:z.string().trim().min(1).max(700), suggestedReply:z.string().trim().min(1).max(1800),
});
export type WrittenResult=z.infer<typeof writtenResultSchema>;

export const emptyExtractedDeal:ExtractedDeal={brandName:null,monetaryOfferGbp:null,currency:null,primaryDeliverableCount:0,primaryDeliverableType:"unclear",storyFrames:0,organicUsage:false,paidUsage:false,whitelisting:false,usageMonths:null,exclusivity:false,exclusivityMonths:null,rawFootage:false,revisionRounds:null,unlimitedRevisions:false,turnaroundHours:null,perpetualRights:false,conflictingPlatform:false,unsupportedReasons:[],unclearTerms:[]};
