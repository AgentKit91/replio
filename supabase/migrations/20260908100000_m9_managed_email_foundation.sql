-- M9H: dedicated creator commercial addresses transported by Resend, sharing Deal/message records with Gmail.
create table public.creator_email_addresses (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  address text not null unique, local_part text not null, domain text not null,
  status text not null default 'active' check(status in ('active','paused','retired')),
  is_primary boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(workspace_id,is_primary)
);
create index creator_email_addresses_workspace_idx on public.creator_email_addresses(workspace_id);

create table private.managed_email_events (
  id uuid primary key default gen_random_uuid(), provider_event_id text not null unique, provider_email_id text not null unique,
  status text not null default 'received' check(status in ('received','processing','completed','rejected','failed')),
  rejection_reason text, workspace_id uuid references public.workspaces(id) on delete cascade,
  message_id uuid references public.gmail_messages(id) on delete set null,
  safe_metadata jsonb not null default '{}'::jsonb, attempt_count integer not null default 0 check(attempt_count between 0 and 5),
  created_at timestamptz not null default now(), completed_at timestamptz
);
revoke all on private.managed_email_events from public,anon,authenticated;

insert into private.feature_flags(key,enabled,description) values
  ('managed_email_send_enabled',false,'Allow explicitly approved Rep Bureau managed email drafts to be claimed and sent through Resend.')
on conflict(key) do nothing;

alter table public.deals drop constraint if exists deals_created_source_check;
alter table public.deals add constraint deals_created_source_check check(created_source in ('gmail_label','managed_email'));

alter table public.deal_threads alter column gmail_connection_id drop not null;
alter table public.deal_threads add column transport_provider text not null default 'gmail' check(transport_provider in ('gmail','resend'));
alter table public.deal_threads add column creator_email_address_id uuid references public.creator_email_addresses(id) on delete restrict;
alter table public.deal_threads add constraint deal_threads_transport_check check(
  (transport_provider='gmail' and gmail_connection_id is not null and creator_email_address_id is null) or
  (transport_provider='resend' and gmail_connection_id is null and creator_email_address_id is not null)
) not valid;
alter table public.deal_threads validate constraint deal_threads_transport_check;

alter table public.gmail_messages add column transport_provider text not null default 'gmail' check(transport_provider in ('gmail','resend'));
alter table public.gmail_messages add column reply_to_addresses text[] not null default '{}';
alter table public.gmail_messages add column original_sender_address text;
alter table public.gmail_messages add column forwarded_by_address text;
alter table public.gmail_messages add column ingestion_fingerprint text;
alter table public.gmail_messages add column provider_received_email_id text;
create unique index gmail_messages_transport_provider_id_idx on public.gmail_messages(workspace_id,transport_provider,provider_message_id);
create unique index gmail_messages_ingestion_fingerprint_idx on public.gmail_messages(workspace_id,ingestion_fingerprint) where ingestion_fingerprint is not null;

