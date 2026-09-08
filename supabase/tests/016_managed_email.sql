begin;set search_path=public,extensions;select plan(17);
insert into auth.users(id,email,raw_user_meta_data) values
 ('00000000-0000-4000-8000-000000000161','email-one@example.test','{"full_name":"Test Creator"}'),
 ('00000000-0000-4000-8000-000000000162','email-two@example.test','{"full_name":"Other Creator"}');
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000161' \gset one_
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000161","role":"authenticated"}';
select like(public.allocate_creator_email_address('inbox.repbureau.test'),'%@inbox.repbureau.test','creator receives an address on the configured subdomain');
select is(public.allocate_creator_email_address('inbox.repbureau.test'),(select address from public.creator_email_addresses where workspace_id=:'one_workspace_id'),'allocation is idempotent');
select is((select count(*) from public.creator_email_addresses),1::bigint,'one primary address is allocated');
set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000162","role":"authenticated"}';
select is((select count(*) from public.creator_email_addresses),0::bigint,'another creator cannot read the address');
reset role;set local role service_role;set local request.jwt.claims='{"role":"service_role"}';
select isnt(public.ingest_managed_email('evt-direct-1','00000000-0000-4000-8000-000000000001','<message-1@brand.test>','brand@brand.test',array[(select address from public.creator_email_addresses where workspace_id=:'one_workspace_id')],array[]::text[],array['brand@brand.test'],'Campaign enquiry','Hello creator',null,now(),'{}','brand@brand.test',null,'fingerprint-one'),null,'direct managed email enters the shared message store');
select is((select count(*) from public.deals where workspace_id=:'one_workspace_id'),1::bigint,'direct email creates one living Deal');
select is((select transport_provider from public.deal_threads where workspace_id=:'one_workspace_id'),'resend','managed transport uses the shared Deal thread');
select is((select transport_provider from public.gmail_messages where workspace_id=:'one_workspace_id'),'resend','managed email uses the shared normalized message table');
select is(public.ingest_managed_email('evt-direct-1','00000000-0000-4000-8000-000000000001','<message-1@brand.test>','brand@brand.test',array[(select address from public.creator_email_addresses where workspace_id=:'one_workspace_id')],array[]::text[],array['brand@brand.test'],'Campaign enquiry','Hello creator',null,now(),'{}','brand@brand.test',null,'fingerprint-one'),(select id from public.gmail_messages where workspace_id=:'one_workspace_id'),'webhook replay returns the original message');
select is((select count(*) from public.gmail_messages where workspace_id=:'one_workspace_id'),1::bigint,'webhook replay cannot duplicate messages');
select is(public.ingest_managed_email('evt-ambiguous','00000000-0000-4000-8000-000000000002','<message-2@brand.test>','brand@brand.test',array['unknown@inbox.repbureau.test'],array[]::text[],array[]::text[],'Unknown destination','Hello',null,now(),'{}',null,null,'fingerprint-two'),null::uuid,'unknown destination fails closed');
select is((select status from private.managed_email_events where provider_event_id='evt-ambiguous'),'rejected','ambiguous destination is recorded without content exposure');
insert into public.provider_email_drafts(workspace_id,deal_id,purpose,provider_route,to_address,subject,body,idempotency_key) select :'one_workspace_id',d.id,'negotiation','managed_email','brand@brand.test','Re: Campaign enquiry','Draft only','managed-send-test' from public.deals d where d.workspace_id=:'one_workspace_id' returning id \gset draft_
reset role;set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000161","role":"authenticated"}';
select throws_ok(format('select public.approve_managed_email_send(%L,1,false)',:'draft_id'),'22023','explicit send confirmation required','outbound send cannot queue without explicit creator confirmation');
select isnt(public.approve_managed_email_send(:'draft_id',1,true),null,'confirmed draft queues exactly one managed send job');
reset role;select is((select count(*) from private.managed_email_send_jobs where draft_id=:'draft_id'),1::bigint,'send job is unique per approved draft');
select is((select enabled from private.feature_flags where key='managed_email_send_enabled'),false,'managed outbound transport is disabled until founder activation');
set local role service_role;set local request.jwt.claims='{"role":"service_role"}';
select is(public.claim_managed_email_send(),null::jsonb,'disabled transport cannot claim an approved send');
select * from finish();rollback;

