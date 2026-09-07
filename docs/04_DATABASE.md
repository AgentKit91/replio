# Database Specification

## Global rules

- Postgres is the system of record.
- UUID primary keys unless a strong reason exists otherwise.
- All timestamps are `timestamptz` stored in UTC; display in user timezone.
- Money is stored as integer minor units plus ISO currency code. Never use floating point for money.
- Every workspace-owned row carries `workspace_id` directly or through an unambiguous parent.
- Every public/exposed table has RLS enabled and tested.
- User-editable values record source/ownership where AI/imports might also update them.
- Material auto-populated values preserve provenance/evidence.
- Soft-deletable private records use `deleted_at` + `purge_after`; 30-day recycle bin unless explicitly purged earlier.
- Permanent purge removes private creator data and managed/generated artifacts; only irreversibly anonymised aggregate intelligence may remain.
- Phase 1 Deal/message storage is provider-neutral across Gmail and the dedicated Rep Bureau creator email.

## Identity and tenancy

### `user_profiles`

- `user_id uuid pk` -> auth.users
- `display_name text`
- `timezone text`
- `base_currency char(3)`
- `country_code char(2)`
- `created_at`, `updated_at`

### `workspaces`

Hidden tenancy boundary. Phase 1 creates one workspace per creator account.

- `id uuid pk`
- `name text`
- `kind text` default `creator`
- `created_by uuid`
- timestamps

### `workspace_members`

- `workspace_id`
- `user_id`
- `role` (`owner` in creator Phase 1; schema extensible)
- `created_at`
- unique `(workspace_id,user_id)`

Do not expose team-management UI in Phase 1.

## Creator profile

### `creator_profiles`

- `id`, `workspace_id` unique
- `creator_name`
- `niche`
- `country_code`
- `base_currency`
- `profile_schema_version`
- timestamps

### `creator_platforms`

- `id`, `workspace_id`, `creator_profile_id`
- `platform`
- `handle`
- `profile_url` nullable
- `followers` nullable
- `avg_views` nullable
- `engagement_rate` nullable
- `source_type` (`verified`,`self_reported`,`ai_estimated`)
- `verified_at` nullable
- timestamps

### `creator_goals`

Up to three primary active goals. Store goal code + optional creator wording.

### `creator_non_negotiables`

- category (`commercial`,`brand`,`personal`,`working_preference`)
- rule text / structured value where possible
- active flag
- creator-owned only

### `creator_preferences`

Explicit permanent/standard preferences. Creator-owned.

### `learned_preference_suggestions`

Observed pattern, evidence summary, confidence, suggested preference, state (`pending`,`accepted`,`rejected`,`dismissed`). Accepted suggestions write a new creator-owned preference through an explicit user action.

### `creator_voice_profiles`

Private structured voice characteristics and current version. Do not store hidden reasoning.

### `rate_cards` and `rate_card_items`

- platform/deliverable type
- amount minor units
- currency
- notes
- source/updated_at

### `invoice_issuer_profiles`

Versioned creator-owned invoice/business identity used to prepare Deal invoices.

At minimum:

- `id`, `workspace_id`
- version/current flag
- legal/trading name
- address/contact details
- creator-supplied tax/VAT identifiers where applicable
- creator-supplied bank/payment instructions
- invoice prefix/numbering preferences where supported
- default payment terms nullable
- timestamps

Never infer legal/tax/bank identity. Treat these fields as highly private business data.

## Brands and contacts

### `brands` (global)

Contains non-private brand identity only:

- canonical name
- normalized domain(s)
- industry/category
- country/region where known
- safe public metadata

No creator-specific Deal content or notes.

### `workspace_brands`

Private creator relationship overlay:

- `workspace_id`, `brand_id` unique
- private relationship status
- creator-specific notes summary if needed
- timestamps

### `brand_contacts`

Private/workspace-scoped contact records connected to a global brand.

