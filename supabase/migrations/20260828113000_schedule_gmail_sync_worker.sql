create extension if not exists pg_cron;
create extension if not exists pg_net with schema extensions;

create or replace function private.invoke_gmail_sync_worker()
returns bigint
language plpgsql
security definer
set search_path = pg_catalog, private
as $$
declare
  worker_secret text;
  request_id bigint;
begin
  select decrypted_secret
  into worker_secret
  from vault.decrypted_secrets
  where name = 'internal_job_secret';

  -- Keep the scheduled job inert until the matching Vercel secret has been
  -- stored in Vault. This avoids unauthenticated requests during setup.
  if worker_secret is null then
    return null;
  end if;

  select net.http_post(
    url := 'https://replio-three.vercel.app/api/internal/workers/gmail-sync',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || worker_secret
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 15000
  )
  into request_id;

  return request_id;
end;
$$;

revoke all on function private.invoke_gmail_sync_worker() from public, anon, authenticated;

select cron.schedule(
  'replio-gmail-sync-worker',
  '* * * * *',
  'select private.invoke_gmail_sync_worker();'
);
