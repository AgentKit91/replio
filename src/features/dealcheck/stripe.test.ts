import {describe,expect,it} from "vitest";
import {validateDealCheckCheckoutSession,type DealCheckCheckoutSession} from "./stripe";

const session=(overrides:Partial<DealCheckCheckoutSession>={}):DealCheckCheckoutSession=>({id:"cs_test_once",payment_status:"paid",currency:"gbp",amount_total:499,metadata:{kind:"dealcheck_credit_pack",user_id:"user-1",pack_key:"pack_3",credit_quantity:"3"},...overrides});

describe("DealCheck Stripe boundary",()=>{
 it("accepts the exact three-credit pack",()=>expect(validateDealCheckCheckoutSession(session())).toEqual({userId:"user-1",packKey:"pack_3",credits:3}));
 it("accepts the exact ten-credit pack",()=>expect(validateDealCheckCheckoutSession(session({amount_total:999,metadata:{kind:"dealcheck_credit_pack",user_id:"user-1",pack_key:"pack_10",credit_quantity:"10"}}))).toEqual({userId:"user-1",packKey:"pack_10",credits:10}));
 it.each([{payment_status:"unpaid"},{amount_total:498},{currency:"usd"},{metadata:{kind:"dealcheck_credit_pack",user_id:"user-1",pack_key:"pack_3",credit_quantity:"10"}}])("rejects an untrusted mismatch: %o",override=>expect(validateDealCheckCheckoutSession(session(override))).toBeNull());
});
