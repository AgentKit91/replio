-- Connect deterministic invoice/reminder admin to the existing provider-neutral email queue.
alter table public.provider_email_drafts
  add column if not exists invoice_id uuid references public.invoices(id) on delete cascade,
  add column if not exists payment_reminder_id uuid references public.payment_reminders(id) on delete cascade;

create unique index if not exists provider_email_drafts_invoice_route_idx
  on public.provider_email_drafts(invoice_id,provider_route) where purpose='invoice' and state<>'cancelled';
create unique index if not exists provider_email_drafts_reminder_route_idx
  on public.provider_email_drafts(payment_reminder_id,provider_route) where purpose='payment_chase' and state<>'cancelled';

create or replace function public.prepare_invoice_email(p_invoice_id uuid,p_provider_route text default 'managed_email') returns uuid
language plpgsql security definer set search_path='' as $$
declare v_invoice public.invoices;v_version public.invoice_versions;v_deal public.deals;v_draft uuid;
begin
  if p_provider_route not in('gmail','managed_email') then raise exception 'invalid provider route' using errcode='22023';end if;
  select i.* into v_invoice from public.invoices i where i.id=p_invoice_id and i.status='ready'
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=i.workspace_id and wm.user_id=auth.uid()) for update;
  if v_invoice.id is null then raise exception 'invoice not ready' using errcode='P0002';end if;
  if v_invoice.accounts_payable_email is null or v_invoice.accounts_payable_email!~*'^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then raise exception 'review accounts payable email' using errcode='22023';end if;
  select * into v_version from public.invoice_versions where invoice_id=v_invoice.id and pdf_storage_path is not null order by version desc limit 1;
  if v_version.id is null then raise exception 'invoice PDF not ready' using errcode='P0002';end if;
  select * into v_deal from public.deals where id=v_invoice.deal_id;
  insert into public.provider_email_drafts(workspace_id,deal_id,invoice_id,purpose,provider_route,to_address,subject,body,attachment_refs,idempotency_key)
  values(v_invoice.workspace_id,v_invoice.deal_id,v_invoice.id,'invoice',p_provider_route,lower(v_invoice.accounts_payable_email),
    'Invoice '||v_invoice.invoice_number||' — '||v_deal.title,
    'Hello,\n\nPlease find attached invoice '||v_invoice.invoice_number||' for '||v_deal.title||'. Payment is due by '||to_char(v_invoice.due_date,'DD Mon YYYY')||'.\n\nPlease let me know if you need anything else to process it.\n\nBest,',
    jsonb_build_array(jsonb_build_object('bucket','invoice-pdfs','path',v_version.pdf_storage_path,'filename',v_invoice.invoice_number||'.pdf','mimeType','application/pdf')),
    'invoice:'||v_invoice.id::text||':v'||v_version.version::text||':'||p_provider_route)
  on conflict(workspace_id,idempotency_key) do update set updated_at=now() returning id into v_draft;
  return v_draft;
end $$;
revoke all on function public.prepare_invoice_email(uuid,text) from public,anon;grant execute on function public.prepare_invoice_email(uuid,text) to authenticated;

create or replace function public.prepare_payment_chase_email(p_reminder_id uuid,p_provider_route text default 'managed_email') returns uuid
language plpgsql security definer set search_path='' as $$
declare v_reminder public.payment_reminders;v_invoice public.invoices;v_draft uuid;
begin
  if p_provider_route not in('gmail','managed_email') then raise exception 'invalid provider route' using errcode='22023';end if;
  select r.* into v_reminder from public.payment_reminders r where r.id=p_reminder_id and r.status in('draft','failed')
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=r.workspace_id and wm.user_id=auth.uid()) for update;
  if v_reminder.id is null then raise exception 'reminder not available' using errcode='P0002';end if;
  select * into v_invoice from public.invoices where id=v_reminder.invoice_id and status in('sent','query');
  if v_invoice.id is null then raise exception 'invoice is not awaiting payment' using errcode='P0002';end if;
  if v_invoice.accounts_payable_email is null or v_invoice.accounts_payable_email!~*'^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then raise exception 'review accounts payable email' using errcode='22023';end if;
  insert into public.provider_email_drafts(workspace_id,deal_id,payment_reminder_id,purpose,provider_route,to_address,subject,body,idempotency_key)
  values(v_reminder.workspace_id,v_invoice.deal_id,v_reminder.id,'payment_chase',p_provider_route,lower(v_invoice.accounts_payable_email),v_reminder.subject,v_reminder.body,'payment-chase:'||v_reminder.id::text||':'||p_provider_route)
  on conflict(workspace_id,idempotency_key) do update set subject=excluded.subject,body=excluded.body,version=public.provider_email_drafts.version+1,updated_at=now() where public.provider_email_drafts.state in('draft','failed') returning id into v_draft;
  if v_draft is null then select id into v_draft from public.provider_email_drafts where workspace_id=v_reminder.workspace_id and idempotency_key='payment-chase:'||v_reminder.id::text||':'||p_provider_route;end if;
  return v_draft;
