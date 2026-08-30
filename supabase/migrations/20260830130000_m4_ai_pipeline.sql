create type public.analysis_state as enum ('queued','running','partial','completed','failed');
create type public.worker_run_state as enum ('running','completed','failed','skipped');

create table public.knowledge_documents (
  id uuid primary key default gen_random_uuid(), slug text not null unique, title text not null,
  trust_tier text not null check (trust_tier in ('primary','expert','editorial','fixture')),
  is_production_approved boolean not null default false, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  constraint fixture_not_production check (trust_tier <> 'fixture' or not is_production_approved)
);
create table public.knowledge_versions (
  id uuid primary key default gen_random_uuid(), document_id uuid not null references public.knowledge_documents(id) on delete cascade,
  version integer not null check (version > 0), state text not null check (state in ('draft','current','deprecated','archived')),
  source_url text, author text, change_summary text not null, content text not null, effective_at timestamptz,
  created_at timestamptz not null default now(), unique(document_id,version)
);
create table public.analysis_snapshots (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null references public.deals(id) on delete cascade, input_snapshot_hash text not null,
  schema_version integer not null default 1 check (schema_version > 0), state public.analysis_state not null default 'queued',
  is_current boolean not null default false, structured_output jsonb not null default '{}'::jsonb,
  score integer check (score between 0 and 100), score_version_id uuid, failure_class text,
  created_at timestamptz not null default now(), completed_at timestamptz,
  unique(deal_id,input_snapshot_hash)
);
create unique index analysis_snapshots_one_current_idx on public.analysis_snapshots(deal_id) where is_current;
create index analysis_snapshots_workspace_created_idx on public.analysis_snapshots(workspace_id,created_at desc);
create table public.analysis_facts (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  snapshot_id uuid not null references public.analysis_snapshots(id) on delete cascade, deal_id uuid not null references public.deals(id) on delete cascade,
  fact_type text not null, normalized_value jsonb not null, display_value text,
  fact_state text not null check (fact_state in ('confirmed','missing','inferred')), confidence numeric(4,3) check (confidence between 0 and 1),
  source_owner text not null check (source_owner in ('ai_extraction','user','imported')),
  evidence jsonb not null default '[]'::jsonb, created_at timestamptz not null default now()
);
create index analysis_facts_snapshot_idx on public.analysis_facts(snapshot_id);
create table public.ai_worker_runs (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  snapshot_id uuid not null references public.analysis_snapshots(id) on delete cascade, worker_name text not null,
  worker_version integer not null default 1, provider text, model_id text, input_hash text not null,
  output_schema_version integer not null default 1, state public.worker_run_state not null default 'running', confidence numeric(4,3),
  input_tokens integer check (input_tokens is null or input_tokens >= 0), output_tokens integer check (output_tokens is null or output_tokens >= 0),
  estimated_cost_microunits bigint check (estimated_cost_microunits is null or estimated_cost_microunits >= 0), latency_ms integer check (latency_ms is null or latency_ms >= 0),
  retry_count integer not null default 0 check (retry_count >= 0), error_class text, output jsonb,
  started_at timestamptz not null default now(), completed_at timestamptz,
  unique(snapshot_id,worker_name,worker_version)
);
create index ai_worker_runs_workspace_started_idx on public.ai_worker_runs(workspace_id,started_at desc);
create table public.analysis_knowledge_versions (
  snapshot_id uuid not null references public.analysis_snapshots(id) on delete cascade,
  knowledge_version_id uuid not null references public.knowledge_versions(id) on delete restrict,
  primary key(snapshot_id,knowledge_version_id)
);
create table private.ai_analysis_jobs (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null references public.deals(id) on delete cascade, snapshot_id uuid not null unique references public.analysis_snapshots(id) on delete cascade,
  status text not null default 'queued' check (status in ('queued','processing','completed','failed')),
  attempt_count integer not null default 0, last_error_class text, created_at timestamptz not null default now(), completed_at timestamptz
);
revoke all on private.ai_analysis_jobs from public,anon,authenticated;
select pgmq.create('ai_analysis');

alter table public.knowledge_documents enable row level security; alter table public.knowledge_versions enable row level security;
alter table public.analysis_snapshots enable row level security; alter table public.analysis_facts enable row level security;
alter table public.ai_worker_runs enable row level security; alter table public.analysis_knowledge_versions enable row level security;
revoke all on public.knowledge_documents,public.knowledge_versions,public.analysis_snapshots,public.analysis_facts,public.ai_worker_runs,public.analysis_knowledge_versions from anon,authenticated;
grant select on public.analysis_snapshots,public.analysis_facts,public.ai_worker_runs,public.analysis_knowledge_versions to authenticated;
create policy analysis_snapshots_select_member on public.analysis_snapshots for select to authenticated using (exists(select 1 from public.workspace_members wm where wm.workspace_id=analysis_snapshots.workspace_id and wm.user_id=(select auth.uid())));
create policy analysis_facts_select_member on public.analysis_facts for select to authenticated using (exists(select 1 from public.workspace_members wm where wm.workspace_id=analysis_facts.workspace_id and wm.user_id=(select auth.uid())));
create policy ai_worker_runs_select_member on public.ai_worker_runs for select to authenticated using (exists(select 1 from public.workspace_members wm where wm.workspace_id=ai_worker_runs.workspace_id and wm.user_id=(select auth.uid())));
create policy analysis_knowledge_versions_select_member on public.analysis_knowledge_versions for select to authenticated using (exists(select 1 from public.analysis_snapshots s join public.workspace_members wm on wm.workspace_id=s.workspace_id where s.id=analysis_knowledge_versions.snapshot_id and wm.user_id=(select auth.uid())));

