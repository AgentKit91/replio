create table public.brands (
  id uuid primary key default gen_random_uuid(),
  canonical_name text not null,
  normalized_domain text unique,
  industry text,
  country_code char(2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.workspace_brands (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  brand_id uuid not null references public.brands(id) on delete cascade,
  relationship_status text not null default 'active' check (relationship_status in ('prospect','active','past','do_not_work_with')),
  notes_summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workspace_id, brand_id)
);

create table public.brand_contacts (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  brand_id uuid not null references public.brands(id) on delete cascade,
  name text,
  email text not null,
  title text,
  source text not null default 'gmail' check (source in ('gmail','user')),
  last_seen_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workspace_id, brand_id, email)
);

alter table public.deals
  add column brand_id uuid references public.brands(id) on delete set null,
  add column human_status_code text not null default 'needs_review',
  add column primary_platform text,
  add column currency char(3) not null default 'GBP',
  add column current_offer_minor bigint check (current_offer_minor is null or current_offer_minor >= 0),
  add column final_agreed_minor bigint check (final_agreed_minor is null or final_agreed_minor >= 0),
  add column purge_after timestamptz;

create table public.deal_notes (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null references public.deals(id) on delete cascade,
  body text not null check (length(trim(body)) between 1 and 10000),
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.deal_offers (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null references public.deals(id) on delete cascade,
  offered_by text not null check (offered_by in ('brand','creator')),
  amount_minor bigint not null check (amount_minor >= 0), currency char(3) not null,
  offer_type text not null check (offer_type in ('initial','counter','revised','final')),
  source_message_id uuid references public.gmail_messages(id) on delete set null,
  observed_at timestamptz not null default now(), created_at timestamptz not null default now()
);

create table public.deal_terms (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null references public.deals(id) on delete cascade,
  term_type text not null, normalized_value jsonb not null default '{}'::jsonb, display_value text not null,
  fact_state text not null default 'confirmed' check (fact_state in ('confirmed','missing','inferred')),
  source_owner text not null default 'user' check (source_owner in ('user','approved_ai','ai_extraction','imported')),
  is_current boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.deal_deliverables (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null references public.deals(id) on delete cascade,
  platform text, deliverable_type text not null, quantity integer not null default 1 check (quantity > 0),
  due_at timestamptz, status text not null default 'proposed' check (status in ('proposed','agreed','in_progress','delivered','cancelled')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create index workspace_brands_workspace_idx on public.workspace_brands(workspace_id);
create index brand_contacts_workspace_brand_idx on public.brand_contacts(workspace_id, brand_id);
create index deals_workspace_updated_idx on public.deals(workspace_id, updated_at desc);
create index deal_notes_deal_created_idx on public.deal_notes(deal_id, created_at desc);
create index deal_offers_deal_observed_idx on public.deal_offers(deal_id, observed_at desc);
create index deal_terms_deal_current_idx on public.deal_terms(deal_id) where is_current;
create index deal_deliverables_deal_idx on public.deal_deliverables(deal_id);

alter table public.brands enable row level security;
alter table public.workspace_brands enable row level security;
alter table public.brand_contacts enable row level security;
alter table public.deal_notes enable row level security;
alter table public.deal_offers enable row level security;
alter table public.deal_terms enable row level security;
alter table public.deal_deliverables enable row level security;

revoke all on public.brands, public.workspace_brands, public.brand_contacts, public.deal_notes, public.deal_offers, public.deal_terms, public.deal_deliverables from anon, authenticated;
grant select on public.brands, public.workspace_brands, public.brand_contacts, public.deal_offers, public.deal_terms, public.deal_deliverables to authenticated;
grant select, insert, update, delete on public.deal_notes to authenticated;
grant update on public.deals to authenticated;

create policy brands_select_linked on public.brands for select to authenticated using (exists (select 1 from public.workspace_brands wb join public.workspace_members wm on wm.workspace_id = wb.workspace_id where wb.brand_id = brands.id and wm.user_id = (select auth.uid())));
create policy workspace_brands_select_member on public.workspace_brands for select to authenticated using (exists (select 1 from public.workspace_members wm where wm.workspace_id = workspace_brands.workspace_id and wm.user_id = (select auth.uid())));
create policy brand_contacts_select_member on public.brand_contacts for select to authenticated using (exists (select 1 from public.workspace_members wm where wm.workspace_id = brand_contacts.workspace_id and wm.user_id = (select auth.uid())));
create policy deal_offers_select_member on public.deal_offers for select to authenticated using (exists (select 1 from public.workspace_members wm where wm.workspace_id = deal_offers.workspace_id and wm.user_id = (select auth.uid())));
create policy deal_terms_select_member on public.deal_terms for select to authenticated using (exists (select 1 from public.workspace_members wm where wm.workspace_id = deal_terms.workspace_id and wm.user_id = (select auth.uid())));
create policy deal_deliverables_select_member on public.deal_deliverables for select to authenticated using (exists (select 1 from public.workspace_members wm where wm.workspace_id = deal_deliverables.workspace_id and wm.user_id = (select auth.uid())));
create policy deal_notes_select_member on public.deal_notes for select to authenticated using (exists (select 1 from public.workspace_members wm where wm.workspace_id = deal_notes.workspace_id and wm.user_id = (select auth.uid())));
create policy deal_notes_insert_member on public.deal_notes for insert to authenticated with check (created_by = (select auth.uid()) and exists (select 1 from public.workspace_members wm where wm.workspace_id = deal_notes.workspace_id and wm.user_id = (select auth.uid())) and exists (select 1 from public.deals d where d.id = deal_id and d.workspace_id = deal_notes.workspace_id));
create policy deal_notes_update_owner on public.deal_notes for update to authenticated using (created_by = (select auth.uid())) with check (created_by = (select auth.uid()));
create policy deal_notes_delete_owner on public.deal_notes for delete to authenticated using (created_by = (select auth.uid()));
create policy deals_update_member on public.deals for update to authenticated using (exists (select 1 from public.workspace_members wm where wm.workspace_id = deals.workspace_id and wm.user_id = (select auth.uid()))) with check (exists (select 1 from public.workspace_members wm where wm.workspace_id = deals.workspace_id and wm.user_id = (select auth.uid())));

create or replace function public.log_deal_change() returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if old.status is distinct from new.status then
    insert into public.activity_events(workspace_id, actor_user_id, event_type, entity_type, entity_id, metadata)
    values (new.workspace_id, auth.uid(), 'deal_status_changed', 'deal', new.id, jsonb_build_object('from', old.status, 'to', new.status));
  end if;
  if old.deleted_at is null and new.deleted_at is not null then
    insert into public.activity_events(workspace_id, actor_user_id, event_type, entity_type, entity_id) values (new.workspace_id, auth.uid(), 'deal_moved_to_recycle_bin', 'deal', new.id);
  elsif old.deleted_at is not null and new.deleted_at is null then
    insert into public.activity_events(workspace_id, actor_user_id, event_type, entity_type, entity_id) values (new.workspace_id, auth.uid(), 'deal_restored', 'deal', new.id);
  end if;
  return new;
end $$;
revoke all on function public.log_deal_change() from public, anon, authenticated;
create trigger log_deal_change after update of status, deleted_at on public.deals for each row execute function public.log_deal_change();

create or replace function public.set_deal_state(p_deal_id uuid, p_status public.deal_status)
returns void language plpgsql security invoker set search_path = '' as $$
begin
  update public.deals set status = p_status,
    human_status_code = case p_status when 'awaiting_brand' then 'waiting_on_brand' when 'awaiting_creator' then 'your_reply_needed' when 'agreed' then 'agreement_reached' when 'completed' then 'work_complete' else p_status::text end,
    updated_at = now() where id = p_deal_id and deleted_at is null;
  if not found then raise exception 'deal not found' using errcode = 'P0002'; end if;
end $$;
grant execute on function public.set_deal_state(uuid, public.deal_status) to authenticated;

create or replace function public.set_deal_recycled(p_deal_id uuid, p_recycled boolean)
returns void language plpgsql security invoker set search_path = '' as $$
begin
  update public.deals set deleted_at = case when p_recycled then now() else null end,
    purge_after = case when p_recycled then now() + interval '30 days' else null end, updated_at = now()
  where id = p_deal_id;
  if not found then raise exception 'deal not found' using errcode = 'P0002'; end if;
end $$;
grant execute on function public.set_deal_recycled(uuid, boolean) to authenticated;

create or replace function private.purge_expired_deals()
returns bigint language plpgsql security definer set search_path = '' as $$
declare v_count bigint;
begin
  delete from public.deals where deleted_at is not null and purge_after <= now();
  get diagnostics v_count = row_count;
  return v_count;
end $$;
revoke all on function private.purge_expired_deals() from public, anon, authenticated;

select cron.schedule('replio-purge-expired-deals', '17 3 * * *', 'select private.purge_expired_deals();');

comment on table public.brands is 'Shared safe brand identity only; creator-private relationship data belongs in workspace-scoped tables.';
