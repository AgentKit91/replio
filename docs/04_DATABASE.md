# Database Specification

## Global rules

- Postgres is the system of record.
- UUID primary keys unless a strong reason exists otherwise.
- All timestamps are `timestamptz` stored in UTC; display in user timezone.
- Money is stored as integer minor units plus ISO currency code. Never use floating point for money.
- Every workspace-owned row carries `workspace_id` directly or through an unambiguous parent.
- Every public/exposed table has RLS enabled and tested.
- User-editable values record source/ownership where AI/imports might also update them.
- Soft-deletable private records use `deleted_at` + `purge_after`; 30-day recycle bin unless explicitly purged earlier.
- Permanent purge removes private creator data; only irreversibly anonymised aggregate intelligence may remain.

## Identity and tenancy

### `user_profiles`

- `user_id uuid pk` -> auth.users
- `display_name text`
- `timezone text`
- `base_currency char(3)`
- `country_code char(2)`
- `created_at`, `updated_at`

### `workspaces`

Hidden tenancy boundary. MVP creates one workspace per creator account.

- `id uuid pk`
- `name text`
- `kind text` default `creator`
- `created_by uuid`
- timestamps

### `workspace_members`

- `workspace_id`
- `user_id`
- `role` (`owner` in creator MVP; schema extensible)
- `created_at`
- unique `(workspace_id,user_id)`

Do not expose team-management UI in MVP.

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

## Brands and contacts

### `brands` (global)

Contains non-private brand identity only:

- canonical name
- normalized domain(s)
- industry/category
- country/region where known
- safe public metadata

No creator-specific deal content or notes.

### `workspace_brands`

Private creator relationship overlay:

- `workspace_id`, `brand_id` unique
- private relationship status
- creator-specific notes summary if needed
- timestamps

### `brand_contacts`

Private/workspace-scoped contact records connected to a global brand.

- name, email, title/team where known
- source
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
- `created_source` (`gmail_label`,`manual_future`,...)
- `deleted_at`, `purge_after`
- timestamps

### `deal_threads`

Links one or more provider threads to a deal.

- provider (`gmail`)
- provider_thread_id
- role (`primary_negotiation`,`outreach`,`contract`,`deliverables`,`payment`,`usage_extension`,`other`)
- is_primary
- unique workspace/provider/thread

### `email_messages`

- `workspace_id`, `deal_thread_id`
- provider message id unique per connection
- thread id
- sender/recipient headers as structured JSON
- subject
- sent_at
- direction (`inbound`,`outbound`)
- `body_text` canonical
- `body_html_sanitized` optional
- `provider_label_ids`
- `source_hash`
- `raw_provider_ref` minimal reference, not an unnecessary mailbox dump
- timestamps

Do not load remote images/tracking pixels by default in rendered email HTML. Sanitize HTML.

### `email_attachment_refs`

Metadata/reference only for MVP:

- provider attachment/message id
- filename, mime type, size
- provider reference
- no duplicate blob unless a later explicit feature imports it

### `deal_deliverables`

Structured deliverables:

- platform
- deliverable_type
- quantity
- due timing if known
- status if used
- source fact id

### `deal_terms`

Structured commercial terms:

- term_type (usage_duration, territory, exclusivity, payment_terms, approval_rounds, licensing, whitelisting/paid_media, cancellation, travel, etc.)
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
- evidence references to message + quoted span/locator (short excerpt only as needed)

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

- one active composer per deal/thread
- content
- creator edited flag
- version
- source strategy snapshot
- autosave timestamp
- sent message id nullable

### `score_versions`

Versioned configuration for Replio Score components/weights. Exact launch calibration is product-sign-off configuration, not hard-coded forever.

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

## Gmail/integrations

### `integration_connections`

Provider, state, connected identity, granted scopes, last successful sync, error state.

### `gmail_connections`

- user/workspace
- Gmail email address
- Replio label id
- last history id
- watch expiration
- watch status
- token encryption key version
- timestamps

OAuth refresh tokens belong in a restricted server-only/private storage path and must be encrypted at application level or with an approved secret facility. Never expose through the Data API.

## Billing

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

Operational health snapshots/incidents.

### `founder_actions`

All consequential Founder OS actions with actor, action, target, before/after metadata, confirmation state, idempotency key and result. Never copy raw creator negotiations into these logs.

### `feature_flags`

Versioned/safe feature rollout configuration.

### `support_access_grants` / `support_access_sessions`

Explicit creator-granted, scoped, expiring access. All access logged. Founder/admin role alone is not permission to read private negotiations.

## RLS policy model

- `workspace_members` grants row access for creator-owned domain tables.
- Global `brands` exposes only safe shared identity fields.
- Benchmark raw contribution tables are never directly readable by normal users. Creators receive only thresholded aggregate outputs through server-controlled queries/views/functions.
- Founder OS operational tables are founder-role/server only.
- Support access uses explicit grant checks in server-side access paths; do not casually bypass RLS with a service key.
- Service/secret key exists only server-side and is used only for integrations/controlled operations that cannot run under end-user RLS.
- Test the access matrix automatically.
