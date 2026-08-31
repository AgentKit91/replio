create table public.score_versions (
  id uuid primary key default gen_random_uuid(), version integer not null unique check(version>0),
  state text not null check(state in ('draft','current','deprecated','archived')), provisional boolean not null default true,
  config jsonb not null, change_summary text not null, created_at timestamptz not null default now()
);
create unique index score_versions_one_current_idx on public.score_versions((state)) where state='current';
create table public.pricing_framework_versions (
  id uuid primary key default gen_random_uuid(), version integer not null unique check(version>0),
  state text not null check(state in ('draft','current','deprecated','archived')), provisional boolean not null default true,
  config jsonb not null, change_summary text not null, created_at timestamptz not null default now()
);
create unique index pricing_framework_versions_one_current_idx on public.pricing_framework_versions((state)) where state='current';
insert into public.score_versions(version,state,provisional,config,change_summary) values
  (1,'current',true,'{"components":{"commercial_value":30,"term_completeness":25,"risk":25,"creator_fit":20}}','Provisional mechanism calibration; requires corpus review before launch.');
insert into public.pricing_framework_versions(version,state,provisional,config,change_summary) values
  (1,'current',true,'{"requires_three_ordered_values":true,"currency_source":"deal_or_creator_profile","invented_benchmarks_forbidden":true}','Provisional structural rules only; contains no invented market rates.');

create table public.analysis_scores (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  snapshot_id uuid not null unique references public.analysis_snapshots(id) on delete cascade, deal_id uuid not null references public.deals(id) on delete cascade,
  score_version_id uuid not null references public.score_versions(id) on delete restrict, score integer not null check(score between 0 and 100),
  components jsonb not null, improvement_actions jsonb not null default '[]'::jsonb, created_at timestamptz not null default now()
);
alter table public.analysis_snapshots add constraint analysis_snapshots_score_version_fk foreign key(score_version_id) references public.score_versions(id) on delete restrict;

create table public.reply_drafts (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  deal_id uuid not null unique references public.deals(id) on delete cascade, deal_thread_id uuid not null references public.deal_threads(id) on delete cascade,
  subject text not null default '', body text not null default '', version integer not null default 1 check(version>0),
  creator_edited boolean not null default false, source_snapshot_id uuid references public.analysis_snapshots(id) on delete set null,
  state text not null default 'draft' check(state in ('draft','sending','sent','failed')),
  provider_message_id text, provider_thread_id text, autosaved_at timestamptz not null default now(), sent_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.reply_versions (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  reply_draft_id uuid not null references public.reply_drafts(id) on delete cascade, version integer not null check(version>0),
  subject text not null, body text not null, change_kind text not null check(change_kind in ('ai_initial','creator_edit','targeted_rewrite','start_again')),
  instruction text, source_snapshot_id uuid references public.analysis_snapshots(id) on delete set null,
  created_by uuid references auth.users(id) on delete set null, created_at timestamptz not null default now(), unique(reply_draft_id,version)
);
create index analysis_scores_workspace_idx on public.analysis_scores(workspace_id,created_at desc);
create index reply_versions_draft_idx on public.reply_versions(reply_draft_id,version desc);

alter table public.score_versions enable row level security; alter table public.pricing_framework_versions enable row level security;
alter table public.analysis_scores enable row level security; alter table public.reply_drafts enable row level security; alter table public.reply_versions enable row level security;
revoke all on public.score_versions,public.pricing_framework_versions,public.analysis_scores,public.reply_drafts,public.reply_versions from anon,authenticated;
grant select on public.score_versions,public.pricing_framework_versions,public.analysis_scores,public.reply_drafts,public.reply_versions to authenticated;
create policy score_versions_read on public.score_versions for select to authenticated using(state in ('current','deprecated'));
create policy pricing_versions_read on public.pricing_framework_versions for select to authenticated using(state in ('current','deprecated'));
create policy analysis_scores_member on public.analysis_scores for select to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=analysis_scores.workspace_id and wm.user_id=(select auth.uid())));
create policy reply_drafts_member on public.reply_drafts for select to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=reply_drafts.workspace_id and wm.user_id=(select auth.uid())));
create policy reply_versions_member on public.reply_versions for select to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=reply_versions.workspace_id and wm.user_id=(select auth.uid())));

create or replace function public.save_reply_draft(p_deal_id uuid,p_subject text,p_body text,p_expected_version integer) returns integer language plpgsql security definer set search_path='' as $$
declare v_draft public.reply_drafts; v_next integer;
begin
  if length(p_subject)>998 or length(p_body)>100000 then raise exception 'reply exceeds size limit' using errcode='22001'; end if;
  select rd.* into v_draft from public.reply_drafts rd join public.workspace_members wm on wm.workspace_id=rd.workspace_id where rd.deal_id=p_deal_id and wm.user_id=auth.uid() for update of rd;
  if v_draft.id is null then raise exception 'reply draft not found' using errcode='P0002'; end if;
  if v_draft.state<>'draft' then raise exception 'reply is not editable' using errcode='55000'; end if;
  if v_draft.version<>p_expected_version then raise exception 'reply version conflict' using errcode='40001'; end if;
  v_next:=v_draft.version+1;
  update public.reply_drafts set subject=p_subject,body=p_body,version=v_next,creator_edited=true,autosaved_at=now(),updated_at=now() where id=v_draft.id;
  insert into public.reply_versions(workspace_id,reply_draft_id,version,subject,body,change_kind,source_snapshot_id,created_by) values(v_draft.workspace_id,v_draft.id,v_next,p_subject,p_body,'creator_edit',v_draft.source_snapshot_id,auth.uid());
  return v_next;
end $$;
revoke all on function public.save_reply_draft(uuid,text,text,integer) from public,anon; grant execute on function public.save_reply_draft(uuid,text,text,integer) to authenticated;

comment on table public.score_versions is 'Versioned score calibration. Provisional versions require product/eval review before launch.';
comment on table public.pricing_framework_versions is 'Versioned pricing structure; no sample or invented market rates.';
