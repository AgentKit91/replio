begin;set search_path=public,extensions;select plan(10);
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
select is(private.has_active_support_grant('00000000-0000-4000-8000-000000000143',:'owner_workspace_id',null),false,'founder role alone grants no private access');
insert into private.support_access_sessions(grant_id,founder_user_id) values(:'grant_id','00000000-0000-4000-8000-000000000143');
select is(private.has_active_support_grant('00000000-0000-4000-8000-000000000143',:'owner_workspace_id',null),true,'active session plus active grant permits scoped support access');
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000141","role":"authenticated"}';
update public.support_access_grants set revoked_at=now() where id=:'grant_id';
select is((select count(*) from public.support_access_grants where revoked_at is not null),1::bigint,'creator can revoke access immediately');
reset role;
select is(private.has_active_support_grant('00000000-0000-4000-8000-000000000143',:'owner_workspace_id',null),false,'revocation ends support access immediately');
select is((select count(*) from private.support_access_sessions),1::bigint,'support session remains auditable after revocation');
select * from finish();rollback;

