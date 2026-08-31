begin;set search_path=public,extensions;select plan(12);
insert into auth.users(id,email) values('00000000-0000-4000-8000-000000000121','billing-one@example.test'),('00000000-0000-4000-8000-000000000122','billing-two@example.test');
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000121' \gset one_
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000122' \gset two_
select is((select count(*) from public.plan_catalog where publicly_visible),2::bigint,'only Standard and Pro are public');
select is((select analysis_limit from public.plan_entitlements where plan_key='standard'),10,'Standard limit is centralized');
select is((select analysis_limit from public.plan_entitlements where plan_key='pro'),null::integer,'Pro is not a customer-visible fixed cap');
select is(has_schema_privilege('authenticated','private','usage'),false,'Stripe event ledger is outside the Data API');
insert into public.subscriptions(workspace_id,plan_key,status,trial_ends_at,current_period_starts_at,current_period_ends_at) values(:'one_workspace_id','standard','trialing',now()+interval '30 days',now(),now()+interval '30 days');
select lives_ok(format('select private.consume_analysis_entitlement(%L)',:'one_workspace_id'),'active trial can consume entitlement');
select is((select value from public.usage_counters where workspace_id=:'one_workspace_id'),1,'usage is counted server-side');
select lives_ok(format('select private.consume_analysis_entitlement(%L) from generate_series(1,9)',:'one_workspace_id'),'remaining Standard allowance is usable');
select throws_ok(format('select private.consume_analysis_entitlement(%L)',:'one_workspace_id'),'P0001','analysis limit reached','eleventh analysis is blocked');
select is((select value from public.usage_counters where workspace_id=:'one_workspace_id'),10,'failed limit attempt rolls back its increment');
select throws_ok(format('select private.consume_analysis_entitlement(%L)',:'two_workspace_id'),'P0001','subscription required','redirect or missing projection grants nothing');
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000122","role":"authenticated"}';
select is((select count(*) from public.subscriptions),0::bigint,'other tenant cannot read subscription');
select is((select count(*) from public.usage_counters),0::bigint,'other tenant cannot read usage');
select * from finish();rollback;
