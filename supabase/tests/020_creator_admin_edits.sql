begin;set search_path=public,extensions;
select plan(14);
insert into auth.users(id,email,raw_user_meta_data) values('00000000-0000-4000-8000-000000000201','admin-edits@example.test','{"full_name":"Creator"}');
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000201' \gset
insert into public.deals(workspace_id,title,status,operational_stage,currency,final_agreed_minor) values(:'workspace_id','Editable campaign','agreed','ready_to_invoice','GBP',100000) returning id as deal_id \gset
insert into public.invoice_issuer_profiles(workspace_id,legal_name,address,email) values(:'workspace_id','Creator Ltd','1 Street','creator@example.test') returning id as issuer_id \gset
insert into public.invoices(workspace_id,deal_id,issuer_profile_id,status,currency,subtotal_minor,payment_terms_days) values(:'workspace_id',:'deal_id',:'issuer_id','draft','GBP',100000,30) returning id as invoice_id \gset
insert into public.invoice_line_items(workspace_id,invoice_id,position,description,quantity,unit_amount_minor,line_total_minor,source_kind) values(:'workspace_id',:'invoice_id',1,'Old item',1,100000,100000,'deal');
insert into public.provider_email_drafts(workspace_id,deal_id,purpose,provider_route,to_address,subject,body,state,idempotency_key) values(:'workspace_id',:'deal_id','invoice','managed_email','ap@brand.test','Old subject','Old body','draft','edit-test') returning id as draft_id \gset

set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000201","role":"authenticated"}';
select isnt(public.save_deal_deadline(:'deal_id',null,'publish_due','Post live','2026-10-01T10:00:00Z','open'),null,'creator adds a deadline');
select is((select status from public.deal_deadlines where deal_id=:'deal_id'),'open','new deadline is open');
select isnt(public.save_deal_deadline(:'deal_id',(select id from public.deal_deadlines where deal_id=:'deal_id'),'publish_due','Post published','2026-10-01T11:00:00Z','completed'),null,'creator updates the same deadline');
select is((select count(*) from public.deal_deadlines where deal_id=:'deal_id'),1::bigint,'deadline edit is not a duplicate');
select isnt(public.save_deal_contract_reference(:'deal_id','received','creator_signed','contract.pdf'),null,'creator saves contract status');
select isnt(public.save_deal_contract_reference(:'deal_id','received','fully_signed','signed.pdf'),null,'contract status upserts');
select is((select count(*) from public.deal_contract_references where deal_id=:'deal_id'),1::bigint,'contract upsert is not a duplicate');
select is(public.update_draft_invoice(:'invoice_id','Brand Ltd','2 Road','AP@Brand.Test','PO-42','Two posts',2,60000,20000,45),140000::bigint,'invoice total is deterministic');
select is((select total_minor from public.invoices where id=:'invoice_id'),140000::bigint,'invoice stores creator tax and calculated subtotal');
select is((select accounts_payable_email from public.invoices where id=:'invoice_id'),'ap@brand.test','AP recipient is normalized');
select is(public.update_admin_email_draft(:'draft_id',1,'Invoice attached','Please find the invoice attached.'),2,'email edit increments version');
select is((select state from public.provider_email_drafts where id=:'draft_id'),'draft','editing never approves or sends');
select throws_ok(format('select public.update_admin_email_draft(%L,1,%L,%L)',:'draft_id','Stale','Stale body'),'40001','draft changed','stale email edit fails closed');
reset role;
select is((select count(*) from pg_policies where schemaname='public' and tablename in ('invoice_issuer_profiles','invoice_line_items') and policyname like '%member_select'),0::bigint,'redundant select policies are removed');
select * from finish();rollback;

