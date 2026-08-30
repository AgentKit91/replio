begin;
set search_path = public, extensions;
select plan(8);
insert into auth.users(id,email) values ('00000000-0000-4000-8000-000000000041','m3-one@example.test'),('00000000-0000-4000-8000-000000000042','m3-two@example.test');
insert into public.brands(canonical_name,normalized_domain) values ('North Star','north-star.example') returning id as brand_id \gset
insert into public.workspace_brands(workspace_id,brand_id) select workspace_id, :'brand_id' from public.workspace_members where user_id='00000000-0000-4000-8000-000000000041';
insert into public.deals(workspace_id,title,brand_id) select workspace_id,'Private campaign',:'brand_id' from public.workspace_members where user_id='00000000-0000-4000-8000-000000000041' returning id as deal_id, workspace_id \gset
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-4000-8000-000000000041","role":"authenticated"}';
select is((select count(*)::int from public.brands),1,'member sees linked safe brand');
select is((select count(*)::int from public.deals),1,'member sees own deal');
insert into public.deal_notes(workspace_id,deal_id,body,created_by) values (:'workspace_id',:'deal_id','Private note','00000000-0000-4000-8000-000000000041');
select is((select count(*)::int from public.deal_notes),1,'member can add a private note');
select lives_ok(format('select public.set_deal_state(%L, %L)', :'deal_id', 'awaiting_brand'),'member can change own deal state');
select is((select human_status_code from public.deals where id=:'deal_id'),'waiting_on_brand','state has human-readable code');
select lives_ok(format('select public.set_deal_recycled(%L, true)', :'deal_id'),'member can recycle own deal');
select ok((select purge_after > now() + interval '29 days' from public.deals where id=:'deal_id'),'recycled deal receives retention deadline');
set local request.jwt.claims = '{"sub":"00000000-0000-4000-8000-000000000042","role":"authenticated"}';
select is((select count(*)::int from public.deal_notes),0,'other tenant cannot see private note');
select * from finish();
rollback;
