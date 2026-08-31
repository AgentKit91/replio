create or replace function public.complete_deal_outcome(p_deal_id uuid,p_outcome text,p_final_amount_minor bigint,p_negotiation_rounds integer,p_major_term_improvements jsonb default '[]'::jsonb,p_contextual_learning jsonb default '{}'::jsonb) returns uuid language plpgsql security definer set search_path='' as $$
declare v_deal public.deals;v_profile public.creator_profiles;v_initial bigint;v_eae bigint;v_uplift numeric(9,2);v_outcome_id uuid;v_algorithm integer;v_platform text;v_size_bucket text;v_deliverables text;
begin
  if p_outcome not in ('success','lost','declined') or p_final_amount_minor<0 or p_negotiation_rounds<0 then raise exception 'invalid outcome' using errcode='22023';end if;
  select d.* into v_deal from public.deals d join public.workspace_members wm on wm.workspace_id=d.workspace_id where d.id=p_deal_id and d.deleted_at is null and wm.user_id=auth.uid() for update of d;
  if v_deal.id is null then raise exception 'deal not found' using errcode='P0002';end if;
  select min(amount_minor) filter(where offered_by='brand' and offer_type='initial') into v_initial from public.deal_offers where deal_id=v_deal.id;
  if v_initial is null then select amount_minor into v_initial from public.deal_offers where deal_id=v_deal.id and offered_by='brand' order by observed_at limit 1;end if;
  v_eae:=case when v_initial is null then 0 else greatest(0,p_final_amount_minor-v_initial) end;
  v_uplift:=case when coalesce(v_initial,0)>0 then round((v_eae::numeric/v_initial::numeric)*100,2) else null end;
  insert into public.deal_outcomes(workspace_id,deal_id,outcome,currency,initial_offer_minor,final_amount_minor,estimated_additional_earnings_minor,uplift_percent,negotiation_rounds,major_term_improvements,contextual_learning,eae_method_version,eae_inputs)
  values(v_deal.workspace_id,v_deal.id,p_outcome,v_deal.currency,v_initial,p_final_amount_minor,v_eae,v_uplift,p_negotiation_rounds,coalesce(p_major_term_improvements,'[]'::jsonb),coalesce(p_contextual_learning,'{}'::jsonb),1,jsonb_build_object('initial_offer_minor',v_initial,'final_amount_minor',p_final_amount_minor))
  on conflict(deal_id) do update set outcome=excluded.outcome,final_amount_minor=excluded.final_amount_minor,estimated_additional_earnings_minor=excluded.estimated_additional_earnings_minor,uplift_percent=excluded.uplift_percent,negotiation_rounds=excluded.negotiation_rounds,major_term_improvements=excluded.major_term_improvements,contextual_learning=excluded.contextual_learning,eae_inputs=excluded.eae_inputs,updated_at=now()
  returning id into v_outcome_id;
  update public.deals set status=case p_outcome when 'success' then 'completed'::public.deal_status when 'declined' then 'declined'::public.deal_status else 'lost'::public.deal_status end,final_agreed_minor=case when p_outcome='success' then p_final_amount_minor else null end,human_status_code=case p_outcome when 'success' then 'work_complete' when 'declined' then 'declined' else 'lost' end,updated_at=now() where id=v_deal.id;
  if not exists(select 1 from public.deal_outcomes where id=v_outcome_id and benchmark_contributed_at is not null) then
    select * into v_profile from public.creator_profiles where workspace_id=v_deal.workspace_id;
    select version into v_algorithm from public.benchmark_algorithm_versions where state='current';
    select platform into v_platform from public.deal_deliverables where deal_id=v_deal.id order by created_at limit 1;
    select string_agg(deliverable_type||':'||quantity::text,',' order by deliverable_type) into v_deliverables from public.deal_deliverables where deal_id=v_deal.id;
    select case when max(followers) is null then null when max(followers)<10000 then 'under_10k' when max(followers)<50000 then '10k_49k' when max(followers)<250000 then '50k_249k' when max(followers)<1000000 then '250k_999k' else '1m_plus' end into v_size_bucket from public.creator_platforms where workspace_id=v_deal.workspace_id;
    insert into private.benchmark_contributions(anonymisation_version,benchmark_algorithm_version,brand_id,creator_niche,platform,creator_size_bucket,deliverable_signature,currency,initial_offer_minor,final_amount_minor,estimated_uplift_minor,negotiation_rounds,outcome)
    values(1,v_algorithm,v_deal.brand_id,v_profile.niche,v_platform,v_size_bucket,v_deliverables,v_deal.currency,v_initial,p_final_amount_minor,v_eae,p_negotiation_rounds,p_outcome);
    update public.deal_outcomes set benchmark_contributed_at=now() where id=v_outcome_id;
  end if;
  insert into public.activity_events(workspace_id,actor_user_id,event_type,entity_type,entity_id,metadata) values(v_deal.workspace_id,auth.uid(),'deal_outcome_recorded','deal',v_deal.id,jsonb_build_object('outcome',p_outcome,'eae_method_version',1));
  return v_outcome_id;
end $$;
revoke all on function public.complete_deal_outcome(uuid,text,bigint,integer,jsonb,jsonb) from public,anon;
grant execute on function public.complete_deal_outcome(uuid,text,bigint,integer,jsonb,jsonb) to authenticated;
