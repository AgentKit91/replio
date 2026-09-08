-- Makes repeated analysis completion replay-safe for extracted deadlines.
create unique index deal_deadlines_analysis_source_idx on public.deal_deadlines(deal_id,deadline_type,source_id,due_at) where source_kind='ai_extraction' and source_id is not null;

create or replace function public.apply_analysis_deal_deltas(p_workspace_id uuid,p_deal_id uuid,p_snapshot_id uuid,p_facts jsonb,p_deadlines jsonb) returns void
language plpgsql security definer set search_path='' as $$
declare item jsonb;v_old public.deal_operational_facts;v_new uuid;
begin
  if auth.role()<>'service_role' or not exists(select 1 from public.analysis_snapshots s where s.id=p_snapshot_id and s.workspace_id=p_workspace_id and s.deal_id=p_deal_id) then raise exception 'service boundary denied' using errcode='42501';end if;
  for item in select value from jsonb_array_elements(coalesce(p_facts,'[]'::jsonb)) loop
    if item->>'field_key' not in('brand_name','agency_name','contact_name','contact_email','billing_entity','billing_address','accounts_payable_email','purchase_order','invoice_instructions','campaign_start','campaign_end','usage_terms','exclusivity_terms','paid_media_terms') or length(trim(item->>'display_value')) not between 1 and 5000 or jsonb_array_length(coalesce(item->'evidence','[]'::jsonb))=0 then raise exception 'invalid operational fact' using errcode='23514';end if;
    select * into v_old from public.deal_operational_facts where deal_id=p_deal_id and field_key=item->>'field_key' and is_current for update;
    if v_old.source_kind='creator' or v_old.display_value=trim(item->>'display_value') then continue;end if;
    if v_old.id is not null then update public.deal_operational_facts set is_current=false where id=v_old.id;end if;
    insert into public.deal_operational_facts(workspace_id,deal_id,field_key,value,display_value,source_kind,source_id,precedence) values(p_workspace_id,p_deal_id,item->>'field_key',jsonb_build_object('text',trim(item->>'display_value'),'confidence',item->'confidence','evidence',item->'evidence'),trim(item->>'display_value'),'ai_extraction',p_snapshot_id,60) returning id into v_new;
    if v_old.id is not null then update public.deal_operational_facts set superseded_by=v_new where id=v_old.id;end if;
  end loop;
  for item in select value from jsonb_array_elements(coalesce(p_deadlines,'[]'::jsonb)) loop
    if item->>'deadline_type' not in('campaign_start','campaign_end','draft_due','approval_due','publish_due','invoice_due','payment_due','other') or length(trim(item->>'label')) not between 1 and 200 or jsonb_array_length(coalesce(item->'evidence','[]'::jsonb))=0 then raise exception 'invalid deadline' using errcode='23514';end if;
    insert into public.deal_deadlines(workspace_id,deal_id,deadline_type,label,due_at,status,source_kind,source_id) values(p_workspace_id,p_deal_id,item->>'deadline_type',trim(item->>'label'),(item->>'due_at')::timestamptz,'open','ai_extraction',p_snapshot_id) on conflict(deal_id,deadline_type,source_id,due_at) where source_kind='ai_extraction' and source_id is not null do nothing;
  end loop;
end $$;
revoke all on function public.apply_analysis_deal_deltas(uuid,uuid,uuid,jsonb,jsonb) from public,anon,authenticated;
grant execute on function public.apply_analysis_deal_deltas(uuid,uuid,uuid,jsonb,jsonb) to service_role;

