create or replace function private.refresh_benchmark_cells()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_version integer;
  v_minimum integer;
  v_inserted integer;
begin
  select version, minimum_sample_count
  into strict v_version, v_minimum
  from public.benchmark_algorithm_versions
  where state = 'current';

  delete from public.benchmark_cells where algorithm_version = v_version;

  with grouped as (
    select
      jsonb_strip_nulls(jsonb_build_object(
        'creator_niche', creator_niche,
        'platform', platform,
        'creator_size_bucket', creator_size_bucket,
        'deliverable_signature', deliverable_signature
      )) as dimensions,
      currency,
      count(*)::integer as sample_count,
      round(percentile_cont(0.5) within group (order by initial_offer_minor))::bigint as median_offer_minor,
      round(percentile_cont(0.5) within group (order by final_amount_minor))::bigint as median_settlement_minor,
      round(percentile_cont(0.25) within group (order by final_amount_minor))::bigint as p25_settlement_minor,
      round(percentile_cont(0.75) within group (order by final_amount_minor))::bigint as p75_settlement_minor,
      round(percentile_cont(0.5) within group (order by estimated_uplift_minor))::bigint as median_uplift_minor,
      round(percentile_cont(0.5) within group (order by negotiation_rounds)::numeric, 2) as median_rounds,
      round(percentile_cont(0.5) within group (order by response_seconds))::bigint as median_response_seconds
    from private.benchmark_contributions
    where benchmark_algorithm_version = v_version
    group by creator_niche, platform, creator_size_bucket, deliverable_signature, currency
    having count(*) >= v_minimum
  )
  insert into public.benchmark_cells(
    dimension_signature, dimensions, currency, sample_count,
    median_offer_minor, median_settlement_minor, p25_settlement_minor,
    p75_settlement_minor, median_uplift_minor, median_rounds,
    median_response_seconds, evidence_strength, algorithm_version
  )
  select
    encode(extensions.digest(convert_to(dimensions::text, 'UTF8'), 'sha256'), 'hex'),
    dimensions, currency, sample_count, median_offer_minor,
    median_settlement_minor, p25_settlement_minor, p75_settlement_minor,
    median_uplift_minor, median_rounds, median_response_seconds,
    case when sample_count >= greatest(v_minimum * 4, 20) then 'strong' else 'emerging' end,
    v_version
  from grouped;

  get diagnostics v_inserted = row_count;
  return v_inserted;
end;
$$;

revoke all on function private.refresh_benchmark_cells() from public, anon, authenticated;

select cron.schedule(
  'replio-benchmark-refresh',
  '30 3 * * *',
  'select private.refresh_benchmark_cells();'
);

comment on function private.refresh_benchmark_cells() is
  'Rebuilds current-version benchmark cells atomically; groups below the versioned evidence floor are omitted.';