create or replace function public.request_deal_analysis(p_deal_id uuid) returns uuid language plpgsql security definer set search_path='' as $$
declare v_workspace_id uuid; v_hash text; v_snapshot_id uuid; v_job_id uuid; v_job_status text; v_should_enqueue boolean:=false;
begin
  select workspace_id into v_workspace_id from public.deals d where d.id=p_deal_id and d.deleted_at is null
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=d.workspace_id and wm.user_id=auth.uid());
  if v_workspace_id is null then raise exception 'deal not found' using errcode='P0002'; end if;
  select encode(extensions.digest(coalesce(string_agg(m.id::text||':'||m.updated_at::text||':'||m.body_text,E'\n' order by m.internal_date),''),'sha256'),'hex') into v_hash
    from public.deal_threads t left join public.gmail_messages m on m.deal_thread_id=t.id where t.deal_id=p_deal_id;
  insert into public.analysis_snapshots(workspace_id,deal_id,input_snapshot_hash,state) values(v_workspace_id,p_deal_id,v_hash,'queued')
    on conflict(deal_id,input_snapshot_hash) do update set state=case when public.analysis_snapshots.state='failed' then 'queued'::public.analysis_state else public.analysis_snapshots.state end
    returning id into v_snapshot_id;
  select id,status into v_job_id,v_job_status from private.ai_analysis_jobs where snapshot_id=v_snapshot_id;
  if v_job_id is null then insert into private.ai_analysis_jobs(workspace_id,deal_id,snapshot_id) values(v_workspace_id,p_deal_id,v_snapshot_id) returning id into v_job_id; v_should_enqueue:=true;
  elsif v_job_status='failed' then update private.ai_analysis_jobs set status='queued',last_error_class=null where id=v_job_id; v_should_enqueue:=true; end if;
  if v_should_enqueue then perform pgmq.send('ai_analysis',jsonb_build_object('job_id',v_job_id)); end if;
  return v_snapshot_id;
end $$;
revoke all on function public.request_deal_analysis(uuid) from public,anon; grant execute on function public.request_deal_analysis(uuid) to authenticated;

create or replace function public.claim_ai_analysis() returns jsonb language plpgsql security definer set search_path='' as $$
declare v_message record; v_result jsonb;
begin
  if auth.role()<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  select * into v_message from pgmq.read('ai_analysis',300,1) limit 1; if v_message.msg_id is null then return null; end if;
  update private.ai_analysis_jobs set status='processing',attempt_count=attempt_count+1 where id=(v_message.message->>'job_id')::uuid;
  update public.analysis_snapshots set state='running' where id=(select snapshot_id from private.ai_analysis_jobs where id=(v_message.message->>'job_id')::uuid);
  select jsonb_build_object('queue_message_id',v_message.msg_id,'job_id',j.id,'snapshot_id',j.snapshot_id,'workspace_id',j.workspace_id,'deal_id',j.deal_id,
    'messages',coalesce((select jsonb_agg(jsonb_build_object('id',m.id,'direction',m.direction,'subject',m.subject,'body_text',m.body_text,'internal_date',m.internal_date) order by m.internal_date) from public.deal_threads t join public.gmail_messages m on m.deal_thread_id=t.id where t.deal_id=j.deal_id),'[]'::jsonb))
  into v_result from private.ai_analysis_jobs j where j.id=(v_message.message->>'job_id')::uuid; return v_result;
end $$;
revoke all on function public.claim_ai_analysis() from public,anon,authenticated; grant execute on function public.claim_ai_analysis() to service_role;

create or replace function public.finish_ai_analysis(p_queue_message_id bigint,p_job_id uuid,p_success boolean,p_error_class text default null) returns void language plpgsql security definer set search_path='' as $$
begin
  if auth.role()<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  update private.ai_analysis_jobs set status=case when p_success then 'completed' else 'failed' end,last_error_class=left(p_error_class,80),completed_at=case when p_success then now() else null end where id=p_job_id;
  if p_success then update public.analysis_snapshots set is_current=false where deal_id=(select deal_id from private.ai_analysis_jobs where id=p_job_id); end if;
  update public.analysis_snapshots set state=case when p_success then 'completed'::public.analysis_state else 'failed'::public.analysis_state end,is_current=p_success,failure_class=left(p_error_class,80),completed_at=case when p_success then now() else null end where id=(select snapshot_id from private.ai_analysis_jobs where id=p_job_id);
  if p_success then perform pgmq.archive('ai_analysis',p_queue_message_id); end if;
end $$;
revoke all on function public.finish_ai_analysis(bigint,uuid,boolean,text) from public,anon,authenticated; grant execute on function public.finish_ai_analysis(bigint,uuid,boolean,text) to service_role;

comment on table public.ai_worker_runs is 'Operational structured outputs and usage only. Prompts and chain-of-thought are never stored.';

create or replace function private.invoke_ai_analysis_worker() returns bigint language plpgsql security definer set search_path=pg_catalog,private as $$
declare worker_secret text; request_id bigint;
begin
  select decrypted_secret into worker_secret from vault.decrypted_secrets where name='internal_job_secret'; if worker_secret is null then return null; end if;
  select net.http_post(url:='https://replio-three.vercel.app/api/internal/workers/ai-analysis',headers:=jsonb_build_object('Content-Type','application/json','Authorization','Bearer '||worker_secret),body:='{}'::jsonb,timeout_milliseconds:=60000) into request_id;
  return request_id;
end $$;
revoke all on function private.invoke_ai_analysis_worker() from public,anon,authenticated;
select cron.schedule('replio-ai-analysis-worker','* * * * *','select private.invoke_ai_analysis_worker();');
