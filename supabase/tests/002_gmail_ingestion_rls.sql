begin;
set search_path = public, extensions;
select plan(10);

insert into auth.users(id, email, raw_user_meta_data) values
  ('00000000-0000-4000-8000-000000000011', 'gmail-one@example.test', '{"full_name":"Gmail One"}'),
  ('00000000-0000-4000-8000-000000000012', 'gmail-two@example.test', '{"full_name":"Gmail Two"}');

insert into public.integration_connections(workspace_id, user_id, provider, state, connected_identity, granted_scopes)
select workspace_id, user_id, 'gmail', 'active', 'creator@example.test', array['https://www.googleapis.com/auth/gmail.modify'] from public.workspace_members;

insert into public.gmail_connections(integration_connection_id, workspace_id, gmail_email_address, replio_label_id, token_encryption_key_version)
select id, workspace_id, connected_identity, 'Label_Replio', 'v1' from public.integration_connections;

insert into public.deals(workspace_id, title)
select workspace_id, 'Test deal' from public.workspace_members;

insert into public.deal_threads(workspace_id, deal_id, gmail_connection_id, provider_thread_id)
select d.workspace_id, d.id, g.id, 'thread-' || d.id::text from public.deals d join public.gmail_connections g using (workspace_id);

insert into public.gmail_messages(workspace_id, deal_thread_id, provider_message_id, provider_thread_id, internal_date, direction, from_address)
select t.workspace_id, t.id, 'message-' || t.id::text, t.provider_thread_id, now(), 'inbound', 'brand@example.test' from public.deal_threads t;

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-4000-8000-000000000011","role":"authenticated"}';

select is((select count(*)::integer from public.integration_connections), 1, 'creator sees only own integration');
select is((select count(*)::integer from public.gmail_connections), 1, 'creator sees only own Gmail metadata');
select is((select count(*)::integer from public.deals), 1, 'creator sees only own deal');
select is((select count(*)::integer from public.deal_threads), 1, 'creator sees only own Gmail thread');
select is((select count(*)::integer from public.gmail_messages), 1, 'creator sees only own Gmail message');
select throws_ok($$insert into public.deals(workspace_id, title) select workspace_id, 'Client insert' from public.workspace_members limit 1$$, '42501', null, 'client cannot insert integration-owned deal');
select throws_ok($$select * from private.gmail_oauth_tokens$$, '42501', null, 'creator cannot read encrypted OAuth tokens');
select throws_ok($$select * from private.gmail_sync_events$$, '42501', null, 'creator cannot read private sync events');
select is((select count(*)::integer from public.deals where workspace_id = (select workspace_id from public.workspace_members where user_id = '00000000-0000-4000-8000-000000000012')), 0, 'cross-tenant deal lookup fails closed');
select is((select count(*)::integer from public.gmail_messages where workspace_id = (select workspace_id from public.workspace_members where user_id = '00000000-0000-4000-8000-000000000012')), 0, 'cross-tenant message lookup fails closed');

select * from finish();
rollback;
