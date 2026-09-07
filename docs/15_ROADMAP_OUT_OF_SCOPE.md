# Roadmap / Explicitly Out of Phase 1

These items may influence extensibility but Codex must not implement them in Phase 1 unless the specification is formally revised.

## Important scope change — 7 September 2026

The following are **no longer out of scope** and are mandatory Phase 1 features under the dated founder amendments:

### `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md`

- invoice generation/sending with creator approval;
- payment tracking;
- due-date tracking;
- payment reminders/overdue chase preparation;
- creator confirmation of paid/still waiting;
- Deal deadlines/deliverable operations needed for end-to-end administration;
- Kanban-esque operational Deal pipeline;
- creator financial states for agreed/invoiced/outstanding/overdue/received.

### `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`

- one optional dedicated Rep Bureau commercial email address per creator workspace;
- direct inbound brand enquiries to that address;
- creator-forwarded brand emails from otherwise unconnected mailboxes;
- outbound creator-approved negotiation/invoice/chase emails from that dedicated address;
- provider-neutral Deal/message support so managed-address Deals have the same end-to-end capabilities as Gmail Deals;
- secure inbound attachment handling, spam/abuse and deliverability controls required for the public address.

Do not defer these merely because older documents called them Phase 1.5/Phase 2/future.

## Later candidates

- Outlook OAuth/inbox source;
- creator-owned custom-domain email hosting / bring-your-own-domain sending;
- multiple creator aliases/inboxes beyond the simple Phase 1 dedicated-address requirement;
- full arbitrary consumer-mailbox features such as folders/rules/general personal mail management;
- full legal contract upload/extraction/review/generation beyond Phase 1 contract metadata;
- automatic external negotiation/invoice/chase sending without creator approval;
- bank feed/open-banking integration and automatic payment reconciliation;
- accounting/bookkeeping/general ledger;
- tax filing/advice and expense accounting;
- calendar integrations beyond internal Deal deadlines;
- opportunity discovery/outreach;
- creator platform API enrichment beyond approved profile data;
- richer brand-intelligence surfaces when evidence thresholds exist;
- natural-language search;
- broader advanced automation.

## Future vision

- agency/team mode and shared workspaces;
- multiple creator identities/businesses;
- creator/brand marketplace;
- Brand Intelligence Graph;
- advanced reporting/data products;
- API/integrations ecosystem;
- media kit tools;
- accounting/tax integrations;
- Founder AI assistant.

## Explicitly rejected/bounded

- Creator Score;
- full external-inbox scanning as a Phase 1 trigger;
- random reply regeneration;
- raw model chain-of-thought storage/display;
- fake/pre-populated brand negotiation claims;
- user-facing AI credit counter as primary experience;
- AI fine-tuning as a Phase 1 dependency;
- inferring that an invoice has been paid without creator confirmation or a later explicit verified payment integration;
- treating a dedicated Rep Bureau commercial address as permission to access any unrelated external mailbox;
- auto-sending from the managed address without creator approval.
