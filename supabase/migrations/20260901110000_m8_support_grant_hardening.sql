create or replace function private.enforce_support_grant_revoke_only()
returns trigger language plpgsql security definer set search_path='' as $$
begin
  if new.workspace_id<>old.workspace_id or new.granted_by_user_id<>old.granted_by_user_id
    or new.scope_type<>old.scope_type or new.scope_id is distinct from old.scope_id
    or new.reason<>old.reason or new.expires_at<>old.expires_at or new.created_at<>old.created_at
    or old.revoked_at is not null or new.revoked_at is null then
    raise exception 'support grants may only be revoked' using errcode='42501';
  end if;
  return new;
end;
$$;
revoke all on function private.enforce_support_grant_revoke_only() from public,anon,authenticated;
create trigger enforce_support_grant_revoke_only before update on public.support_access_grants
for each row execute function private.enforce_support_grant_revoke_only();

