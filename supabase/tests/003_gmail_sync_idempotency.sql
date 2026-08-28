begin;
set search_path = public, extensions;
select plan(6);

insert into auth.users(id, email, raw_user_meta_data)
values ('00000000-0000-4000-8000-000000000021', 'sync@example.test', '{"full_name":"Sync Creator"}');

set local role service_role;
set local request.jwt.claims = '{"sub":"00000000-0000-4000-8000-000000000021","role":"service_role"}';

select lives_ok($$
  select public.complete_gmail_connection(
    (select workspace_id from public.workspace_members where user_id = '00000000-0000-4000-8000-000000000021'),
    '00000000-0000-4000-8000-000000000021', 'sync@example.test', array['https://www.googleapis.com/auth/gmail.modify'],
    'Label_Replio', 100, now() + interval '6 days', 'ciphertext', 'iv', 'tag', 'v1')
$$, 'service boundary stores Gmail connection');

select isnt(public.enqueue_gmail_sync('sync@example.test', 101, 'pubsub-1'), null::bigint, 'first notification is queued');
select is(public.enqueue_gmail_sync('sync@example.test', 101, 'pubsub-duplicate'), null::bigint, 'same history window is deduplicated');

select lives_ok($$
  select public.persist_gmail_thread(
    (select workspace_id from public.workspace_members where user_id = '00000000-0000-4000-8000-000000000021'),
    (select id from public.gmail_connections where gmail_email_address = 'sync@example.test'),
    'thread-1', 'Brand collaboration',
    '[{"provider_message_id":"message-1","provider_history_id":"101","internal_date":"2026-08-28T00:00:00Z","direction":"inbound","from_address":"brand@example.test","to_addresses":["sync@example.test"],"cc_addresses":[],"subject":"Brand collaboration","body_text":"Hello","body_html_sanitized":null,"provider_label_ids":["Label_Replio"],"raw_headers":{},"attachments":[]}]'::jsonb)
$$, 'first labelled thread persists');

select lives_ok($$
  select public.persist_gmail_thread(
    (select workspace_id from public.workspace_members where user_id = '00000000-0000-4000-8000-000000000021'),
    (select id from public.gmail_connections where gmail_email_address = 'sync@example.test'),
    'thread-1', 'Brand collaboration',
    '[{"provider_message_id":"message-1","provider_history_id":"101","internal_date":"2026-08-28T00:00:00Z","direction":"inbound","from_address":"brand@example.test","to_addresses":["sync@example.test"],"cc_addresses":[],"subject":"Brand collaboration","body_text":"Hello again","body_html_sanitized":null,"provider_label_ids":["Label_Replio"],"raw_headers":{},"attachments":[]}]'::jsonb)
$$, 'repeated thread persistence is safe');

select results_eq(
  $$select (select count(*) from public.deals)::integer, (select count(*) from public.deal_threads)::integer, (select count(*) from public.gmail_messages)::integer$$,
  $$values (1, 1, 1)$$,
  'one Gmail thread creates exactly one deal and message'
);

select * from finish();
rollback;
