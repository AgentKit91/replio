begin;set search_path=public,extensions;
select plan(13);
insert into auth.users(id,email,raw_user_meta_data) values('00000000-0000-4000-8000-000000000181','admin-mail@example.test','{"full_name":"Creator"}');
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000181' \gset
insert into public.creator_email_addresses(workspace_id,address,local_part,domain) values(:'workspace_id','creator@inbox.repbureau.test','creator','inbox.repbureau.test');
insert into public.deals(workspace_id,title,status,operational_stage,currency,final_agreed_minor) values(:'workspace_id','Campaign','agreed','ready_to_invoice','GBP',100000) returning id as deal_id \gset
insert into public.invoice_issuer_profiles(workspace_id,legal_name,address,email) values(:'workspace_id','Creator Ltd','1 Street','creator@example.test') returning id as issuer_id \gset
insert into public.invoices(workspace_id,deal_id,issuer_profile_id,status,invoice_number,currency,subtotal_minor,payment_terms_days,issue_date,due_date,billing_entity,billing_address,accounts_payable_email,creator_reviewed_at)
values(:'workspace_id',:'deal_id',:'issuer_id','ready','RB-0001','GBP',100000,30,current_date,current_date+30,'Brand Ltd','2 Road','ap@brand.test',now()) returning id as invoice_id \gset
insert into public.invoice_versions(workspace_id,invoice_id,version,snapshot,pdf_storage_path,pdf_sha256) values(:'workspace_id',:'invoice_id',1,'{}','workspace/invoice/v1.pdf','abc');
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000181","role":"authenticated"}';

select isnt(public.prepare_invoice_email(:'invoice_id','managed_email'),null,'invoice email is prepared');
select is((select state from public.provider_email_drafts where invoice_id=:'invoice_id'),'draft','preparation never approves');
select is((select attachment_refs->0->>'path' from public.provider_email_drafts where invoice_id=:'invoice_id'),'workspace/invoice/v1.pdf','immutable PDF is attached by reference');
select is((select state from public.provider_email_drafts where invoice_id=:'invoice_id'),'draft','preparation remains review-only');
select is(public.prepare_invoice_email(:'invoice_id','managed_email'),(select id from public.provider_email_drafts where invoice_id=:'invoice_id'),'invoice preparation is idempotent');
select throws_ok(format('select public.approve_managed_email_send(%L,1,false)',(select id from public.provider_email_drafts where invoice_id=:'invoice_id')),'22023','explicit send confirmation required','approval requires explicit confirmation');
select isnt(public.approve_managed_email_send((select id from public.provider_email_drafts where invoice_id=:'invoice_id'),1,true),null,'creator confirmation queues one send');
select is((select state from public.provider_email_drafts where invoice_id=:'invoice_id'),'approved','confirmed draft records creator approval');
select is((select status from public.invoices where id=:'invoice_id'),'ready','queueing does not claim the invoice was sent');

reset role;
update public.invoices set status='sent',sent_at=now() where id=:'invoice_id';
insert into public.payment_reminders(workspace_id,invoice_id,reminder_kind,subject,body,due_snapshot,idempotency_key) values(:'workspace_id',:'invoice_id','overdue','Payment reminder','Please confirm payment.',current_date-1,'test-reminder') returning id as reminder_id \gset
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000181","role":"authenticated"}';
select isnt(public.prepare_payment_chase_email(:'reminder_id','managed_email'),null,'payment chase is prepared');
select is((select status from public.payment_reminders where id=:'reminder_id'),'draft','preparation keeps reminder draft-only');
select is((select count(*) from public.provider_email_drafts),2::bigint,'preparing chase adds one reviewable draft');
select is((select to_address from public.provider_email_drafts where payment_reminder_id=:'reminder_id'),'ap@brand.test','chase uses creator-reviewed AP recipient');

select * from finish();
rollback;

