create or replace function public.founder_operational_snapshot(p_founder_user_id uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare v_ai_cost numeric; v_ai_cost_complete boolean;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not exists(select 1 from private.founder_users f where f.user_id=p_founder_user_id) then return null; end if;
  select coalesce(sum(r.estimated_cost_usd),0),bool_and(r.estimated_cost_usd is not null) into v_ai_cost,v_ai_cost_complete
    from public.ai_worker_runs r where r.started_at>=now()-interval '30 days';
  return jsonb_build_object(
    'trials',(select count(*) from public.subscriptions where status='trialing'),
    'activeSubscriptions',(select count(*) from public.subscriptions where status='active'),
    'pastDueSubscriptions',(select count(*) from public.subscriptions where status in ('past_due','unpaid')),
    'connectedGmail',(select count(*) from public.gmail_connections where watch_status='active' and watch_expiration>now()),
    'unhealthyGmail',(select count(*) from public.gmail_connections where watch_status<>'active' or watch_expiration is null or watch_expiration<=now()),
    'queuedAi',(select count(*) from private.ai_analysis_jobs where status in ('queued','processing')),
    'failedAi',(select count(*) from private.ai_analysis_jobs where status='failed'),
    'queuedSends',(select count(*) from private.gmail_send_jobs where status in ('queued','processing')),
    'failedSends',(select count(*) from private.gmail_send_jobs where status='failed'),
    'aiCostUsd',case when coalesce(v_ai_cost_complete,true) then v_ai_cost else null end,
    'openSupportGrants',(select count(*) from public.support_access_grants where revoked_at is null and expires_at>now()),
    'incidents',coalesce((select jsonb_agg(jsonb_build_object('id',i.id,'severity',i.severity,'title',i.title,'context',i.summary,'nextStep',coalesce(i.recommended_action,'Review the component health and choose the safest recovery action.')) order by i.opened_at desc) from (select * from private.system_incidents where status<>'resolved' order by opened_at desc limit 20) i),'[]'::jsonb)
  );
end;
$$;
revoke all on function public.founder_operational_snapshot(uuid) from public,anon,authenticated;
grant execute on function public.founder_operational_snapshot(uuid) to service_role;

