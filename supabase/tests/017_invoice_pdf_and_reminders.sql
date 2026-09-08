begin;set search_path=public,extensions;select plan(10);
select is((select public from storage.buckets where id='invoice-pdfs'),false,'invoice PDF bucket is private');
select is((select file_size_limit from storage.buckets where id='invoice-pdfs'),5000000::bigint,'invoice PDF size is bounded');
insert into auth.users(id,email) values('00000000-0000-4000-8000-000000000171','invoice-admin@example.test');
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000171' \gset inv_
insert into public.deals(workspace_id,title,status,final_agreed_minor,currency) values(:'inv_workspace_id','Reminder fixture','agreed',90000,'GBP') returning id \gset deal_
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000171","role":"authenticated"}';
insert into public.invoice_issuer_profiles(workspace_id,legal_name,address,email) values(:'inv_workspace_id','Creator Ltd','1 Test Street','creator@example.test');
select public.prepare_deal_invoice(:'deal_id') as invoice_id \gset
select is(public.finalise_invoice(:'invoice_id',90000),'RB-'||to_char(current_date,'YYYY')||'-0001','invoice finalisation remains deterministic');
reset role;update public.invoices set status='sent',sent_at=now(),due_date=current_date-1 where id=:'invoice_id';
select is(private.prepare_payment_reminder_drafts(current_date),1,'overdue reminder draft is prepared automatically');
select is(private.prepare_payment_reminder_drafts(current_date),0,'reminder preparation is idempotent');
select is((select reminder_kind from public.payment_reminders where invoice_id=:'invoice_id'),'overdue','overdue context is deterministic');
select is((select status from public.payment_reminders where invoice_id=:'invoice_id'),'draft','automatic admin never approves a reminder');
select is((select sent_at from public.payment_reminders where invoice_id=:'invoice_id'),null::timestamptz,'automatic admin never sends a reminder');
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000171","role":"authenticated"}';
select is((select agreed_minor from public.deal_financial_overview where currency='GBP'),90000::bigint,'financial overview keeps agreed value distinct');
select is((select overdue_minor from public.deal_financial_overview where currency='GBP'),90000::bigint,'financial overview reports overdue value by currency');
select * from finish();rollback;

