import Link from "next/link";
import { loadFounderDashboard } from "@/features/founder/dashboard";
import { setWorkerControl } from "./actions";

export default async function FounderPage() {
  const dashboard = await loadFounderDashboard();
  return <main className="founder-shell">
    <header className="founder-header"><div><p className="eyebrow">Founder OS</p><h1>Today</h1><p className="muted">Operational control without casual access to creator negotiations.</p></div><Link className="button button-secondary" href="/dashboard">Creator app</Link></header>
    <section className="founder-metrics" aria-label="Business and system summary">
      <article><span>Paying</span><strong>{dashboard.activeSubscriptions}</strong><small>{dashboard.trials} trials · {dashboard.pastDueSubscriptions} payment issues</small></article>
      <article><span>Gmail healthy</span><strong>{dashboard.connectedGmail}</strong><small>{dashboard.unhealthyGmail} need attention</small></article>
      <article><span>AI queue</span><strong>{dashboard.queuedAi}</strong><small>{dashboard.failedAi} failed</small></article>
      <article><span>Send queue</span><strong>{dashboard.queuedSends}</strong><small>{dashboard.failedSends} failed</small></article>
      <article><span>AI cost · 30d</span><strong>{dashboard.aiCostUsd == null ? "Partial" : `$${dashboard.aiCostUsd.toFixed(2)}`}</strong><small>{dashboard.aiCostUsd == null ? "Some provider cost data is unavailable" : "Recorded model cost only"}</small></article>
      <article><span>Support grants</span><strong>{dashboard.openSupportGrants}</strong><small>Active, explicit and expiring</small></article>
    </section>
    <section className="founder-action-centre"><div className="section-heading"><div><p className="eyebrow">Action Centre</p><h2>What needs attention</h2></div><span className="status-pill">{dashboard.actionItems.length} open</span></div>
      {dashboard.actionItems.length ? <ol>{dashboard.actionItems.map((item) => <li key={item.id} className={`founder-action founder-action-${item.severity}`}><div><strong>{item.title}</strong><p>{item.context}</p></div><p><span>Safest next step</span>{item.nextStep}</p></li>)}</ol> : <div className="founder-empty"><strong>No critical action right now.</strong><p className="muted">Queues, Gmail watches, billing state and recorded incidents are clear.</p></div>}
    </section>
    <section className="founder-controls"><div className="section-heading"><div><p className="eyebrow">Company controls</p><h2>Worker kill switches</h2></div><span className="status-pill">Versioned · audited</span></div>
      <p className="muted">Pausing is immediate and leaves queued work untouched. Resuming may restart private-data processing or outbound delivery, so it requires explicit confirmation.</p>
      <div className="founder-control-list">{dashboard.workerControls.map((control) => { const enabling=!control.enabled; return <article key={control.key}><div><strong>{control.key==="ai_worker_enabled"?"AI analysis worker":"Outbound Gmail worker"}</strong><p>{control.description}</p><small>Version {control.version} · updated {new Date(control.updatedAt).toLocaleString("en-GB")}</small></div><div><span className={`status-pill ${control.enabled?"status-pill-success":""}`}>{control.enabled?"Running":"Paused"}</span><form action={setWorkerControl}><input type="hidden" name="key" value={control.key}/><input type="hidden" name="enabled" value={String(enabling)}/><input type="hidden" name="expectedVersion" value={control.version}/><input type="hidden" name="idempotencyKey" value={crypto.randomUUID()}/>{enabling&&<label><input required type="checkbox" name="confirmation" value="confirmed"/> I understand this resumes processing</label>}<button className={`button ${enabling?"button-primary":"button-secondary"}`} type="submit">{enabling?"Resume worker":"Pause worker"}</button></form></div></article>})}</div>
    </section>
    <section className="founder-customers"><div className="section-heading"><div><p className="eyebrow">Customers</p><h2>Operational directory</h2></div><span className="status-pill">{dashboard.customers.length} total</span></div>
      <div className="founder-customer-list">{dashboard.customers.map((customer) => <article key={customer.userId}><div><strong>{customer.name || customer.email}</strong><p>{customer.email}</p><small>Joined {new Date(customer.signedUpAt).toLocaleDateString("en-GB")}{customer.lastActivityAt ? ` · Active ${new Date(customer.lastActivityAt).toLocaleDateString("en-GB")}` : ""}</small></div><dl><div><dt>Plan</dt><dd>{customer.plan ?? "None"} {customer.subscriptionStatus ? `· ${customer.subscriptionStatus}` : ""}</dd></div><div><dt>Gmail</dt><dd>{customer.gmailStatus ?? "Not connected"}</dd></div><div><dt>Usage</dt><dd>{customer.analysedDeals} analysed</dd></div><div><dt>Ops</dt><dd>{customer.failedJobs} failed jobs</dd></div></dl><span className="muted">{customer.supportGrantActive ? "Support access granted" : "Private content shielded"}</span></article>)}</div>
    </section>
    <section className="content-block"><h2>Privacy boundary</h2><p className="muted">Customer operational metadata is visible here. Message bodies, drafts, private notes and negotiation analysis remain hidden unless the creator grants scoped, time-limited Support Mode access. Every support session and consequential action is audited.</p></section>
  </main>;
}

