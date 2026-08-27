create extension if not exists pgcrypto;
create extension if not exists pgtap with schema extensions;
create schema if not exists private;

create table public.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  timezone text not null default 'UTC',
  base_currency char(3),
  country_code char(2),
  onboarding_completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint currency_uppercase check (base_currency is null or base_currency = upper(base_currency)),
  constraint country_uppercase check (country_code is null or country_code = upper(country_code))
);

create table public.workspaces (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  kind text not null default 'creator' check (kind = 'creator'),
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.workspace_members (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'owner' check (role in ('owner')),
  created_at timestamptz not null default now(),
  primary key (workspace_id, user_id),
  unique (user_id)
);

create table public.creator_profiles (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null unique references public.workspaces(id) on delete cascade,
  creator_name text not null default '',
  niche text,
  country_code char(2),
  base_currency char(3),
  profile_schema_version integer not null default 1 check (profile_schema_version > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.creator_platforms (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  creator_profile_id uuid not null references public.creator_profiles(id) on delete cascade,
  platform text not null check (platform in ('instagram','tiktok','youtube','other')),
  handle text not null,
  profile_url text,
  followers bigint check (followers is null or followers >= 0),
  avg_views bigint check (avg_views is null or avg_views >= 0),
  engagement_rate numeric(7,4) check (engagement_rate is null or engagement_rate between 0 and 100),
  source_type text not null default 'self_reported' check (source_type in ('verified','self_reported','ai_estimated')),
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (creator_profile_id, platform, handle)
);

create table public.activity_events (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  actor_user_id uuid references auth.users(id) on delete set null,
  event_type text not null,
  entity_type text,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  category text not null check (category in ('action_required','opportunity','risk','success')),
  title text not null,
  body text not null,
  entity_type text,
  entity_id uuid,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index creator_platforms_workspace_idx on public.creator_platforms(workspace_id);
create index activity_events_workspace_created_idx on public.activity_events(workspace_id, created_at desc);
create index notifications_workspace_created_idx on public.notifications(workspace_id, created_at desc);

alter table public.user_profiles enable row level security;
alter table public.workspaces enable row level security;
alter table public.workspace_members enable row level security;
alter table public.creator_profiles enable row level security;
alter table public.creator_platforms enable row level security;
alter table public.activity_events enable row level security;
alter table public.notifications enable row level security;

revoke all on all tables in schema public from anon;
revoke all on public.user_profiles, public.workspaces, public.workspace_members, public.creator_profiles, public.creator_platforms, public.activity_events, public.notifications from authenticated;
grant select, update on public.user_profiles to authenticated;
grant select, update on public.workspaces to authenticated;
grant select on public.workspace_members to authenticated;
grant select, update on public.creator_profiles to authenticated;
grant select, insert, update, delete on public.creator_platforms to authenticated;
grant select on public.activity_events to authenticated;
grant select, update on public.notifications to authenticated;

create policy user_profiles_select_own on public.user_profiles for select to authenticated using ((select auth.uid()) = user_id);
create policy user_profiles_update_own on public.user_profiles for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy workspace_members_select_own on public.workspace_members for select to authenticated using ((select auth.uid()) = user_id);
create policy workspaces_select_member on public.workspaces for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = id and m.user_id = (select auth.uid())));
create policy workspaces_update_owner on public.workspaces for update to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = id and m.user_id = (select auth.uid()) and m.role = 'owner')) with check (created_by = (select auth.uid()));
create policy creator_profiles_select_member on public.creator_profiles for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = creator_profiles.workspace_id and m.user_id = (select auth.uid())));
create policy creator_profiles_update_member on public.creator_profiles for update to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = creator_profiles.workspace_id and m.user_id = (select auth.uid()))) with check (exists (select 1 from public.workspace_members m where m.workspace_id = creator_profiles.workspace_id and m.user_id = (select auth.uid())));
create policy creator_platforms_select_member on public.creator_platforms for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = creator_platforms.workspace_id and m.user_id = (select auth.uid())));
create policy creator_platforms_insert_member on public.creator_platforms for insert to authenticated with check (exists (select 1 from public.workspace_members m where m.workspace_id = creator_platforms.workspace_id and m.user_id = (select auth.uid())) and exists (select 1 from public.creator_profiles p where p.id = creator_profile_id and p.workspace_id = creator_platforms.workspace_id));
create policy creator_platforms_update_member on public.creator_platforms for update to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = creator_platforms.workspace_id and m.user_id = (select auth.uid()))) with check (exists (select 1 from public.workspace_members m where m.workspace_id = creator_platforms.workspace_id and m.user_id = (select auth.uid())));
create policy creator_platforms_delete_member on public.creator_platforms for delete to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = creator_platforms.workspace_id and m.user_id = (select auth.uid())));
create policy activity_events_select_member on public.activity_events for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = activity_events.workspace_id and m.user_id = (select auth.uid())));
create policy notifications_select_member on public.notifications for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = notifications.workspace_id and m.user_id = (select auth.uid())));
create policy notifications_update_member on public.notifications for update to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = notifications.workspace_id and m.user_id = (select auth.uid()))) with check (exists (select 1 from public.workspace_members m where m.workspace_id = notifications.workspace_id and m.user_id = (select auth.uid())));

create or replace function private.bootstrap_creator_account()
returns trigger language plpgsql security definer set search_path = '' as $$
declare new_workspace_id uuid;
begin
  insert into public.user_profiles(user_id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', new.email, ''))
  on conflict (user_id) do nothing;
  select workspace_id into new_workspace_id from public.workspace_members where user_id = new.id;
  if new_workspace_id is null then
    insert into public.workspaces(name, created_by) values ('My Replio workspace', new.id) returning id into new_workspace_id;
    insert into public.workspace_members(workspace_id, user_id, role) values (new_workspace_id, new.id, 'owner');
    insert into public.creator_profiles(workspace_id, creator_name) values (new_workspace_id, coalesce(new.raw_user_meta_data ->> 'full_name', ''));
  end if;
  return new;
end;
$$;
revoke all on function private.bootstrap_creator_account() from public, anon, authenticated;

create trigger on_auth_user_created after insert on auth.users for each row execute function private.bootstrap_creator_account();
