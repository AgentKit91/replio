import { notFound } from "next/navigation";
import { AppShell } from "@/components/replio/AppShell";
import { requireUser } from "@/features/auth/require-user";

const sections: Record<string, { title: string; description: string; action: string }> = {
  deals: { title: "Deals", description: "Your labelled brand conversations will become living deals here.", action: "Connect Gmail in Settings to import your first chosen thread." },
  brands: { title: "Brands", description: "Private relationship history and reusable contacts will appear as you negotiate.", action: "Your first brand is created from a labelled deal." },
  insights: { title: "Insights", description: "See honest earnings uplift and personal negotiation trends after completed deals.", action: "Complete a deal to begin building your private insights." },
  "train-replio": { title: "Train Replio", description: "Add goals, rates and non-negotiables when they can improve your advice.", action: "Start with the short creator baseline in onboarding." },
  settings: { title: "Settings", description: "Gmail, billing, notifications and account security live here.", action: "Connect a dedicated Supabase project to enable Google sign-in." },
};

export default async function SectionPage({ params }: { params: Promise<{ section: string }> }) {
  await requireUser();
  const { section } = await params;
  const content = sections[section];
  if (!content) notFound();
  return <AppShell><header className="page-header"><div><p className="eyebrow">Replio</p><h1>{content.title}</h1></div></header><section className="content-block"><h2>Nothing to show yet</h2><p className="muted">{content.description}</p><p className="empty-action">{content.action}</p></section></AppShell>;
}
