import Link from "next/link";
import { AppShell } from "@/components/replio/AppShell";
import { requireUser } from "@/features/auth/require-user";
import { recycleDeal } from "../actions";

export default async function RecycleBinPage() {
  const { supabase } = await requireUser();
  const { data: deals, error } = await supabase.from("deals").select("id,title,purge_after").not("deleted_at", "is", null).order("deleted_at", { ascending: false });
  if (error) throw new Error("Unable to load the recycle bin.");
  return <AppShell><header className="page-header"><div><p className="eyebrow">30-day safety net</p><h1>Recycle bin</h1></div><Link className="button button-secondary" href="/deals">Back to deals</Link></header>
    {deals?.length ? <div className="deal-list">{deals.map((deal) => <div className="deal-row" key={deal.id}><div><h2>{deal.title}</h2><p className="muted">Scheduled for permanent deletion {deal.purge_after ? new Intl.DateTimeFormat("en-GB", { dateStyle: "long" }).format(new Date(deal.purge_after)) : "after 30 days"}</p></div><form action={recycleDeal}><input type="hidden" name="dealId" value={deal.id}/><input type="hidden" name="recycled" value="false"/><button className="button button-secondary">Restore</button></form></div>)}</div> : <section className="content-block"><h2>Recycle bin is empty</h2><p className="muted">Deleted deals remain restorable here for 30 days.</p></section>}
  </AppShell>;
}
