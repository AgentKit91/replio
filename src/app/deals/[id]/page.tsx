import Link from "next/link";
import { notFound } from "next/navigation";
import { AppShell } from "@/components/replio/AppShell";
import { requireUser } from "@/features/auth/require-user";
import { dealState, dealStates } from "@/features/deals/state";
import { addDealNote, recycleDeal, updateDealState } from "../actions";

export default async function DealWorkspace({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const { supabase } = await requireUser();
  const { data: deal } = await supabase.from("deals").select("id,title,status,currency,current_offer_minor,final_agreed_minor,primary_platform,brand_id,created_at").eq("id", id).is("deleted_at", null).maybeSingle();
  if (!deal) notFound();
  const [{ data: threads }, { data: offers }, { data: terms }, { data: deliverables }, { data: notes }, { data: activity }] = await Promise.all([
    supabase.from("deal_threads").select("id").eq("deal_id", id),
    supabase.from("deal_offers").select("id,offered_by,amount_minor,currency,offer_type,observed_at").eq("deal_id", id).order("observed_at", { ascending: false }),
    supabase.from("deal_terms").select("id,term_type,display_value,fact_state").eq("deal_id", id).eq("is_current", true),
    supabase.from("deal_deliverables").select("id,platform,deliverable_type,quantity,due_at,status").eq("deal_id", id),
    supabase.from("deal_notes").select("id,body,created_at").eq("deal_id", id).order("created_at", { ascending: false }),
    supabase.from("activity_events").select("id,event_type,metadata,created_at").eq("entity_type", "deal").eq("entity_id", id).order("created_at", { ascending: false }),
  ]);
  const threadIds = (threads ?? []).map((thread) => thread.id);
  const { data: messages } = threadIds.length ? await supabase.from("gmail_messages").select("id,direction,from_address,to_addresses,subject,body_text,internal_date").in("deal_thread_id", threadIds).order("internal_date") : { data: [] };
  const messageIds = (messages ?? []).map((message) => message.id);
  const { data: attachments } = messageIds.length ? await supabase.from("gmail_attachment_references").select("id,gmail_message_id,filename,mime_type,size_bytes").in("gmail_message_id", messageIds) : { data: [] };
  const state = dealState(deal.status);
  return <AppShell>
    <header className="page-header deal-heading"><div><Link className="back-link" href="/deals">← Deals</Link><h1>{deal.title}</h1><p className="status-explainer"><span className={`status-pill status-${deal.status}`}>{state.label}</span> {state.detail}</p></div><form action={recycleDeal}><input type="hidden" name="dealId" value={deal.id}/><input type="hidden" name="recycled" value="true"/><button className="button button-secondary">Move to recycle bin</button></form></header>
    <div className="workspace-grid">
      <section className="workspace-analysis" aria-label="Commercial details">
        <section className="workspace-card"><div className="section-heading"><div><p className="eyebrow">Next move</p><h2>Deal state</h2></div></div><form action={updateDealState} className="state-form"><input type="hidden" name="dealId" value={deal.id}/><select name="status" defaultValue={deal.status} aria-label="Deal state">{Object.entries(dealStates).map(([value, copy]) => <option value={value} key={value}>{copy.label}</option>)}</select><button className="button button-primary">Update state</button></form></section>
        <section className="workspace-card"><h2>Commercial snapshot</h2><dl className="detail-grid"><div><dt>Current offer</dt><dd>{deal.current_offer_minor === null ? "Not recorded" : new Intl.NumberFormat("en-GB", { style: "currency", currency: deal.currency }).format(deal.current_offer_minor / 100)}</dd></div><div><dt>Platform</dt><dd>{deal.primary_platform ?? "Not confirmed"}</dd></div></dl>
          <h3>Offer history</h3>{offers?.length ? <ul className="fact-list">{offers.map((offer) => <li key={offer.id}><span>{offer.offered_by === "brand" ? "Brand" : "You"} · {offer.offer_type}</span><strong>{new Intl.NumberFormat("en-GB", { style: "currency", currency: offer.currency }).format(offer.amount_minor / 100)}</strong></li>)}</ul> : <p className="muted">No structured offers recorded yet.</p>}
          <h3>Terms</h3>{terms?.length ? <ul className="fact-list">{terms.map((term) => <li key={term.id}><span>{term.term_type.replaceAll("_", " ")}</span><strong>{term.display_value}</strong></li>)}</ul> : <p className="muted">No commercial terms recorded yet.</p>}
          <h3>Deliverables</h3>{deliverables?.length ? <ul className="fact-list">{deliverables.map((item) => <li key={item.id}><span>{item.quantity} × {item.deliverable_type}</span><strong>{item.status.replaceAll("_", " ")}</strong></li>)}</ul> : <p className="muted">No deliverables recorded yet.</p>}
        </section>
        <section className="workspace-card"><h2>Private notes</h2><form action={addDealNote} className="note-form"><input type="hidden" name="dealId" value={deal.id}/><textarea name="body" required maxLength={10000} placeholder="Add context only you can see" aria-label="Private note"/><button className="button button-primary">Save note</button></form>{notes?.map((note) => <article className="note" key={note.id}><p>{note.body}</p><time>{new Intl.DateTimeFormat("en-GB", { dateStyle: "medium", timeStyle: "short" }).format(new Date(note.created_at))}</time></article>)}</section>
        <section className="workspace-card"><h2>Activity</h2>{activity?.length ? <ol className="timeline">{activity.map((event) => <li key={event.id}><strong>{event.event_type.replaceAll("_", " ")}</strong><time>{new Intl.DateTimeFormat("en-GB", { dateStyle: "medium", timeStyle: "short" }).format(new Date(event.created_at))}</time></li>)}</ol> : <p className="muted">Activity will appear as the deal changes.</p>}</section>
      </section>
      <section className="conversation-pane" aria-label="Email conversation"><div className="conversation-heading"><p className="eyebrow">Conversation</p><h2>Email thread</h2></div>{messages?.length ? messages.map((message) => <article className={`message-card message-${message.direction}`} key={message.id}><header><strong>{message.direction === "outbound" ? "You" : message.from_address}</strong><time>{new Intl.DateTimeFormat("en-GB", { dateStyle: "medium", timeStyle: "short" }).format(new Date(message.internal_date))}</time></header>{message.subject && <p className="message-subject">{message.subject}</p>}<p className="message-body">{message.body_text || "No plain-text content."}</p>{attachments?.filter((file) => file.gmail_message_id === message.id).map((file) => <span className="attachment" key={file.id}>📎 {file.filename}</span>)}</article>) : <p className="muted">No messages have synced for this deal yet.</p>}</section>
    </div>
  </AppShell>;
}
