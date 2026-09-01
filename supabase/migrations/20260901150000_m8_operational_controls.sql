create or replace function public.founder_set_worker_control(
  p_founder_user_id uuid,
  p_key text,
  p_enabled boolean,
  p_expected_version integer,
  p_confirmation boolean,
  p_idempotency_key text
) returns jsonb language plpgsql security definer set search_path='' as $$
declare v_flag private.feature_flags; v_action private.founder_actions; v_safety text;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not exists(select 1 from private.founder_users f where f.user_id=p_founder_user_id) then raise exception 'founder required' using errcode='42501'; end if;
  if p_key not in ('ai_worker_enabled','gmail_send_enabled') then raise exception 'unsupported worker control' using errcode='22023'; end if;
  if p_enabled and not p_confirmation then raise exception 'enabling a worker requires confirmation' using errcode='22023'; end if;
  if p_idempotency_key is null or char_length(p_idempotency_key)<16 then raise exception 'idempotency key required' using errcode='22023'; end if;

  select * into v_action from private.founder_actions where idempotency_key=p_idempotency_key;
  if v_action.id is not null then
    if v_action.action_type<>'set_worker_control' or v_action.target_id<>p_key or (v_action.after_safe_metadata->>'enabled')::boolean<>p_enabled then
      raise exception 'idempotency key conflict' using errcode='23505';
    end if;
    return jsonb_build_object('key',p_key,'enabled',(v_action.after_safe_metadata->>'enabled')::boolean,'version',(v_action.after_safe_metadata->>'version')::integer,'replayed',true);
  end if;

  select * into v_flag from private.feature_flags where key=p_key for update;
  if v_flag.key is null then raise exception 'worker control not found' using errcode='P0002'; end if;
  if v_flag.version<>p_expected_version then raise exception 'worker control version conflict' using errcode='40001'; end if;
  v_safety:=case when p_enabled then 'confirm' else 'immediate' end;

  insert into private.founder_actions(actor_user_id,action_type,target_type,target_id,safety_level,confirmation_state,before_safe_metadata,after_safe_metadata,idempotency_key,result)
  values(p_founder_user_id,'set_worker_control','feature_flag',p_key,v_safety,case when p_enabled then 'confirmed' else 'not_required' end,
    jsonb_build_object('enabled',v_flag.enabled,'version',v_flag.version),jsonb_build_object('enabled',p_enabled,'version',v_flag.version+1),p_idempotency_key,'pending');
  update private.feature_flags set enabled=p_enabled,version=version+1,updated_by_user_id=p_founder_user_id,updated_at=now() where key=p_key returning * into v_flag;
  update private.founder_actions set result='succeeded',completed_at=now() where idempotency_key=p_idempotency_key;
  return jsonb_build_object('key',v_flag.key,'enabled',v_flag.enabled,'version',v_flag.version,'replayed',false);
exception when others then
  update private.founder_actions set result='failed',error_class=sqlstate,completed_at=now() where idempotency_key=p_idempotency_key and result='pending';
  raise;
end;
$$;
revoke all on function public.founder_set_worker_control(uuid,text,boolean,integer,boolean,text) from public,anon,authenticated;
grant execute on function public.founder_set_worker_control(uuid,text,boolean,integer,boolean,text) to service_role;

