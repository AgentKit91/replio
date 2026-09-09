import Stripe from "stripe";
import {NextResponse} from "next/server";
import {serverEnv} from "@/lib/env.server";
import {createAdminClient} from "@/lib/supabase/admin";
import {getStripe} from "@/lib/stripe/server";
import {validateDealCheckCheckoutSession} from "@/features/dealcheck/stripe";

function timestamp(value:number|null|undefined){return value?new Date(value*1000).toISOString():null;}
export async function POST(request:Request){
 const signature=request.headers.get("stripe-signature");if(!signature||!serverEnv.STRIPE_WEBHOOK_SECRET)return NextResponse.json({error:"Webhook unavailable"},{status:400});
 let event:Stripe.Event;try{event=getStripe().webhooks.constructEvent(await request.text(),signature,serverEnv.STRIPE_WEBHOOK_SECRET);}catch{return NextResponse.json({error:"Invalid signature"},{status:400});}
 const admin=createAdminClient();
 if(event.type==="checkout.session.completed"){
  const session=event.data.object as Stripe.Checkout.Session;
  if(session.metadata?.kind==="dealcheck_credit_pack"){
   const purchase=validateDealCheckCheckoutSession(session);
   if(!purchase)return NextResponse.json({error:"DealCheck purchase metadata invalid"},{status:422});
   const {error}=await admin.rpc("grant_dealcheck_stripe_pack",{p_user_id:purchase.userId,p_session_id:session.id,p_credits:purchase.credits,p_pack_key:purchase.packKey});if(error)return NextResponse.json({error:"Credit grant failed"},{status:500});
  }
  const {error}=await admin.rpc("record_stripe_event",{p_event_id:event.id,p_event_type:event.type,p_event_created_at:timestamp(event.created)});if(error)return NextResponse.json({error:"Event record failed"},{status:500});
 }else if(event.type.startsWith("customer.subscription.")){
  const subscription=event.data.object as Stripe.Subscription;const workspaceId=subscription.metadata.workspace_id;const planKey=subscription.metadata.plan_key;const item=subscription.items.data[0];
  if(!workspaceId||!planKey||!item)return NextResponse.json({error:"Subscription metadata missing"},{status:422});
  const customerId=typeof subscription.customer==="string"?subscription.customer:subscription.customer.id;
  const {error}=await admin.rpc("project_stripe_subscription",{p_event_id:event.id,p_event_type:event.type,p_event_created_at:timestamp(event.created),p_workspace_id:workspaceId,p_plan_key:planKey,p_customer_id:customerId,p_subscription_id:subscription.id,p_status:subscription.status,p_trial_end:timestamp(subscription.trial_end),p_period_start:timestamp(item.current_period_start),p_period_end:timestamp(item.current_period_end),p_cancel_at_period_end:subscription.cancel_at_period_end});
  if(error)return NextResponse.json({error:"Projection failed"},{status:500});
 }else{
  const {error}=await admin.rpc("record_stripe_event",{p_event_id:event.id,p_event_type:event.type,p_event_created_at:timestamp(event.created)});if(error)return NextResponse.json({error:"Event record failed"},{status:500});
 }
 return NextResponse.json({received:true});
}
