"use server";

import { redirect } from "next/navigation";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";

const onboardingSchema = z.object({
  creatorName: z.string().trim().min(1).max(100),
  countryCode: z.string().trim().length(2).transform((value) => value.toUpperCase()),
  baseCurrency: z.string().trim().length(3).transform((value) => value.toUpperCase()),
  niche: z.string().trim().min(1).max(100),
  platforms: z.array(z.enum(["instagram", "tiktok", "youtube", "other"])).min(1),
  gmailConsent: z.literal("on"),
});

export async function completeOnboarding(formData: FormData) {
  const parsed = onboardingSchema.safeParse({
    creatorName: formData.get("creatorName"), countryCode: formData.get("countryCode"),
    baseCurrency: formData.get("baseCurrency"), niche: formData.get("niche"),
    platforms: formData.getAll("platforms"), gmailConsent: formData.get("gmailConsent"),
  });
  if (!parsed.success) redirect("/onboarding?error=invalid");
  const supabase = await createClient();
  const { data: auth, error: authError } = await supabase.auth.getUser();
  if (authError || !auth.user) redirect("/login");
  const { data: membership } = await supabase.from("workspace_members").select("workspace_id").single();
  if (!membership) redirect("/onboarding?error=workspace");
  const values = parsed.data;
  const { data: profile, error: profileError } = await supabase.from("creator_profiles").update({
    creator_name: values.creatorName, country_code: values.countryCode,
    base_currency: values.baseCurrency, niche: values.niche,
  }).eq("workspace_id", membership.workspace_id).select("id").single();
  if (profileError || !profile) redirect("/onboarding?error=save");
  await supabase.from("user_profiles").update({
    display_name: values.creatorName, country_code: values.countryCode,
    base_currency: values.baseCurrency, onboarding_completed_at: new Date().toISOString(),
  }).eq("user_id", auth.user.id);
  const { error: platformError } = await supabase.from("creator_platforms").upsert(
    values.platforms.map((platform) => ({ workspace_id: membership.workspace_id, creator_profile_id: profile.id, platform, handle: "To add" })),
    { onConflict: "creator_profile_id,platform,handle" },
  );
  if (platformError) redirect("/onboarding?error=platforms");
  redirect("/dashboard");
}
