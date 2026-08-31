alter table public.reply_drafts add column respectful_challenge text, add column challenge_acknowledged_at timestamptz;

create or replace function public.acknowledge_reply_challenge(p_deal_id uuid) returns void language plpgsql security definer set search_path='' as $$
begin
  update public.reply_drafts rd set challenge_acknowledged_at=now(),updated_at=now() where rd.deal_id=p_deal_id and rd.state='draft' and exists(select 1 from public.workspace_members wm where wm.workspace_id=rd.workspace_id and wm.user_id=auth.uid());
  if not found then raise exception 'reply draft not found' using errcode='P0002'; end if;
end $$;
revoke all on function public.acknowledge_reply_challenge(uuid) from public,anon;
grant execute on function public.acknowledge_reply_challenge(uuid) to authenticated;

create or replace function public.apply_reply_rewrite(p_deal_id uuid,p_body text,p_expected_version integer,p_instruction text,p_start_again boolean default false) returns integer language plpgsql security definer set search_path='' as $$
declare v_draft public.reply_drafts; v_next integer;
begin
  if length(p_body)>100000 or btrim(p_body)='' or length(p_instruction)>500 or btrim(p_instruction)='' then raise exception 'invalid rewrite' using errcode='22023'; end if;
  select rd.* into v_draft from public.reply_drafts rd join public.workspace_members wm on wm.workspace_id=rd.workspace_id where rd.deal_id=p_deal_id and wm.user_id=auth.uid() for update of rd;
  if v_draft.id is null then raise exception 'reply draft not found' using errcode='P0002'; end if;
  if v_draft.state<>'draft' then raise exception 'reply is not editable' using errcode='55000'; end if;
  if v_draft.version<>p_expected_version then raise exception 'reply version conflict' using errcode='40001'; end if;
  v_next:=v_draft.version+1;
  update public.reply_drafts set body=p_body,version=v_next,creator_edited=true,autosaved_at=now(),updated_at=now() where id=v_draft.id;
  insert into public.reply_versions(workspace_id,reply_draft_id,version,subject,body,change_kind,instruction,source_snapshot_id,created_by)
    values(v_draft.workspace_id,v_draft.id,v_next,v_draft.subject,p_body,case when p_start_again then 'start_again' else 'targeted_rewrite' end,p_instruction,v_draft.source_snapshot_id,auth.uid());
  return v_next;
end $$;
revoke all on function public.apply_reply_rewrite(uuid,text,integer,text,boolean) from public,anon;
grant execute on function public.apply_reply_rewrite(uuid,text,integer,text,boolean) to authenticated;

create or replace function public.finish_gmail_send(p_queue_message_id bigint,p_job_id uuid,p_provider_message_id text) returns void language plpgsql security definer set search_path='' as $$
declare v_draft public.reply_drafts; v_job private.gmail_send_jobs; v_thread public.deal_threads; v_connection public.gmail_connections; v_latest public.gmail_messages;
begin
  if coalesce((select auth.jwt()->>'role'),'')<>'service_role' then raise exception 'service role required' using errcode='42501'; end if;
  select * into v_job from private.gmail_send_jobs where id=p_job_id for update;
  if v_job.id is null then raise exception 'send job not found' using errcode='P0002'; end if;
  select * into v_draft from public.reply_drafts where id=v_job.reply_draft_id;
  select * into v_thread from public.deal_threads where id=v_draft.deal_thread_id;
  select * into v_connection from public.gmail_connections where id=v_thread.gmail_connection_id;
  select * into v_latest from public.gmail_messages where deal_thread_id=v_thread.id and direction='inbound' order by internal_date desc limit 1;
  update private.gmail_send_jobs set status='sent',provider_message_id=p_provider_message_id,completed_at=now(),last_error_class=null where id=p_job_id;
  update public.reply_drafts set state='sent',provider_message_id=p_provider_message_id,sent_at=now(),updated_at=now() where id=v_draft.id;
  insert into public.gmail_messages(workspace_id,deal_thread_id,provider_message_id,provider_thread_id,internal_date,direction,from_address,to_addresses,subject,body_text,provider_label_ids,raw_headers)
    values(v_draft.workspace_id,v_thread.id,p_provider_message_id,v_thread.provider_thread_id,now(),'outbound',v_connection.gmail_email_address,array[v_latest.from_address],v_draft.subject,v_draft.body,array['SENT'],jsonb_build_object('Message-ID',v_job.rfc822_message_id))
    on conflict(workspace_id,provider_message_id) do nothing;
  update public.deals set status='awaiting_brand',human_status_code='waiting_on_brand',updated_at=now() where id=v_draft.deal_id;
  insert into public.activity_events(workspace_id,event_type,entity_type,entity_id,metadata) values(v_draft.workspace_id,'reply_sent','deal',v_draft.deal_id,jsonb_build_object('reply_version',v_job.reply_version));
  perform pgmq.archive('gmail_send',p_queue_message_id);
