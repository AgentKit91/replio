create table public.creator_goals(
  id uuid primary key default gen_random_uuid(),workspace_id uuid not null references public.workspaces(id) on delete cascade,
  goal_code text not null check(goal_code in ('increase_rates','better_terms','more_deals','better_fit','save_time','other')),
  creator_wording text check(length(creator_wording)<=500),active boolean not null default true,priority smallint not null check(priority between 1 and 3),
  created_at timestamptz not null default now(),updated_at timestamptz not null default now(),unique(workspace_id,priority)
);
create table public.creator_non_negotiables(
  id uuid primary key default gen_random_uuid(),workspace_id uuid not null references public.workspaces(id) on delete cascade,
  category text not null check(category in ('commercial','brand','personal','working_preference')),rule_text text not null check(length(rule_text) between 1 and 1000),structured_value jsonb not null default '{}'::jsonb,active boolean not null default true,
  created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
create table public.creator_preferences(
  id uuid primary key default gen_random_uuid(),workspace_id uuid not null references public.workspaces(id) on delete cascade,
  preference_code text not null,preference_value jsonb not null,creator_wording text check(length(creator_wording)<=1000),source text not null default 'creator' check(source in ('creator','accepted_suggestion')),active boolean not null default true,
  created_at timestamptz not null default now(),updated_at timestamptz not null default now(),unique(workspace_id,preference_code)
);
create table public.learned_preference_suggestions(
  id uuid primary key default gen_random_uuid(),workspace_id uuid not null references public.workspaces(id) on delete cascade,
  pattern_code text not null,evidence_summary text not null check(length(evidence_summary)<=1000),confidence numeric(4,3) not null check(confidence between 0 and 1),suggested_preference jsonb not null,
  state text not null default 'pending' check(state in ('pending','accepted','rejected','dismissed')),resolved_at timestamptz,created_at timestamptz not null default now()
);
create table public.creator_voice_profiles(
  id uuid primary key default gen_random_uuid(),workspace_id uuid not null references public.workspaces(id) on delete cascade,version integer not null check(version>0),characteristics jsonb not null,
  source_summary text not null check(length(source_summary)<=1000),current boolean not null default true,created_at timestamptz not null default now(),unique(workspace_id,version)
);
create unique index creator_voice_one_current_idx on public.creator_voice_profiles(workspace_id) where current;
create table public.rate_cards(
  id uuid primary key default gen_random_uuid(),workspace_id uuid not null references public.workspaces(id) on delete cascade,name text not null check(length(name)<=200),currency char(3) not null,active boolean not null default true,created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
create table public.rate_card_items(
  id uuid primary key default gen_random_uuid(),workspace_id uuid not null references public.workspaces(id) on delete cascade,rate_card_id uuid not null references public.rate_cards(id) on delete cascade,
  platform text not null,deliverable_type text not null,amount_minor bigint not null check(amount_minor>=0),notes text check(length(notes)<=1000),created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
create table public.eae_method_versions(
  version integer primary key,state text not null check(state in ('current','deprecated')),description text not null,created_at timestamptz not null default now()
);
insert into public.eae_method_versions(version,state,description) values(1,'current','Positive uplift from the earliest brand offer to the final agreed amount; negative uplift floors at zero.');
create table public.deal_outcomes(
  id uuid primary key default gen_random_uuid(),workspace_id uuid not null references public.workspaces(id) on delete cascade,deal_id uuid not null unique references public.deals(id) on delete cascade,
  outcome text not null check(outcome in ('success','lost','declined')),currency char(3) not null,initial_offer_minor bigint check(initial_offer_minor is null or initial_offer_minor>=0),final_amount_minor bigint check(final_amount_minor is null or final_amount_minor>=0),
  estimated_additional_earnings_minor bigint not null default 0 check(estimated_additional_earnings_minor>=0),uplift_percent numeric(9,2),negotiation_rounds integer check(negotiation_rounds is null or negotiation_rounds>=0),
  time_to_first_reply_seconds bigint check(time_to_first_reply_seconds is null or time_to_first_reply_seconds>=0),time_to_final_seconds bigint check(time_to_final_seconds is null or time_to_final_seconds>=0),
  major_term_improvements jsonb not null default '[]'::jsonb,contextual_learning jsonb not null default '{}'::jsonb,eae_method_version integer not null references public.eae_method_versions(version),eae_inputs jsonb not null,
  anonymisation_version integer not null default 1,benchmark_contributed_at timestamptz,created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
create table public.benchmark_algorithm_versions(version integer primary key,state text not null check(state in ('current','deprecated')),minimum_sample_count integer not null check(minimum_sample_count>=5),description text not null,created_at timestamptz not null default now());
insert into public.benchmark_algorithm_versions(version,state,minimum_sample_count,description) values(1,'current',5,'MVP aggregation gate; cells below five outcomes are never exposed or used.');
create table private.benchmark_contributions(
  id uuid primary key default gen_random_uuid(),anonymisation_version integer not null,benchmark_algorithm_version integer not null references public.benchmark_algorithm_versions(version),
  brand_id uuid,creator_niche text,platform text,creator_size_bucket text,engagement_bucket text,deliverable_signature text,currency char(3) not null,
  initial_offer_minor bigint,final_amount_minor bigint,estimated_uplift_minor bigint not null,negotiation_rounds integer,response_seconds bigint,outcome text not null,created_at timestamptz not null default now()
);
create table public.benchmark_cells(
  id uuid primary key default gen_random_uuid(),dimension_signature text not null,dimensions jsonb not null,currency char(3) not null,sample_count integer not null check(sample_count>=5),
  median_offer_minor bigint,median_settlement_minor bigint,p25_settlement_minor bigint,p75_settlement_minor bigint,median_uplift_minor bigint,median_rounds numeric(8,2),median_response_seconds bigint,
  evidence_strength text not null check(evidence_strength in ('emerging','strong')),algorithm_version integer not null references public.benchmark_algorithm_versions(version),generated_at timestamptz not null default now(),unique(dimension_signature,currency,algorithm_version)
);
create index creator_goals_workspace_idx on public.creator_goals(workspace_id);
create index creator_non_negotiables_workspace_idx on public.creator_non_negotiables(workspace_id);
create index creator_preferences_workspace_idx on public.creator_preferences(workspace_id);
create index learned_preference_suggestions_workspace_idx on public.learned_preference_suggestions(workspace_id);
create index creator_voice_profiles_workspace_idx on public.creator_voice_profiles(workspace_id);
create index rate_cards_workspace_idx on public.rate_cards(workspace_id);
create index rate_card_items_workspace_idx on public.rate_card_items(workspace_id);
create index rate_card_items_card_idx on public.rate_card_items(rate_card_id);
create index deal_outcomes_workspace_idx on public.deal_outcomes(workspace_id);
create index benchmark_contributions_version_idx on private.benchmark_contributions(benchmark_algorithm_version);
create index benchmark_cells_algorithm_idx on public.benchmark_cells(algorithm_version);

do $$ declare t text; begin foreach t in array array['creator_goals','creator_non_negotiables','creator_preferences','learned_preference_suggestions','creator_voice_profiles','rate_cards','rate_card_items','deal_outcomes','eae_method_versions','benchmark_algorithm_versions','benchmark_cells'] loop execute format('alter table public.%I enable row level security',t); end loop; end $$;
revoke all on public.creator_goals,public.creator_non_negotiables,public.creator_preferences,public.learned_preference_suggestions,public.creator_voice_profiles,public.rate_cards,public.rate_card_items,public.deal_outcomes,public.eae_method_versions,public.benchmark_algorithm_versions,public.benchmark_cells from anon,authenticated;
grant select,insert,update,delete on public.creator_goals,public.creator_non_negotiables,public.creator_preferences,public.rate_cards,public.rate_card_items to authenticated;
grant select on public.learned_preference_suggestions,public.creator_voice_profiles,public.deal_outcomes,public.eae_method_versions,public.benchmark_algorithm_versions,public.benchmark_cells to authenticated;
revoke all on private.benchmark_contributions from public,anon,authenticated;

do $$ declare t text; begin foreach t in array array['creator_goals','creator_non_negotiables','creator_preferences','learned_preference_suggestions','creator_voice_profiles','rate_cards','rate_card_items','deal_outcomes'] loop
 execute format('create policy %I on public.%I for select to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=%I.workspace_id and wm.user_id=(select auth.uid())))',t||'_member_select',t,t);
 end loop; end $$;
create policy creator_goals_member_insert on public.creator_goals for insert to authenticated with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_goals.workspace_id and wm.user_id=(select auth.uid())));
create policy creator_goals_member_update on public.creator_goals for update to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_goals.workspace_id and wm.user_id=(select auth.uid()))) with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_goals.workspace_id and wm.user_id=(select auth.uid())));
create policy creator_goals_member_delete on public.creator_goals for delete to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_goals.workspace_id and wm.user_id=(select auth.uid())));
create policy creator_non_negotiables_member_insert on public.creator_non_negotiables for insert to authenticated with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_non_negotiables.workspace_id and wm.user_id=(select auth.uid())));
create policy creator_non_negotiables_member_update on public.creator_non_negotiables for update to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_non_negotiables.workspace_id and wm.user_id=(select auth.uid()))) with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_non_negotiables.workspace_id and wm.user_id=(select auth.uid())));
create policy creator_non_negotiables_member_delete on public.creator_non_negotiables for delete to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_non_negotiables.workspace_id and wm.user_id=(select auth.uid())));
create policy creator_preferences_member_insert on public.creator_preferences for insert to authenticated with check(source='creator' and exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_preferences.workspace_id and wm.user_id=(select auth.uid())));
create policy creator_preferences_member_update on public.creator_preferences for update to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_preferences.workspace_id and wm.user_id=(select auth.uid()))) with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_preferences.workspace_id and wm.user_id=(select auth.uid())));
create policy creator_preferences_member_delete on public.creator_preferences for delete to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=creator_preferences.workspace_id and wm.user_id=(select auth.uid())));
create policy rate_cards_member_insert on public.rate_cards for insert to authenticated with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=rate_cards.workspace_id and wm.user_id=(select auth.uid())));
create policy rate_cards_member_update on public.rate_cards for update to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=rate_cards.workspace_id and wm.user_id=(select auth.uid()))) with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=rate_cards.workspace_id and wm.user_id=(select auth.uid())));
create policy rate_cards_member_delete on public.rate_cards for delete to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=rate_cards.workspace_id and wm.user_id=(select auth.uid())));
create policy rate_card_items_member_insert on public.rate_card_items for insert to authenticated with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=rate_card_items.workspace_id and wm.user_id=(select auth.uid())) and exists(select 1 from public.rate_cards rc where rc.id=rate_card_id and rc.workspace_id=rate_card_items.workspace_id));
create policy rate_card_items_member_update on public.rate_card_items for update to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=rate_card_items.workspace_id and wm.user_id=(select auth.uid()))) with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=rate_card_items.workspace_id and wm.user_id=(select auth.uid())));
create policy rate_card_items_member_delete on public.rate_card_items for delete to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=rate_card_items.workspace_id and wm.user_id=(select auth.uid())));
create policy eae_versions_read on public.eae_method_versions for select to authenticated using(state in ('current','deprecated'));
create policy benchmark_versions_read on public.benchmark_algorithm_versions for select to authenticated using(state in ('current','deprecated'));
create policy benchmark_cells_evidence_gate on public.benchmark_cells for select to authenticated using(sample_count>=(select minimum_sample_count from public.benchmark_algorithm_versions bav where bav.version=algorithm_version));

