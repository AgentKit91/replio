create table public.dealcheck_accounts (
  user_id uuid primary key references auth.users(id) on delete cascade,
  credit_balance integer not null default 0 check (credit_balance >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.dealcheck_credit_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  delta integer not null check (delta <> 0),
  reason text not null check (reason in ('signup_free','check_consumed','failed_check_refund','stripe_pack')),
  idempotency_key text unique not null,
  stripe_session_id text unique,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.dealcheck_checks (
  id uuid primary key default gen_random_uuid(),
  client_request_id uuid not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'processing' check (status in ('processing','completed','failed')),
  raw_offer text not null check (char_length(raw_offer) between 1 and 12000),
  platform text not null check (platform in ('tiktok','instagram')),
  followers integer not null check (followers between 1000 and 999999),
  average_views integer check (average_views is null or average_views >= 0),
  engagement_rate numeric(6,3) check (engagement_rate is null or engagement_rate between 0 and 100),
  extracted_data jsonb,
  valuation_data jsonb,
  score integer check (score is null or score between 0 and 100),
  result jsonb,
  ai_usage jsonb,
  failure_code text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (user_id, client_request_id)
);

create index dealcheck_credit_transactions_user_created_idx on public.dealcheck_credit_transactions(user_id, created_at desc);
create index dealcheck_checks_user_created_idx on public.dealcheck_checks(user_id, created_at desc);

alter table public.dealcheck_accounts enable row level security;
alter table public.dealcheck_credit_transactions enable row level security;
alter table public.dealcheck_checks enable row level security;

revoke all on public.dealcheck_accounts, public.dealcheck_credit_transactions, public.dealcheck_checks from anon, authenticated;
grant select on public.dealcheck_accounts, public.dealcheck_credit_transactions, public.dealcheck_checks to authenticated;

create policy dealcheck_accounts_own_read on public.dealcheck_accounts for select to authenticated using ((select auth.uid()) = user_id);
create policy dealcheck_transactions_own_read on public.dealcheck_credit_transactions for select to authenticated using ((select auth.uid()) = user_id);
create policy dealcheck_checks_own_read on public.dealcheck_checks for select to authenticated using ((select auth.uid()) = user_id);

create or replace function private.ensure_dealcheck_account(p_user_id uuid) returns integer
language plpgsql security definer set search_path = '' as $$
declare v_balance integer;
begin
  insert into public.dealcheck_accounts(user_id, credit_balance) values (p_user_id, 1)
  on conflict (user_id) do nothing;
  if found then
    insert into public.dealcheck_credit_transactions(user_id, delta, reason, idempotency_key)
    values (p_user_id, 1, 'signup_free', 'signup_free:' || p_user_id::text);
  end if;
  select credit_balance into strict v_balance from public.dealcheck_accounts where user_id = p_user_id;
  return v_balance;
end $$;
revoke all on function private.ensure_dealcheck_account(uuid) from public, anon, authenticated;

create or replace function public.dealcheck_initialize_account() returns integer
language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := auth.uid();
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '42501'; end if;
  return private.ensure_dealcheck_account(v_user_id);
end $$;
revoke all on function public.dealcheck_initialize_account() from public, anon;
grant execute on function public.dealcheck_initialize_account() to authenticated;

create or replace function public.dealcheck_start_check(
  p_client_request_id uuid, p_raw_offer text, p_platform text, p_followers integer,
  p_average_views integer default null, p_engagement_rate numeric default null
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := auth.uid(); v_check public.dealcheck_checks; v_balance integer;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '42501'; end if;
  if p_client_request_id is null or char_length(trim(coalesce(p_raw_offer,''))) not between 1 and 12000
    or p_platform not in ('tiktok','instagram') or p_followers not between 1000 and 999999
    or (p_average_views is not null and p_average_views < 0)
    or (p_engagement_rate is not null and p_engagement_rate not between 0 and 100)
  then raise exception 'INVALID_INPUT' using errcode = '22023'; end if;

  perform private.ensure_dealcheck_account(v_user_id);
  select * into v_check from public.dealcheck_checks where user_id = v_user_id and client_request_id = p_client_request_id;
  if v_check.id is not null then return jsonb_build_object('check_id',v_check.id,'status',v_check.status,'reused',true); end if;

  select credit_balance into v_balance from public.dealcheck_accounts where user_id = v_user_id for update;
  select * into v_check from public.dealcheck_checks where user_id = v_user_id and client_request_id = p_client_request_id;
  if v_check.id is not null then return jsonb_build_object('check_id',v_check.id,'status',v_check.status,'reused',true); end if;
  if v_balance <= 0 then raise exception 'NO_CREDITS' using errcode = 'P0001'; end if;

  insert into public.dealcheck_checks(client_request_id,user_id,raw_offer,platform,followers,average_views,engagement_rate)
  values (p_client_request_id,v_user_id,trim(p_raw_offer),p_platform,p_followers,p_average_views,p_engagement_rate) returning * into v_check;
  update public.dealcheck_accounts set credit_balance = credit_balance - 1, updated_at = now() where user_id = v_user_id;
  insert into public.dealcheck_credit_transactions(user_id,delta,reason,idempotency_key,metadata)
  values (v_user_id,-1,'check_consumed','check_consumed:' || v_check.id::text,jsonb_build_object('check_id',v_check.id));
  return jsonb_build_object('check_id',v_check.id,'status',v_check.status,'reused',false);
end $$;
revoke all on function public.dealcheck_start_check(uuid,text,text,integer,integer,numeric) from public, anon;
grant execute on function public.dealcheck_start_check(uuid,text,text,integer,integer,numeric) to authenticated;

create or replace function public.complete_dealcheck(
  p_check_id uuid, p_extracted_data jsonb, p_valuation_data jsonb, p_score integer, p_result jsonb, p_ai_usage jsonb
) returns boolean language plpgsql security definer set search_path = '' as $$
begin
  if coalesce(auth.jwt()->>'role','') <> 'service_role' then raise exception 'service role required' using errcode = '42501'; end if;
  if p_score not between 0 and 100 or p_extracted_data is null or p_valuation_data is null or p_result is null then raise exception 'invalid result' using errcode='22023'; end if;
  update public.dealcheck_checks set status='completed',extracted_data=p_extracted_data,valuation_data=p_valuation_data,
    score=p_score,result=p_result,ai_usage=coalesce(p_ai_usage,'{}'::jsonb),failure_code=null,completed_at=now(),updated_at=now()
  where id=p_check_id and status='processing';
  return found;
end $$;
revoke all on function public.complete_dealcheck(uuid,jsonb,jsonb,integer,jsonb,jsonb) from public, anon, authenticated;
grant execute on function public.complete_dealcheck(uuid,jsonb,jsonb,integer,jsonb,jsonb) to service_role;

create or replace function public.refund_failed_dealcheck(p_check_id uuid, p_failure_code text) returns boolean
language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid;
begin
  if coalesce(auth.jwt()->>'role','') <> 'service_role' then raise exception 'service role required' using errcode = '42501'; end if;
  update public.dealcheck_checks set status='failed',failure_code=left(coalesce(p_failure_code,'SYSTEM_FAILURE'),80),updated_at=now()
  where id=p_check_id and status='processing' returning user_id into v_user_id;
  if v_user_id is null then return false; end if;
  insert into public.dealcheck_credit_transactions(user_id,delta,reason,idempotency_key,metadata)
  values(v_user_id,1,'failed_check_refund','failed_check_refund:' || p_check_id::text,jsonb_build_object('check_id',p_check_id,'failure_code',left(coalesce(p_failure_code,'SYSTEM_FAILURE'),80)))
  on conflict(idempotency_key) do nothing;
  if found then update public.dealcheck_accounts set credit_balance=credit_balance+1,updated_at=now() where user_id=v_user_id; end if;
  return true;
end $$;
revoke all on function public.refund_failed_dealcheck(uuid,text) from public, anon, authenticated;
grant execute on function public.refund_failed_dealcheck(uuid,text) to service_role;

create or replace function public.grant_dealcheck_stripe_pack(p_user_id uuid,p_session_id text,p_credits integer,p_pack_key text) returns boolean
language plpgsql security definer set search_path = '' as $$
begin
  if coalesce(auth.jwt()->>'role','') <> 'service_role' then raise exception 'service role required' using errcode = '42501'; end if;
  if p_user_id is null or p_session_id is null or p_credits not in (3,10) or
    (p_pack_key,p_credits) not in (('pack_3',3),('pack_10',10)) then raise exception 'invalid credit pack' using errcode='22023'; end if;
  perform private.ensure_dealcheck_account(p_user_id);
  insert into public.dealcheck_credit_transactions(user_id,delta,reason,idempotency_key,stripe_session_id,metadata)
  values(p_user_id,p_credits,'stripe_pack','stripe_session:' || p_session_id,p_session_id,jsonb_build_object('pack_key',p_pack_key))
  on conflict(idempotency_key) do nothing;
  if not found then return false; end if;
  update public.dealcheck_accounts set credit_balance=credit_balance+p_credits,updated_at=now() where user_id=p_user_id;
  return true;
end $$;
revoke all on function public.grant_dealcheck_stripe_pack(uuid,text,integer,text) from public, anon, authenticated;
grant execute on function public.grant_dealcheck_stripe_pack(uuid,text,integer,text) to service_role;

comment on table public.dealcheck_accounts is 'DealCheck-only lifetime credit balance; mutations occur through narrow RPCs.';
comment on table public.dealcheck_checks is 'Private DealCheck inputs and reproducible stored results.';
