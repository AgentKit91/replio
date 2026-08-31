create table private.gmail_send_jobs (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  reply_draft_id uuid not null references public.reply_drafts(id) on delete cascade, reply_version integer not null check(reply_version>0),
  idempotency_key text not null unique, rfc822_message_id text not null unique,
  status text not null default 'queued' check(status in ('queued','processing','sent','failed')),
  attempt_count integer not null default 0 check(attempt_count>=0), provider_message_id text, last_error_class text,
  created_at timestamptz not null default now(), completed_at timestamptz, unique(reply_draft_id,reply_version)
);
revoke all on private.gmail_send_jobs from public,anon,authenticated;
select pgmq.create('gmail_send');

create or replace function public.request_reply_send(p_deal_id uuid,p_expected_version integer) returns uuid language plpgsql security definer set search_path='' as $$
declare v_draft public.reply_drafts; v_job_id uuid; v_key text; v_message_id text;
begin
  select rd.* into v_draft from public.reply_drafts rd join public.workspace_members wm on wm.workspace_id=rd.workspace_id where rd.deal_id=p_deal_id and wm.user_id=auth.uid() for update of rd;
  if v_draft.id is null then raise exception 'reply draft not found' using errcode='P0002'; end if;
  if v_draft.version<>p_expected_version then raise exception 'reply version conflict' using errcode='40001'; end if;
  select id into v_job_id from private.gmail_send_jobs where reply_draft_id=v_draft.id and reply_version=v_draft.version;
  if v_draft.state in ('sending','sent') and v_job_id is not null then return v_job_id; end if;
  if v_draft.state<>'draft' then raise exception 'reply is already being sent' using errcode='55000'; end if;
  if btrim(v_draft.body)='' then raise exception 'reply body is empty' using errcode='22023'; end if;
  v_key:=encode(extensions.digest(v_draft.id::text||':'||v_draft.version::text||':'||v_draft.subject||':'||v_draft.body,'sha256'),'hex');
  v_message_id:='<replio-'||v_draft.id::text||'-v'||v_draft.version::text||'@replio.app>';
  insert into private.gmail_send_jobs(workspace_id,reply_draft_id,reply_version,idempotency_key,rfc822_message_id) values(v_draft.workspace_id,v_draft.id,v_draft.version,v_key,v_message_id)
    on conflict(reply_draft_id,reply_version) do update set idempotency_key=private.gmail_send_jobs.idempotency_key returning id into v_job_id;
  update public.reply_drafts set state='sending',updated_at=now() where id=v_draft.id;
  if not exists(select 1 from pgmq.q_gmail_send q where (q.message->>'job_id')::uuid=v_job_id) then perform pgmq.send('gmail_send',jsonb_build_object('job_id',v_job_id)); end if;
  return v_job_id;
end $$;
revoke all on function public.request_reply_send(uuid,integer) from public,anon; grant execute on function public.request_reply_send(uuid,integer) to authenticated;

