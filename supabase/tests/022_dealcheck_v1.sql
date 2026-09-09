begin; set search_path=public,extensions; select plan(28);
insert into auth.users(id,email) values
 ('00000000-0000-4000-8000-000000000221','dealcheck-one@example.test'),
 ('00000000-0000-4000-8000-000000000222','dealcheck-two@example.test');

select is(has_table_privilege('anon','public.dealcheck_checks','select'),false,'anonymous cannot read checks');
select is(has_table_privilege('authenticated','public.dealcheck_checks','insert'),false,'browser cannot fabricate checks');
select is(has_table_privilege('authenticated','public.dealcheck_accounts','update'),false,'browser cannot update balances');
select is(has_function_privilege('authenticated','public.grant_dealcheck_stripe_pack(uuid,text,integer,text)','execute'),false,'browser cannot grant packs');

set local role authenticated; set local request.jwt.claims='{"role":"authenticated","sub":"00000000-0000-4000-8000-000000000221"}';
select is(public.dealcheck_initialize_account(),1,'first account initialization grants one credit');
select is(public.dealcheck_initialize_account(),1,'repeated initialization does not grant again');
select is((select count(*) from public.dealcheck_credit_transactions where reason='signup_free'),1::bigint,'one lifetime grant ledger row');
select public.dealcheck_start_check('00000000-0000-4000-8000-000000000229','Offer is £500 for one Reel','instagram',20000,null,null) as started \gset
select is((:'started'::jsonb->>'reused')::boolean,false,'first request creates check');
select is((select credit_balance from public.dealcheck_accounts),0,'check consumes one credit');
select public.dealcheck_start_check('00000000-0000-4000-8000-000000000229','Offer is £500 for one Reel','instagram',20000,null,null) as duplicate \gset
select is((:'duplicate'::jsonb->>'reused')::boolean,true,'duplicate request reuses check');
select is((select count(*) from public.dealcheck_credit_transactions where reason='check_consumed'),1::bigint,'duplicate consumes once');
select throws_ok($$select public.dealcheck_start_check('00000000-0000-4000-8000-000000000228','Another £500 offer','instagram',20000,null,null)$$,'P0001','NO_CREDITS','zero balance blocks before processing');
select is((select count(*) from public.dealcheck_checks),1::bigint,'blocked request creates no check');

set local request.jwt.claims='{"role":"authenticated","sub":"00000000-0000-4000-8000-000000000222"}';
select is((select count(*) from public.dealcheck_checks),0::bigint,'another user cannot read private checks');
select is((select count(*) from public.dealcheck_accounts),0::bigint,'another user cannot read account');
reset role; set local role service_role; set local request.jwt.claims='{"role":"service_role"}';
select is(public.refund_failed_dealcheck((:'started'::jsonb->>'check_id')::uuid,'PROVIDER_FAILURE'),true,'failed check refunds');
select is(public.refund_failed_dealcheck((:'started'::jsonb->>'check_id')::uuid,'PROVIDER_FAILURE'),false,'refund replay is inert');
select is((select credit_balance from public.dealcheck_accounts where user_id='00000000-0000-4000-8000-000000000221'),1,'refund restores exactly one');
select is(public.grant_dealcheck_stripe_pack('00000000-0000-4000-8000-000000000221','cs_test_pack',3,'pack_3'),true,'verified pack grants three');
select is(public.grant_dealcheck_stripe_pack('00000000-0000-4000-8000-000000000221','cs_test_pack',3,'pack_3'),false,'Stripe session replay is idempotent');
select is((select credit_balance from public.dealcheck_accounts where user_id='00000000-0000-4000-8000-000000000221'),4,'replay cannot duplicate paid credits');
select is(public.grant_dealcheck_stripe_pack('00000000-0000-4000-8000-000000000221','cs_test_pack_10',10,'pack_10'),true,'verified 10-pack grants ten');
select is(public.grant_dealcheck_stripe_pack('00000000-0000-4000-8000-000000000221','cs_test_pack_10',10,'pack_10'),false,'10-pack replay is idempotent');
select is((select credit_balance from public.dealcheck_accounts where user_id='00000000-0000-4000-8000-000000000221'),14,'both paid packs grant exact quantities');
reset role; set local role authenticated; set local request.jwt.claims='{"role":"authenticated","sub":"00000000-0000-4000-8000-000000000221"}';
select public.dealcheck_start_check('00000000-0000-4000-8000-000000000227','A purchased-credit check for £750','tiktok',30000,15000,4.2) as purchased \gset
select is((:'purchased'::jsonb->>'reused')::boolean,false,'purchased credit starts another check');
select is((select credit_balance from public.dealcheck_accounts),13,'another completed-flow start consumes exactly one purchased credit');
reset role; set local role service_role; set local request.jwt.claims='{"role":"service_role"}';
select is(public.complete_dealcheck((:'purchased'::jsonb->>'check_id')::uuid,'{"monetaryOfferGbp":750}'::jsonb,'{"version":"uk_shortform_v1_2026_09_08"}'::jsonb,85,'{"label":"Strong offer"}'::jsonb,'{}'::jsonb),true,'service boundary completes a processing check');
select is((select status from public.dealcheck_checks where id=(:'purchased'::jsonb->>'check_id')::uuid),'completed','completed result is stored');
select * from finish(); rollback;
