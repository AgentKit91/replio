"use server";

import {redirect} from "next/navigation";
import {createClient} from "@/lib/supabase/server";
import {publicEnv} from "@/lib/env";

export async function signInToDealCheck(){
  const supabase=await createClient();
  const next="/dealcheck/resume";
  const callback=new URL("/auth/callback",publicEnv.NEXT_PUBLIC_APP_URL);
  callback.searchParams.set("next",next);
  const {data,error}=await supabase.auth.signInWithOAuth({provider:"google",options:{redirectTo:callback.toString(),scopes:"openid email profile"}});
  if(error)redirect("/dealcheck/sign-in?error=signin");
  if(data.url)redirect(data.url);
}
