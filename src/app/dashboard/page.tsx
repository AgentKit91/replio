import Link from "next/link";
import { redirect } from "next/navigation";
import { AppShell } from "@/components/replio/AppShell";
import { requireUser } from "@/features/auth/require-user";

export default async function Dashboard() {
  const { supabase, userId } = await requireUser();
  const { data: profile } = await supabase.from("user_profiles").select("display_name,onboarding_completed_at").eq("user_id", userId).single();
  if (!profile?.onboarding_completed_at) {
    redirect("/onboarding");
  }
  const firstName = profile.display_name.trim().split(/\s+/)[0] || "there";
  return <AppShell><header className="page-header"><div><p className="eyebrow">Your day</p><h1>Good morning, {firstName}</h1></div></header>
    <section className="content-block"><h2>Your priorities today</h2><p className="muted">Label a brand collaboration email “Replio” and your next action will appear here.</p><Link className="empty-action" href="/settings">Connect Gmail →</Link></section>
    <section className="content-block"><h2>Estimated Additional Earnings</h2><p className="muted">Your honest, reproducible estimate will appear after you complete negotiated deals.</p></section>
  </AppShell>;
}