create or replace function public.persist_gmail_thread(p_workspace_id uuid,p_gmail_connection_id uuid,p_provider_thread_id text,p_title text,p_messages jsonb)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_deal_id uuid;v_thread_id uuid;v_message jsonb;v_message_id uuid;v_attachment jsonb;v_latest_inbound timestamptz;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501';end if;
  if not exists(select 1 from public.gmail_connections where id=p_gmail_connection_id and workspace_id=p_workspace_id and watch_status='active') then raise exception 'active workspace Gmail connection required' using errcode='42501';end if;
  select deal_id,id into v_deal_id,v_thread_id from public.deal_threads where workspace_id=p_workspace_id and transport_provider='gmail' and provider_thread_id=p_provider_thread_id;
  if v_thread_id is null then insert into public.deals(workspace_id,title) values(p_workspace_id,coalesce(nullif(p_title,''),'Untitled Gmail conversation')) returning id into v_deal_id;
    insert into public.deal_threads(workspace_id,deal_id,gmail_connection_id,provider_thread_id,transport_provider) values(p_workspace_id,v_deal_id,p_gmail_connection_id,p_provider_thread_id,'gmail') returning id into v_thread_id;end if;
  for v_message in select value from jsonb_array_elements(p_messages) loop
    select id into v_message_id from public.gmail_messages where workspace_id=p_workspace_id and transport_provider='gmail' and provider_message_id=v_message->>'provider_message_id';
    if v_message_id is not null then update public.gmail_messages set provider_history_id=nullif(v_message->>'provider_history_id','')::numeric,body_text=coalesce(v_message->>'body_text',''),body_html_sanitized=v_message->>'body_html_sanitized',provider_label_ids=coalesce(array(select jsonb_array_elements_text(v_message->'provider_label_ids')),'{}'),raw_headers=coalesce(v_message->'raw_headers','{}'::jsonb),updated_at=now() where id=v_message_id;
    else insert into public.gmail_messages(workspace_id,deal_thread_id,provider_message_id,provider_thread_id,provider_history_id,internal_date,direction,from_address,to_addresses,cc_addresses,subject,body_text,body_html_sanitized,provider_label_ids,raw_headers,transport_provider,reply_to_addresses,original_sender_address,forwarded_by_address,ingestion_fingerprint)
      values(p_workspace_id,v_thread_id,v_message->>'provider_message_id',p_provider_thread_id,nullif(v_message->>'provider_history_id','')::numeric,(v_message->>'internal_date')::timestamptz,v_message->>'direction',v_message->>'from_address',coalesce(array(select jsonb_array_elements_text(v_message->'to_addresses')),'{}'),coalesce(array(select jsonb_array_elements_text(v_message->'cc_addresses')),'{}'),coalesce(v_message->>'subject',''),coalesce(v_message->>'body_text',''),v_message->>'body_html_sanitized',coalesce(array(select jsonb_array_elements_text(v_message->'provider_label_ids')),'{}'),coalesce(v_message->'raw_headers','{}'::jsonb),'gmail',coalesce(array(select jsonb_array_elements_text(v_message->'reply_to_addresses')),'{}'),v_message->>'original_sender_address',v_message->>'forwarded_by_address',v_message->>'ingestion_fingerprint')
      on conflict(workspace_id,ingestion_fingerprint) where ingestion_fingerprint is not null do update set updated_at=now() returning id into v_message_id;end if;
    if v_message->>'direction'='inbound' then v_latest_inbound:=greatest(coalesce(v_latest_inbound,'-infinity'::timestamptz),(v_message->>'internal_date')::timestamptz);end if;
    for v_attachment in select value from jsonb_array_elements(coalesce(v_message->'attachments','[]'::jsonb)) loop insert into public.gmail_attachment_references(workspace_id,gmail_message_id,provider_attachment_id,filename,mime_type,size_bytes) values(p_workspace_id,v_message_id,v_attachment->>'provider_attachment_id',v_attachment->>'filename',v_attachment->>'mime_type',nullif(v_attachment->>'size_bytes','')::bigint) on conflict(gmail_message_id,provider_attachment_id) do update set filename=excluded.filename,mime_type=excluded.mime_type,size_bytes=excluded.size_bytes;end loop;
  end loop;
  if exists(select 1 from public.reply_drafts where deal_id=v_deal_id and sent_at<v_latest_inbound) then update public.deals set status='awaiting_creator',human_status_code='your_reply_needed',updated_at=now() where id=v_deal_id and status='awaiting_brand';end if;
  return v_deal_id;
end $$;
revoke all on function public.persist_gmail_thread(uuid,uuid,text,text,jsonb) from public,anon,authenticated;grant execute on function public.persist_gmail_thread(uuid,uuid,text,text,jsonb) to service_role;

alter table public.gmail_attachment_references add column transport_provider text not null default 'gmail' check(transport_provider in ('gmail','resend'));
alter table public.gmail_attachment_references add column private_storage_path text;
alter table public.gmail_attachment_references add column safety_status text not null default 'metadata_only' check(safety_status in ('metadata_only','quarantined','safe','blocked'));

alter table public.creator_email_addresses enable row level security;
revoke all on public.creator_email_addresses from anon,authenticated;
grant select on public.creator_email_addresses to authenticated;
create policy creator_email_addresses_member_select on public.creator_email_addresses for select to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_email_addresses.workspace_id and wm.user_id=(select auth.uid())));