create or replace function public.claim_ai_analysis() returns jsonb language plpgsql security definer set search_path='' as $$
declare v_message record; v_result jsonb;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not coalesce((select enabled from private.feature_flags where key='ai_worker_enabled'),false) then return null; end if;
  select * into v_message from pgmq.read('ai_analysis',300,1) limit 1; if v_message.msg_id is null then return null; end if;
  update private.ai_analysis_jobs set status='processing',attempt_count=attempt_count+1 where id=(v_message.message->>'job_id')::uuid;
  update public.analysis_snapshots set state='running' where id=(select snapshot_id from private.ai_analysis_jobs where id=(v_message.message->>'job_id')::uuid);
  select jsonb_build_object('queue_message_id',v_message.msg_id,'job_id',j.id,'snapshot_id',j.snapshot_id,'workspace_id',j.workspace_id,'deal_id',j.deal_id,
    'messages',coalesce((select jsonb_agg(jsonb_build_object('id',m.id,'direction',m.direction,'subject',m.subject,'body_text',m.body_text,'internal_date',m.internal_date) order by m.internal_date) from public.deal_threads t join public.gmail_messages m on m.deal_thread_id=t.id where t.deal_id=j.deal_id),'[]'::jsonb))
  into v_result from private.ai_analysis_jobs j where j.id=(v_message.message->>'job_id')::uuid; return v_result;
end $$;
revoke all on function public.claim_ai_analysis() from public,anon,authenticated;
grant execute on function public.claim_ai_analysis() to service_role;

create or replace function public.claim_gmail_send() returns jsonb language plpgsql security definer set search_path='' as $$
declare v_message record; v_job private.gmail_send_jobs; v_result jsonb;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not coalesce((select enabled from private.feature_flags where key='gmail_send_enabled'),false) then return null; end if;
  select * into v_message from pgmq.read('gmail_send',300,1) limit 1; if v_message.msg_id is null then return null; end if;
  select * into v_job from private.gmail_send_jobs where id=(v_message.message->>'job_id')::uuid for update;
  if v_job.status='sent' then perform pgmq.archive('gmail_send',v_message.msg_id); return null; end if;
  update private.gmail_send_jobs set status='processing',attempt_count=attempt_count+1 where id=v_job.id;
  select jsonb_build_object('queue_message_id',v_message.msg_id,'job_id',v_job.id,'reply_draft_id',rd.id,'reply_version',rd.version,'rfc822_message_id',v_job.rfc822_message_id,
    'from_address',gc.gmail_email_address,'to_address',latest.from_address,'subject',latest.subject,'body',rd.body,'provider_thread_id',dt.provider_thread_id,
    'in_reply_to',(select value from jsonb_each_text(latest.raw_headers) where lower(key)='message-id' limit 1),'references',(select value from jsonb_each_text(latest.raw_headers) where lower(key)='references' limit 1),'encrypted_refresh_token',tok.encrypted_refresh_token,
    'encryption_iv',tok.encryption_iv,'encryption_auth_tag',tok.encryption_auth_tag,'key_version',tok.key_version)
  into v_result from public.reply_drafts rd join public.deal_threads dt on dt.id=rd.deal_thread_id join public.gmail_connections gc on gc.id=dt.gmail_connection_id
    join private.gmail_oauth_tokens tok on tok.gmail_connection_id=gc.id
    join lateral(select m.from_address,m.subject,m.raw_headers from public.gmail_messages m where m.deal_thread_id=dt.id and m.direction='inbound' order by m.internal_date desc limit 1) latest on true
    where rd.id=v_job.reply_draft_id;
  if v_result is null or coalesce(v_result->>'in_reply_to','')='' then raise exception 'thread has no RFC Message-ID' using errcode='22023'; end if;
  return v_result;
end $$;
revoke all on function public.claim_gmail_send() from public,anon,authenticated;
grant execute on function public.claim_gmail_send() to service_role;

create or replace function public.founder_worker_controls(p_founder_user_id uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $$
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  if not exists(select 1 from private.founder_users f where f.user_id=p_founder_user_id) then return null; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('key',f.key,'enabled',f.enabled,'description',f.description,'version',f.version,'updatedAt',f.updated_at) order by f.key) from private.feature_flags f where f.key in ('ai_worker_enabled','gmail_send_enabled')),'[]'::jsonb);
end;
$$;
revoke all on function public.founder_worker_controls(uuid) from public,anon,authenticated;
grant execute on function public.founder_worker_controls(uuid) to service_role;

