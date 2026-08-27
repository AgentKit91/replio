import { NextResponse, type NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: NextRequest) {
  const code = request.nextUrl.searchParams.get("code");
  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      const { data: auth } = await supabase.auth.getUser();
      const { data: profile } = auth.user
        ? await supabase.from("user_profiles").select("onboarding_completed_at").eq("user_id", auth.user.id).single()
        : { data: null };
      return NextResponse.redirect(new URL(profile?.onboarding_completed_at ? "/dashboard" : "/onboarding", request.url));
    }
  }
  return NextResponse.redirect(new URL("/login?error=callback", request.url));
}
