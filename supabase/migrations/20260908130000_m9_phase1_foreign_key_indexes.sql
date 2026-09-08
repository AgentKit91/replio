-- Cover Phase 1 foreign keys used by tenant deletion, cascading cleanup and operational joins.
create index if not exists managed_email_events_message_idx on private.managed_email_events(message_id);
create index if not exists managed_email_events_workspace_idx on private.managed_email_events(workspace_id);
create index if not exists deal_contract_references_workspace_idx on public.deal_contract_references(workspace_id);
create index if not exists deal_deadlines_created_by_idx on public.deal_deadlines(created_by);
create index if not exists deal_deadlines_deal_idx on public.deal_deadlines(deal_id);
create index if not exists deal_operational_facts_created_by_idx on public.deal_operational_facts(created_by);
create index if not exists deal_operational_facts_superseded_idx on public.deal_operational_facts(superseded_by);
create index if not exists deal_threads_creator_email_address_idx on public.deal_threads(creator_email_address_id);
create index if not exists invoice_line_items_workspace_idx on public.invoice_line_items(workspace_id);
create index if not exists invoice_versions_created_by_idx on public.invoice_versions(created_by);
create index if not exists invoice_versions_workspace_idx on public.invoice_versions(workspace_id);
create index if not exists invoices_issuer_profile_idx on public.invoices(issuer_profile_id);
create index if not exists payment_reminders_invoice_idx on public.payment_reminders(invoice_id);
create index if not exists provider_email_drafts_deal_idx on public.provider_email_drafts(deal_id);