end $$;
revoke all on function public.prepare_payment_chase_email(uuid,text) from public,anon;grant execute on function public.prepare_payment_chase_email(uuid,text) to authenticated;

create or replace function public.approve_managed_email_send(p_draft_id uuid,p_expected_version integer,p_confirmation boolean) returns uuid
language plpgsql security definer set search_path='' as $$
declare v_draft public.provider_email_drafts;v_latest public.gmail_messages;v_invoice public.invoices;v_reminder public.payment_reminders;v_job uuid;
begin
  if not p_confirmation then raise exception 'explicit send confirmation required' using errcode='22023';end if;
  select d.* into v_draft from public.provider_email_drafts d where d.id=p_draft_id and d.provider_route='managed_email' and d.state in('draft','failed') and d.version=p_expected_version
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=d.workspace_id and wm.user_id=auth.uid()) for update;
  if v_draft.id is null then raise exception 'draft not found or changed' using errcode='P0002';end if;
  if v_draft.purpose in('negotiation','terms_confirmation') then
    select m.* into v_latest from public.gmail_messages m join public.deal_threads t on t.id=m.deal_thread_id where t.deal_id=v_draft.deal_id and t.transport_provider='resend' and m.direction='inbound' order by m.internal_date desc limit 1;
    if v_latest.id is null or v_latest.original_sender_address is null or lower(v_draft.to_address)<>lower(v_latest.original_sender_address) then raise exception 'managed reply recipient is ambiguous' using errcode='22023';end if;
  elsif v_draft.purpose='invoice' then
    select * into v_invoice from public.invoices where id=v_draft.invoice_id and status='ready' and workspace_id=v_draft.workspace_id;
    if v_invoice.id is null or lower(v_draft.to_address)<>lower(v_invoice.accounts_payable_email) then raise exception 'invoice recipient is not confirmed' using errcode='22023';end if;
  elsif v_draft.purpose='payment_chase' then
    select r.* into v_reminder from public.payment_reminders r join public.invoices i on i.id=r.invoice_id where r.id=v_draft.payment_reminder_id and r.workspace_id=v_draft.workspace_id and r.status in('draft','failed') and i.status in('sent','query') and lower(v_draft.to_address)=lower(i.accounts_payable_email);
    if v_reminder.id is null then raise exception 'payment reminder recipient is not confirmed' using errcode='22023';end if;
    update public.payment_reminders set status='approved',creator_approved_at=now() where id=v_reminder.id;
  end if;
  update public.provider_email_drafts set state='approved',creator_approved_at=now(),updated_at=now() where id=v_draft.id;
  insert into private.managed_email_send_jobs(draft_id) values(v_draft.id) on conflict(draft_id) do update set status=case when private.managed_email_send_jobs.status='failed' then 'queued' else private.managed_email_send_jobs.status end returning id into v_job;
  perform pgmq.send('managed_email_send',jsonb_build_object('job_id',v_job));return v_job;
end $$;
revoke all on function public.approve_managed_email_send(uuid,integer,boolean) from public,anon;grant execute on function public.approve_managed_email_send(uuid,integer,boolean) to authenticated;

