import {DEALCHECK_PACKS,dealCheckPackKeySchema,type DealCheckPackKey} from "./catalog";

export type DealCheckCheckoutSession={
 id:string;
 payment_status:string;
 currency:string|null;
 amount_total:number|null;
 metadata:Record<string,string>|null;
};

export function validateDealCheckCheckoutSession(session:DealCheckCheckoutSession):{userId:string;packKey:DealCheckPackKey;credits:number}|null{
 if(session.metadata?.kind!=="dealcheck_credit_pack")return null;
 const parsed=dealCheckPackKeySchema.safeParse(session.metadata.pack_key);
 if(!parsed.success)return null;
 const pack=DEALCHECK_PACKS[parsed.data];
 if(!session.metadata.user_id||session.payment_status!=="paid"||session.currency!=="gbp"||session.amount_total!==pack.amountMinor||session.metadata.credit_quantity!==String(pack.credits))return null;
 return {userId:session.metadata.user_id,packKey:parsed.data,credits:pack.credits};
}
