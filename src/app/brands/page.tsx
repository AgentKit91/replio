import { AppShell } from "@/components/replio/AppShell";
import { requireUser } from "@/features/auth/require-user";

export default async function BrandsPage() {
  const { supabase } = await requireUser();
  const { data, error } = await supabase.from("workspace_brands").select("id,relationship_status,notes_summary,brand_id,brands(canonical_name,normalized_domain)").order("updated_at", { ascending: false });
  if (error) throw new Error("Unable to load brands.");
  const { data: contacts } = data?.length ? await supabase.from("brand_contacts").select("id,brand_id,name,email,title,last_seen_at").in("brand_id", data.map((item) => item.brand_id)) : { data: [] };
  return <AppShell><header className="page-header"><div><p className="eyebrow">Private relationships</p><h1>Brands</h1></div></header>{data?.length ? <div className="brand-grid">{data.map((item) => { const brand = Array.isArray(item.brands) ? item.brands[0] : item.brands; const brandContacts = contacts?.filter((contact) => contact.brand_id === item.brand_id) ?? []; return <article className="workspace-card" key={item.id}><span className="status-pill">{item.relationship_status.replaceAll("_", " ")}</span><h2>{brand?.canonical_name ?? "Unknown brand"}</h2>{brand?.normalized_domain && <p className="muted">{brand.normalized_domain}</p>}<h3>Contacts</h3>{brandContacts.length ? <ul className="contact-list">{brandContacts.map((contact) => <li key={contact.id}><strong>{contact.name || contact.email}</strong>{contact.title && <span>{contact.title}</span>}<a href={`mailto:${contact.email}`}>{contact.email}</a></li>)}</ul> : <p className="muted">No contacts recorded.</p>}{item.notes_summary && <p>{item.notes_summary}</p>}</article>; })}</div> : <section className="content-block"><h2>No brands yet</h2><p className="muted">Brand relationships will appear when imported deals are matched to a brand.</p></section>}</AppShell>;
}
