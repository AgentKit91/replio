begin;
set search_path=public,extensions;
select plan(13);

select is(has_function_privilege('authenticated','private.refresh_benchmark_cells()','execute'),false,'creators cannot run internal aggregation');

insert into private.benchmark_contributions(
  anonymisation_version,benchmark_algorithm_version,creator_niche,platform,creator_size_bucket,
  deliverable_signature,currency,initial_offer_minor,final_amount_minor,estimated_uplift_minor,
  negotiation_rounds,response_seconds,outcome
)
select 1,1,'synthetic_niche','synthetic_platform','10k_49k','synthetic_post:1','GBP',
  10000+n*1000,20000+n*2000,10000+n*1000,n,100+n,'success'
from generate_series(1,4) n;

select is(private.refresh_benchmark_cells(),0,'four matching contributions remain below the evidence floor');
select is((select count(*) from public.benchmark_cells),0::bigint,'no sub-threshold cell is stored');

insert into private.benchmark_contributions(
  anonymisation_version,benchmark_algorithm_version,creator_niche,platform,creator_size_bucket,
  deliverable_signature,currency,initial_offer_minor,final_amount_minor,estimated_uplift_minor,
  negotiation_rounds,response_seconds,outcome
) values(1,1,'synthetic_niche','synthetic_platform','10k_49k','synthetic_post:1','GBP',15000,30000,15000,5,105,'success');

select is(private.refresh_benchmark_cells(),1,'five matching contributions create one eligible cell');
select is((select sample_count from public.benchmark_cells),5,'cell records its evidence count');
select is((select median_offer_minor from public.benchmark_cells),13000::bigint,'offer median is reproducible');
select is((select median_settlement_minor from public.benchmark_cells),26000::bigint,'settlement median is reproducible');
select is((select median_uplift_minor from public.benchmark_cells),13000::bigint,'uplift median is reproducible');
select is((select evidence_strength from public.benchmark_cells),'emerging','five samples are labelled emerging');
select ok(not ((select dimensions from public.benchmark_cells) ?| array['creator_id','workspace_id','deal_id','contact_id','message_id','brand_id']),'public dimensions contain no linkable identifiers');
select is((select dimensions->>'creator_niche' from public.benchmark_cells),'synthetic_niche','only approved coarse dimensions are exposed');

delete from private.benchmark_contributions where initial_offer_minor=15000;
select is(private.refresh_benchmark_cells(),0,'refresh removes a cell after evidence falls below the floor');
select is((select count(*) from public.benchmark_cells),0::bigint,'no stale sub-threshold cell survives');

select * from finish();
rollback;
