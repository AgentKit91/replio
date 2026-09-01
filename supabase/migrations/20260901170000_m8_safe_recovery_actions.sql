create or replace function public.founder_recovery_actions(p_founder_user_id uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $$
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not exists(select 1 from private.founder_users f where f.user_id=p_founder_user_id) then return null; end if;
  return jsonb_build_object(
    'gmailSyncs',coalesce((select jsonb_agg(jsonb_build_object(
      'eventId',e.id,'gmailAddress',g.gmail_email_address,'attemptCount',e.attempt_count,'errorClass',e.last_error,'failedAt',e.created_at,
      'eligible',e.attempt_count<5 and g.watch_status='active' and lower(coalesce(e.last_error,''))!~'(invalid.grant|unauthori|revok|forbidden|insufficient|credential)',
      'blockedReason',case when e.attempt_count>=5 then 'Attempt cap reached' when g.watch_status<>'active' then 'Gmail watch is not active' when lower(coalesce(e.last_error,''))~'(invalid.grant|unauthori|revok|forbidden|insufficient|credential)' then 'Creator reauthorization is required' else null end
    ) order by e.created_at desc) from private.gmail_sync_events e join public.gmail_connections g on g.id=e.gmail_connection_id where e.status='failed'),'[]'::jsonb),
    'incidents',coalesce((select jsonb_agg(jsonb_build_object('id',i.id,'severity',i.severity,'title',i.title,'summary',i.summary,'recommendedAction',i.recommended_action,'openedAt',i.opened_at) order by i.opened_at desc) from private.system_incidents i where i.status='open'),'[]'::jsonb)
  );
end;
$$;
revoke all on function public.founder_recovery_actions(uuid) from public,anon,authenticated;
grant execute on function public.founder_recovery_actions(uuid) to service_role;

create or replace function public.founder_retry_gmail_sync(p_founder_user_id uuid,p_event_id uuid,p_idempotency_key text)
returns boolean language plpgsql security definer set search_path='' as $$
declare v_event private.gmail_sync_events; v_watch_status text; v_action private.founder_actions; v_message_id bigint;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not exists(select 1 from private.founder_users f where f.user_id=p_founder_user_id) then raise exception 'founder required' using errcode='42501'; end if;
  if p_idempotency_key is null or char_length(p_idempotency_key)<16 then raise exception 'idempotency key required' using errcode='22023'; end if;
  select * into v_action from private.founder_actions where idempotency_key=p_idempotency_key;
  if v_action.id is not null then
    if v_action.action_type<>'retry_gmail_sync' or v_action.target_id<>p_event_id::text then raise exception 'idempotency key conflict' using errcode='23505'; end if;
    return true;
  end if;
  select e,g.watch_status into v_event,v_watch_status from private.gmail_sync_events e join public.gmail_connections g on g.id=e.gmail_connection_id where e.id=p_event_id for update of e;
  if v_event.id is null or v_event.status<>'failed' then raise exception 'failed Gmail sync not found' using errcode='P0002'; end if;
  if v_event.attempt_count>=5 then raise exception 'Gmail sync attempt cap reached' using errcode='55000'; end if;
  if v_watch_status<>'active' or lower(coalesce(v_event.last_error,''))~'(invalid.grant|unauthori|revok|forbidden|insufficient|credential)' then raise exception 'creator reauthorization required' using errcode='55000'; end if;
  select q.msg_id into v_message_id from pgmq.q_gmail_sync q where (q.message->>'event_id')::uuid=p_event_id order by q.msg_id desc limit 1;
  if v_message_id is null then select * into v_message_id from pgmq.send('gmail_sync',jsonb_build_object('event_id',v_event.id,'gmail_connection_id',v_event.gmail_connection_id,'history_id',v_event.history_id));
  else perform pgmq.set_vt('gmail_sync',v_message_id,0); end if;
  update private.gmail_sync_events set status='queued',last_error=null where id=p_event_id;
  insert into private.founder_actions(actor_user_id,action_type,target_type,target_id,safety_level,confirmation_state,before_safe_metadata,after_safe_metadata,idempotency_key,result,completed_at)
  values(p_founder_user_id,'retry_gmail_sync','gmail_sync_event',p_event_id::text,'immediate','not_required',jsonb_build_object('status','failed','attemptCount',v_event.attempt_count,'errorClass',v_event.last_error),jsonb_build_object('status','queued'),p_idempotency_key,'succeeded',now());
  return true;
end;
$$;
revoke all on function public.founder_retry_gmail_sync(uuid,uuid,text) from public,anon,authenticated;
grant execute on function public.founder_retry_gmail_sync(uuid,uuid,text) to service_role;

create or replace function public.founder_acknowledge_incident(p_founder_user_id uuid,p_incident_id uuid,p_idempotency_key text)
returns boolean language plpgsql security definer set search_path='' as $$
declare v_action private.founder_actions; v_changed integer;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not exists(select 1 from private.founder_users f where f.user_id=p_founder_user_id) then raise exception 'founder required' using errcode='42501'; end if;
  if p_idempotency_key is null or char_length(p_idempotency_key)<16 then raise exception 'idempotency key required' using errcode='22023'; end if;
  select * into v_action from private.founder_actions where idempotency_key=p_idempotency_key;
  if v_action.id is not null then
    if v_action.action_type<>'acknowledge_incident' or v_action.target_id<>p_incident_id::text then raise exception 'idempotency key conflict' using errcode='23505'; end if;
    return true;
  end if;
  update private.system_incidents set status='acknowledged',acknowledged_at=now() where id=p_incident_id and status='open';get diagnostics v_changed=row_count;
  if v_changed=0 then raise exception 'open incident not found' using errcode='P0002'; end if;
  insert into private.founder_actions(actor_user_id,action_type,target_type,target_id,safety_level,confirmation_state,before_safe_metadata,after_safe_metadata,idempotency_key,result,completed_at)
  values(p_founder_user_id,'acknowledge_incident','system_incident',p_incident_id::text,'immediate','not_required',jsonb_build_object('status','open'),jsonb_build_object('status','acknowledged'),p_idempotency_key,'succeeded',now());
  return true;
end;
$$;
revoke all on function public.founder_acknowledge_incident(uuid,uuid,text) from public,anon,authenticated;
grant execute on function public.founder_acknowledge_incident(uuid,uuid,text) to service_role;

