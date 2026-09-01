import Link from "next/link";
import { AppShell } from "@/components/replio/AppShell";
import { requireUser } from "@/features/auth/require-user";
import {openBillingPortal,startCheckout} from "./billing-actions";
import {grantSupportAccess,revokeSupportAccess} from "./support-actions";

const notices: Record<string, string> = {
  connected: "Gmail is connected. Your Replio label is ready.",
  invalid_state: "That connection attempt expired. Please try again.",
  failed: "Gmail could not be connected. No mail was imported; please try again.",
  workspace_missing: "Your creator workspace is not ready yet.",
};

export default async function SettingsPage({ searchParams }: { searchParams: Promise<{ gmail?: string;billing?:string }> }) {
  const { supabase, userId } = await requireUser();
  const [{data:connection},{data:subscription},{data:plans},{data:usage},{data:supportGrants}]=await Promise.all([
    supabase.from("integration_connections").select("state, connected_identity, last_successful_sync_at, error_message").eq("user_id", userId).eq("provider", "gmail").maybeSingle(),
    supabase.from("subscriptions").select("plan_key,status,trial_ends_at,current_period_ends_at,cancel_at_period_end").maybeSingle(),
    supabase.from("plan_catalog").select("plan_key,display_name,monthly_price_minor,currency,trial_days").order("monthly_price_minor"),
    supabase.from("usage_counters").select("value,period_end").eq("metric","analysed_deals").order("period_start",{ascending:false}).limit(1).maybeSingle(),
    supabase.from("support_access_grants").select("id,reason,expires_at,revoked_at,created_at").order("created_at",{ascending:false}).limit(10)
  ]);
  const { gmail,billing } = await searchParams;
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
    <section className="content-block settings-card" aria-labelledby="billing-heading">
      <div><p className="eyebrow">Subscription</p><h2 id="billing-heading">Billing</h2></div>
      {billing==="processing"&&<p className="notice notice-success" role="status">Checkout finished. Access updates only after Stripe confirms the subscription.</p>}
      {billing==="canceled"&&<p className="notice" role="status">Checkout was canceled. Nothing was charged.</p>}
      {subscription?<><p><strong>{subscription.plan_key}</strong> · {subscription.status.replaceAll("_"," ")}</p>{subscription.status==="past_due"||subscription.status==="unpaid"?<p className="notice notice-error">Payment needs attention. Open Stripe billing to update the payment method.</p>:null}<p className="muted">{usage?`${usage.value} analysed Deals used in the current period.`:"No analysed Deals counted in this period."} {subscription.cancel_at_period_end?"Cancellation is scheduled at period end.":""}</p><form action={openBillingPortal}><button className="button button-secondary">Manage billing in Stripe</button></form></>:<><p className="muted">Start with a 30-day test-mode trial. Stripe—not this return page—confirms access.</p><div className="insight-grid">{plans?.map(plan=><article className="workspace-card" key={plan.plan_key}><h3>{plan.display_name}</h3><p>{new Intl.NumberFormat("en-GB",{style:"currency",currency:plan.currency}).format(plan.monthly_price_minor/100)} / month after {plan.trial_days} days</p><form action={startCheckout}><input type="hidden" name="planKey" value={plan.plan_key}/><button className="button button-primary">Start test trial</button></form></article>)}</div></>}
      <p className="privacy-note">Prices are provisional test configuration. Tax collection is not enabled until registrations and launch markets are approved.</p>
    </section>
    <section className="content-block settings-card" aria-labelledby="support-heading">
      <div><p className="eyebrow">Privacy & security</p><h2 id="support-heading">Support Mode</h2></div>
      <p className="muted">Replio support cannot read your private negotiations by default. A grant is time-limited and still requires the founder to start a separately confirmed, audited support session.</p>
      {supportGrants?.some(g=>!g.revoked_at&&new Date(g.expires_at)>new Date())?<div className="support-grant-list">{supportGrants.filter(g=>!g.revoked_at&&new Date(g.expires_at)>new Date()).map(g=><article key={g.id}><div><strong>Workspace support granted</strong><p>{g.reason}</p><small>Expires {new Date(g.expires_at).toLocaleString("en-GB")}</small></div><form action={revokeSupportAccess}><input type="hidden" name="grantId" value={g.id}/><button className="button button-secondary">Revoke now</button></form></article>)}</div>:<form action={grantSupportAccess} className="support-grant-form"><label>Why do you need help?<textarea required minLength={3} maxLength={500} name="reason" placeholder="For example: help diagnose a Deal that is not updating"/></label><label>Access duration<select name="durationHours" defaultValue="24"><option value="24">24 hours</option><option value="72">3 days</option><option value="168">7 days</option></select></label><label className="check-row"><input required type="checkbox" name="confirmation" value="confirmed"/> I understand this permits scoped support access until I revoke it or it expires.</label><button className="button button-primary">Grant Support Mode</button></form>}
      <p className="privacy-note">You can revoke access immediately. Granting access does not automatically open or transmit any message.</p>
    </section>
  </AppShell>;
}