- name, email, title/team where known
- source/provenance
- last_seen_at

## Deals

### `deals`

- `id`, `workspace_id`, `brand_id` nullable until resolved
- `title`
- `status`
- `human_status_code`/derived state if useful
- `primary_platform` nullable
- `currency`
- `current_offer_minor` nullable
- `final_agreed_minor` nullable
- `replio_score` nullable
- `replio_score_version_id` nullable
- `estimated_additional_earnings_minor` nullable
- `created_source` (`gmail_label`,`rep_bureau_email_direct`,`rep_bureau_email_forward`, ...)
- `deleted_at`, `purge_after`
- timestamps

### `deal_threads`

Links one or more provider conversations to a Deal.

- `workspace_id`
- provider (`gmail`,`rep_bureau_email`)
- provider connection/address id where needed
- `provider_thread_id`
- role (`primary_negotiation`,`outreach`,`contract`,`deliverables`,`payment`,`usage_extension`,`other`)
- is_primary
- unique workspace/provider/provider-scope/thread

Do not create a second parallel Deal model for managed email.

### `email_messages`

Normalized provider-neutral message model:

- `workspace_id`, `deal_thread_id`
- provider
- provider message id unique within provider scope/connection
- provider thread/conversation id
- sender/recipient/reply-to/envelope headers as structured JSON
- subject
- sent_at
- direction (`inbound`,`outbound`)
- source mode (`gmail_selected`,`managed_direct`,`managed_forwarded`,...)
- `body_text` canonical
- `body_html_sanitized` optional
- `provider_label_ids` nullable / Gmail-specific
- `source_hash`
- `raw_provider_ref` minimal provider reference
- forwarding provenance/metadata where applicable
- timestamps

Do not load remote images/tracking pixels by default in rendered email HTML. Sanitize HTML.

Forwarded headers embedded in body text are creator-supplied evidence unless independently transport/provider verified. Preserve this distinction so the UI/AI cannot misrepresent provenance.

### `email_attachment_refs`

For Gmail, provider-reference metadata remains preferred:

- provider attachment/message id
- filename, mime type, size
- provider reference

For direct managed-email inbound, an external mailbox reference may not exist; use a secure private object reference when the attachment must be retained.

Store:

- provider/source
- filename/mime/size/hash
- provider reference or private object-storage path/reference
- safety/processing state where applicable
- timestamps

Managed-email stored attachments must be workspace-private, size/type limited, signed-access only, and purge with private Deal/account data.

### `deal_deliverables`

Structured deliverables:

- platform
- deliverable_type
- quantity
- due timing if known
- operational status
- source fact id
- timestamps/versioning where useful

### `deal_deadlines`

Structured operational deadlines extracted/confirmed during the Deal:

- workspace/deal
- deadline type (draft, approval, live/post, campaign end, invoice, payment follow-up, other)
- due_at/date
- status
- source/evidence/provenance
- internal confidence if AI-derived
- current/version
- timestamps

### `deal_terms`

Structured commercial terms:

- term_type (usage_duration, territory, exclusivity, payment_terms, approval_rounds, licensing, whitelisting/paid_media, cancellation, travel, billing_entity, invoice_instructions, PO/reference, etc.)
- normalized value JSONB
- display value
- fact_state (`confirmed`,`missing`,`inferred`)
- source ownership (`user`,`approved_ai`,`ai_extraction`,`imported`)
- evidence pointer(s)
- current flag/version

### `deal_offers`

Preserve the negotiation story rather than overwriting one fee:

- offered_by (`brand`,`creator`)
- amount_minor
- currency
- offer_type (`initial`,`counter`,`revised`,`final`)
- source message id
- observed_at

### `deal_notes`

Private basic rich text, searchable.

### `deal_outcomes`

On close/completion:

