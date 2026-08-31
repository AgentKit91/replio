begin;set search_path=public,extensions;select plan(13);
insert into auth.users(id,email) values('00000000-0000-4000-8000-000000000091','learning-one@example.test'),('00000000-0000-4000-8000-000000000092','learning-two@example.test');
select workspace_id from public.workspace_members where user_id='00000000-0000-4000-8000-000000000091' \gset one_
set local role authenticated;set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000091","role":"authenticated"}';
insert into public.creator_goals(workspace_id,goal_code,priority) values(:'one_workspace_id','increase_rates',1),(:'one_workspace_id','better_terms',2),(:'one_workspace_id','save_time',3);
select is((select count(*) from public.creator_goals),3::bigint,'creator can own three goals');
select throws_ok(format('insert into public.creator_goals(workspace_id,goal_code,priority) values(%L,%L,1)',:'one_workspace_id','other'),'23505',null,'three priority slots enforce the goal limit');
insert into public.creator_non_negotiables(workspace_id,category,rule_text) values(:'one_workspace_id','commercial','Synthetic minimum only');
select is((select count(*) from public.creator_non_negotiables),1::bigint,'creator can store own red line');
insert into public.rate_cards(workspace_id,name,currency) values(:'one_workspace_id','Private card','GBP') returning id \gset card_
insert into public.rate_card_items(workspace_id,rate_card_id,platform,deliverable_type,amount_minor) values(:'one_workspace_id',:'card_id','instagram','synthetic_post',50000);
select is((select count(*) from public.rate_card_items),1::bigint,'creator can store private rate');
set local request.jwt.claims='{"sub":"00000000-0000-4000-8000-000000000092","role":"authenticated"}';
select is((select count(*) from public.creator_goals),0::bigint,'other creator cannot read goals');
select is((select count(*) from public.creator_non_negotiables),0::bigint,'other creator cannot read red lines');
select is((select count(*) from public.rate_cards),0::bigint,'other creator cannot read rate card');
select throws_ok(format('insert into public.creator_goals(workspace_id,goal_code,priority) values(%L,%L,1)',:'one_workspace_id','increase_rates'),'42501',null,'other creator cannot write goal');
select is((select count(*) from public.benchmark_cells),0::bigint,'no fake benchmark intelligence is seeded');
select is(has_table_privilege('authenticated','private.benchmark_contributions','select'),false,'authenticated API cannot read raw contributions');
reset role;select is((select count(*) from private.benchmark_contributions),0::bigint,'raw benchmark store starts empty');
select is((select minimum_sample_count from public.benchmark_algorithm_versions where state='current'),5,'minimum evidence gate is versioned');
select is((select count(*) from public.deal_outcomes),0::bigint,'outcomes begin empty and private');
select * from finish();rollback;
