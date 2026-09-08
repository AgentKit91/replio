-- Creator-controlled operational edits. All consequential sends remain separate approval actions.
create or replace function public.save_deal_deadline(p_deal_id uuid,p_deadline_id uuid,p_deadline_type text,p_label text,p_due_at timestamptz,p_status text default 'open') returns uuid
language plpgsql security definer set search_path='' as $$
declare v_workspace uuid; v_id uuid;
begin
  select d.workspace_id into v_workspace from public.deals d where d.id=p_deal_id and d.deleted_at is null
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=d.workspace_id and wm.user_id=auth.uid());
  if v_workspace is null then raise exception 'deal not found' using errcode='P0002'; end if;
  if p_deadline_type not in ('campaign_start','campaign_end','draft_due','approval_due','publish_due','invoice_due','payment_due','other') or p_status not in ('open','completed','cancelled') or length(trim(p_label)) not between 1 and 200 then raise exception 'invalid deadline' using errcode='23514'; end if;
  if p_deadline_id is null then
    insert into public.deal_deadlines(workspace_id,deal_id,deadline_type,label,due_at,status,source_kind,created_by)
    values(v_workspace,p_deal_id,p_deadline_type,trim(p_label),p_due_at,p_status,'creator',auth.uid()) returning id into v_id;
  else
    update public.deal_deadlines set deadline_type=p_deadline_type,label=trim(p_label),due_at=p_due_at,status=p_status,source_kind='creator',source_id=null,updated_at=now()
    where id=p_deadline_id and deal_id=p_deal_id and workspace_id=v_workspace returning id into v_id;
    if v_id is null then raise exception 'deadline not found' using errcode='P0002'; end if;
  end if;
  insert into public.activity_events(workspace_id,entity_type,entity_id,event_type,actor_user_id,metadata) values(v_workspace,'deal',p_deal_id,'deal_deadline_updated',auth.uid(),jsonb_build_object('deadlineId',v_id,'status',p_status));
  return v_id;
end $$;

create or replace function public.save_deal_contract_reference(p_deal_id uuid,p_received_status text,p_signature_status text,p_reference text) returns uuid
language plpgsql security definer set search_path='' as $$
declare v_workspace uuid; v_id uuid;
begin
  select d.workspace_id into v_workspace from public.deals d where d.id=p_deal_id and d.deleted_at is null
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=d.workspace_id and wm.user_id=auth.uid());
  if v_workspace is null then raise exception 'deal not found' using errcode='P0002'; end if;
  if p_received_status not in ('not_received','received','not_applicable') or p_signature_status not in ('not_signed','creator_signed','fully_signed','not_applicable') or length(coalesce(p_reference,''))>500 then raise exception 'invalid contract state' using errcode='23514'; end if;
  insert into public.deal_contract_references(workspace_id,deal_id,received_status,signature_status,reference,creator_confirmed_at)
  values(v_workspace,p_deal_id,p_received_status,p_signature_status,nullif(trim(p_reference),''),now())
  on conflict(deal_id) do update set received_status=excluded.received_status,signature_status=excluded.signature_status,reference=excluded.reference,creator_confirmed_at=now(),updated_at=now()
  returning id into v_id;
  insert into public.activity_events(workspace_id,entity_type,entity_id,event_type,actor_user_id,metadata) values(v_workspace,'deal',p_deal_id,'deal_contract_updated',auth.uid(),jsonb_build_object('receivedStatus',p_received_status,'signatureStatus',p_signature_status));
  return v_id;
end $$;

create or replace function public.update_draft_invoice(p_invoice_id uuid,p_billing_entity text,p_billing_address text,p_accounts_payable_email text,p_purchase_order text,p_description text,p_quantity numeric,p_unit_amount_minor bigint,p_tax_minor bigint,p_payment_terms_days integer) returns bigint
language plpgsql security definer set search_path='' as $$
declare v_invoice public.invoices; v_total bigint; v_line_total bigint;
begin
  select i.* into v_invoice from public.invoices i where i.id=p_invoice_id and i.status='draft'
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=i.workspace_id and wm.user_id=auth.uid()) for update;
  if v_invoice.id is null then raise exception 'draft invoice not found' using errcode='P0002'; end if;
  if length(trim(p_billing_entity)) not between 1 and 200 or length(coalesce(p_billing_address,''))>2000 or p_accounts_payable_email !~* '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' or length(trim(p_description)) not between 1 and 500 or p_quantity<=0 or p_unit_amount_minor<0 or p_tax_minor<0 or p_payment_terms_days not between 0 and 180 then raise exception 'invalid invoice facts' using errcode='23514'; end if;
  v_line_total:=round(p_quantity*p_unit_amount_minor)::bigint; v_total:=v_line_total+p_tax_minor;
  update public.invoices set billing_entity=trim(p_billing_entity),billing_address=nullif(trim(p_billing_address),''),accounts_payable_email=lower(trim(p_accounts_payable_email)),purchase_order=nullif(trim(p_purchase_order),''),subtotal_minor=v_line_total,tax_minor=p_tax_minor,payment_terms_days=p_payment_terms_days,updated_at=now() where id=p_invoice_id;
  update public.invoice_line_items set description=trim(p_description),quantity=p_quantity,unit_amount_minor=p_unit_amount_minor,line_total_minor=v_line_total,source_kind='creator',updated_at=now() where invoice_id=p_invoice_id and position=1;
  return v_total;
end $$;

create or replace function public.update_admin_email_draft(p_draft_id uuid,p_expected_version integer,p_subject text,p_body text) returns integer
language plpgsql security definer set search_path='' as $$
declare v_version integer;
begin
  if length(trim(p_subject)) not between 1 and 998 or length(trim(p_body)) not between 1 and 100000 then raise exception 'invalid email draft' using errcode='23514'; end if;
  update public.provider_email_drafts d set subject=trim(p_subject),body=p_body,version=version+1,creator_approved_at=null,updated_at=now()
  where d.id=p_draft_id and d.version=p_expected_version and d.state in ('draft','failed')
    and exists(select 1 from public.workspace_members wm where wm.workspace_id=d.workspace_id and wm.user_id=auth.uid()) returning version into v_version;
  if v_version is null then raise exception 'draft changed' using errcode='40001'; end if;
  return v_version;
end $$;

revoke all on function public.save_deal_deadline(uuid,uuid,text,text,timestamptz,text),public.save_deal_contract_reference(uuid,text,text,text),public.update_draft_invoice(uuid,text,text,text,text,text,numeric,bigint,bigint,integer),public.update_admin_email_draft(uuid,integer,text,text) from public,anon;
grant execute on function public.save_deal_deadline(uuid,uuid,text,text,timestamptz,text),public.save_deal_contract_reference(uuid,text,text,text),public.update_draft_invoice(uuid,text,text,text,text,text,numeric,bigint,bigint,integer),public.update_admin_email_draft(uuid,integer,text,text) to authenticated;

-- The ALL policies already cover SELECT; remove redundant read-only policies.
drop policy if exists invoice_issuer_profiles_member_select on public.invoice_issuer_profiles;
drop policy if exists invoice_line_items_member_select on public.invoice_line_items;

