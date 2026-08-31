export const EAE_METHOD_VERSION=1;

export type EaeResult={estimatedAdditionalEarningsMinor:number;upliftPercent:number|null;methodVersion:number;inputs:{initialOfferMinor:number;finalAmountMinor:number}};

export function calculateEstimatedAdditionalEarnings(initialOfferMinor:number,finalAmountMinor:number):EaeResult{
  if(!Number.isSafeInteger(initialOfferMinor)||!Number.isSafeInteger(finalAmountMinor)||initialOfferMinor<0||finalAmountMinor<0)throw new Error("EAE inputs must be non-negative safe integers");
  const uplift=Math.max(0,finalAmountMinor-initialOfferMinor);
  return {estimatedAdditionalEarningsMinor:uplift,upliftPercent:initialOfferMinor>0?Math.round((uplift/initialOfferMinor)*10000)/100:null,methodVersion:EAE_METHOD_VERSION,inputs:{initialOfferMinor,finalAmountMinor}};
}
