begin;
set search_path = public, extensions;
select plan(8);

insert into auth.users(id, email, raw_user_meta_data) values
  ('00000000-0000-4000-8000-000000000001', 'one@example.test', '{"full_name":"Creator One"}'),
  ('00000000-0000-4000-8000-000000000002', 'two@example.test', '{"full_name":"Creator Two"}');

select is((select count(*)::integer from public.workspace_members), 2, 'one workspace membership per new user');
select is((select count(*)::integer from public.creator_profiles), 2, 'one creator profile per new user');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-4000-8000-000000000001","role":"authenticated"}';

select is((select count(*)::integer from public.workspaces), 1, 'creator sees only own workspace');
select is((select count(*)::integer from public.creator_profiles), 1, 'creator sees only own creator profile');
select is((select count(*)::integer from public.workspace_members), 1, 'creator sees only own membership');
select is((select count(*)::integer from public.user_profiles), 1, 'creator sees only own user profile');
select lives_ok($$update public.user_profiles set base_currency = 'GBP' where user_id = '00000000-0000-4000-8000-000000000001'$$, 'creator can update own profile');
select is((select count(*)::integer from public.user_profiles where user_id = '00000000-0000-4000-8000-000000000002'), 0, 'cross-tenant user lookup fails closed');

select * from finish();
rollback;
