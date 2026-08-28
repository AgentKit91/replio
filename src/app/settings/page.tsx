import Link from "next/link";
import { AppShell } from "@/components/replio/AppShell";
import { requireUser } from "@/features/auth/require-user";

const notices: Record<string, string> = {
  connected: "Gmail is connected. Your Replio label is ready.",
  invalid_state: "That connection attempt expired. Please try again.",
  failed: "Gmail could not be connected. No mail was imported; please try again.",
  workspace_missing: "Your creator workspace is not ready yet.",
};

export default async function SettingsPage({ searchParams }: { searchParams: Promise<{ gmail?: string }> }) {
  const { supabase, userId } = await requireUser();
  const { data: connection } = await supabase.from("integration_connections").select("state, connected_identity, last_successful_sync_at, error_message").eq("user_id", userId).eq("provider", "gmail").maybeSingle();
  const { gmail } = await searchParams;
  const connected = connection?.state === "active";
  return <AppShell>
    <header className="page-header"><div><p className="eyebrow">Replio</p><h1>Settings</h1></div></header>
    {gmail && notices[gmail] ? <p className={gmail === "connected" ? "notice notice-success" : "notice notice-error"} role="status">{notices[gmail]}</p> : null}
    <section className="content-block settings-card" aria-labelledby="gmail-heading">
      <div><p className="eyebrow">Commercial inbox</p><h2 id="gmail-heading">Gmail</h2></div>
      {connected ? <>
        <p className="connection-status"><span aria-hidden="true">●</span> Connected as {connection.connected_identity}</p>
        <p className="muted">Apply the Gmail label <strong>Replio</strong> once to a brand collaboration thread. Only labelled conversations are imported; future replies in that thread stay with the same Deal.</p>
        <Link className="button button-secondary" href="https://mail.google.com" target="_blank" rel="noreferrer">Open Gmail</Link>
      </> : <>
        <p className="muted">Connect Gmail separately so you can choose commercial conversations with a Replio label. Replio does not scan your whole inbox.</p>
        <Link className="button button-primary" href="/api/integrations/gmail/connect">Connect Gmail</Link>
        <p className="privacy-note">Google will ask for permission to read, label, compose and send email. Replio processes only threads you label Replio.</p>
      </>}
    </section>
  </AppShell>;
}
