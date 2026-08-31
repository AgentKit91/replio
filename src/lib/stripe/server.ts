import "server-only";
import Stripe from "stripe";
import {serverEnv} from "@/lib/env.server";

let stripeClient:Stripe|undefined;

export function getStripe(){
  if(!serverEnv.STRIPE_SECRET_KEY)throw new Error("Stripe test mode is not configured");
  stripeClient??=new Stripe(serverEnv.STRIPE_SECRET_KEY,{apiVersion:"2026-08-26.dahlia",appInfo:{name:"Replio",version:"0.1.0"}});
  return stripeClient;
}
