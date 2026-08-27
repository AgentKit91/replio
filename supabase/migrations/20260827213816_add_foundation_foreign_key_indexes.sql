create index workspaces_created_by_idx on public.workspaces(created_by);
create index activity_events_actor_user_idx on public.activity_events(actor_user_id);
