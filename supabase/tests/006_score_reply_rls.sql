begin; set search_path=public,extensions; select plan(8);
insert into auth.users(id,email) values('00000000-0000-4000-8000-000000000061','reply-one@example.test'),('00000000-0000-4000-8000-000000000062','reply-two@example.test');
insert into public.deals(workspace_id,title) select workspace_id,'Reply fixture' from public.workspace_members where user_id='00000000-0000-4000-8000-000000000061' returning id,workspace_id \gset deal_
insert into public.integration_connections(workspace_id,user_id,provider,state,connected_identity,granted_scopes) values(:'deal_workspace_id','00000000-0000-4000-8000-000000000061','gmail','active','reply-one@example.test','{}') returning id \gset integration_
insert into public.gmail_connections(integration_connection_id,workspace_id,gmail_email_address,replio_label_id,watch_status,token_encryption_key_version) values(:'integration_id',:'deal_workspace_id','reply-one@example.test','fixture-label','active','v1') returning id \gset connection_
insert into public.deal_threads(workspace_id,deal_id,gmail_connection_id,provider_thread_id) values(:'deal_workspace_id',:'deal_id',:'connection_id','fixture-thread') returning id \gset thread_
insert into public.reply_drafts(workspace_id,deal_id,deal_thread_id,subject,body) values(:'deal_workspace_id',:'deal_id',:'thread_id','Hello','Initial') returning id \gset draft_
insert into public.reply_versions(workspace_id,reply_draft_id,version,subject,body,change_kind) values(:'deal_workspace_id',:'draft_id',1,'Hello','Initial','ai_initial');
set local role authenticated; set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000061","role":"authenticated"}';
select is((select count(*)::int from public.reply_drafts),1,'owner sees draft');
select is((select count(*)::int from public.reply_versions),1,'owner sees version');
select is(public.save_reply_draft(:'deal_id','Hello','Creator edit',1),2,'owner autosaves next version');
select is((select creator_edited from public.reply_drafts),true,'autosave records creator edit');
select is((select count(*)::int from public.reply_versions),2,'autosave appends immutable version');
select throws_ok(format('select public.save_reply_draft(%L,%L,%L,1)',:'deal_id','Old','Stale'),'40001','reply version conflict','stale autosave is rejected');
set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000062","role":"authenticated"}';
select is((select count(*)::int from public.reply_drafts),0,'other tenant cannot see draft');
select throws_ok(format('select public.save_reply_draft(%L,%L,%L,2)',:'deal_id','No','Access'),'P0002','reply draft not found','other tenant cannot edit draft');
select * from finish(); rollback;