- initial offer
- final agreed amount
- calculated uplift
- rounds
- time to first reply/final agreement where derivable
- major term improvements structured
- success/lost/declined outcome
- optional contextual learning responses
- `anonymisation_version`

## Invoices and payments

Detailed behaviour is defined in `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md`; the schema must provide equivalent concepts.

### `deal_invoices`

Workspace/Deal-scoped invoice lifecycle record, including:

- invoice issuer profile/version used
- stable invoice number
- currency
- subtotal/tax/total minor units as applicable
- billing entity/address/contact
- PO/reference
- payment terms
- invoice date and calculated due date
- status (`draft`,`approved`,`sent`,`void` or equivalent)
- approved/sent timestamps
- email provider/thread/message references
- immutable-ish approved snapshot/version
- idempotency keys
- timestamps

### `deal_invoice_line_items`

- invoice id
- description/deliverable reference
- quantity
- unit/line amount minor units
- tax treatment only where explicitly configured/supplied
- ordering

### `invoice_artifacts`

Private generated invoice PDF/version reference or reproducible artifact metadata:

- workspace/invoice/version
- object/storage reference or deterministic generation snapshot
- content hash
- generated_at
- access/deletion state

### `deal_payments`

Phase 1 payment-status record, not bank reconciliation:

- workspace/deal/invoice
- expected/invoiced/outstanding amount
- due date
- current payment state
- creator-confirmed paid amount/date nullable
- latest promised payment date nullable
- timestamps

### `payment_status_events`

Preserve state history/provenance, including brand statements and creator confirmations.

### `payment_reminders`

- deal/invoice/payment
- reminder stage/type
- scheduled/prepared/sent/cancelled state
- draft/version
- provider send intent/message id
- sent_at
- next review date
- idempotency key
- timestamps

## Dedicated Rep Bureau creator email

Detailed behaviour is defined in `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`.

### `creator_email_addresses`

At least:

- `id`, `workspace_id`
- normalized local part/address
- configured domain/domain version
- status (`active`,`disabled`,`retired`)
- provider routing identifier if required
- created/updated/retired timestamps
- unique normalized address

Initial Phase 1 requires one active primary address per creator workspace. Retired addresses must not be casually reassigned to another creator while inbound mail may still arrive.

### Managed-email provider events / idempotency

Use a private/internal ledger or equivalent durable mechanism for:

- authenticated inbound provider event id;
- provider message id;
- processing status/retry count/error class;
- received timestamp;
- workspace/address routing result;
- source hash/idempotency key.

Do not store provider secrets or raw private message bodies in operational logs.

## AI and evidence

### `analysis_snapshots`

Immutable meaningful analysis versions:

- deal/workspace
- input snapshot hash
- analysis schema/version
- current flag
- structured combined output JSONB
- score/version
- knowledge version set id
- created_at

Never overwrite old meaningful snapshots.

### `analysis_facts`

Normalized extracted facts with:

- fact type
- normalized value
- `confirmed|missing|inferred`
- internal confidence
- owner/source priority
- evidence references to normalized message + quoted span/locator
- provenance/source mode, including forwarded-message distinction
- current/version where appropriate

### `ai_worker_runs`

Operational metadata:

- worker name/version
- job id
- provider/model id
- input hash
- output schema version
- status
- confidence summary
- token/usage counts where provider exposes them
- calculated cost
- latency
- retry/fallback info
- error class
- timestamps

**Never store chain-of-thought.**

### `reply_drafts` / `reply_versions`

- one active composer per Deal/thread
- content
- creator edited flag
- version
- source strategy snapshot
- autosave timestamp
- target provider/thread/recipient state
- sent message id nullable

### `score_versions`

Versioned configuration for Rep Bureau/Replio Score components/weights. Exact launch calibration is product-sign-off configuration, not hard-coded forever.

### `pricing_framework_versions`

Versioned rules/configuration that guide the Pricing Engine.

## Knowledge

### `knowledge_documents`

Logical source/document identity.

