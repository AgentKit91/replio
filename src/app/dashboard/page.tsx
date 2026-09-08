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
  const [{data:deals},{data:invoices},{data:deadlines},{data:financials}]=await Promise.all([
    supabase.from("deals").select("id,title,status,operational_stage,final_agreed_minor,currency").is("deleted_at",null).order("updated_at",{ascending:false}),
    supabase.from("invoices").select("id,deal_id,status,invoice_number,currency,total_minor,due_date").not("status","in","(void,written_off)"),
    supabase.from("deal_deadlines").select("id,deal_id,label,due_at,status").eq("status","open").order("due_at").limit(20),
    supabase.from("deal_financial_overview").select("currency,ready_to_invoice_minor,prepared_minor,outstanding_minor,overdue_minor,received_minor")
  ]);
  const invoiceByDeal=new Map((invoices??[]).map(invoice=>[invoice.deal_id,invoice]));
  const actions=[...(deals??[]).flatMap(deal=>{
    const invoice=invoiceByDeal.get(deal.id);if(deal.status==="awaiting_creator")return [{key:`reply-${deal.id}`,title:`Reply to ${deal.title}`,detail:"The brand is waiting for your decision.",href:`/deals/${deal.id}`}];
    if(invoice?.status==="draft")return [{key:`invoice-${invoice.id}`,title:`Review ${deal.title} invoice`,detail:"Rep Bureau has prepared the invoice; check the facts and total.",href:`/deals/${deal.id}`}];
    if(invoice?.status==="ready")return [{key:`send-${invoice.id}`,title:`Approve invoice send for ${deal.title}`,detail:"The numbered invoice is ready. Nothing will be sent without you.",href:`/deals/${deal.id}`}];
    if(invoice?.status==="sent")return [{key:`payment-${invoice.id}`,title:`Track payment for ${deal.title}`,detail:`Payment is due${invoice.due_date?` ${new Intl.DateTimeFormat("en-GB",{dateStyle:"medium",timeZone:"UTC"}).format(new Date(`${invoice.due_date}T00:00:00Z`))}`:" after invoice send"}. Rep Bureau will surface a chase for your approval when needed.`,href:`/deals/${deal.id}`}];
    if(["agreed","completed"].includes(deal.status)&&deal.final_agreed_minor!==null&&!invoice)return [{key:`prepare-${deal.id}`,title:`Prepare invoice for ${deal.title}`,detail:"The agreed fee is recorded and the Deal is ready for invoice preparation.",href:`/deals/${deal.id}`}];return [];
  }),...(deadlines??[]).map(deadline=>({key:`deadline-${deadline.id}`,title:deadline.label,detail:`Due ${new Intl.DateTimeFormat("en-GB",{dateStyle:"medium"}).format(new Date(deadline.due_at))}`,href:`/deals/${deadline.deal_id}`}))];
  return <AppShell><header className="page-header"><div><p className="eyebrow">Your day</p><h1>Good morning, {firstName}</h1></div></header>
    <section className="content-block"><p className="eyebrow">What actually needs you</p><h2>Your action dashboard</h2>{actions.length?<ol className="action-list">{actions.map(action=><li key={action.key}><div><strong>{action.title}</strong><p>{action.detail}</p></div><Link className="button button-secondary" href={action.href}>Review →</Link></li>)}</ol>:<><p className="muted">Rep Bureau is handling the admin. There is nothing waiting for your decision right now.</p><Link className="empty-action" href="/deals">View Deal pipeline →</Link></>}</section>
    <section className="content-block"><h2>Money by currency</h2>{financials?.length?<div className="financial-grid">{financials.map(row=><article key={row.currency}><strong>{row.currency}</strong><dl><div><dt>Ready</dt><dd>{new Intl.NumberFormat("en-GB",{style:"currency",currency:row.currency}).format(row.ready_to_invoice_minor/100)}</dd></div><div><dt>Outstanding</dt><dd>{new Intl.NumberFormat("en-GB",{style:"currency",currency:row.currency}).format(row.outstanding_minor/100)}</dd></div><div><dt>Overdue</dt><dd>{new Intl.NumberFormat("en-GB",{style:"currency",currency:row.currency}).format(row.overdue_minor/100)}</dd></div><div><dt>Received</dt><dd>{new Intl.NumberFormat("en-GB",{style:"currency",currency:row.currency}).format(row.received_minor/100)}</dd></div></dl></article>)}</div>:<p className="muted">Agreed, invoiced and received amounts will stay separated by currency here.</p>}</section>
    <section className="content-block"><h2>Estimated Additional Earnings</h2><p className="muted">Your honest, reproducible estimate will appear after you complete negotiated deals.</p></section>
  </AppShell>;
}

