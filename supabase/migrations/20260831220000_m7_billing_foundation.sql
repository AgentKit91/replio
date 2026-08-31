create table public.plan_catalog(
  plan_key text primary key,
  display_name text not null,
  monthly_price_minor integer not null check(monthly_price_minor>=0),
  currency char(3) not null,
  trial_days integer not null default 30 check(trial_days>=0),
  publicly_visible boolean not null default false,
  active boolean not null default true,
  stripe_price_id text unique,
  created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
create table public.plan_entitlements(
  plan_key text primary key references public.plan_catalog(plan_key) on delete cascade,
  analysis_limit integer check(analysis_limit is null or analysis_limit>=0),
  priority_class text not null check(priority_class in ('standard','priority','reserved')),
  features jsonb not null default '{}'::jsonb
);
insert into public.plan_catalog(plan_key,display_name,monthly_price_minor,currency,trial_days,publicly_visible) values
 ('standard','Standard',1499,'GBP',30,true),('pro','Pro',2999,'GBP',30,true),('ultra','Ultra',4999,'GBP',30,false);
insert into public.plan_entitlements(plan_key,analysis_limit,priority_class,features) values
 ('standard',10,'standard','{"core_mvp":true}'::jsonb),('pro',null,'priority','{"core_mvp":true,"fair_use":true}'::jsonb),('ultra',null,'reserved','{"core_mvp":true,"reserved":true}'::jsonb);

create table public.subscriptions(
  id uuid primary key default gen_random_uuid(),workspace_id uuid not null unique references public.workspaces(id) on delete cascade,
  plan_key text not null references public.plan_catalog(plan_key),stripe_customer_id text unique,stripe_subscription_id text unique,
  status text not null check(status in ('incomplete','trialing','active','past_due','unpaid','canceled','paused')),
  trial_ends_at timestamptz,current_period_starts_at timestamptz,current_period_ends_at timestamptz,cancel_at_period_end boolean not null default false,
  last_stripe_event_created_at timestamptz,created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
create table public.usage_counters(
  id uuid primary key default gen_random_uuid(),workspace_id uuid not null references public.workspaces(id) on delete cascade,
  metric text not null check(metric in ('analysed_deals')),period_start date not null,period_end date not null,value integer not null default 0 check(value>=0),
  created_at timestamptz not null default now(),updated_at timestamptz not null default now(),unique(workspace_id,metric,period_start)
);
create table private.stripe_events(
  event_id text primary key,event_type text not null,stripe_created_at timestamptz not null,status text not null check(status in ('processing','processed','ignored','failed')),
  error_class text,received_at timestamptz not null default now(),processed_at timestamptz
);
create index subscriptions_plan_idx on public.subscriptions(plan_key);
create index usage_counters_workspace_period_idx on public.usage_counters(workspace_id,period_start desc);

alter table public.plan_catalog enable row level security;alter table public.plan_entitlements enable row level security;alter table public.subscriptions enable row level security;alter table public.usage_counters enable row level security;
revoke all on public.plan_catalog,public.plan_entitlements,public.subscriptions,public.usage_counters from anon,authenticated;
grant select on public.plan_catalog,public.plan_entitlements,public.subscriptions,public.usage_counters to authenticated;
revoke all on private.stripe_events from public,anon,authenticated;
create policy plan_catalog_read on public.plan_catalog for select to authenticated using(active and publicly_visible);
create policy plan_entitlements_visible_read on public.plan_entitlements for select to authenticated using(exists(select 1 from public.plan_catalog pc where pc.plan_key=plan_entitlements.plan_key and pc.active and pc.publicly_visible));
create policy subscriptions_member_read on public.subscriptions for select to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=subscriptions.workspace_id and wm.user_id=(select auth.uid())));
create policy usage_counters_member_read on public.usage_counters for select to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=usage_counters.workspace_id and wm.user_id=(select auth.uid())));

create or replace function private.consume_analysis_entitlement(p_workspace_id uuid) returns void language plpgsql security definer set search_path='' as $$
declare v_subscription public.subscriptions;v_limit integer;v_start date;v_end date;v_value integer;
begin
  select * into v_subscription from public.subscriptions where workspace_id=p_workspace_id for update;
  if v_subscription.id is null or v_subscription.status not in ('trialing','active') then raise exception 'subscription required' using errcode='P0001';end if;
  if v_subscription.status='trialing' and v_subscription.trial_ends_at<=now() then raise exception 'trial ended' using errcode='P0001';end if;
  select analysis_limit into v_limit from public.plan_entitlements where plan_key=v_subscription.plan_key;
  if v_limit is null then return;end if;
  v_start:=coalesce(v_subscription.current_period_starts_at::date,date_trunc('month',now())::date);v_end:=coalesce(v_subscription.current_period_ends_at::date,(v_start+interval '1 month')::date);
  insert into public.usage_counters(workspace_id,metric,period_start,period_end,value) values(p_workspace_id,'analysed_deals',v_start,v_end,1)
  on conflict(workspace_id,metric,period_start) do update set value=public.usage_counters.value+1,updated_at=now() returning value into v_value;
  if v_value>v_limit then raise exception 'analysis limit reached' using errcode='P0001';end if;
end $$;
revoke all on function private.consume_analysis_entitlement(uuid) from public,anon,authenticated;

create or replace function public.request_deal_analysis(p_deal_id uuid) returns uuid language plpgsql security definer set search_path='' as $$
declare v_workspace_id uuid;v_hash text;v_snapshot_id uuid;v_job_id uuid;v_job_status text;v_should_enqueue boolean:=false;
begin
 select workspace_id into v_workspace_id from public.deals d where d.id=p_deal_id and d.deleted_at is null and exists(select 1 from public.workspace_members wm where wm.workspace_id=d.workspace_id and wm.user_id=auth.uid());
 if v_workspace_id is null then raise exception 'deal not found' using errcode='P0002';end if;
 select encode(extensions.digest(coalesce(string_agg(m.id::text||':'||m.updated_at::text||':'||m.body_text,E'\n' order by m.internal_date),''),'sha256'),'hex') into v_hash from public.deal_threads t left join public.gmail_messages m on m.deal_thread_id=t.id where t.deal_id=p_deal_id;
 select id into v_snapshot_id from public.analysis_snapshots where deal_id=p_deal_id and input_snapshot_hash=v_hash and state in ('queued','running','completed');
 if v_snapshot_id is not null then return v_snapshot_id;end if;
 perform private.consume_analysis_entitlement(v_workspace_id);
 insert into public.analysis_snapshots(workspace_id,deal_id,input_snapshot_hash,state) values(v_workspace_id,p_deal_id,v_hash,'queued') returning id into v_snapshot_id;
 insert into private.ai_analysis_jobs(workspace_id,deal_id,snapshot_id) values(v_workspace_id,p_deal_id,v_snapshot_id) returning id into v_job_id;perform pgmq.send('ai_analysis',jsonb_build_object('job_id',v_job_id));return v_snapshot_id;
end $$;
revoke all on function public.request_deal_analysis(uuid) from public,anon;grant execute on function public.request_deal_analysis(uuid) to authenticated;

comment on table private.stripe_events is 'Idempotent verified Stripe event ledger; payloads are intentionally not retained.';
comment on table public.subscriptions is 'Product-access projection of verified Stripe state; redirects never update this table.';
