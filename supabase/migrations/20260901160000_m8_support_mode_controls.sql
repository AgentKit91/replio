create or replace function public.founder_support_grants(p_founder_user_id uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $$
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not exists(select 1 from private.founder_users f where f.user_id=p_founder_user_id) then return null; end if;
  return coalesce((select jsonb_agg(jsonb_build_object(
    'id',g.id,'workspaceId',g.workspace_id,'creatorEmail',u.email,'scopeType',g.scope_type,'scopeId',g.scope_id,
    'reason',g.reason,'expiresAt',g.expires_at,'createdAt',g.created_at,
    'sessionId',s.id,'sessionStartedAt',s.started_at
  ) order by g.created_at desc)
  from public.support_access_grants g
  join auth.users u on u.id=g.granted_by_user_id
  left join lateral(select ss.id,ss.started_at from private.support_access_sessions ss where ss.grant_id=g.id and ss.founder_user_id=p_founder_user_id and ss.ended_at is null order by ss.started_at desc limit 1) s on true
  where g.revoked_at is null and g.expires_at>now()),'[]'::jsonb);
end;
$$;
revoke all on function public.founder_support_grants(uuid) from public,anon,authenticated;
grant execute on function public.founder_support_grants(uuid) to service_role;

create or replace function public.founder_start_support_session(p_founder_user_id uuid,p_grant_id uuid,p_confirmation boolean,p_idempotency_key text)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_grant public.support_access_grants; v_session_id uuid; v_action private.founder_actions;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not exists(select 1 from private.founder_users f where f.user_id=p_founder_user_id) then raise exception 'founder required' using errcode='42501'; end if;
  if not p_confirmation then raise exception 'support session requires confirmation' using errcode='22023'; end if;
  if p_idempotency_key is null or char_length(p_idempotency_key)<16 then raise exception 'idempotency key required' using errcode='22023'; end if;
  select * into v_action from private.founder_actions where idempotency_key=p_idempotency_key;
  if v_action.id is not null then
    if v_action.action_type<>'start_support_session' or v_action.target_id<>p_grant_id::text then raise exception 'idempotency key conflict' using errcode='23505'; end if;
    return (v_action.after_safe_metadata->>'sessionId')::uuid;
  end if;
  select * into v_grant from public.support_access_grants g where g.id=p_grant_id and g.revoked_at is null and g.expires_at>now() for update;
  if v_grant.id is null then raise exception 'active support grant not found' using errcode='P0002'; end if;
  select id into v_session_id from private.support_access_sessions where grant_id=p_grant_id and founder_user_id=p_founder_user_id and ended_at is null order by started_at desc limit 1;
  if v_session_id is null then insert into private.support_access_sessions(grant_id,founder_user_id) values(p_grant_id,p_founder_user_id) returning id into v_session_id; end if;
  insert into private.founder_actions(actor_user_id,action_type,target_type,target_id,safety_level,confirmation_state,before_safe_metadata,after_safe_metadata,idempotency_key,result,completed_at)
  values(p_founder_user_id,'start_support_session','support_grant',p_grant_id::text,'confirm','confirmed','{}',jsonb_build_object('sessionId',v_session_id,'scopeType',v_grant.scope_type,'expiresAt',v_grant.expires_at),p_idempotency_key,'succeeded',now());
  return v_session_id;
end;
$$;
revoke all on function public.founder_start_support_session(uuid,uuid,boolean,text) from public,anon,authenticated;
grant execute on function public.founder_start_support_session(uuid,uuid,boolean,text) to service_role;

create or replace function public.founder_end_support_session(p_founder_user_id uuid,p_session_id uuid,p_idempotency_key text)
returns boolean language plpgsql security definer set search_path='' as $$
declare v_action private.founder_actions; v_changed integer;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not exists(select 1 from private.founder_users f where f.user_id=p_founder_user_id) then raise exception 'founder required' using errcode='42501'; end if;
  if p_idempotency_key is null or char_length(p_idempotency_key)<16 then raise exception 'idempotency key required' using errcode='22023'; end if;
  select * into v_action from private.founder_actions where idempotency_key=p_idempotency_key;
  if v_action.id is not null then
    if v_action.action_type<>'end_support_session' or v_action.target_id<>p_session_id::text then raise exception 'idempotency key conflict' using errcode='23505'; end if;
    return true;
  end if;
  update private.support_access_sessions set ended_at=now(),last_accessed_at=now() where id=p_session_id and founder_user_id=p_founder_user_id and ended_at is null;
  get diagnostics v_changed=row_count;
  if v_changed=0 then raise exception 'active support session not found' using errcode='P0002'; end if;
  insert into private.founder_actions(actor_user_id,action_type,target_type,target_id,safety_level,confirmation_state,before_safe_metadata,after_safe_metadata,idempotency_key,result,completed_at)
  values(p_founder_user_id,'end_support_session','support_session',p_session_id::text,'immediate','not_required',jsonb_build_object('active',true),jsonb_build_object('active',false),p_idempotency_key,'succeeded',now());
  return true;
end;
$$;
revoke all on function public.founder_end_support_session(uuid,uuid,text) from public,anon,authenticated;
grant execute on function public.founder_end_support_session(uuid,uuid,text) to service_role;

