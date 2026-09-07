# Pre-flight: Accounts, Connections and Founder Actions

Codex should complete everything it can before interrupting the founder. Separate **build blockers** from **production activation blockers**.

## Build-start required

### GitHub

- dedicated Replio/Rep Bureau repository;
- Codex access;
- branch/PR permissions;
- main protected from accidental force push where feasible.

### Supabase

- dedicated Rep Bureau project (do not reuse City Seekers DB);
- project URL + publishable key;
- server-side secret/service credential;
- local/preview DB workflow chosen;
- Queues/Cron modules available/enabled when milestone reaches jobs.

### Vercel

- Rep Bureau project linked to GitHub repo;
- Preview + Production environments;
- Supabase env vars configured;
- production public domain may wait while local/test implementation proceeds.

### AI

- at least one provider/gateway credential for integration testing;
- model routing remains config-driven.

Build can begin with AI mocks before a paid provider is connected.

## Required before Gmail end-to-end testing

### Google Cloud

Founder/account-owner work:

- create/select Rep Bureau Google Cloud project;
- configure OAuth consent/branding;
- enable Gmail API;
- create OAuth web client;
- add localhost/Preview/Production redirect URIs as needed;
- enable Pub/Sub;
- create Gmail events topic;
- grant Gmail publish permission required by current official docs;
- create authenticated push subscription/service account for Rep Bureau webhook;
- configure allowed/test users during development;
- begin required Google verification/restricted-scope process early because this can outlast coding.

Codex work:

- callback/PKCE/state;
- encrypted token storage;
- label creation;
- watch setup/renewal;
- authenticated push verification;
- incremental sync.

## Dedicated Rep Bureau creator email — build/test preflight

Canonical behaviour: `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`.

Codex should verify current official documentation and choose the simplest secure provider/provider-combination that supports:

- authenticated inbound email webhooks/routing on a Rep Bureau-controlled domain/subdomain;
- outbound email sending from creator-dedicated Rep Bureau addresses;
- reliable message/provider identifiers for idempotency/reconciliation;
- production sender authentication/deliverability support;
- attachment handling compatible with Phase 1 limits/security.

### Can be implemented before final production domain sign-off

- provider abstraction;
- database/address-allocation model;
- local/test domain configuration seam;
- webhook verification mechanics using provider test/sandbox mode where available;
- normalized inbound/outbound message pipeline;
- forwarding/parser fixtures;
- private attachment-storage path;
- spam/abuse/cost controls;
- no-Gmail E2E with safe test configuration.

Do **not** repeatedly block coding on the final vanity domain/local-part format if a configurable safe test value works.

### Required before external beta using dedicated addresses

Founder/account-owner work:

- approve a Rep Bureau-owned sending/inbound domain or subdomain;
- control DNS for that domain;
- create/verify the chosen email provider account as required;
- configure provider-required DNS records and current appropriate SPF/DKIM/DMARC policy;
- configure inbound routing/webhook destination and secrets;
- configure outbound sender/domain verification;
- approve any provider billing/limits needed for beta;
- review provider DPA/retention/security terms as part of legal/privacy launch work.

Codex work:

- verify provider webhook signatures/authentication;
- verify exact recipient-to-workspace routing;
- verify outbound sender identity/threading;
- verify replay/idempotency;
- verify attachment/privacy/deletion path;
- verify abuse/spam/cost controls;
- record managed-email health in Founder OS without private content exposure.

## Required before subscription billing E2E

### Stripe

- Stripe test mode available;
- secret/webhook credentials connected;
- current working product/price catalogue created in TEST;
- production pricing/trial-card rule can be signed off later;
- account/business verification completed before live charges.

## Analytics

- PostHog project/key/host if using PostHog at launch;
- otherwise analytics adapter uses no-op/dev sink until connected.

## Production-only / can wait while Codex builds

- final public Rep Bureau domain/DNS;
- final managed-email domain/subdomain choice;
- managed-email provider production credentials/limits;
- Stripe live prices/keys;
- final public plan copy;
- Google OAuth production verification/branding;
- production AI budget/model routing;
- final Knowledge Library content;
- Privacy Policy / Terms / cookie configuration, including dedicated-email disclosure;
- support/contact address;
- live PostHog/Sentry or other ops accounts if chosen;
- score calibration approval;
- final benchmark sample threshold;
- trial payment-method sign-off.

## Environment variable inventory

Names may map to current provider conventions, but keep semantic separation. Never commit values.

```text
# App
NEXT_PUBLIC_APP_URL=
APP_ENV=

# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=
SUPABASE_SECRET_KEY=

# Google identity/Gmail
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_OAUTH_REDIRECT_URI=
GOOGLE_PUBSUB_TOPIC=
GOOGLE_PUBSUB_AUDIENCE=
GOOGLE_PUBSUB_PUSH_SERVICE_ACCOUNT_EMAIL=
GMAIL_TOKEN_ENCRYPTION_KEY=
GMAIL_TOKEN_ENCRYPTION_KEY_VERSION=

# Managed Rep Bureau creator email
MANAGED_EMAIL_PROVIDER=
MANAGED_EMAIL_DOMAIN=
MANAGED_EMAIL_WEBHOOK_SECRET=
MANAGED_EMAIL_API_KEY=
MANAGED_EMAIL_FROM_DOMAIN=
# Add provider-specific server-only vars only when the chosen provider requires them.

# Stripe subscription billing
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_STANDARD_PRICE_ID=
STRIPE_PRO_PRICE_ID=
STRIPE_ULTRA_PRICE_ID=
STRIPE_LIVE_BILLING_ENABLED=false

# Fail closed until founder-approved final wording/identity values are configured.
LEGAL_PAGES_PUBLISHED=false
LEGAL_ENTITY_NAME=
LEGAL_CONTACT_EMAIL=
LEGAL_POSTAL_ADDRESS=
LEGAL_GOVERNING_LAW=
LEGAL_EFFECTIVE_DATE=

# AI gateway/provider
AI_GATEWAY_API_KEY=
# provider-specific AI keys only if chosen behind gateway

# Analytics
NEXT_PUBLIC_POSTHOG_KEY=
NEXT_PUBLIC_POSTHOG_HOST=

# Internal jobs
INTERNAL_JOB_SECRET=

# Founder bootstrap (server only; replace with role record after bootstrap)
FOUNDER_BOOTSTRAP_EMAIL=
```
