"use server";
import {randomBytes} from "node:crypto";
import {redirect} from "next/navigation";
import {z} from "zod";
import {requireUser} from "@/features/auth/require-user";
import {publicEnv} from "@/lib/env";
import {getStripe} from "@/lib/stripe/server";

const planSchema=z.enum(["standard","pro"]);
function identifier(){const letters="abcdefghijklmnopqrstuvwxyz";return `replio_${[...randomBytes(8)].map(value=>letters[value%letters.length]).join("")}`;}

export async function startCheckout(formData:FormData){
 const planKey=planSchema.parse(formData.get("planKey"));const {supabase,userId}=await requireUser();
 const [{data:member},{data:plan}]=await Promise.all([supabase.from("workspace_members").select("workspace_id").single(),supabase.from("plan_catalog").select("stripe_price_id,trial_days").eq("plan_key",planKey).single()]);
 if(!member||!plan?.stripe_price_id)throw new Error("Stripe test catalogue is not configured");
 const session=await getStripe().checkout.sessions.create({mode:"subscription",managed_payments:{enabled:false},line_items:[{price:plan.stripe_price_id,quantity:1}],success_url:`${publicEnv.NEXT_PUBLIC_APP_URL}/settings?billing=processing`,cancel_url:`${publicEnv.NEXT_PUBLIC_APP_URL}/settings?billing=canceled`,client_reference_id:member.workspace_id,metadata:{workspace_id:member.workspace_id,plan_key:planKey,user_id:userId},subscription_data:{trial_period_days:plan.trial_days,metadata:{workspace_id:member.workspace_id,plan_key:planKey}},integration_identifier:identifier()});
 if(!session.url)throw new Error("Stripe Checkout did not return a URL");redirect(session.url);
}

export async function openBillingPortal(){
 const {supabase}=await requireUser();const {data}=await supabase.from("subscriptions").select("stripe_customer_id").single();if(!data?.stripe_customer_id)throw new Error("No Stripe customer is linked");
 const session=await getStripe().billingPortal.sessions.create({customer:data.stripe_customer_id,return_url:`${publicEnv.NEXT_PUBLIC_APP_URL}/settings`});redirect(session.url);
}
