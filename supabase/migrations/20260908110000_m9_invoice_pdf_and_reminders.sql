-- Deterministic invoice artifacts and draft-only payment administration.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('invoice-pdfs','invoice-pdfs',false,5000000,array['application/pdf'])
on conflict(id) do update set public=false,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;

create or replace function private.prepare_payment_reminder_drafts(p_as_of date default current_date) returns integer
language plpgsql security definer set search_path='' as $$
declare v_count integer;
begin
  insert into public.payment_reminders(workspace_id,invoice_id,reminder_kind,subject,body,due_snapshot,idempotency_key)
  select i.workspace_id,i.id,
    case when i.status='query' then 'query_follow_up' when i.due_date<p_as_of then 'overdue' else 'due_soon' end,
    case when i.due_date<p_as_of then 'Payment reminder: invoice ' else 'Upcoming payment: invoice ' end||i.invoice_number,
    case
      when i.status='query' then 'Hello,\n\nI am following up on the payment query for invoice '||i.invoice_number||', due '||to_char(i.due_date,'DD Mon YYYY')||'. Please let me know if you need anything else to process it.\n\nBest,'
      when i.due_date<p_as_of then 'Hello,\n\nA quick reminder that invoice '||i.invoice_number||' was due on '||to_char(i.due_date,'DD Mon YYYY')||'. Could you confirm the payment status, please?\n\nBest,'
      else 'Hello,\n\nA friendly note that invoice '||i.invoice_number||' is due on '||to_char(i.due_date,'DD Mon YYYY')||'. Please let me know if anything is needed to process it.\n\nBest,' end,
    i.due_date,'payment-reminder:'||i.id::text||':'||case when i.status='query' then 'query' when i.due_date<p_as_of then 'overdue' else 'due-soon' end||':'||i.due_date::text
  from public.invoices i
  where i.status in('sent','query') and i.due_date is not null and (i.status='query' or i.due_date between p_as_of and p_as_of+5 or i.due_date<p_as_of)
  on conflict(workspace_id,idempotency_key) do nothing;
  get diagnostics v_count=row_count;return v_count;
end $$;
revoke all on function private.prepare_payment_reminder_drafts(date) from public,anon,authenticated;

drop view public.deal_financial_overview;
create view public.deal_financial_overview with(security_invoker=true) as
with deal_totals as(
  select d.workspace_id,d.currency,
    coalesce(sum(d.final_agreed_minor) filter(where d.final_agreed_minor is not null),0)::bigint agreed_minor,
    coalesce(sum(d.final_agreed_minor) filter(where d.final_agreed_minor is not null and not exists(select 1 from public.invoices i where i.deal_id=d.id and i.status not in('void','written_off'))),0)::bigint ready_to_invoice_minor
  from public.deals d where d.deleted_at is null group by d.workspace_id,d.currency
), invoice_totals as(
  select i.workspace_id,i.currency,
    coalesce(sum(i.total_minor) filter(where i.status in('draft','ready','sending')),0)::bigint prepared_minor,
    coalesce(sum(i.total_minor) filter(where i.status in('sent','query')),0)::bigint outstanding_minor,
    coalesce(sum(i.total_minor) filter(where i.status in('sent','query') and i.due_date<current_date),0)::bigint overdue_minor,
    coalesce(sum(i.total_minor) filter(where i.status='paid'),0)::bigint received_minor,
    coalesce(sum(i.total_minor) filter(where i.status in('sent','query','paid')),0)::bigint invoiced_minor
  from public.invoices i where i.status not in('void','written_off') group by i.workspace_id,i.currency
)
select coalesce(d.workspace_id,i.workspace_id) workspace_id,coalesce(d.currency,i.currency) currency,
  coalesce(d.ready_to_invoice_minor,0)::bigint ready_to_invoice_minor,coalesce(i.prepared_minor,0)::bigint prepared_minor,
  coalesce(i.outstanding_minor,0)::bigint outstanding_minor,coalesce(i.overdue_minor,0)::bigint overdue_minor,
  coalesce(i.received_minor,0)::bigint received_minor,coalesce(d.agreed_minor,0)::bigint agreed_minor,coalesce(i.invoiced_minor,0)::bigint invoiced_minor
from deal_totals d full join invoice_totals i on i.workspace_id=d.workspace_id and i.currency=d.currency;
grant select on public.deal_financial_overview to authenticated;

select cron.schedule('rep-bureau-payment-reminder-drafts','13 8 * * *','select private.prepare_payment_reminder_drafts();');

comment on function private.prepare_payment_reminder_drafts(date) is 'Creates deterministic draft reminders only. It cannot approve or send email.';
comment on column public.invoice_versions.pdf_sha256 is 'SHA-256 integrity digest of the private immutable PDF object.';

