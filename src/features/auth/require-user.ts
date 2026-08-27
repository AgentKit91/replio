import { redirect } from "next/navigation";
import { hasSupabaseConfig } from "@/lib/env";
import { createClient } from "@/lib/supabase/server";

export async function requireUser() {
  if (!hasSupabaseConfig()) redirect("/login");
  const supabase = await createClient();
  const { data, error } = await supabase.auth.getClaims();
  const subject = data?.claims?.sub;
  if (error || typeof subject !== "string") redirect("/login");
  return { supabase, userId: subject };
}
