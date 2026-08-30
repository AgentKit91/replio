create or replace function private.resolve_brand_from_message(p_message_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_message public.gmail_messages%rowtype; v_deal_id uuid; v_email text; v_domain text; v_brand_id uuid; v_contact_name text;
begin
  select * into v_message from public.gmail_messages where id = p_message_id and direction = 'inbound';
  if not found then return; end if;
  v_email := lower(coalesce((regexp_match(v_message.from_address, '<([^>]+)>'))[1], trim(v_message.from_address)));
  v_domain := split_part(v_email, '@', 2);
  if v_domain = '' or v_domain = any(array['gmail.com','googlemail.com','outlook.com','hotmail.com','live.com','icloud.com','me.com','yahoo.com','proton.me','protonmail.com']) then return; end if;
  select deal_id into v_deal_id from public.deal_threads where id = v_message.deal_thread_id;
  if v_deal_id is null then return; end if;
  insert into public.brands(canonical_name, normalized_domain) values (initcap(replace(split_part(v_domain, '.', 1), '-', ' ')), v_domain)
    on conflict (normalized_domain) do update set updated_at = public.brands.updated_at returning id into v_brand_id;
  insert into public.workspace_brands(workspace_id, brand_id) values (v_message.workspace_id, v_brand_id) on conflict (workspace_id, brand_id) do nothing;
  v_contact_name := nullif(trim(regexp_replace(v_message.from_address, '\s*<[^>]+>\s*$', '')), v_message.from_address);
  insert into public.brand_contacts(workspace_id, brand_id, name, email, source, last_seen_at)
    values (v_message.workspace_id, v_brand_id, v_contact_name, v_email, 'gmail', v_message.internal_date)
    on conflict (workspace_id, brand_id, email) do update set name = coalesce(public.brand_contacts.name, excluded.name), last_seen_at = greatest(public.brand_contacts.last_seen_at, excluded.last_seen_at), updated_at = now();
  update public.deals set brand_id = v_brand_id, updated_at = now() where id = v_deal_id and brand_id is null;
end $$;

update public.deals set brand_id = null where brand_id in (select id from public.brands where normalized_domain = any(array['gmail.com','googlemail.com','outlook.com','hotmail.com','live.com','icloud.com','me.com','yahoo.com','proton.me','protonmail.com']));
delete from public.brands where normalized_domain = any(array['gmail.com','googlemail.com','outlook.com','hotmail.com','live.com','icloud.com','me.com','yahoo.com','proton.me','protonmail.com']);
