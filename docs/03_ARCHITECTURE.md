# Technical Architecture

## Architecture objective

Build a lean, production-grade modular monolith that is inexpensive to operate, easy for Codex to reason about, and capable of growing without premature microservices.

## Current implementation baseline (27 Aug 2026)

Technical versions must be re-verified against official docs at implementation time and pinned in the lockfile.

- **Next.js:** current Active LTS; use App Router, TypeScript, Server Components by default.
- **Hosting:** Vercel with Git integration, Preview deployments and reversible production releases.
- **Database/Auth/Realtime:** Supabase Postgres + Supabase Auth + Realtime.
- **Background jobs:** Supabase Queues (durable) + Supabase Cron invoking authenticated internal worker endpoints.
- **Frontend styling:** Tailwind CSS with accessible primitives; bespoke Replio design tokens.
- **Billing:** Stripe Checkout/Subscriptions + Customer Portal + signed webhooks.
- **Gmail:** Google OAuth + Gmail API + Google Cloud Pub/Sub push notifications filtered to the Replio label.
- **AI:** internal provider-agnostic gateway; Vercel AI SDK/Gateway may be used behind the abstraction if current docs/costs support it.
- **Analytics:** PostHog behind an analytics adapter.
- **Error/ops:** structured server logging + operational event tables + Founder OS health; external error tracker may be added if it materially improves launch reliability.

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
      gmail/
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

Feature folders may contain server services, schemas, domain logic and UI specific to that domain. Avoid a giant generic `utils` folder.

## Rendering/data boundaries

- Server Components for secure authenticated data reads where possible.
- Client Components only where interaction/browser APIs require them.
- Server Actions for trusted first-party mutations when appropriate.
- Route Handlers for webhooks, OAuth callbacks, public integration endpoints and worker endpoints.
- Node runtime by default; use Edge only after verifying dependencies and a concrete benefit.

## Background work

Use durable queues for tasks that may outlive a request:

- Gmail incremental sync
- AI analysis/orchestration
- reply rewrites
- benchmark aggregation
- notifications
- Gmail watch renewal/recovery
- cleanup/permanent deletion
- low-priority metrics aggregation

Suggested queues:

```text
gmail-sync
ai-analysis
ai-rewrite
benchmark-update
notifications
maintenance
```

A webhook should enqueue and acknowledge quickly. Workers process messages idempotently. Retryable failures remain queued; poison messages are archived/dead-lettered with Founder OS visibility.

**Implementation choice:** use Supabase Cron to invoke the worker endpoint on a short interval appropriate to the plan/runtime; the Gmail push handler may also use a best-effort post-response kick, but durability comes from the queue, not that kick.

## Realtime

Use targeted Realtime subscriptions for:

- new email message persisted;
- analysis snapshot becomes current;
- reply draft ready/updated;
- deal status changed;
- notification created.

No constant polling of the whole app.

## Idempotency

Every integration write or retryable action gets a stable key:

- Gmail message: provider + message id unique.
- Gmail thread/deal link: workspace + provider thread id unique.
- Pub/Sub/history event: connection + history window/key unique.
- AI analysis job: deal + input snapshot hash + analysis version unique.
- email send: draft/send intent id unique.
- Stripe event: `event.id` unique.
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
- notification thresholds.

Do not turn arbitrary code into a home-made rules engine. Configuration is for genuine operational/product parameters.
