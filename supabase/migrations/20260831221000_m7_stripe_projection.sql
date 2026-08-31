create or replace function public.project_stripe_subscription(
  p_event_id text,p_event_type text,p_event_created_at timestamptz,p_workspace_id uuid,p_plan_key text,
  p_customer_id text,p_subscription_id text,p_status text,p_trial_end timestamptz,p_period_start timestamptz,
  p_period_end timestamptz,p_cancel_at_period_end boolean
) returns boolean language plpgsql security definer set search_path='' as $$
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501';end if;
  insert into private.stripe_events(event_id,event_type,stripe_created_at,status) values(p_event_id,p_event_type,p_event_created_at,'processing') on conflict(event_id) do nothing;
  if not found then return false;end if;
  if p_status not in ('incomplete','trialing','active','past_due','unpaid','canceled','paused') then
    update private.stripe_events set status='ignored',processed_at=now() where event_id=p_event_id;return false;
  end if;
  insert into public.subscriptions(workspace_id,plan_key,stripe_customer_id,stripe_subscription_id,status,trial_ends_at,current_period_starts_at,current_period_ends_at,cancel_at_period_end,last_stripe_event_created_at)
  values(p_workspace_id,p_plan_key,p_customer_id,p_subscription_id,p_status,p_trial_end,p_period_start,p_period_end,p_cancel_at_period_end,p_event_created_at)
  on conflict(workspace_id) do update set plan_key=excluded.plan_key,stripe_customer_id=excluded.stripe_customer_id,stripe_subscription_id=excluded.stripe_subscription_id,status=excluded.status,trial_ends_at=excluded.trial_ends_at,current_period_starts_at=excluded.current_period_starts_at,current_period_ends_at=excluded.current_period_ends_at,cancel_at_period_end=excluded.cancel_at_period_end,last_stripe_event_created_at=excluded.last_stripe_event_created_at,updated_at=now()
  where public.subscriptions.last_stripe_event_created_at is null or public.subscriptions.last_stripe_event_created_at<=excluded.last_stripe_event_created_at;
  update private.stripe_events set status='processed',processed_at=now() where event_id=p_event_id;return true;
exception when others then
  update private.stripe_events set status='failed',error_class=sqlstate,processed_at=now() where event_id=p_event_id;raise;
end $$;
revoke all on function public.project_stripe_subscription(text,text,timestamptz,uuid,text,text,text,text,timestamptz,timestamptz,timestamptz,boolean) from public,anon,authenticated;
grant execute on function public.project_stripe_subscription(text,text,timestamptz,uuid,text,text,text,text,timestamptz,timestamptz,timestamptz,boolean) to service_role;

create or replace function public.record_stripe_event(p_event_id text,p_event_type text,p_event_created_at timestamptz) returns boolean language plpgsql security definer set search_path='' as $$
begin
 if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'service role required' using errcode='42501';end if;
 insert into private.stripe_events(event_id,event_type,stripe_created_at,status,processed_at) values(p_event_id,p_event_type,p_event_created_at,'ignored',now()) on conflict(event_id) do nothing;return found;
end $$;
revoke all on function public.record_stripe_event(text,text,timestamptz) from public,anon,authenticated;grant execute on function public.record_stripe_event(text,text,timestamptz) to service_role;
