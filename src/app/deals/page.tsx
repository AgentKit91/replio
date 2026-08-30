import Link from "next/link";
import { AppShell } from "@/components/replio/AppShell";
import { requireUser } from "@/features/auth/require-user";
import { dealState } from "@/features/deals/state";

export default async function DealsPage({ searchParams }: { searchParams: Promise<{ q?: string; status?: string }> }) {
  const { supabase } = await requireUser();
  const { q = "", status = "all" } = await searchParams;
  let query = supabase.from("deals").select("id,title,status,updated_at,current_offer_minor,currency,brand_id").is("deleted_at", null).order("updated_at", { ascending: false });
  if (q.trim()) query = query.ilike("title", `%${q.trim().replaceAll("%", "\\%").replaceAll("_", "\\_")}%`);
  if (status !== "all") query = query.eq("status", status);
  const { data: deals, error } = await query;
  if (error) throw new Error("Unable to load deals.");
  return <AppShell>
    <header className="page-header"><div><p className="eyebrow">Your pipeline</p><h1>Deals</h1></div><Link className="button button-secondary" href="/deals/recycle-bin">Recycle bin</Link></header>
    <form className="deal-filters"><input name="q" defaultValue={q} placeholder="Search deals" aria-label="Search deals"/><select name="status" defaultValue={status} aria-label="Filter by status"><option value="all">All active deals</option><option value="awaiting_creator">Your reply needed</option><option value="awaiting_brand">Waiting on brand</option><option value="negotiating">Negotiating</option><option value="agreed">Agreed</option><option value="completed">Complete</option></select><button className="button button-primary">Apply</button></form>
    {deals?.length ? <div className="deal-list">{deals.map((deal) => { const state = dealState(deal.status); return <Link href={`/deals/${deal.id}`} className="deal-row" key={deal.id}><div><h2>{deal.title}</h2><p className="muted">Updated {new Intl.DateTimeFormat("en-GB", { dateStyle: "medium" }).format(new Date(deal.updated_at))}</p></div><div className="deal-row-meta"><span className={`status-pill status-${deal.status}`}>{state.label}</span>{deal.current_offer_minor !== null && <strong>{new Intl.NumberFormat("en-GB", { style: "currency", currency: deal.currency }).format(deal.current_offer_minor / 100)}</strong>}</div></Link>; })}</div> : <section className="content-block"><h2>No matching deals</h2><p className="muted">Label a Gmail conversation “Replio”, or clear the filters to see imported deals.</p></section>}
  </AppShell>;
}
