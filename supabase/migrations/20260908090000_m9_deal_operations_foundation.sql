-- M9A-F: one operational Deal record, deterministic invoicing and creator-controlled payment state.
create table public.deal_operational_facts (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null references public.deals(id) on delete cascade,
  field_key text not null check (field_key in (
    'brand_name','agency_name','contact_name','contact_email','billing_entity','billing_address',
    'accounts_payable_email','purchase_order','invoice_instructions','campaign_start','campaign_end',
    'usage_terms','exclusivity_terms','paid_media_terms'
  )),
  value jsonb not null,
  display_value text not null check (length(trim(display_value)) between 1 and 5000),
  source_kind text not null check (source_kind in ('creator','message','ai_extraction','profile','previous_deal','system')),
  source_id uuid,
  precedence smallint not null check (precedence between 1 and 100),
  is_current boolean not null default true,
  superseded_by uuid references public.deal_operational_facts(id) on delete set null,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
create unique index deal_operational_facts_current_idx on public.deal_operational_facts(deal_id,field_key) where is_current;
create index deal_operational_facts_workspace_idx on public.deal_operational_facts(workspace_id,deal_id);

create table public.deal_deadlines (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null references public.deals(id) on delete cascade,
  deadline_type text not null check (deadline_type in ('campaign_start','campaign_end','draft_due','approval_due','publish_due','invoice_due','payment_due','other')),
  label text not null check (length(trim(label)) between 1 and 200), due_at timestamptz not null,
  status text not null default 'open' check (status in ('open','completed','cancelled')),
  source_kind text not null check (source_kind in ('creator','message','ai_extraction','system')),
  source_id uuid, created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index deal_deadlines_due_idx on public.deal_deadlines(workspace_id,status,due_at);

create table public.deal_contract_references (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null unique references public.deals(id) on delete cascade,
  received_status text not null default 'not_received' check (received_status in ('not_received','received','not_applicable')),
  signature_status text not null default 'not_signed' check (signature_status in ('not_signed','creator_signed','fully_signed','not_applicable')),
  reference text, private_storage_path text, creator_confirmed_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.invoice_issuer_profiles (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null unique references public.workspaces(id) on delete cascade,
  legal_name text not null check (length(trim(legal_name)) between 1 and 200), trading_name text,
  address text not null check (length(trim(address)) between 1 and 2000), email text not null,
  registration_number text, tax_number text, bank_details text,
  invoice_prefix text not null default 'RB' check (invoice_prefix ~ '^[A-Z0-9-]{1,12}$'),
  payment_terms_days integer not null default 30 check (payment_terms_days between 0 and 180),
  next_sequence integer not null default 1 check (next_sequence > 0),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.invoices (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null references public.deals(id) on delete restrict,
  issuer_profile_id uuid not null references public.invoice_issuer_profiles(id) on delete restrict,
  status text not null default 'draft' check (status in ('draft','ready','sending','sent','query','paid','written_off','void')),
  invoice_number text, currency char(3) not null, subtotal_minor bigint not null default 0 check (subtotal_minor>=0),
  tax_minor bigint not null default 0 check (tax_minor>=0), total_minor bigint generated always as (subtotal_minor+tax_minor) stored,
  issue_date date, payment_terms_days integer not null check (payment_terms_days between 0 and 180), due_date date,
  billing_entity text, billing_address text, accounts_payable_email text, purchase_order text, notes text,
  creator_reviewed_at timestamptz, sent_at timestamptz, paid_confirmed_at timestamptz, written_off_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(workspace_id,invoice_number)
);
create unique index invoices_one_open_per_deal_idx on public.invoices(deal_id) where status not in ('void','written_off');
create index invoices_workspace_status_idx on public.invoices(workspace_id,status,due_date);

create table public.invoice_line_items (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  invoice_id uuid not null references public.invoices(id) on delete cascade,
  position integer not null check (position>0), description text not null check (length(trim(description)) between 1 and 500),
  quantity numeric(12,3) not null check (quantity>0), unit_amount_minor bigint not null check (unit_amount_minor>=0),
  line_total_minor bigint not null check (line_total_minor>=0), source_kind text not null check (source_kind in ('deal','creator')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(invoice_id,position)
);

create table public.invoice_versions (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  invoice_id uuid not null references public.invoices(id) on delete cascade, version integer not null check(version>0),
  snapshot jsonb not null, pdf_storage_path text, pdf_sha256 text,
  created_by uuid references auth.users(id) on delete set null, created_at timestamptz not null default now(), unique(invoice_id,version)
);

create table public.payment_reminders (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  invoice_id uuid not null references public.invoices(id) on delete cascade,
  reminder_kind text not null check (reminder_kind in ('due_soon','overdue','query_follow_up')),
  status text not null default 'draft' check (status in ('draft','approved','sending','sent','cancelled','failed')),
  subject text not null, body text not null, due_snapshot date not null, idempotency_key text not null,
  creator_approved_at timestamptz, sent_at timestamptz, created_at timestamptz not null default now(), unique(workspace_id,idempotency_key)
);

create table public.provider_email_drafts (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null references public.deals(id) on delete cascade,
  purpose text not null check (purpose in ('negotiation','terms_confirmation','invoice','payment_chase')),
  provider_route text not null check (provider_route in ('gmail','managed_email')),
  provider_thread_id text, to_address text not null, reply_to_address text, subject text not null, body text not null,
  attachment_refs jsonb not null default '[]'::jsonb, state text not null default 'draft' check (state in ('draft','approved','sending','sent','failed','cancelled')),
  version integer not null default 1 check(version>0), idempotency_key text not null,
  creator_approved_at timestamptz, provider_message_id text, sent_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(workspace_id,idempotency_key)
);

alter table public.deals add column if not exists operational_stage text not null default 'enquiry'
  check (operational_stage in ('enquiry','analysis','negotiation','agreement','campaign','ready_to_invoice','invoiced','payment_due','complete','closed'));
update public.deals set operational_stage=case status when 'new' then 'enquiry' when 'reviewing' then 'analysis' when 'negotiating' then 'negotiation' when 'awaiting_brand' then 'negotiation' when 'awaiting_creator' then 'negotiation' when 'agreed' then 'agreement' when 'completed' then 'campaign' else 'closed' end;
create or replace function private.sync_deal_operational_stage() returns trigger language plpgsql set search_path='' as $$
begin
  if tg_op='UPDATE' and new.operational_stage is distinct from old.operational_stage then return new; end if;
  new.operational_stage:=case new.status when 'new' then 'enquiry' when 'reviewing' then 'analysis' when 'negotiating' then 'negotiation' when 'awaiting_brand' then 'negotiation' when 'awaiting_creator' then 'negotiation' when 'agreed' then 'agreement' when 'completed' then 'campaign' else 'closed' end;
  return new;
end $$;
create trigger sync_deal_operational_stage before insert or update of status,operational_stage on public.deals for each row execute function private.sync_deal_operational_stage();

create or replace function public.set_deal_operational_fact(p_deal_id uuid,p_field_key text,p_value jsonb,p_display_value text)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_workspace uuid; v_old public.deal_operational_facts; v_new uuid;
begin
  select d.workspace_id into v_workspace from public.deals d where d.id=p_deal_id and d.deleted_at is null
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=d.workspace_id and wm.user_id=auth.uid());
  if v_workspace is null then raise exception 'deal not found' using errcode='P0002'; end if;
  select * into v_old from public.deal_operational_facts where deal_id=p_deal_id and field_key=p_field_key and is_current for update;
  insert into public.deal_operational_facts(workspace_id,deal_id,field_key,value,display_value,source_kind,precedence,created_by)
  values(v_workspace,p_deal_id,p_field_key,p_value,trim(p_display_value),'creator',100,auth.uid()) returning id into v_new;
  if v_old.id is not null then update public.deal_operational_facts set is_current=false,superseded_by=v_new where id=v_old.id; end if;
  insert into public.activity_events(workspace_id,entity_type,entity_id,event_type,actor_user_id,metadata)
  values(v_workspace,'deal',p_deal_id,'deal_fact_updated',auth.uid(),jsonb_build_object('fieldKey',p_field_key));
  return v_new;
end $$;

create or replace function public.prepare_deal_invoice(p_deal_id uuid) returns uuid language plpgsql security definer set search_path='' as $$
declare v_deal public.deals; v_profile public.invoice_issuer_profiles; v_invoice uuid; v_description text;
begin
  select d.* into v_deal from public.deals d where d.id=p_deal_id and d.deleted_at is null
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=d.workspace_id and wm.user_id=auth.uid());
  if v_deal.id is null then raise exception 'deal not found' using errcode='P0002'; end if;
  select * into v_profile from public.invoice_issuer_profiles where workspace_id=v_deal.workspace_id;
  if v_profile.id is null then raise exception 'invoice issuer profile required' using errcode='23514'; end if;
  if v_deal.final_agreed_minor is null then raise exception 'final agreed fee required' using errcode='23514'; end if;
  select id into v_invoice from public.invoices where deal_id=p_deal_id and status not in ('void','written_off');
  if v_invoice is not null then return v_invoice; end if;
  select coalesce((select display_value from public.deal_operational_facts where deal_id=p_deal_id and field_key='brand_name' and is_current),v_deal.title) into v_description;
  insert into public.invoices(workspace_id,deal_id,issuer_profile_id,currency,subtotal_minor,payment_terms_days,billing_entity,billing_address,accounts_payable_email,purchase_order)
  values(v_deal.workspace_id,p_deal_id,v_profile.id,v_deal.currency,v_deal.final_agreed_minor,v_profile.payment_terms_days,
    (select display_value from public.deal_operational_facts where deal_id=p_deal_id and field_key='billing_entity' and is_current),
    (select display_value from public.deal_operational_facts where deal_id=p_deal_id and field_key='billing_address' and is_current),
    (select display_value from public.deal_operational_facts where deal_id=p_deal_id and field_key='accounts_payable_email' and is_current),
    (select display_value from public.deal_operational_facts where deal_id=p_deal_id and field_key='purchase_order' and is_current)) returning id into v_invoice;
  insert into public.invoice_line_items(workspace_id,invoice_id,position,description,quantity,unit_amount_minor,line_total_minor,source_kind)
  values(v_deal.workspace_id,v_invoice,1,'Campaign services — '||v_description,1,v_deal.final_agreed_minor,v_deal.final_agreed_minor,'deal');
  update public.deals set operational_stage='ready_to_invoice',updated_at=now() where id=p_deal_id;
  return v_invoice;
end $$;

create or replace function public.finalise_invoice(p_invoice_id uuid,p_expected_total_minor bigint) returns text language plpgsql security definer set search_path='' as $$
declare v_invoice public.invoices; v_profile public.invoice_issuer_profiles; v_number text; v_subtotal bigint;
begin
  select i.* into v_invoice from public.invoices i where i.id=p_invoice_id and i.status='draft'
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=i.workspace_id and wm.user_id=auth.uid()) for update;
  if v_invoice.id is null then raise exception 'draft invoice not found' using errcode='P0002'; end if;
  select coalesce(sum(line_total_minor),0) into v_subtotal from public.invoice_line_items where invoice_id=p_invoice_id;
  if v_subtotal+v_invoice.tax_minor<>p_expected_total_minor then raise exception 'invoice total changed' using errcode='40001'; end if;
  select * into v_profile from public.invoice_issuer_profiles where id=v_invoice.issuer_profile_id for update;
  v_number:=v_profile.invoice_prefix||'-'||to_char(current_date,'YYYY')||'-'||lpad(v_profile.next_sequence::text,4,'0');
  update public.invoice_issuer_profiles set next_sequence=next_sequence+1,updated_at=now() where id=v_profile.id;
  update public.invoices set invoice_number=v_number,subtotal_minor=v_subtotal,status='ready',issue_date=current_date,
    due_date=current_date+payment_terms_days,creator_reviewed_at=now(),updated_at=now() where id=p_invoice_id;
  insert into public.invoice_versions(workspace_id,invoice_id,version,snapshot,created_by)
  select workspace_id,id,1,jsonb_build_object('invoiceNumber',v_number,'currency',currency,'subtotalMinor',v_subtotal,'taxMinor',tax_minor,'totalMinor',v_subtotal+tax_minor,'issueDate',current_date,'dueDate',current_date+payment_terms_days,
    'items',(select coalesce(jsonb_agg(to_jsonb(li) - 'workspace_id' - 'invoice_id' order by position),'[]'::jsonb) from public.invoice_line_items li where li.invoice_id=p_invoice_id)),auth.uid()
  from public.invoices where id=p_invoice_id;
  return v_number;
end $$;

create or replace function public.confirm_invoice_paid(p_invoice_id uuid) returns void language plpgsql security definer set search_path='' as $$
declare v_invoice public.invoices;
begin
  select i.* into v_invoice from public.invoices i where i.id=p_invoice_id and i.status in ('sent','query')
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=i.workspace_id and wm.user_id=auth.uid()) for update;
  if v_invoice.id is null then raise exception 'eligible invoice not found' using errcode='P0002'; end if;
  update public.invoices set status='paid',paid_confirmed_at=now(),updated_at=now() where id=p_invoice_id;
  update public.deals set operational_stage='complete',status='completed',updated_at=now() where id=v_invoice.deal_id;
end $$;

create or replace view public.deal_financial_overview with (security_invoker=true) as
select workspace_id,currency,
  coalesce(sum(total_minor) filter(where status='draft'),0)::bigint as ready_to_invoice_minor,
  coalesce(sum(total_minor) filter(where status in ('ready','sending')),0)::bigint as prepared_minor,
  coalesce(sum(total_minor) filter(where status in ('sent','query')),0)::bigint as outstanding_minor,
  coalesce(sum(total_minor) filter(where status in ('sent','query') and due_date<current_date),0)::bigint as overdue_minor,
  coalesce(sum(total_minor) filter(where status='paid'),0)::bigint as received_minor
from public.invoices group by workspace_id,currency;

alter table public.deal_operational_facts enable row level security; alter table public.deal_deadlines enable row level security;
alter table public.deal_contract_references enable row level security; alter table public.invoice_issuer_profiles enable row level security;
alter table public.invoices enable row level security; alter table public.invoice_line_items enable row level security;
alter table public.invoice_versions enable row level security; alter table public.payment_reminders enable row level security;
alter table public.provider_email_drafts enable row level security;

grant select on public.deal_operational_facts,public.deal_deadlines,public.deal_contract_references,public.invoices,public.invoice_versions,public.payment_reminders,public.provider_email_drafts,public.deal_financial_overview to authenticated;
grant select,insert,update on public.invoice_issuer_profiles,public.invoice_line_items to authenticated;
revoke all on function public.set_deal_operational_fact(uuid,text,jsonb,text),public.prepare_deal_invoice(uuid),public.finalise_invoice(uuid,bigint),public.confirm_invoice_paid(uuid) from public,anon;
grant execute on function public.set_deal_operational_fact(uuid,text,jsonb,text),public.prepare_deal_invoice(uuid),public.finalise_invoice(uuid,bigint),public.confirm_invoice_paid(uuid) to authenticated;

do $$ declare t text; begin foreach t in array array['deal_operational_facts','deal_deadlines','deal_contract_references','invoice_issuer_profiles','invoices','invoice_line_items','invoice_versions','payment_reminders','provider_email_drafts'] loop
  execute format('create policy %I_member_select on public.%I for select to authenticated using (exists(select 1 from public.workspace_members wm where wm.workspace_id=%I.workspace_id and wm.user_id=(select auth.uid())))',t,t,t);
end loop; end $$;
create policy invoice_issuer_profiles_member_write on public.invoice_issuer_profiles for all to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=invoice_issuer_profiles.workspace_id and wm.user_id=(select auth.uid()))) with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=invoice_issuer_profiles.workspace_id and wm.user_id=(select auth.uid())));
create policy invoice_line_items_member_write on public.invoice_line_items for all to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=invoice_line_items.workspace_id and wm.user_id=(select auth.uid()))) with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=invoice_line_items.workspace_id and wm.user_id=(select auth.uid())));

comment on table public.deal_operational_facts is 'Append-only provenance ledger. Creator values have precedence 100 and are never silently overwritten.';
comment on column public.invoices.paid_confirmed_at is 'Phase 1 payment evidence is an explicit creator confirmation, never an inferred bank event.';

