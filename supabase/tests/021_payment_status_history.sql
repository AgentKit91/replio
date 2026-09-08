begin;set search_path=public,extensions;select plan(7);
insert into auth.users(id,email,raw_user_meta_data) values('00000000-0000-4000-8000-000000000211','payment-state@example.test','{"full_name":"Creator"}');
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000211' \gset
insert into public.deals(workspace_id,title,status,operational_stage,currency) values(:'workspace_id','Payment campaign','agreed','payment_due','GBP') returning id as deal_id \gset
insert into public.invoice_issuer_profiles(workspace_id,legal_name,address,email) values(:'workspace_id','Creator','1 Street','creator@example.test') returning id as issuer_id \gset
insert into public.invoices(workspace_id,deal_id,issuer_profile_id,status,currency,subtotal_minor,payment_terms_days) values(:'workspace_id',:'deal_id',:'issuer_id','sent','GBP',10000,30) returning id as invoice_id \gset
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000211","role":"authenticated"}';
select isnt(public.record_invoice_still_waiting(:'invoice_id'),null,'still waiting is recorded');
select is((select status from public.invoices where id=:'invoice_id'),'sent','still waiting never infers a state change');
select throws_ok(format('select public.write_off_invoice(%L,false)',:'invoice_id'),'22023','explicit confirmation required','write-off needs confirmation');
select lives_ok(format('select public.write_off_invoice(%L,true)',:'invoice_id'),'creator can explicitly write off');
select is((select status from public.invoices where id=:'invoice_id'),'written_off','write-off updates invoice');
select is((select count(*) from public.payment_status_events where invoice_id=:'invoice_id'),2::bigint,'payment checks preserve history');
select is((select string_agg(event_type,',' order by event_type) from public.payment_status_events where invoice_id=:'invoice_id'),'still_waiting,written_off','history distinguishes creator decisions');
select * from finish();rollback;

