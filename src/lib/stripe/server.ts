import "server-only";
import Stripe from "stripe";
import {requireStripeServerEnv} from "@/lib/env.server";

let stripeClient:Stripe|undefined;

export function getStripe(){
  const env=requireStripeServerEnv();
  stripeClient??=new Stripe(env.STRIPE_SECRET_KEY,{apiVersion:"2026-08-26.dahlia",appInfo:{name:"Replio",version:"0.1.0"}});
  return stripeClient;
}