### `knowledge_versions`

- version number
- created/effective dates
- source/author
- change summary
- trust tier
- state (`draft`,`current`,`deprecated`,`archived`)
- content/reference

### `analysis_knowledge_versions`

Junction recording exactly which knowledge versions influenced each analysis.

## Commercial benchmark engine

Do not expose creator-specific outcome rows to other creators.

### `benchmark_contributions` (restricted/private schema preferred)

Irreversibly de-identified contribution derived from completed outcomes, containing only dimensions permitted by the benchmark design. It must not contain creator id, workspace id, raw email text, contact identity or any reversible user identifier.

Dimensions may include brand, niche, platform, creator-size bucket, engagement bucket, deliverable signature, usage/exclusivity/territory/campaign/seasonality, offer/outcome values and response timings.

### `benchmark_cells`

Aggregated materialized/computed cells:

- dimension signature
- sample count
- median/percentile offer and settlement values
- average/median uplift
- response/round metrics
- evidence strength
- generated_at
- benchmark algorithm version

Benchmarks below the configured minimum evidence threshold must not influence recommendations.

## Integrations

### `integration_connections`

Provider, state, connected identity, granted scopes, last successful sync, error state. Gmail OAuth connections use this foundation where already implemented; managed creator email may instead be workspace-address/provider-routing configuration rather than user OAuth.

### `gmail_connections`

- user/workspace
- Gmail email address
- Rep Bureau/Replio label id
- last history id
- watch expiration
- watch status
- token encryption key version
- timestamps

OAuth refresh tokens belong in a restricted server-only/private storage path and must be encrypted at application level or with an approved secret facility. Never expose through the Data API.

## Subscription billing

These tables govern the creator's subscription to Rep Bureau and are separate from creator-to-brand Deal invoices.

### `subscriptions`

Stripe customer/subscription ids, plan key, status, trial dates, current period, cancel flags.

### `plan_catalog` / `plan_entitlements`

Server-authoritative plan configuration. Frontend renders from this catalogue; do not scatter tier logic through UI components.

### `usage_counters`

Period-based analysed-deal count and other entitlements. AI cost budgets are internal and separate from user-visible counts.

### `stripe_events`

Store processed event id/status for idempotency and debugging.

## Operations / Founder OS

### `activity_events`

Append significant system/user actions. Private data deletion can purge/transform associated private events as required by the deletion policy.

### `notifications`

User notification category/severity/entity/action.

### `system_health_checks` / `system_incidents`

Operational health snapshots/incidents, including managed-email provider/routing health without exposing private message bodies.

### `founder_actions`

All consequential Founder OS actions with actor, action, target, before/after metadata, confirmation state, idempotency key and result. Never copy raw creator negotiations, managed-email bodies, invoice details or payment instructions into these logs.

### `feature_flags`

Versioned/safe feature rollout configuration.

### `support_access_grants` / `support_access_sessions`

Explicit creator-granted, scoped, expiring access. All access logged. Founder/admin role alone is not permission to read private negotiations, managed-email content, invoices or payment details.

## RLS policy model

- `workspace_members` grants row access for creator-owned domain tables.
- Creator email addresses, managed-email messages/attachments, Deal invoices and payment records are workspace-private.
- Global `brands` exposes only safe shared identity fields.
- Benchmark raw contribution tables are never directly readable by normal users. Creators receive only thresholded aggregate outputs through server-controlled queries/views/functions.
- Founder OS operational tables are founder-role/server only.
- Support access uses explicit grant checks in server-side access paths; do not casually bypass RLS with a service key.
- Service/secret key exists only server-side and is used only for integrations/controlled operations that cannot run under end-user RLS.
- Private object storage for managed-email attachments/invoice artifacts requires equivalent tenant isolation and signed/temporary access.
- Test the access matrix automatically, including cross-workspace address/message/attachment/invoice/payment access denial.
