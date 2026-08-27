import Link from "next/link";
import { AppShell } from "@/components/replio/AppShell";

export default function Dashboard() {
  return <AppShell><header className="page-header"><div><p className="eyebrow">Your day</p><h1>Good morning</h1></div></header>
    <section className="content-block"><h2>Your priorities today</h2><p className="muted">Label a brand collaboration email “Replio” and your next action will appear here.</p><Link className="empty-action" href="/settings">Connect Gmail →</Link></section>
    <section className="content-block"><h2>Estimated Additional Earnings</h2><p className="muted">Your honest, reproducible estimate will appear after you complete negotiated deals.</p></section>
  </AppShell>;
}
