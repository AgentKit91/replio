create or replace function public.request_deal_analysis(p_deal_id uuid) returns uuid language plpgsql security definer set search_path='' as $$
declare
  v_workspace_id uuid;
  v_hash text;
  v_snapshot_id uuid;
  v_snapshot_state public.analysis_state;
  v_job_id uuid;
begin
  select workspace_id into v_workspace_id
  from public.deals d
  where d.id=p_deal_id and d.deleted_at is null
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=d.workspace_id and wm.user_id=auth.uid());
  if v_workspace_id is null then raise exception 'deal not found' using errcode='P0002'; end if;

  select encode(extensions.digest(coalesce(string_agg(m.id::text||':'||m.updated_at::text||':'||m.body_text,E'\n' order by m.internal_date),''),'sha256'),'hex')
  into v_hash
  from public.deal_threads t
  left join public.gmail_messages m on m.deal_thread_id=t.id
  where t.deal_id=p_deal_id;

  select id,state into v_snapshot_id,v_snapshot_state
  from public.analysis_snapshots
  where deal_id=p_deal_id and input_snapshot_hash=v_hash;

  if v_snapshot_id is not null and v_snapshot_state in ('queued','running','completed') then return v_snapshot_id; end if;

  if v_snapshot_id is not null and v_snapshot_state='failed' then
    select id into v_job_id from private.ai_analysis_jobs where snapshot_id=v_snapshot_id for update;
    if v_job_id is null then raise exception 'analysis job missing' using errcode='P0002'; end if;
    update public.analysis_snapshots set state='queued',failure_class=null,completed_at=null where id=v_snapshot_id;
    update private.ai_analysis_jobs set status='queued',attempt_count=0,last_error_class=null,completed_at=null where id=v_job_id;
    perform pgmq.send('ai_analysis',jsonb_build_object('job_id',v_job_id));
    return v_snapshot_id;
  end if;

  perform private.consume_analysis_entitlement(v_workspace_id);
  insert into public.analysis_snapshots(workspace_id,deal_id,input_snapshot_hash,state)
  values(v_workspace_id,p_deal_id,v_hash,'queued') returning id into v_snapshot_id;
  insert into private.ai_analysis_jobs(workspace_id,deal_id,snapshot_id)
  values(v_workspace_id,p_deal_id,v_snapshot_id) returning id into v_job_id;
  perform pgmq.send('ai_analysis',jsonb_build_object('job_id',v_job_id));
  return v_snapshot_id;
end $$;
revoke all on function public.request_deal_analysis(uuid) from public,anon;
grant execute on function public.request_deal_analysis(uuid) to authenticated;


