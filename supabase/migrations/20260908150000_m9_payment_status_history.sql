create table public.payment_status_events (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  invoice_id uuid not null references public.invoices(id) on delete cascade,
  event_type text not null check(event_type in ('still_waiting','paid_confirmed','written_off')),
  actor_user_id uuid references auth.users(id) on delete set null, created_at timestamptz not null default now()
);
create index payment_status_events_workspace_idx on public.payment_status_events(workspace_id,created_at desc);
create index payment_status_events_invoice_idx on public.payment_status_events(invoice_id,created_at desc);
alter table public.payment_status_events enable row level security;
grant select on public.payment_status_events to authenticated;
create policy payment_status_events_member_select on public.payment_status_events for select to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=payment_status_events.workspace_id and wm.user_id=(select auth.uid())));

create or replace function public.record_invoice_still_waiting(p_invoice_id uuid) returns uuid language plpgsql security definer set search_path='' as $$
declare v_invoice public.invoices;v_id uuid;
begin select i.* into v_invoice from public.invoices i where i.id=p_invoice_id and i.status in('sent','query') and exists(select 1 from public.workspace_members wm where wm.workspace_id=i.workspace_id and wm.user_id=auth.uid());
if v_invoice.id is null then raise exception 'eligible invoice not found' using errcode='P0002';end if;
insert into public.payment_status_events(workspace_id,invoice_id,event_type,actor_user_id) values(v_invoice.workspace_id,p_invoice_id,'still_waiting',auth.uid()) returning id into v_id;return v_id;end $$;

create or replace function public.write_off_invoice(p_invoice_id uuid,p_confirmation boolean) returns void language plpgsql security definer set search_path='' as $$
declare v_invoice public.invoices;
begin if p_confirmation is distinct from true then raise exception 'explicit confirmation required' using errcode='22023';end if;
select i.* into v_invoice from public.invoices i where i.id=p_invoice_id and i.status in('sent','query') and exists(select 1 from public.workspace_members wm where wm.workspace_id=i.workspace_id and wm.user_id=auth.uid()) for update;
if v_invoice.id is null then raise exception 'eligible invoice not found' using errcode='P0002';end if;
update public.invoices set status='written_off',written_off_at=now(),updated_at=now() where id=p_invoice_id;
insert into public.payment_status_events(workspace_id,invoice_id,event_type,actor_user_id) values(v_invoice.workspace_id,p_invoice_id,'written_off',auth.uid());end $$;

create or replace function public.confirm_invoice_paid(p_invoice_id uuid) returns void language plpgsql security definer set search_path='' as $$
declare v_invoice public.invoices;
begin select i.* into v_invoice from public.invoices i where i.id=p_invoice_id and i.status in('sent','query') and exists(select 1 from public.workspace_members wm where wm.workspace_id=i.workspace_id and wm.user_id=auth.uid()) for update;
if v_invoice.id is null then raise exception 'eligible invoice not found' using errcode='P0002';end if;
update public.invoices set status='paid',paid_confirmed_at=now(),updated_at=now() where id=p_invoice_id;
insert into public.payment_status_events(workspace_id,invoice_id,event_type,actor_user_id) values(v_invoice.workspace_id,p_invoice_id,'paid_confirmed',auth.uid());
update public.deals set operational_stage='complete',status='completed',updated_at=now() where id=v_invoice.deal_id;end $$;

revoke all on function public.record_invoice_still_waiting(uuid),public.write_off_invoice(uuid,boolean) from public,anon;
grant execute on function public.record_invoice_still_waiting(uuid),public.write_off_invoice(uuid,boolean) to authenticated;

