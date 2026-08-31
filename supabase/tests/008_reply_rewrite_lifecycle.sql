begin; set search_path=public,extensions; select plan(10);
insert into auth.users(id,email) values('00000000-0000-4000-8000-000000000081','rewrite-one@example.test'),('00000000-0000-4000-8000-000000000082','rewrite-two@example.test');
insert into public.deals(workspace_id,title) select workspace_id,'Rewrite fixture' from public.workspace_members where user_id='00000000-0000-4000-8000-000000000081' returning id,workspace_id \gset deal_
insert into public.integration_connections(workspace_id,user_id,provider,state,connected_identity,granted_scopes) values(:'deal_workspace_id','00000000-0000-4000-8000-000000000081','gmail','active','rewrite-one@example.test','{https://www.googleapis.com/auth/gmail.modify}') returning id \gset integration_
insert into public.gmail_connections(integration_connection_id,workspace_id,gmail_email_address,replio_label_id,watch_status,token_encryption_key_version) values(:'integration_id',:'deal_workspace_id','rewrite-one@example.test','fixture-label','active','v1') returning id \gset connection_
insert into private.gmail_oauth_tokens(gmail_connection_id,encrypted_refresh_token,encryption_iv,encryption_auth_tag,key_version) values(:'connection_id','ciphertext','iv','tag','v1');
insert into public.deal_threads(workspace_id,deal_id,gmail_connection_id,provider_thread_id) values(:'deal_workspace_id',:'deal_id',:'connection_id','fixture-rewrite-thread') returning id \gset thread_
insert into public.gmail_messages(workspace_id,deal_thread_id,provider_message_id,provider_thread_id,internal_date,direction,from_address,to_addresses,subject,body_text,raw_headers) values(:'deal_workspace_id',:'thread_id','fixture-rewrite-inbound','fixture-rewrite-thread',now()-interval '1 minute','inbound','Brand <brand@example.test>','{rewrite-one@example.test}','Synthetic partnership','Hello','{"Message-ID":"<rewrite-brand@example.test>"}');
insert into public.reply_drafts(workspace_id,deal_id,deal_thread_id,subject,body,version) values(:'deal_workspace_id',:'deal_id',:'thread_id','Synthetic partnership','Creator wording',2) returning id \gset draft_
insert into public.reply_versions(workspace_id,reply_draft_id,version,subject,body,change_kind) values(:'deal_workspace_id',:'draft_id',2,'Synthetic partnership','Creator wording','creator_edit');
set local role authenticated; set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000081","role":"authenticated"}';
select is(public.apply_reply_rewrite(:'deal_id','Creator wording, tightened.',2,'shorter',false),3,'owner applies targeted rewrite');
select is((select body from public.reply_drafts where id=:'draft_id'),'Creator wording, tightened.','rewrite becomes current body');
select is((select change_kind from public.reply_versions where reply_draft_id=:'draft_id' and version=3),'targeted_rewrite','targeted rewrite is immutable version');
select throws_ok(format('select public.apply_reply_rewrite(%L,%L,2,%L,false)',:'deal_id','stale','shorter'),'40001','reply version conflict','stale rewrite cannot overwrite creator work');
select lives_ok(format('select public.acknowledge_reply_challenge(%L)',:'deal_id'),'owner can acknowledge a respectful challenge once');
set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000082","role":"authenticated"}';
select throws_ok(format('select public.apply_reply_rewrite(%L,%L,3,%L,false)',:'deal_id','foreign','shorter'),'P0002','reply draft not found','other tenant cannot rewrite');
reset role; update public.reply_drafts set version=3 where id=:'draft_id';
set local role authenticated; set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000081","role":"authenticated"}'; select public.request_reply_send(:'deal_id',3) as job_id \gset
reset role; set local role service_role; set local request.jwt.claims='{"role":"service_role"}'; create temporary table lifecycle_job as select public.claim_gmail_send() as job; select lives_ok($$select public.finish_gmail_send((job->>'queue_message_id')::bigint,(job->>'job_id')::uuid,'sent-provider-id') from lifecycle_job$$,'successful send is persisted');
reset role; select is((select status from public.deals where id=:'deal_id'),'awaiting_brand'::public.deal_status,'send waits on brand');
select is((select count(*) from public.gmail_messages where deal_thread_id=:'thread_id' and direction='outbound'),1::bigint,'sent reply appears immediately');
set local role service_role; set local request.jwt.claims='{"role":"service_role"}';
select public.persist_gmail_thread(:'deal_workspace_id',:'connection_id','fixture-rewrite-thread','Synthetic partnership',jsonb_build_array(jsonb_build_object('provider_message_id','fixture-brand-reply','provider_history_id','2','internal_date',(now()+interval '1 minute')::text,'direction','inbound','from_address','Brand <brand@example.test>','to_addresses',jsonb_build_array('rewrite-one@example.test'),'cc_addresses','[]'::jsonb,'subject','Synthetic partnership','body_text','Following up','provider_label_ids',jsonb_build_array('fixture-label'),'raw_headers',jsonb_build_object('Message-ID','<brand-reply@example.test>'),'attachments','[]'::jsonb)));
reset role; select is((select status from public.deals where id=:'deal_id'),'awaiting_creator'::public.deal_status,'new brand reply returns the deal to creator');
select * from finish(); rollback;