create or replace function public.claim_gmail_send() returns jsonb language plpgsql security definer set search_path='' as $$
declare v_message record; v_job private.gmail_send_jobs; v_result jsonb;
begin
  if coalesce((select auth.jwt()->>'role'),'')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  select * into v_message from pgmq.read('gmail_send',300,1) limit 1; if v_message.msg_id is null then return null; end if;
  select * into v_job from private.gmail_send_jobs where id=(v_message.message->>'job_id')::uuid for update;
  if v_job.status='sent' then perform pgmq.archive('gmail_send',v_message.msg_id); return null; end if;
  update private.gmail_send_jobs set status='processing',attempt_count=attempt_count+1 where id=v_job.id;
  select jsonb_build_object('queue_message_id',v_message.msg_id,'job_id',v_job.id,'reply_draft_id',rd.id,'reply_version',rd.version,'rfc822_message_id',v_job.rfc822_message_id,
    'from_address',gc.gmail_email_address,'to_address',latest.from_address,'subject',latest.subject,'body',rd.body,'provider_thread_id',dt.provider_thread_id,
    'in_reply_to',(select value from jsonb_each_text(latest.raw_headers) where lower(key)='message-id' limit 1),'references',(select value from jsonb_each_text(latest.raw_headers) where lower(key)='references' limit 1),'encrypted_refresh_token',tok.encrypted_refresh_token,
    'encryption_iv',tok.encryption_iv,'encryption_auth_tag',tok.encryption_auth_tag,'key_version',tok.key_version)
  into v_result from public.reply_drafts rd join public.deal_threads dt on dt.id=rd.deal_thread_id join public.gmail_connections gc on gc.id=dt.gmail_connection_id
    join private.gmail_oauth_tokens tok on tok.gmail_connection_id=gc.id
    join lateral(select m.from_address,m.subject,m.raw_headers from public.gmail_messages m where m.deal_thread_id=dt.id and m.direction='inbound' order by m.internal_date desc limit 1) latest on true
    where rd.id=v_job.reply_draft_id;
  if v_result is null or coalesce(v_result->>'in_reply_to','')='' then raise exception 'thread has no RFC Message-ID' using errcode='22023'; end if;
  return v_result;
end $$;
revoke all on function public.claim_gmail_send() from public,anon,authenticated; grant execute on function public.claim_gmail_send() to service_role;

create or replace function public.finish_gmail_send(p_queue_message_id bigint,p_job_id uuid,p_provider_message_id text) returns void language plpgsql security definer set search_path='' as $$
begin
  if coalesce((select auth.jwt()->>'role'),'')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  update private.gmail_send_jobs set status='sent',provider_message_id=p_provider_message_id,completed_at=now(),last_error_class=null where id=p_job_id;
  update public.reply_drafts set state='sent',provider_message_id=p_provider_message_id,sent_at=now(),updated_at=now() where id=(select reply_draft_id from private.gmail_send_jobs where id=p_job_id);
  perform pgmq.archive('gmail_send',p_queue_message_id);
end $$;
revoke all on function public.finish_gmail_send(bigint,uuid,text) from public,anon,authenticated; grant execute on function public.finish_gmail_send(bigint,uuid,text) to service_role;

create or replace function public.fail_gmail_send(p_queue_message_id bigint,p_job_id uuid,p_error_class text) returns void language plpgsql security definer set search_path='' as $$
declare v_attempts integer; v_terminal boolean;
begin
  if coalesce((select auth.jwt()->>'role'),'')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  select attempt_count into v_attempts from private.gmail_send_jobs where id=p_job_id; v_terminal:=coalesce(v_attempts,0)>=3;
  update private.gmail_send_jobs set status=case when v_terminal then 'failed' else 'queued' end,last_error_class=left(p_error_class,80),completed_at=case when v_terminal then now() else null end where id=p_job_id;
  if v_terminal then update public.reply_drafts set state='draft',updated_at=now() where id=(select reply_draft_id from private.gmail_send_jobs where id=p_job_id); perform pgmq.archive('gmail_send',p_queue_message_id); end if;
end $$;
revoke all on function public.fail_gmail_send(bigint,uuid,text) from public,anon,authenticated; grant execute on function public.fail_gmail_send(bigint,uuid,text) to service_role;

create or replace function private.invoke_gmail_send_worker() returns bigint language plpgsql security definer set search_path=pg_catalog,private as $$
declare worker_secret text; request_id bigint;
begin
  select decrypted_secret into worker_secret from vault.decrypted_secrets where name='internal_job_secret'; if worker_secret is null then return null; end if;
  select net.http_post(url:='https://replio-three.vercel.app/api/internal/workers/gmail-send',headers:=jsonb_build_object('Content-Type','application/json','Authorization','Bearer '||worker_secret),body:='{}'::jsonb,timeout_milliseconds:=30000) into request_id; return request_id;
end $$;
revoke all on function private.invoke_gmail_send_worker() from public,anon,authenticated;
select cron.schedule('replio-gmail-send-worker','* * * * *','select private.invoke_gmail_send_worker();');
