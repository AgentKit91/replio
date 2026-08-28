create or replace function public.claim_gmail_sync()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_message record; v_result jsonb;
begin
  if auth.role() <> 'service_role' then raise exception 'service role required' using errcode = '42501'; end if;
  select * into v_message from pgmq.read('gmail_sync', 120, 1) limit 1;
  if v_message.msg_id is null then return null; end if;
  update private.gmail_sync_events set status = 'processing', attempt_count = attempt_count + 1
    where id = (v_message.message ->> 'event_id')::uuid;
  select jsonb_build_object(
    'queue_message_id', v_message.msg_id,
    'event_id', e.id,
    'gmail_connection_id', g.id,
    'workspace_id', g.workspace_id,
    'gmail_email_address', g.gmail_email_address,
    'replio_label_id', g.replio_label_id,
    'last_history_id', g.last_history_id::text,
    'encrypted_refresh_token', t.encrypted_refresh_token,
    'encryption_iv', t.encryption_iv,
    'encryption_auth_tag', t.encryption_auth_tag,
    'key_version', t.key_version
  ) into v_result
  from private.gmail_sync_events e
  join public.gmail_connections g on g.id = e.gmail_connection_id
  join private.gmail_oauth_tokens t on t.gmail_connection_id = g.id
  where e.id = (v_message.message ->> 'event_id')::uuid;
  return v_result;
end;
$$;
revoke all on function public.claim_gmail_sync() from public, anon, authenticated;
grant execute on function public.claim_gmail_sync() to service_role;

create or replace function public.finish_gmail_sync(p_queue_message_id bigint, p_event_id uuid, p_history_id numeric)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.role() <> 'service_role' then raise exception 'service role required' using errcode = '42501'; end if;
  update public.gmail_connections g set last_history_id = greatest(coalesce(g.last_history_id, 0), p_history_id), updated_at = now()
  from public.integration_connections i where g.integration_connection_id = i.id
    and g.id = (select gmail_connection_id from private.gmail_sync_events where id = p_event_id);
  update public.integration_connections i set last_successful_sync_at = now(), error_code = null, error_message = null, updated_at = now()
  from public.gmail_connections g where g.integration_connection_id = i.id
    and g.id = (select gmail_connection_id from private.gmail_sync_events where id = p_event_id);
  update private.gmail_sync_events set status = 'completed', completed_at = now(), last_error = null where id = p_event_id;
  perform pgmq.archive('gmail_sync', p_queue_message_id);
end;
$$;
revoke all on function public.finish_gmail_sync(bigint, uuid, numeric) from public, anon, authenticated;
grant execute on function public.finish_gmail_sync(bigint, uuid, numeric) to service_role;

create or replace function public.fail_gmail_sync(p_event_id uuid, p_error_code text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.role() <> 'service_role' then raise exception 'service role required' using errcode = '42501'; end if;
  update private.gmail_sync_events set status = 'failed', last_error = left(p_error_code, 200) where id = p_event_id;
  update public.integration_connections i set state = 'error', error_code = left(p_error_code, 80), error_message = 'Gmail sync needs attention.', updated_at = now()
  from public.gmail_connections g where g.integration_connection_id = i.id
    and g.id = (select gmail_connection_id from private.gmail_sync_events where id = p_event_id);
end;
$$;
revoke all on function public.fail_gmail_sync(uuid, text) from public, anon, authenticated;
grant execute on function public.fail_gmail_sync(uuid, text) to service_role;

create or replace function public.persist_gmail_thread(
  p_workspace_id uuid, p_gmail_connection_id uuid, p_provider_thread_id text, p_title text, p_messages jsonb
) returns uuid language plpgsql security definer set search_path = '' as $$
declare v_deal_id uuid; v_thread_id uuid; v_message jsonb; v_message_id uuid; v_attachment jsonb;
begin
  if auth.role() <> 'service_role' then raise exception 'service role required' using errcode = '42501'; end if;
  if not exists (select 1 from public.gmail_connections where id = p_gmail_connection_id and workspace_id = p_workspace_id and watch_status = 'active') then
    raise exception 'active workspace Gmail connection required' using errcode = '42501';
  end if;
  select deal_id, id into v_deal_id, v_thread_id from public.deal_threads where workspace_id = p_workspace_id and provider_thread_id = p_provider_thread_id;
  if v_thread_id is null then
    insert into public.deals(workspace_id, title) values (p_workspace_id, coalesce(nullif(p_title, ''), 'Untitled Gmail conversation')) returning id into v_deal_id;
    insert into public.deal_threads(workspace_id, deal_id, gmail_connection_id, provider_thread_id)
      values (p_workspace_id, v_deal_id, p_gmail_connection_id, p_provider_thread_id) returning id into v_thread_id;
  end if;
  for v_message in select value from jsonb_array_elements(p_messages) loop
    insert into public.gmail_messages(workspace_id, deal_thread_id, provider_message_id, provider_thread_id, provider_history_id, internal_date,
      direction, from_address, to_addresses, cc_addresses, subject, body_text, body_html_sanitized, provider_label_ids, raw_headers)
    values (p_workspace_id, v_thread_id, v_message->>'provider_message_id', p_provider_thread_id, nullif(v_message->>'provider_history_id','')::numeric,
      (v_message->>'internal_date')::timestamptz, v_message->>'direction', v_message->>'from_address',
      coalesce(array(select jsonb_array_elements_text(v_message->'to_addresses')), '{}'), coalesce(array(select jsonb_array_elements_text(v_message->'cc_addresses')), '{}'),
      coalesce(v_message->>'subject',''), coalesce(v_message->>'body_text',''), v_message->>'body_html_sanitized',
      coalesce(array(select jsonb_array_elements_text(v_message->'provider_label_ids')), '{}'), coalesce(v_message->'raw_headers','{}'::jsonb))
    on conflict (workspace_id, provider_message_id) do update set provider_history_id = excluded.provider_history_id, body_text = excluded.body_text,
      body_html_sanitized = excluded.body_html_sanitized, provider_label_ids = excluded.provider_label_ids, raw_headers = excluded.raw_headers, updated_at = now()
    returning id into v_message_id;
    for v_attachment in select value from jsonb_array_elements(coalesce(v_message->'attachments','[]'::jsonb)) loop
      insert into public.gmail_attachment_references(workspace_id, gmail_message_id, provider_attachment_id, filename, mime_type, size_bytes)
      values (p_workspace_id, v_message_id, v_attachment->>'provider_attachment_id', v_attachment->>'filename', v_attachment->>'mime_type', nullif(v_attachment->>'size_bytes','')::bigint)
      on conflict (gmail_message_id, provider_attachment_id) do update set filename = excluded.filename, mime_type = excluded.mime_type, size_bytes = excluded.size_bytes;
    end loop;
  end loop;
  return v_deal_id;
end;
$$;
revoke all on function public.persist_gmail_thread(uuid, uuid, text, text, jsonb) from public, anon, authenticated;
grant execute on function public.persist_gmail_thread(uuid, uuid, text, text, jsonb) to service_role;