create or replace function public.allocate_creator_email_address(p_domain text) returns text language plpgsql security definer set search_path='' as $$
declare v_workspace uuid; v_name text; v_base text; v_local text; v_address text; v_existing text; v_try integer:=0;
begin
  if p_domain is null or lower(p_domain)!~'^[a-z0-9.-]+\.[a-z]{2,}$' then raise exception 'invalid managed email domain' using errcode='22023'; end if;
  select wm.workspace_id,cp.creator_name into v_workspace,v_name from public.workspace_members wm join public.creator_profiles cp on cp.workspace_id=wm.workspace_id where wm.user_id=auth.uid();
  if v_workspace is null then raise exception 'workspace not found' using errcode='P0002'; end if;
  select address into v_existing from public.creator_email_addresses where workspace_id=v_workspace and is_primary;
  if v_existing is not null then return v_existing; end if;
  v_base:=trim(both '-' from regexp_replace(lower(coalesce(nullif(v_name,''),'creator')),'[^a-z0-9]+','-','g')); if v_base='' then v_base:='creator'; end if; v_base:=left(v_base,30);
  loop v_try:=v_try+1; v_local:=v_base||'-'||substr(encode(extensions.digest(v_workspace::text||':'||v_try::text,'sha256'),'hex'),1,6); v_address:=v_local||'@'||lower(p_domain);
    begin insert into public.creator_email_addresses(workspace_id,address,local_part,domain) values(v_workspace,v_address,v_local,lower(p_domain)); return v_address;
    exception when unique_violation then if v_try>=5 then raise; end if; end;
  end loop;
end $$;
revoke all on function public.allocate_creator_email_address(text) from public,anon; grant execute on function public.allocate_creator_email_address(text) to authenticated;

create or replace function public.ingest_managed_email(
  p_provider_event_id text,p_provider_email_id text,p_message_id text,p_from text,p_to text[],p_cc text[],p_reply_to text[],p_subject text,p_body_text text,p_body_html text,
  p_received_at timestamptz,p_headers jsonb,p_original_sender text,p_forwarded_by text,p_fingerprint text
) returns uuid language plpgsql security definer set search_path='' as $$
declare v_event private.managed_email_events; v_address public.creator_email_addresses; v_thread public.deal_threads; v_deal uuid; v_message uuid; v_recipient text; v_matches integer;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  insert into private.managed_email_events(provider_event_id,provider_email_id,safe_metadata) values(p_provider_event_id,p_provider_email_id,jsonb_build_object('recipientCount',coalesce(array_length(p_to,1),0),'hasAttachments',false)) on conflict do nothing;
  select * into v_event from private.managed_email_events where provider_event_id=p_provider_event_id or provider_email_id=p_provider_email_id order by created_at limit 1 for update;
  if v_event.status='completed' then return v_event.message_id; end if;
  select count(*),min(lower(t)) into v_matches,v_recipient from unnest(p_to) t join public.creator_email_addresses a on lower(a.address)=lower(t) and a.status='active';
  if v_matches<>1 then update private.managed_email_events set status='rejected',rejection_reason='ambiguous_or_unknown_destination',completed_at=now() where id=v_event.id; return null; end if;
  select * into v_address from public.creator_email_addresses where lower(address)=v_recipient and status='active';
  if (select count(*) from public.gmail_messages where workspace_id=v_address.workspace_id and transport_provider='resend' and created_at>now()-interval '1 hour')>=50 then update private.managed_email_events set status='rejected',rejection_reason='inbound_rate_limit',completed_at=now() where id=v_event.id; return null; end if;
  select t.* into v_thread from public.deal_threads t where t.workspace_id=v_address.workspace_id and t.transport_provider='resend' and t.provider_thread_id=coalesce(nullif(p_headers->>'thread-id',''),p_message_id) limit 1;
  if v_thread.id is null then
    insert into public.deals(workspace_id,title,status,created_source,operational_stage) values(v_address.workspace_id,coalesce(nullif(trim(p_subject),''),'New commercial enquiry'),'new','managed_email','enquiry') returning id into v_deal;
    insert into public.deal_threads(workspace_id,deal_id,gmail_connection_id,provider_thread_id,thread_role,transport_provider,creator_email_address_id)
    values(v_address.workspace_id,v_deal,null,coalesce(nullif(p_headers->>'thread-id',''),p_message_id),'primary','resend',v_address.id) returning * into v_thread;
  end if;
  insert into public.gmail_messages(workspace_id,deal_thread_id,provider_message_id,provider_thread_id,internal_date,direction,from_address,to_addresses,cc_addresses,subject,body_text,body_html_sanitized,raw_headers,transport_provider,reply_to_addresses,original_sender_address,forwarded_by_address,ingestion_fingerprint,provider_received_email_id)
  values(v_address.workspace_id,v_thread.id,p_message_id,v_thread.provider_thread_id,p_received_at,'inbound',p_from,p_to,p_cc,coalesce(p_subject,''),left(coalesce(p_body_text,''),200000),p_body_html,p_headers,'resend',p_reply_to,p_original_sender,p_forwarded_by,p_fingerprint,p_provider_email_id)
  on conflict(workspace_id,ingestion_fingerprint) where ingestion_fingerprint is not null do nothing returning id into v_message;
  if v_message is null then select id into v_message from public.gmail_messages where workspace_id=v_address.workspace_id and (ingestion_fingerprint=p_fingerprint or (transport_provider='resend' and provider_message_id=p_message_id)) limit 1; end if;
  update private.managed_email_events set status='completed',workspace_id=v_address.workspace_id,message_id=v_message,completed_at=now() where id=v_event.id;
  update public.deals set status=case when status in ('awaiting_brand','negotiating') then 'awaiting_creator' else status end,updated_at=now() where id=v_thread.deal_id;
  return v_message;
