update public.plan_catalog
set stripe_price_id = case plan_key
  when 'standard' then 'price_1UAeGwLU3Hc8FOCfYyza1D4F'
  when 'pro' then 'price_1UAeGsLU3Hc8FOCfrA7ZyKJo'
  else stripe_price_id
end,
updated_at = now()
where plan_key in ('standard', 'pro');

comment on column public.plan_catalog.stripe_price_id is
  'Stripe test-mode Price identifier until a separately approved production catalogue is activated.';
