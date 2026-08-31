begin; set search_path=public,extensions; select plan(10);
insert into auth.users(id,email) values('00000000-0000-4000-8000-000000000071','send-one@example.test'),('00000000-0000-4000-8000-000000000072','send-two@example.test');
insert into public.deals(workspace_id,title) select workspace_id,'Send fixture' from public.workspace_members where user_id='00000000-0000-4000-8000-000000000071' returning id,workspace_id \gset deal_
insert into public.integration_connections(workspace_id,user_id,provider,state,connected_identity,granted_scopes) values(:'deal_workspace_id','00000000-0000-4000-8000-000000000071','gmail','active','send-one@example.test','{https://www.googleapis.com/auth/gmail.modify}') returning id \gset integration_
insert into public.gmail_connections(integration_connection_id,workspace_id,gmail_email_address,replio_label_id,watch_status,token_encryption_key_version) values(:'integration_id',:'deal_workspace_id','send-one@example.test','fixture-label','active','v1') returning id \gset connection_
insert into private.gmail_oauth_tokens(gmail_connection_id,encrypted_refresh_token,encryption_iv,encryption_auth_tag,key_version) values(:'connection_id','ciphertext','iv','tag','v1');
insert into public.deal_threads(workspace_id,deal_id,gmail_connection_id,provider_thread_id) values(:'deal_workspace_id',:'deal_id',:'connection_id','fixture-send-thread') returning id \gset thread_
insert into public.gmail_messages(workspace_id,deal_thread_id,provider_message_id,provider_thread_id,internal_date,direction,from_address,to_addresses,subject,body_text,raw_headers) values(:'deal_workspace_id',:'thread_id','fixture-inbound','fixture-send-thread',now(),'inbound','Brand <brand@example.test>','{send-one@example.test}','Synthetic partnership','Hello','{"Message-ID":"<brand-message@example.test>","References":"<earlier@example.test>"}');
insert into public.reply_drafts(workspace_id,deal_id,deal_thread_id,subject,body,version) values(:'deal_workspace_id',:'deal_id',:'thread_id','Synthetic partnership','Creator-approved reply',2) returning id \gset draft_
insert into public.reply_versions(workspace_id,reply_draft_id,version,subject,body,change_kind) values(:'deal_workspace_id',:'draft_id',2,'Synthetic partnership','Creator-approved reply','creator_edit');
set local role authenticated; set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000071","role":"authenticated"}';
select public.request_reply_send(:'deal_id',2) as job_id \gset
select isnt(:'job_id'::uuid,null::uuid,'owner queues an approved reply');
select is((select state from public.reply_drafts where id=:'draft_id'),'sending','draft becomes sending');
select is(public.request_reply_send(:'deal_id',2),:'job_id'::uuid,'repeated request is idempotent');
set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000072","role":"authenticated"}';
select throws_ok(format('select public.request_reply_send(%L,2)',:'deal_id'),'P0002','reply draft not found','other tenant cannot queue send');
reset role; set local role service_role; set local request.jwt.claims='{"role":"service_role"}';
create temporary table claimed_send_job as select public.claim_gmail_send() as job;
select isnt((select job from claimed_send_job),null::jsonb,'service worker claims queued reply');
reset role;
select is((select attempt_count from private.gmail_send_jobs where id=:'job_id'),1,'claim increments attempt count');
set local role service_role; set local request.jwt.claims='{"role":"service_role"}';
select lives_ok($$select public.fail_gmail_send((job->>'queue_message_id')::bigint,(job->>'job_id')::uuid,'TransientProviderError') from claimed_send_job$$,'transient failure is recorded');
reset role;
select is((select status from private.gmail_send_jobs where id=:'job_id'),'queued','send retries below cap');
update private.gmail_send_jobs set attempt_count=3 where id=:'job_id';
set local role service_role; set local request.jwt.claims='{"role":"service_role"}';
select lives_ok($$select public.fail_gmail_send((job->>'queue_message_id')::bigint,(job->>'job_id')::uuid,'ProviderRejected') from claimed_send_job$$,'third failure becomes terminal');
reset role;
select is((select state from public.reply_drafts where id=:'draft_id'),'draft','terminal failure returns the editable draft');
select * from finish(); rollback;