exception when others then update private.managed_email_events set status='failed',attempt_count=least(attempt_count+1,5),rejection_reason=left(sqlstate,80) where id=v_event.id; raise;
end $$;
revoke all on function public.ingest_managed_email(text,text,text,text,text[],text[],text[],text,text,text,timestamptz,jsonb,text,text,text) from public,anon,authenticated;
grant execute on function public.ingest_managed_email(text,text,text,text,text[],text[],text[],text,text,text,timestamptz,jsonb,text,text,text) to service_role;

comment on table public.creator_email_addresses is 'Rep Bureau allocates creator addresses; Resend is transport, not per-creator mailbox identity.';
comment on column public.gmail_messages.original_sender_address is 'Safe reply target for forwarded mail; null means fail closed rather than reply to the forwarding creator.';

create table private.managed_email_send_jobs(
  id uuid primary key default gen_random_uuid(),draft_id uuid not null unique references public.provider_email_drafts(id) on delete cascade,
  status text not null default 'queued' check(status in ('queued','processing','sent','failed')),attempt_count integer not null default 0 check(attempt_count between 0 and 3),
  provider_message_id text,last_error_class text,created_at timestamptz not null default now(),completed_at timestamptz
);
revoke all on private.managed_email_send_jobs from public,anon,authenticated;
select pgmq.create('managed_email_send');

create or replace function public.approve_managed_email_send(p_draft_id uuid,p_expected_version integer,p_confirmation boolean) returns uuid language plpgsql security definer set search_path='' as $$
declare v_draft public.provider_email_drafts;v_latest public.gmail_messages;v_job uuid;
begin
  if not p_confirmation then raise exception 'explicit send confirmation required' using errcode='22023'; end if;
  select d.* into v_draft from public.provider_email_drafts d where d.id=p_draft_id and d.provider_route='managed_email' and d.state='draft' and d.version=p_expected_version
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=d.workspace_id and wm.user_id=auth.uid()) for update;
  if v_draft.id is null then raise exception 'draft not found or changed' using errcode='P0002'; end if;
  select m.* into v_latest from public.gmail_messages m join public.deal_threads t on t.id=m.deal_thread_id where t.deal_id=v_draft.deal_id and t.transport_provider='resend' and m.direction='inbound' order by m.internal_date desc limit 1;
  if v_latest.id is null or v_latest.original_sender_address is null or lower(v_draft.to_address)<>lower(v_latest.original_sender_address) then raise exception 'managed reply recipient is ambiguous' using errcode='22023'; end if;
  update public.provider_email_drafts set state='approved',creator_approved_at=now(),updated_at=now() where id=v_draft.id;
  insert into private.managed_email_send_jobs(draft_id) values(v_draft.id) on conflict(draft_id) do update set status=case when private.managed_email_send_jobs.status='failed' then 'queued' else private.managed_email_send_jobs.status end returning id into v_job;
  perform pgmq.send('managed_email_send',jsonb_build_object('job_id',v_job));return v_job;
