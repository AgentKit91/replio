"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { publicEnv } from "@/lib/env";

export async function signInWithGoogle() {
  const supabase = await createClient();
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: { redirectTo: `${publicEnv.NEXT_PUBLIC_APP_URL}/auth/callback`, scopes: "openid email profile" },
  });
  if (error) redirect("/login?error=signin");
  if (data.url) redirect(data.url);
}