create or replace function public.enforce_three_active_goals() returns trigger language plpgsql security invoker set search_path='' as $$ begin if new.active and (select count(*) from public.creator_goals where workspace_id=new.workspace_id and active and id<>new.id)>=3 then raise exception 'maximum three active goals' using errcode='23514'; end if; return new; end $$;
create trigger creator_goals_max_three before insert or update on public.creator_goals for each row execute function public.enforce_three_active_goals();

create or replace function public.accept_preference_suggestion(p_suggestion_id uuid) returns uuid language plpgsql security definer set search_path='' as $$
declare v_s public.learned_preference_suggestions; v_id uuid;
begin select s.* into v_s from public.learned_preference_suggestions s join public.workspace_members wm on wm.workspace_id=s.workspace_id where s.id=p_suggestion_id and wm.user_id=auth.uid() for update of s;
 if v_s.id is null or v_s.state<>'pending' then raise exception 'pending suggestion not found' using errcode='P0002'; end if;
 insert into public.creator_preferences(workspace_id,preference_code,preference_value,creator_wording,source) values(v_s.workspace_id,v_s.pattern_code,v_s.suggested_preference,v_s.evidence_summary,'accepted_suggestion') on conflict(workspace_id,preference_code) do update set preference_value=excluded.preference_value,creator_wording=excluded.creator_wording,source='accepted_suggestion',active=true,updated_at=now() returning id into v_id;
 update public.learned_preference_suggestions set state='accepted',resolved_at=now() where id=v_s.id; return v_id; end $$;
revoke all on function public.accept_preference_suggestion(uuid) from public,anon; grant execute on function public.accept_preference_suggestion(uuid) to authenticated;

comment on table private.benchmark_contributions is 'Irreversibly unlinked aggregate inputs: never stores creator/workspace/contact/message/outcome/deal identifiers or raw text.';
comment on table public.deal_outcomes is 'Private creator outcome recap with versioned conservative Estimated Additional Earnings inputs.';
