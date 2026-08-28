create extension if not exists pgmq;

create type public.integration_state as enum ('pending', 'active', 'reauthorization_required', 'disconnected', 'error');
create type public.deal_status as enum ('new', 'reviewing', 'negotiating', 'awaiting_brand', 'awaiting_creator', 'agreed', 'declined', 'lost', 'completed', 'archived');

create table public.integration_connections (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  provider text not null check (provider = 'gmail'),
  state public.integration_state not null default 'pending',
  connected_identity text,
  granted_scopes text[] not null default '{}',
  last_successful_sync_at timestamptz,
  error_code text,
  error_message text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workspace_id, provider)
);

create table public.gmail_connections (
  id uuid primary key default gen_random_uuid(),
  integration_connection_id uuid not null unique references public.integration_connections(id) on delete cascade,
  workspace_id uuid not null unique references public.workspaces(id) on delete cascade,
  gmail_email_address text not null,
  replio_label_id text not null,
  last_history_id numeric(20, 0),
  watch_expiration timestamptz,
  watch_status text not null default 'pending' check (watch_status in ('pending', 'active', 'expired', 'error', 'stopped')),
  token_encryption_key_version text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table private.gmail_oauth_tokens (
  gmail_connection_id uuid primary key references public.gmail_connections(id) on delete cascade,
  encrypted_refresh_token text not null,
  encryption_iv text not null,
  encryption_auth_tag text not null,
  key_version text not null,
  created_at timestamptz not null default now(),
  rotated_at timestamptz
);
revoke all on private.gmail_oauth_tokens from public, anon, authenticated;

create table public.deals (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  title text not null,
  status public.deal_status not null default 'new',
  created_source text not null default 'gmail_label' check (created_source = 'gmail_label'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.deal_threads (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null references public.deals(id) on delete cascade,
  gmail_connection_id uuid not null references public.gmail_connections(id) on delete cascade,
  provider_thread_id text not null,
  thread_role text not null default 'primary' check (thread_role in ('primary', 'supporting')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workspace_id, provider_thread_id)
);

create table public.gmail_messages (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_thread_id uuid not null references public.deal_threads(id) on delete cascade,
  provider_message_id text not null,
  provider_thread_id text not null,
  provider_history_id numeric(20, 0),
  internal_date timestamptz not null,
  direction text not null check (direction in ('inbound', 'outbound')),
  from_address text not null,
  to_addresses text[] not null default '{}',
  cc_addresses text[] not null default '{}',
  subject text not null default '',
  body_text text not null default '',
  body_html_sanitized text,
  provider_label_ids text[] not null default '{}',
  raw_headers jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workspace_id, provider_message_id)
);

create table public.gmail_attachment_references (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  gmail_message_id uuid not null references public.gmail_messages(id) on delete cascade,
  provider_attachment_id text not null,
  filename text not null,
  mime_type text not null,
  size_bytes bigint check (size_bytes is null or size_bytes >= 0),
  created_at timestamptz not null default now(),
  unique (gmail_message_id, provider_attachment_id)
);

create table private.gmail_sync_events (
  id uuid primary key default gen_random_uuid(),
  gmail_connection_id uuid not null references public.gmail_connections(id) on delete cascade,
  pubsub_message_id text not null,
  history_id numeric(20, 0) not null,
  status text not null default 'queued' check (status in ('queued', 'processing', 'completed', 'failed')),
  attempt_count integer not null default 0 check (attempt_count >= 0),
  last_error text,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (gmail_connection_id, pubsub_message_id),
  unique (gmail_connection_id, history_id)
);
revoke all on private.gmail_sync_events from public, anon, authenticated;

select pgmq.create('gmail_sync');

create or replace function public.complete_gmail_connection(
  p_workspace_id uuid,
  p_user_id uuid,
  p_email text,
  p_scopes text[],
  p_label_id text,
  p_history_id numeric,
  p_watch_expiration timestamptz,
  p_encrypted_refresh_token text,
  p_encryption_iv text,
  p_encryption_auth_tag text,
  p_key_version text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_integration_id uuid; v_connection_id uuid;
begin
  if auth.role() <> 'service_role' then raise exception 'service role required' using errcode = '42501'; end if;
  if not exists (select 1 from public.workspace_members where workspace_id = p_workspace_id and user_id = p_user_id) then
    raise exception 'workspace membership required' using errcode = '42501';
  end if;
  insert into public.integration_connections(workspace_id, user_id, provider, state, connected_identity, granted_scopes, error_code, error_message)
  values (p_workspace_id, p_user_id, 'gmail', 'active', lower(p_email), p_scopes, null, null)
  on conflict (workspace_id, provider) do update set user_id = excluded.user_id, state = 'active', connected_identity = excluded.connected_identity,
    granted_scopes = excluded.granted_scopes, error_code = null, error_message = null, updated_at = now()
  returning id into v_integration_id;
  insert into public.gmail_connections(integration_connection_id, workspace_id, gmail_email_address, replio_label_id, last_history_id, watch_expiration, watch_status, token_encryption_key_version)
  values (v_integration_id, p_workspace_id, lower(p_email), p_label_id, p_history_id, p_watch_expiration, 'active', p_key_version)
  on conflict (workspace_id) do update set integration_connection_id = excluded.integration_connection_id, gmail_email_address = excluded.gmail_email_address,
    replio_label_id = excluded.replio_label_id, last_history_id = excluded.last_history_id, watch_expiration = excluded.watch_expiration,
    watch_status = 'active', token_encryption_key_version = excluded.token_encryption_key_version, updated_at = now()
  returning id into v_connection_id;
  insert into private.gmail_oauth_tokens(gmail_connection_id, encrypted_refresh_token, encryption_iv, encryption_auth_tag, key_version)
  values (v_connection_id, p_encrypted_refresh_token, p_encryption_iv, p_encryption_auth_tag, p_key_version)
  on conflict (gmail_connection_id) do update set encrypted_refresh_token = excluded.encrypted_refresh_token, encryption_iv = excluded.encryption_iv,
    encryption_auth_tag = excluded.encryption_auth_tag, key_version = excluded.key_version, rotated_at = now();
  return v_connection_id;
end;
$$;
revoke all on function public.complete_gmail_connection(uuid, uuid, text, text[], text, numeric, timestamptz, text, text, text, text) from public, anon, authenticated;
grant execute on function public.complete_gmail_connection(uuid, uuid, text, text[], text, numeric, timestamptz, text, text, text, text) to service_role;

create or replace function public.enqueue_gmail_sync(p_email text, p_history_id numeric, p_pubsub_message_id text)
returns bigint language plpgsql security definer set search_path = '' as $$
declare v_connection_id uuid; v_event_id uuid; v_message_id bigint;
begin
  if auth.role() <> 'service_role' then raise exception 'service role required' using errcode = '42501'; end if;
  select id into v_connection_id from public.gmail_connections where gmail_email_address = lower(p_email) and watch_status = 'active';
  if v_connection_id is null then raise exception 'active Gmail connection not found' using errcode = 'P0002'; end if;
  insert into private.gmail_sync_events(gmail_connection_id, pubsub_message_id, history_id)
  values (v_connection_id, p_pubsub_message_id, p_history_id)
  on conflict do nothing returning id into v_event_id;
  if v_event_id is null then return null; end if;
  select * into v_message_id from pgmq.send('gmail_sync', jsonb_build_object('event_id', v_event_id, 'gmail_connection_id', v_connection_id, 'history_id', p_history_id));
  return v_message_id;
end;
$$;
revoke all on function public.enqueue_gmail_sync(text, numeric, text) from public, anon, authenticated;
grant execute on function public.enqueue_gmail_sync(text, numeric, text) to service_role;

create index integration_connections_user_idx on public.integration_connections(user_id);
create index gmail_connections_integration_idx on public.gmail_connections(integration_connection_id);
create index deals_workspace_status_idx on public.deals(workspace_id, status) where deleted_at is null;
create index deal_threads_deal_idx on public.deal_threads(deal_id);
create index deal_threads_connection_idx on public.deal_threads(gmail_connection_id);
create index gmail_messages_thread_date_idx on public.gmail_messages(deal_thread_id, internal_date);
create index gmail_attachment_references_workspace_idx on public.gmail_attachment_references(workspace_id);
create index gmail_sync_events_connection_status_idx on private.gmail_sync_events(gmail_connection_id, status);

alter table public.integration_connections enable row level security;
alter table public.gmail_connections enable row level security;
alter table public.deals enable row level security;
alter table public.deal_threads enable row level security;
alter table public.gmail_messages enable row level security;
alter table public.gmail_attachment_references enable row level security;

revoke all on public.integration_connections, public.gmail_connections, public.deals, public.deal_threads, public.gmail_messages, public.gmail_attachment_references from anon, authenticated;
grant select on public.integration_connections, public.gmail_connections, public.deals, public.deal_threads, public.gmail_messages, public.gmail_attachment_references to authenticated;

create policy integration_connections_select_member on public.integration_connections for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = integration_connections.workspace_id and m.user_id = (select auth.uid())));
create policy gmail_connections_select_member on public.gmail_connections for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = gmail_connections.workspace_id and m.user_id = (select auth.uid())));
create policy deals_select_member on public.deals for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = deals.workspace_id and m.user_id = (select auth.uid())));
create policy deal_threads_select_member on public.deal_threads for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = deal_threads.workspace_id and m.user_id = (select auth.uid())));
create policy gmail_messages_select_member on public.gmail_messages for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = gmail_messages.workspace_id and m.user_id = (select auth.uid())));
create policy gmail_attachment_references_select_member on public.gmail_attachment_references for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id = gmail_attachment_references.workspace_id and m.user_id = (select auth.uid())));

comment on table private.gmail_oauth_tokens is 'Server-only AES-256-GCM encrypted Gmail refresh tokens; never exposed through the Data API.';
comment on table public.gmail_messages is 'Only messages from creator-selected threads carrying the stored Replio Gmail label may be persisted.';