end $$;
revoke all on function public.approve_managed_email_send(uuid,integer,boolean) from public,anon;grant execute on function public.approve_managed_email_send(uuid,integer,boolean) to authenticated;

create or replace function public.claim_managed_email_send() returns jsonb language plpgsql security definer set search_path='' as $$
declare v_message record;v_job private.managed_email_send_jobs;v_result jsonb;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not coalesce((select enabled from private.feature_flags where key='managed_email_send_enabled'),false) then return null; end if;
  select * into v_message from pgmq.read('managed_email_send',300,1) limit 1;if v_message.msg_id is null then return null;end if;
  select * into v_job from private.managed_email_send_jobs where id=(v_message.message->>'job_id')::uuid for update;
  if v_job.status='sent' then perform pgmq.archive('managed_email_send',v_message.msg_id);return null;end if;
  if v_job.attempt_count>=3 then perform pgmq.archive('managed_email_send',v_message.msg_id);return null;end if;
  update private.managed_email_send_jobs set status='processing',attempt_count=attempt_count+1 where id=v_job.id;
  update public.provider_email_drafts set state='sending',updated_at=now() where id=v_job.draft_id;
  select jsonb_build_object('queueMessageId',v_message.msg_id,'jobId',v_job.id,'draftId',d.id,'fromAddress',a.address,'toAddress',d.to_address,'subject',d.subject,'body',d.body,'idempotencyKey',d.idempotency_key,'inReplyTo',m.provider_message_id,'references',coalesce(m.raw_headers->>'references','')) into v_result
  from public.provider_email_drafts d join public.creator_email_addresses a on a.workspace_id=d.workspace_id and a.is_primary and a.status='active'
  join lateral(select gm.provider_message_id,gm.raw_headers from public.gmail_messages gm join public.deal_threads t on t.id=gm.deal_thread_id where t.deal_id=d.deal_id and t.transport_provider='resend' and gm.direction='inbound' order by gm.internal_date desc limit 1)m on true where d.id=v_job.draft_id;
  return v_result;
end $$;
revoke all on function public.claim_managed_email_send() from public,anon,authenticated;grant execute on function public.claim_managed_email_send() to service_role;

create or replace function public.finish_managed_email_send(p_queue_message_id bigint,p_job_id uuid,p_provider_message_id text,p_error_class text default null) returns void language plpgsql security definer set search_path='' as $$
declare v_attempts integer;v_success boolean:=p_provider_message_id is not null;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501';end if;
  select attempt_count into v_attempts from private.managed_email_send_jobs where id=p_job_id;
  update private.managed_email_send_jobs set status=case when v_success then 'sent' else 'failed' end,provider_message_id=coalesce(p_provider_message_id,provider_message_id),last_error_class=left(p_error_class,80),completed_at=case when v_success then now() else null end where id=p_job_id;
  update public.provider_email_drafts set state=case when v_success then 'sent' else 'failed' end,provider_message_id=coalesce(p_provider_message_id,provider_message_id),sent_at=case when v_success then now() else null end,updated_at=now() where id=(select draft_id from private.managed_email_send_jobs where id=p_job_id);
  if v_success or v_attempts>=3 then perform pgmq.archive('managed_email_send',p_queue_message_id);end if;
end $$;
revoke all on function public.finish_managed_email_send(bigint,uuid,text,text) from public,anon,authenticated;grant execute on function public.finish_managed_email_send(bigint,uuid,text,text) to service_role;

create or replace function private.invoke_managed_email_send_worker() returns bigint language plpgsql security definer set search_path=pg_catalog,private as $$
declare worker_secret text;request_id bigint;begin
if not coalesce((select enabled from private.feature_flags where key='managed_email_send_enabled'),false) then return null;end if;
select decrypted_secret into worker_secret from vault.decrypted_secrets where name='internal_job_secret';if worker_secret is null then return null;end if;
select net.http_post(url:='https://replio-three.vercel.app/api/internal/workers/managed-email-send',headers:=jsonb_build_object('Content-Type','application/json','Authorization','Bearer '||worker_secret),body:='{}'::jsonb,timeout_milliseconds:=30000) into request_id;return request_id;end $$;
revoke all on function private.invoke_managed_email_send_worker() from public,anon,authenticated;
select cron.schedule('rep-bureau-managed-email-send-worker','* * * * *','select private.invoke_managed_email_send_worker();');

