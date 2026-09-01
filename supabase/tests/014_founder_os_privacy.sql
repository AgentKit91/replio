begin;set search_path=public,extensions;select plan(28);
insert into auth.users(id,email) values
 ('00000000-0000-4000-8000-000000000141','support-owner@example.test'),
 ('00000000-0000-4000-8000-000000000142','other-owner@example.test'),
 ('00000000-0000-4000-8000-000000000143','founder@example.test');
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000141' \gset owner_
insert into private.founder_users(user_id) values('00000000-0000-4000-8000-000000000143');
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000141","role":"authenticated"}';
insert into public.support_access_grants(workspace_id,granted_by_user_id,scope_type,reason,expires_at)
values(:'owner_workspace_id','00000000-0000-4000-8000-000000000141','workspace','Synthetic support test',now()+interval '1 hour') returning id \gset grant_
select is((select count(*) from public.support_access_grants),1::bigint,'creator can grant scoped temporary support access');
select throws_ok(format('update public.support_access_grants set reason=%L,revoked_at=now() where id=%L','Changed reason',:'grant_id'),'42501','support grants may only be revoked','revocation cannot mutate grant scope or reason');
set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000142","role":"authenticated"}';
select is((select count(*) from public.support_access_grants),0::bigint,'another creator cannot see the grant');
select throws_ok(format('insert into public.support_access_grants(workspace_id,granted_by_user_id,scope_type,reason,expires_at) values(%L,%L,%L,%L,now()+interval ''1 hour'')',:'owner_workspace_id','00000000-0000-4000-8000-000000000142','workspace','Cross tenant attempt'),'42501',null,'another creator cannot grant access to the workspace');
reset role;
select is(has_schema_privilege('authenticated','private','usage'),false,'browser clients cannot access Founder OS private tables');
select is(has_function_privilege('authenticated','public.founder_operational_snapshot(uuid)','execute'),false,'browser clients cannot call the founder snapshot');
select is(private.has_active_support_grant('00000000-0000-4000-8000-000000000143',:'owner_workspace_id',null),false,'founder role alone grants no private access');
insert into private.support_access_sessions(grant_id,founder_user_id) values(:'grant_id','00000000-0000-4000-8000-000000000143');
select is(private.has_active_support_grant('00000000-0000-4000-8000-000000000143',:'owner_workspace_id',null),true,'active session plus active grant permits scoped support access');
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000141","role":"authenticated"}';
update public.support_access_grants set revoked_at=now() where id=:'grant_id';
select is((select count(*) from public.support_access_grants where revoked_at is not null),1::bigint,'creator can revoke access immediately');
reset role;
select is(private.has_active_support_grant('00000000-0000-4000-8000-000000000143',:'owner_workspace_id',null),false,'revocation ends support access immediately');
select is((select count(*) from private.support_access_sessions),1::bigint,'support session remains auditable after revocation');
set local role service_role;set local request.jwt.claims='{"role":"service_role"}';
select is((public.founder_operational_snapshot('00000000-0000-4000-8000-000000000143')->>'openSupportGrants')::integer,0,'service-only snapshot returns privacy-safe operational counts');
select is(jsonb_array_length(public.founder_operational_snapshot('00000000-0000-4000-8000-000000000143')->'customers'),3,'founder directory returns operational customer rows');
select is((public.founder_operational_snapshot('00000000-0000-4000-8000-000000000143')->'customers'->0) ?| array['message_body','draft','private_notes','analysis_output'],false,'founder directory contains no private negotiation fields');
select is(has_function_privilege('authenticated','public.founder_worker_controls(uuid)','execute'),false,'browser clients cannot read worker controls');
select is(has_function_privilege('authenticated','public.founder_set_worker_control(uuid,text,boolean,integer,boolean,text)','execute'),false,'browser clients cannot mutate worker controls');
select is(jsonb_array_length(public.founder_worker_controls('00000000-0000-4000-8000-000000000143')),2,'service boundary returns the two allowlisted worker controls');
select throws_ok($$select public.founder_set_worker_control('00000000-0000-4000-8000-000000000143','gmail_send_enabled',true,1,false,'test-enable-without-confirmation')$$,'22023','enabling a worker requires confirmation','worker enable requires explicit confirmation');
select is((public.founder_set_worker_control('00000000-0000-4000-8000-000000000143','gmail_send_enabled',false,1,false,'test-disable-gmail-worker')->>'enabled')::boolean,false,'founder can immediately pause outbound Gmail');
select is((public.founder_set_worker_control('00000000-0000-4000-8000-000000000143','gmail_send_enabled',false,1,false,'test-disable-gmail-worker')->>'replayed')::boolean,true,'repeated control action is idempotent');
reset role;
select is((select count(*) from private.founder_actions where idempotency_key='test-disable-gmail-worker' and result='succeeded'),1::bigint,'control mutation creates one successful audit record');
set local role service_role;set local request.jwt.claims='{"role":"service_role"}';
select is(has_function_privilege('authenticated','public.founder_start_support_session(uuid,uuid,boolean,text)','execute'),false,'browser clients cannot start founder support sessions');
select is(jsonb_array_length(public.founder_support_grants('00000000-0000-4000-8000-000000000143')),0,'revoked grants are absent from the founder grant queue');
reset role;
insert into public.support_access_grants(workspace_id,granted_by_user_id,scope_type,reason,expires_at)
values(:'owner_workspace_id','00000000-0000-4000-8000-000000000141','workspace','Second synthetic support test',now()+interval '1 hour') returning id \gset grant2_
set local role service_role;set local request.jwt.claims='{"role":"service_role"}';
select throws_ok(format('select public.founder_start_support_session(%L,%L,false,%L)','00000000-0000-4000-8000-000000000143',:'grant2_id','test-session-no-confirm'),'22023','support session requires confirmation','support session start requires confirmation');
select isnt(public.founder_start_support_session('00000000-0000-4000-8000-000000000143',:'grant2_id',true,'test-start-support-session'),null,'confirmed active grant starts a support session');
select is(jsonb_array_length(public.founder_support_grants('00000000-0000-4000-8000-000000000143')),1,'active grant appears in founder support queue');
select ok((public.founder_support_grants('00000000-0000-4000-8000-000000000143')->0->>'sessionId') is not null,'active session is visible without private content');
select ok(public.founder_end_support_session('00000000-0000-4000-8000-000000000143',(public.founder_support_grants('00000000-0000-4000-8000-000000000143')->0->>'sessionId')::uuid,'test-end-support-session'),'founder can immediately end own session');
select * from finish();rollback;

