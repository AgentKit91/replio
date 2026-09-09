import {redirect} from "next/navigation";import {hasSupabaseConfig} from "@/lib/env";import {createClient} from "@/lib/supabase/server";import {ResumeDealCheck} from "./resume";
export const dynamic="force-dynamic";
export default async function ResumePage(){if(!hasSupabaseConfig())redirect("/dealcheck/sign-in");const supabase=await createClient();const {data}=await supabase.auth.getClaims();if(typeof data?.claims?.sub!=="string")redirect("/dealcheck/sign-in");return <ResumeDealCheck/>;}
