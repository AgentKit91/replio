create or replace function public.finish_ai_analysis(p_queue_message_id bigint,p_job_id uuid,p_success boolean,p_error_class text default null) returns void language plpgsql security definer set search_path='' as $$
declare v_attempts integer; v_terminal boolean;
begin
  if auth.role()<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  select attempt_count into v_attempts from private.ai_analysis_jobs where id=p_job_id; v_terminal:=p_success or coalesce(v_attempts,0)>=3;
  update private.ai_analysis_jobs set status=case when p_success then 'completed' when v_terminal then 'failed' else 'queued' end,
    last_error_class=left(p_error_class,80),completed_at=case when v_terminal then now() else null end where id=p_job_id;
  if p_success then update public.analysis_snapshots set is_current=false where deal_id=(select deal_id from private.ai_analysis_jobs where id=p_job_id); end if;
  update public.analysis_snapshots set state=case when p_success then 'completed'::public.analysis_state when v_terminal then 'failed'::public.analysis_state else 'queued'::public.analysis_state end,
    is_current=p_success,failure_class=left(p_error_class,80),completed_at=case when v_terminal then now() else null end where id=(select snapshot_id from private.ai_analysis_jobs where id=p_job_id);
  if v_terminal then perform pgmq.archive('ai_analysis',p_queue_message_id); end if;
end $$;
revoke all on function public.finish_ai_analysis(bigint,uuid,boolean,text) from public,anon,authenticated; grant execute on function public.finish_ai_analysis(bigint,uuid,boolean,text) to service_role;
