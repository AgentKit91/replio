begin;set search_path=public,extensions;select plan(8);
insert into auth.users(id,email) values('00000000-0000-4000-8000-000000000131','stripe-projection@example.test');
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000131' \gset owner_
select is(has_function_privilege('authenticated','public.project_stripe_subscription(text,text,timestamptz,uuid,text,text,text,text,timestamptz,timestamptz,timestamptz,boolean)','execute'),false,'browser cannot project Stripe state');
set local role service_role;set local request.jwt.claims='{"role":"service_role"}';
select is(public.project_stripe_subscription('evt_new','customer.subscription.created','2026-08-31T20:00:00Z',:'owner_workspace_id','standard','cus_test','sub_test','trialing','2026-09-30T20:00:00Z','2026-08-31T20:00:00Z','2026-09-30T20:00:00Z',false),true,'verified event projects subscription');
select is((select status from public.subscriptions where workspace_id=:'owner_workspace_id'),'trialing','projected status is stored');
select is(public.project_stripe_subscription('evt_new','customer.subscription.created','2026-08-31T20:00:00Z',:'owner_workspace_id','standard','cus_test','sub_test','trialing','2026-09-30T20:00:00Z','2026-08-31T20:00:00Z','2026-09-30T20:00:00Z',false),false,'duplicate event is idempotent');
reset role;
select is((select count(*) from private.stripe_events),1::bigint,'duplicate event has one ledger row');
set local role service_role;set local request.jwt.claims='{"role":"service_role"}';
select is(public.project_stripe_subscription('evt_old','customer.subscription.updated','2026-08-30T20:00:00Z',:'owner_workspace_id','standard','cus_test','sub_test','past_due',null,'2026-08-01T20:00:00Z','2026-09-01T20:00:00Z',false),true,'older verified event is recorded');
select is((select status from public.subscriptions where workspace_id=:'owner_workspace_id'),'trialing','older event cannot overwrite newer access state');
select is(public.record_stripe_event('evt_invoice','invoice.paid','2026-08-31T21:00:00Z'),true,'non-projection event is idempotently recorded');
select * from finish();rollback;
