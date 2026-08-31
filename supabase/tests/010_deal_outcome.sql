begin;set search_path=public,extensions;select plan(8);
insert into auth.users(id,email) values('00000000-0000-4000-8000-000000000101','outcome-one@example.test'),('00000000-0000-4000-8000-000000000102','outcome-two@example.test');
insert into public.deals(workspace_id,title,currency) select workspace_id,'Outcome fixture','GBP' from public.workspace_members where user_id='00000000-0000-4000-8000-000000000101' returning id,workspace_id \gset deal_
insert into public.deal_offers(workspace_id,deal_id,offered_by,amount_minor,currency,offer_type,observed_at) values(:'deal_workspace_id',:'deal_id','brand',50000,'GBP','initial',now()-interval '1 day');
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000101","role":"authenticated"}';
select public.complete_deal_outcome(:'deal_id','success',125000,3) as outcome_id \gset
select isnt(:'outcome_id'::uuid,null::uuid,'creator completes own deal');
select is((select estimated_additional_earnings_minor from public.deal_outcomes where id=:'outcome_id'),75000::bigint,'estimated earnings use positive negotiated uplift');
select is((select eae_method_version from public.deal_outcomes where id=:'outcome_id'),1,'EAE method is versioned');
select is((select status from public.deals where id=:'deal_id'),'completed'::public.deal_status,'successful outcome completes deal');
reset role;select is((select count(*) from private.benchmark_contributions),1::bigint,'one de-identified contribution is produced');
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000101","role":"authenticated"}';select public.complete_deal_outcome(:'deal_id','success',125000,3);
reset role;select is((select count(*) from private.benchmark_contributions),1::bigint,'repeated completion never duplicates contribution');
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000102","role":"authenticated"}';
select throws_ok(format('select public.complete_deal_outcome(%L,%L,125000,3)',:'deal_id','success'),'P0002','deal not found','other tenant cannot complete outcome');
select is((select count(*) from public.deal_outcomes),0::bigint,'other tenant cannot read private recap');
select * from finish();rollback;
