begin;set search_path=public,extensions;select plan(8);
insert into auth.users(id,email,raw_user_meta_data) values('00000000-0000-4000-8000-000000000221','deltas@example.test','{"full_name":"Creator"}');
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000221' \gset
insert into public.deals(workspace_id,title,status,currency) values(:'workspace_id','Delta campaign','new','GBP') returning id as deal_id \gset
insert into public.analysis_snapshots(workspace_id,deal_id,state) values(:'workspace_id',:'deal_id','running') returning id as snapshot_id \gset
set local role service_role;set local request.jwt.claims='{"role":"service_role"}';
select lives_ok(format('select public.apply_analysis_deal_deltas(%L,%L,%L,%L::jsonb,%L::jsonb)',:'workspace_id',:'deal_id',:'snapshot_id','[{"field_key":"billing_entity","display_value":"Brand Ltd","confidence":0.9,"evidence":[{"message_id":"00000000-0000-4000-8000-000000000001"}]}]','[{"deadline_type":"publish_due","label":"Post live","due_at":"2026-10-01T10:00:00Z","confidence":0.9,"evidence":[{"message_id":"00000000-0000-4000-8000-000000000001"}]}]'),'service applies evidenced deltas');
select is((select display_value from public.deal_operational_facts where deal_id=:'deal_id' and is_current),'Brand Ltd','fact becomes current');
select is((select count(*) from public.deal_deadlines where deal_id=:'deal_id'),1::bigint,'deadline created');
select lives_ok(format('select public.apply_analysis_deal_deltas(%L,%L,%L,%L::jsonb,%L::jsonb)',:'workspace_id',:'deal_id',:'snapshot_id','[]','[{"deadline_type":"publish_due","label":"Post live","due_at":"2026-10-01T10:00:00Z","confidence":0.9,"evidence":[{}]}]'),'deadline replay is accepted');
select is((select count(*) from public.deal_deadlines where deal_id=:'deal_id'),1::bigint,'deadline replay is duplicate-safe');
reset role;set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000221","role":"authenticated"}';
select isnt(public.set_deal_operational_fact(:'deal_id','billing_entity','{"text":"Creator Brand"}','Creator Brand'),null,'creator corrects extracted fact');
reset role;set local role service_role;set local request.jwt.claims='{"role":"service_role"}';
select lives_ok(format('select public.apply_analysis_deal_deltas(%L,%L,%L,%L::jsonb,%L::jsonb)',:'workspace_id',:'deal_id',:'snapshot_id','[{"field_key":"billing_entity","display_value":"AI overwrite","confidence":1,"evidence":[{}]}]','[]'),'later AI replay remains safe');
select is((select display_value from public.deal_operational_facts where deal_id=:'deal_id' and is_current),'Creator Brand','creator value remains authoritative');
select * from finish();rollback;

