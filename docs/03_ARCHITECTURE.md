# Technical Architecture

## Architecture objective

Build a lean, production-grade modular monolith that is inexpensive to operate, easy for Codex to reason about, and capable of growing without premature microservices.

The Phase 1 communication architecture is **provider-neutral at the Deal/message layer**. Gmail and the dedicated Rep Bureau creator address are two ingestion/send providers feeding the same normalized Deal, message, AI/admin, composer, invoice and payment systems.

## Current implementation baseline (27 Aug 2026 + 7 Sep 2026 amendments)

Technical versions and provider mechanics must be re-verified against current official docs at implementation time and pinned/configured appropriately.

- **Next.js:** current Active LTS; use App Router, TypeScript, Server Components by default.
- **Hosting:** Vercel with Git integration, Preview deployments and reversible production releases.
- **Database/Auth/Realtime:** Supabase Postgres + Supabase Auth + Realtime.
- **Background jobs:** Supabase Queues (durable) + Supabase Cron invoking authenticated internal worker endpoints.
- **Frontend styling:** Tailwind CSS with accessible primitives; bespoke Rep Bureau design tokens.
- **Billing:** Stripe Checkout/Subscriptions + Customer Portal + signed webhooks for Rep Bureau subscription billing.
- **Gmail provider:** Google OAuth + Gmail API + Google Cloud Pub/Sub push notifications filtered to the explicit Rep Bureau/Replio label.
- **Managed creator email provider:** current verified inbound-webhook + outbound-send provider on a Rep Bureau-controlled domain, behind an internal provider abstraction; requirements in `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`.
- **AI:** internal provider-agnostic gateway; Vercel AI SDK/Gateway may be used behind the abstraction if current docs/costs support it.
- **Analytics:** PostHog behind an analytics adapter.
- **Error/ops:** structured server logging + operational event tables + Founder OS health; external error tracker may be added if materially useful.

## Repository structure

```text
/
  AGENTS.md
  START_HERE_CODEX.md
  package.json
  pnpm-lock.yaml
  next.config.*
  src/
    app/
      (auth)/
      (creator)/
      (founder)/
      api/
    components/
      ui/
      replio/
    features/
      auth/
      email/
        gmail/
        managed-email/
      deals/
      brands/
      creator-profile/
      ai/
      billing/
      founder-os/
      notifications/
      search/
    lib/
      supabase/
      google/
      email/
      stripe/
      analytics/
      observability/
      security/
      money/
      time/
  supabase/
    migrations/
    seed.sql
    tests/
  tests/
    unit/
    integration/
    e2e/
    ai-evals/
  docs/
```

Existing `features/gmail` code does not need a cosmetic move if refactoring would add risk. The important requirement is a clean internal abstraction between provider-specific receive/send mechanics and the normalized Deal/message domain.

## Email provider boundary

Application Deal logic should not care whether a message came from Gmail or the creator's dedicated Rep Bureau address except where provider/provenance behaviour differs.

A suitable internal interface may expose operations such as:

- receive/normalize inbound event;
- fetch/resolve provider message when required;
- create/send reply with stable send intent;
- attach generated invoice artifact;
- reconcile send result;
- expose provider thread/message identifiers;
- report connection/address health.

Do not build one parallel Deal system for managed email.

### Gmail

- existing explicit-label ingestion remains intact;
- no full inbox scan;
- Gmail-specific watch/history mechanics remain provider implementation details.

### Dedicated Rep Bureau email

- inbound provider webhook maps recipient address to workspace;
- direct and forwarded inbound are normalized into the same message model;
- outbound negotiation/invoice/chase sends originate from the creator's dedicated address after explicit creator confirmation;
- inbound attachments may require private object storage;
- public-address spam/abuse and cost controls are part of the provider boundary;
- provider/domain configuration is replaceable and not hard-coded into Deal logic.

## Rendering/data boundaries

- Server Components for secure authenticated data reads where possible.
- Client Components only where interaction/browser APIs require them.
- Server Actions for trusted first-party mutations when appropriate.
- Route Handlers for webhooks, OAuth callbacks, public integration endpoints and worker endpoints.
- Node runtime by default; use Edge only after verifying dependencies and a concrete benefit.

## Background work

Use durable queues for tasks that may outlive a request:

- Gmail incremental sync;
- managed-email inbound normalization/processing where webhook work cannot finish safely inline;
- AI analysis/orchestration;
- Deal admin extraction/deltas;
- reply rewrites;
- invoice generation if asynchronous;
- payment reminder preparation;
- benchmark aggregation;
- notifications;
- Gmail watch renewal/recovery;
- managed-email/provider health maintenance if required;
- cleanup/permanent deletion;
- low-priority metrics aggregation.

Suggested queue concepts may include:

```text
gmail-sync
managed-email-inbound
deal-ops
ai-analysis
ai-rewrite
invoice-generation
payment-reminders
benchmark-update
notifications
maintenance
```

Prefer reusing existing queue/worker infrastructure over multiplying queue types unnecessarily.

A webhook should authenticate, persist/enqueue durably and acknowledge quickly. Workers process messages idempotently. Retryable failures remain queued; poison messages are archived/dead-lettered with Founder OS visibility.

For public managed-email inbound, perform cheap deterministic/provider-level filtering before expensive AI where possible so spam cannot generate unbounded cost.

## Realtime

Use targeted Realtime subscriptions for:

- normalized new email message persisted regardless of provider;
- analysis snapshot becomes current;
- reply draft ready/updated;
- Deal/admin status changed;
- invoice/payment state changed;
- notification created.

No constant polling of the whole app.

## Idempotency

Every integration write or retryable action gets a stable key:

- Gmail message: provider/connection + provider message id unique;
- managed-email inbound: provider/address + provider message/event id unique;
- Deal thread link: workspace + provider + provider thread/conversation id unique;
- Gmail Pub/Sub/history event: connection + history window/key unique;
- managed-email webhook event: provider event id/request identity unique where available;
- AI analysis job: Deal + input snapshot hash + analysis version unique;
- email send: provider + draft/send intent id unique;
- invoice generation: invoice approved version/idempotency key unique;
- payment reminder send: reminder/send intent unique;
- Stripe event: `event.id` unique;
- plan change/refund founder actions: founder action id unique.

## Configuration first

Material behaviour that may change without a deploy belongs in versioned/configurable records where sensible:

- score versions/weights;
- pricing framework versions;
- AI worker prompt/instruction versions;
- model routing;
- AI budgets;
- benchmark evidence threshold;
- feature flags;
- plan/entitlement catalogue;
- notification thresholds;
- managed-email inbound domain;
- managed-email provider/routing configuration;
- attachment size/type limits;
- spam/abuse/cost thresholds.

Do not turn arbitrary code into a home-made rules engine. Configuration is for genuine operational/product parameters.
