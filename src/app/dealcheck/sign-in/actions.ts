"use server";

import {redirect} from "next/navigation";
import {createClient} from "@/lib/supabase/server";
import {trustedRequestOrigin} from "@/lib/request-origin";

export async function signInToDealCheck(){
  const supabase=await createClient();
  const next="/dealcheck/resume";
  const callback=new URL("/auth/callback",await trustedRequestOrigin());
  callback.searchParams.set("next",next);
  const {data,error}=await supabase.auth.signInWithOAuth({provider:"google",options:{redirectTo:callback.toString(),scopes:"openid email profile"}});
  if(error)redirect("/dealcheck/sign-in?error=signin");
  if(data.url)redirect(data.url);
}
