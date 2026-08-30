begin; set search_path=public,extensions; select plan(7);
insert into auth.users(id,email) values('00000000-0000-4000-8000-000000000051','ai-one@example.test'),('00000000-0000-4000-8000-000000000052','ai-two@example.test');
insert into public.deals(workspace_id,title) select workspace_id,'AI fixture deal' from public.workspace_members where user_id='00000000-0000-4000-8000-000000000051' returning id as deal_id \gset
set local role authenticated; set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000051","role":"authenticated"}';
select isnt(public.request_deal_analysis(:'deal_id'),null::uuid,'member can request analysis');
select is((select count(*)::int from public.analysis_snapshots),1,'member sees own queued snapshot');
select is((select state::text from public.analysis_snapshots limit 1),'queued','snapshot starts queued');
select is(public.request_deal_analysis(:'deal_id'),(select id from public.analysis_snapshots limit 1),'unchanged input reuses snapshot');
select is((select count(*)::int from public.analysis_snapshots),1,'unchanged request is idempotent');
set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000052","role":"authenticated"}';
select is((select count(*)::int from public.analysis_snapshots),0,'other tenant cannot see snapshot');
select throws_ok(format('select public.request_deal_analysis(%L)', :'deal_id'),'P0002','deal not found','other tenant cannot enqueue analysis');
select * from finish(); rollback;
