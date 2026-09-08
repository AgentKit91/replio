begin; set search_path=public,extensions; select plan(18);
insert into auth.users(id,email) values
 ('00000000-0000-4000-8000-000000000151','ops-one@example.test'),
 ('00000000-0000-4000-8000-000000000152','ops-two@example.test');
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000151' \gset one_
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000152' \gset two_
insert into public.deals(workspace_id,title,status,final_agreed_minor,currency) values(:'one_workspace_id','Synthetic operations deal','agreed',125000,'GBP') returning id \gset deal_
set local role authenticated; set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000151","role":"authenticated"}';
select isnt(public.set_deal_operational_fact(:'deal_id','billing_entity','{"name":"Example Brand Ltd"}','Example Brand Ltd'),null,'creator can save a sourced Deal fact');
select isnt(public.set_deal_operational_fact(:'deal_id','billing_entity','{"name":"Corrected Brand Ltd"}','Corrected Brand Ltd'),null,'creator can correct a Deal fact');
select is((select count(*) from public.deal_operational_facts where deal_id=:'deal_id'),2::bigint,'fact history is append-only');
select is((select count(*) from public.deal_operational_facts where deal_id=:'deal_id' and is_current),1::bigint,'only one fact value is current');
select is((select display_value from public.deal_operational_facts where deal_id=:'deal_id' and is_current),'Corrected Brand Ltd','creator correction wins');
insert into public.invoice_issuer_profiles(workspace_id,legal_name,address,email,invoice_prefix,payment_terms_days) values(:'one_workspace_id','Creator Ltd','1 Test Street','creator@example.test','RB',30);
select isnt(public.prepare_deal_invoice(:'deal_id'),null,'invoice is prepared from Deal and profile facts');
select is(public.prepare_deal_invoice(:'deal_id'),(select id from public.invoices where deal_id=:'deal_id'),'invoice preparation is idempotent');
select is((select count(*) from public.invoices where deal_id=:'deal_id'),1::bigint,'one open invoice exists per Deal');
select is((select count(*) from public.invoice_line_items where invoice_id=(select id from public.invoices where deal_id=:'deal_id')),1::bigint,'one deterministic Deal line is prepared');
select is(public.finalise_invoice((select id from public.invoices where deal_id=:'deal_id'),125000),'RB-'||to_char(current_date,'YYYY')||'-0001','finalisation assigns the next deterministic number');
select is((select due_date-issue_date from public.invoices where deal_id=:'deal_id'),30,'due date follows saved payment terms');
select is((select count(*) from public.invoice_versions where invoice_id=(select id from public.invoices where deal_id=:'deal_id')),1::bigint,'finalisation records an immutable invoice version');
select is((select next_sequence from public.invoice_issuer_profiles where workspace_id=:'one_workspace_id'),2,'invoice sequence increments once');
select throws_ok(format('select public.finalise_invoice(%L,125000)',(select id from public.invoices where deal_id=:'deal_id')),'P0002','draft invoice not found','a ready invoice cannot consume another number');
set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000152","role":"authenticated"}';
select is((select count(*) from public.invoices),0::bigint,'another creator cannot read invoices');
select is((select count(*) from public.deal_operational_facts),0::bigint,'another creator cannot read Deal fact history');
select is((select count(*) from public.deal_financial_overview),0::bigint,'financial overview remains tenant isolated');
reset role;
select is((select paid_confirmed_at is null from public.invoices where deal_id=:'deal_id'),true,'payment is not inferred before creator confirmation');
select * from finish(); rollback;

