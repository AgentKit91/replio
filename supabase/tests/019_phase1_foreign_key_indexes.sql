begin;set search_path=public,extensions;select plan(14);
select has_index('private','managed_email_events','managed_email_events_message_idx','managed email event message cleanup is indexed');
select has_index('private','managed_email_events','managed_email_events_workspace_idx','managed email event tenant cleanup is indexed');
select has_index('public','deal_contract_references','deal_contract_references_workspace_idx','contract tenant cleanup is indexed');
select has_index('public','deal_deadlines','deal_deadlines_created_by_idx','deadline creator cleanup is indexed');
select has_index('public','deal_deadlines','deal_deadlines_deal_idx','deadline Deal cleanup is indexed');
select has_index('public','deal_operational_facts','deal_operational_facts_created_by_idx','fact creator cleanup is indexed');
select has_index('public','deal_operational_facts','deal_operational_facts_superseded_idx','fact history cleanup is indexed');
select has_index('public','deal_threads','deal_threads_creator_email_address_idx','managed address thread cleanup is indexed');
select has_index('public','invoice_line_items','invoice_line_items_workspace_idx','invoice line tenant cleanup is indexed');
select has_index('public','invoice_versions','invoice_versions_created_by_idx','invoice version creator cleanup is indexed');
select has_index('public','invoice_versions','invoice_versions_workspace_idx','invoice version tenant cleanup is indexed');
select has_index('public','invoices','invoices_issuer_profile_idx','issuer profile cleanup is indexed');
select has_index('public','payment_reminders','payment_reminders_invoice_idx','reminder invoice cleanup is indexed');
select has_index('public','provider_email_drafts','provider_email_drafts_deal_idx','email draft Deal cleanup is indexed');
select * from finish();rollback;