end $$;
revoke all on function public.finish_gmail_send(bigint,uuid,text) from public,anon,authenticated;
grant execute on function public.finish_gmail_send(bigint,uuid,text) to service_role;

create or replace function public.persist_gmail_thread(
  p_workspace_id uuid, p_gmail_connection_id uuid, p_provider_thread_id text, p_title text, p_messages jsonb
) returns uuid language plpgsql security definer set search_path = '' as $$
declare v_deal_id uuid; v_thread_id uuid; v_message jsonb; v_message_id uuid; v_attachment jsonb; v_latest_inbound timestamptz;
begin
  if coalesce((select auth.jwt()->>'role'),'') <> 'service_role' then raise exception 'service role required' using errcode = '42501'; end if;
  if not exists (select 1 from public.gmail_connections where id = p_gmail_connection_id and workspace_id = p_workspace_id and watch_status = 'active') then raise exception 'active workspace Gmail connection required' using errcode = '42501'; end if;
  select deal_id, id into v_deal_id, v_thread_id from public.deal_threads where workspace_id = p_workspace_id and provider_thread_id = p_provider_thread_id;
  if v_thread_id is null then
    insert into public.deals(workspace_id, title) values (p_workspace_id, coalesce(nullif(p_title, ''), 'Untitled Gmail conversation')) returning id into v_deal_id;
    insert into public.deal_threads(workspace_id, deal_id, gmail_connection_id, provider_thread_id) values (p_workspace_id, v_deal_id, p_gmail_connection_id, p_provider_thread_id) returning id into v_thread_id;
  end if;
  for v_message in select value from jsonb_array_elements(p_messages) loop
    insert into public.gmail_messages(workspace_id, deal_thread_id, provider_message_id, provider_thread_id, provider_history_id, internal_date,direction, from_address, to_addresses, cc_addresses, subject, body_text, body_html_sanitized, provider_label_ids, raw_headers)
    values (p_workspace_id, v_thread_id, v_message->>'provider_message_id', p_provider_thread_id, nullif(v_message->>'provider_history_id','')::numeric,(v_message->>'internal_date')::timestamptz, v_message->>'direction', v_message->>'from_address',coalesce(array(select jsonb_array_elements_text(v_message->'to_addresses')), '{}'), coalesce(array(select jsonb_array_elements_text(v_message->'cc_addresses')), '{}'),coalesce(v_message->>'subject',''), coalesce(v_message->>'body_text',''), v_message->>'body_html_sanitized',coalesce(array(select jsonb_array_elements_text(v_message->'provider_label_ids')), '{}'), coalesce(v_message->'raw_headers','{}'::jsonb))
    on conflict (workspace_id, provider_message_id) do update set provider_history_id = excluded.provider_history_id, body_text = excluded.body_text,body_html_sanitized = excluded.body_html_sanitized, provider_label_ids = excluded.provider_label_ids, raw_headers = excluded.raw_headers, updated_at = now()
    returning id into v_message_id;
    if v_message->>'direction'='inbound' then v_latest_inbound:=greatest(coalesce(v_latest_inbound,'-infinity'::timestamptz),(v_message->>'internal_date')::timestamptz); end if;
    for v_attachment in select value from jsonb_array_elements(coalesce(v_message->'attachments','[]'::jsonb)) loop
      insert into public.gmail_attachment_references(workspace_id, gmail_message_id, provider_attachment_id, filename, mime_type, size_bytes)
      values (p_workspace_id, v_message_id, v_attachment->>'provider_attachment_id', v_attachment->>'filename', v_attachment->>'mime_type', nullif(v_attachment->>'size_bytes','')::bigint)
      on conflict (gmail_message_id, provider_attachment_id) do update set filename = excluded.filename, mime_type = excluded.mime_type, size_bytes = excluded.size_bytes;
    end loop;
  end loop;
  if exists(select 1 from public.reply_drafts where deal_id=v_deal_id and sent_at<v_latest_inbound) then
    update public.deals set status='awaiting_creator',human_status_code='your_reply_needed',updated_at=now() where id=v_deal_id and status='awaiting_brand';
  end if;
  return v_deal_id;
end $$;
revoke all on function public.persist_gmail_thread(uuid, uuid, text, text, jsonb) from public, anon, authenticated;
grant execute on function public.persist_gmail_thread(uuid, uuid, text, text, jsonb) to service_role;