create or replace function public.claim_managed_email_send() returns jsonb language plpgsql security definer set search_path='' as $$
declare v_message record;v_job private.managed_email_send_jobs;v_result jsonb;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501';end if;
  if not coalesce((select enabled from private.feature_flags where key='managed_email_send_enabled'),false) then return null;end if;
  select * into v_message from pgmq.read('managed_email_send',300,1) limit 1;if v_message.msg_id is null then return null;end if;
  select * into v_job from private.managed_email_send_jobs where id=(v_message.message->>'job_id')::uuid for update;
  if v_job.status='sent' then perform pgmq.archive('managed_email_send',v_message.msg_id);return null;end if;
  if v_job.attempt_count>=3 then perform pgmq.archive('managed_email_send',v_message.msg_id);return null;end if;
  update private.managed_email_send_jobs set status='processing',attempt_count=attempt_count+1 where id=v_job.id;
  update public.provider_email_drafts set state='sending',updated_at=now() where id=v_job.draft_id;
  select jsonb_build_object('queueMessageId',v_message.msg_id,'jobId',v_job.id,'draftId',d.id,'fromAddress',a.address,'toAddress',d.to_address,'subject',d.subject,'body',d.body,'attachmentRefs',d.attachment_refs,'idempotencyKey',d.idempotency_key,'inReplyTo',m.provider_message_id,'references',coalesce(m.raw_headers->>'references','')) into v_result
  from public.provider_email_drafts d join public.creator_email_addresses a on a.workspace_id=d.workspace_id and a.is_primary and a.status='active'
  left join lateral(select gm.provider_message_id,gm.raw_headers from public.gmail_messages gm join public.deal_threads t on t.id=gm.deal_thread_id where t.deal_id=d.deal_id and t.transport_provider='resend' and gm.direction='inbound' order by gm.internal_date desc limit 1)m on true where d.id=v_job.draft_id;
  return v_result;
end $$;
revoke all on function public.claim_managed_email_send() from public,anon,authenticated;grant execute on function public.claim_managed_email_send() to service_role;

create or replace function public.finish_managed_email_send(p_queue_message_id bigint,p_job_id uuid,p_provider_message_id text,p_error_class text default null) returns void language plpgsql security definer set search_path='' as $$
declare v_attempts integer;v_success boolean:=p_provider_message_id is not null;v_draft public.provider_email_drafts;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501';end if;
  select attempt_count into v_attempts from private.managed_email_send_jobs where id=p_job_id;
  select d.* into v_draft from public.provider_email_drafts d join private.managed_email_send_jobs j on j.draft_id=d.id where j.id=p_job_id;
  update private.managed_email_send_jobs set status=case when v_success then 'sent' else 'failed' end,provider_message_id=coalesce(p_provider_message_id,provider_message_id),last_error_class=left(p_error_class,80),completed_at=case when v_success then now() else null end where id=p_job_id;
  update public.provider_email_drafts set state=case when v_success then 'sent' else 'failed' end,provider_message_id=coalesce(p_provider_message_id,provider_message_id),sent_at=case when v_success then now() else null end,updated_at=now() where id=v_draft.id;
  if v_success and v_draft.purpose='invoice' then
    update public.invoices set status='sent',sent_at=now(),updated_at=now() where id=v_draft.invoice_id and status in('ready','sending');
    update public.deals set operational_stage='payment_due',updated_at=now() where id=v_draft.deal_id;
  elsif v_success and v_draft.purpose='payment_chase' then
    update public.payment_reminders set status='sent',sent_at=now() where id=v_draft.payment_reminder_id;
  elsif not v_success and v_draft.purpose='payment_chase' then
    update public.payment_reminders set status='failed' where id=v_draft.payment_reminder_id;
  end if;
  if v_success or v_attempts>=3 then perform pgmq.archive('managed_email_send',p_queue_message_id);end if;
end $$;
revoke all on function public.finish_managed_email_send(bigint,uuid,text,text) from public,anon,authenticated;grant execute on function public.finish_managed_email_send(bigint,uuid,text,text) to service_role;

comment on function public.prepare_invoice_email(uuid,text) is 'Creates a reviewable provider-neutral invoice email. It never approves or sends.';
comment on function public.prepare_payment_chase_email(uuid,text) is 'Connects a deterministic reminder to a reviewable provider-neutral email. It never approves or sends.';

