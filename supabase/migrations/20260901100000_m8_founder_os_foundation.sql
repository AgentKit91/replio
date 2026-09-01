create table private.founder_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table private.system_health_checks (
  id bigint generated always as identity primary key,
  component text not null check (component in ('database','gmail','ai','stripe','worker','deployment')),
  status text not null check (status in ('healthy','degraded','down','unknown')),
  summary text not null,
  safe_metadata jsonb not null default '{}'::jsonb,
  checked_at timestamptz not null default now()
);

create table private.system_incidents (
  id uuid primary key default gen_random_uuid(),
  component text not null,
  severity text not null check (severity in ('info','warning','critical')),
  status text not null default 'open' check (status in ('open','acknowledged','resolved')),
  title text not null,
  summary text not null,
  recommended_action text,
  safe_metadata jsonb not null default '{}'::jsonb,
  opened_at timestamptz not null default now(),
  acknowledged_at timestamptz,
  resolved_at timestamptz
);

create table private.founder_actions (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid not null references auth.users(id) on delete restrict,
  action_type text not null,
  target_type text not null,
  target_id text,
  safety_level text not null check (safety_level in ('immediate','confirm','guided')),
  confirmation_state text not null check (confirmation_state in ('not_required','requested','confirmed','declined')),
  before_safe_metadata jsonb not null default '{}'::jsonb,
  after_safe_metadata jsonb not null default '{}'::jsonb,
  idempotency_key text not null unique,
  result text not null check (result in ('pending','succeeded','failed')),
  error_class text,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create table public.support_access_grants (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  granted_by_user_id uuid not null references auth.users(id) on delete cascade,
  scope_type text not null check (scope_type in ('workspace','deal')),
  scope_id uuid,
  reason text not null check (char_length(reason) between 3 and 500),
  expires_at timestamptz not null,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  constraint support_scope_shape check ((scope_type='workspace' and scope_id is null) or (scope_type='deal' and scope_id is not null)),
  constraint support_expiry_after_creation check (expires_at > created_at)
);

create table private.support_access_sessions (
  id uuid primary key default gen_random_uuid(),
  grant_id uuid not null references public.support_access_grants(id) on delete cascade,
  founder_user_id uuid not null references auth.users(id) on delete restrict,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  last_accessed_at timestamptz not null default now()
);

create table private.feature_flags (
  key text primary key,
  enabled boolean not null default false,
  description text not null,
  version integer not null default 1 check (version > 0),
  updated_by_user_id uuid references auth.users(id) on delete set null,
  updated_at timestamptz not null default now()
);

create index system_health_component_checked_idx on private.system_health_checks(component, checked_at desc);
create index system_incidents_status_opened_idx on private.system_incidents(status, opened_at desc);
create index founder_actions_created_idx on private.founder_actions(created_at desc);
create index support_access_grants_workspace_idx on public.support_access_grants(workspace_id, expires_at desc);
create index support_access_sessions_grant_idx on private.support_access_sessions(grant_id, started_at desc);

alter table public.support_access_grants enable row level security;
revoke all on private.founder_users, private.system_health_checks, private.system_incidents, private.founder_actions, private.support_access_sessions, private.feature_flags from public, anon, authenticated;
revoke all on public.support_access_grants from anon, authenticated;
grant select, insert, update on public.support_access_grants to authenticated;

create policy support_grants_select_creator on public.support_access_grants for select to authenticated
using (granted_by_user_id=(select auth.uid()) and exists(select 1 from public.workspace_members m where m.workspace_id=support_access_grants.workspace_id and m.user_id=(select auth.uid())));
create policy support_grants_insert_creator on public.support_access_grants for insert to authenticated
with check (granted_by_user_id=(select auth.uid()) and expires_at<=now()+interval '7 days' and revoked_at is null and exists(select 1 from public.workspace_members m where m.workspace_id=support_access_grants.workspace_id and m.user_id=(select auth.uid())) and (scope_type<>'deal' or exists(select 1 from public.deals d where d.id=scope_id and d.workspace_id=support_access_grants.workspace_id)));
create policy support_grants_revoke_creator on public.support_access_grants for update to authenticated
using (granted_by_user_id=(select auth.uid()) and exists(select 1 from public.workspace_members m where m.workspace_id=support_access_grants.workspace_id and m.user_id=(select auth.uid())))
with check (granted_by_user_id=(select auth.uid()) and revoked_at is not null);

create or replace function private.has_active_support_grant(p_founder_user_id uuid,p_workspace_id uuid,p_deal_id uuid default null)
returns boolean language sql stable security definer set search_path='' as $$
  select exists(
    select 1 from private.founder_users f
    join private.support_access_sessions s on s.founder_user_id=f.user_id and s.ended_at is null
    join public.support_access_grants g on g.id=s.grant_id
    where f.user_id=p_founder_user_id and g.workspace_id=p_workspace_id and g.revoked_at is null and g.expires_at>now()
      and (g.scope_type='workspace' or (g.scope_type='deal' and g.scope_id=p_deal_id))
  );
$$;
revoke all on function private.has_active_support_grant(uuid,uuid,uuid) from public,anon,authenticated;

insert into private.feature_flags(key,enabled,description) values
  ('ai_worker_enabled',true,'Allow queued AI analyses to be claimed by the worker.'),
  ('gmail_send_enabled',true,'Allow queued Gmail replies to be claimed by the worker.')
on conflict (key) do nothing;

