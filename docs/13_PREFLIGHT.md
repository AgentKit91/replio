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

## Dedicated Rep Bureau creator email — Resend preflight

Canonical behaviour: `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`.  
Canonical provider choice: `docs/26_EMAIL_PROVIDER_RESEND.md`.

**Provider is locked for Phase 1: Resend.** Codex should not spend build time choosing another provider unless Resend presents a material blocker.

### Founder/account-owner setup

The founder should:

1. create the Rep Bureau Resend account;
2. connect the official Resend plugin/connector to Codex when available and grant only the access needed for setup/development;
3. keep `hello@repbureau.co.uk` and ordinary company email on Zoho;
4. choose/approve a dedicated creator-email subdomain later (for example `inbox.repbureau.co.uk` or `collab.repbureau.co.uk`);
5. retain DNS access for `repbureau.co.uk`;
6. add only the Resend DNS records required for the chosen **subdomain**, not replacement root-domain MX records;
7. create/store production Resend credentials/webhook secrets through the approved secret stores, never GitHub.

Resend's current agent/Codex tooling can be used to inspect domains/provider configuration and perform approved operations. Human setup of the account and DNS ownership remains founder-controlled.

### Can be implemented before final production subdomain sign-off

- provider abstraction;
- database/address-allocation model;
- `MANAGED_EMAIL_PROVIDER=resend` configuration;
- local/test receiving setup using Resend-provided/test capability where appropriate;
- signed Resend `email.received` webhook verification;
- normalized inbound/outbound message pipeline;
- receiving-API retrieval of full content/headers/attachments as required;
- forwarding/parser fixtures;
- private attachment-storage path;
- spam/abuse/cost controls;
- no-Gmail E2E with safe test configuration.

Do **not** repeatedly block coding on the final vanity subdomain/local-part format if a configurable safe test value works.

### Required before external beta using dedicated addresses

Founder/account-owner work:

- approve the Rep Bureau creator-email subdomain;
- add/verify Resend receiving MX for that subdomain without changing Zoho root-domain MX;
- complete Resend sending-domain verification and required current SPF/DKIM configuration;
- review/configure DMARC appropriately for the Rep Bureau domain setup;
- connect production inbound webhook destination and signing secret;
- create/restrict production API credentials as appropriately as Resend currently supports;
- approve any Resend billing/limits needed for beta;
- review Resend DPA/retention/security terms as part of legal/privacy launch work.

Codex work:

- use the current official Resend SDK/API/plugin/CLI docs rather than memory;
- verify raw-body Resend webhook signatures;
- verify exact recipient-to-workspace routing;
- retrieve received content/attachments safely through current Resend APIs;
- verify outbound sender identity/threading;
- verify replay/idempotency and send reconciliation;
- verify attachment/privacy/deletion path;
- verify abuse/spam/cost controls;
- record managed-email health in Founder OS without private content exposure;
- run direct inbound → reply → reply-back and forwarded-email E2E tests.

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
- final Resend managed-email subdomain choice;
- Resend production credentials/limits;
- Stripe live prices/keys;
- final public plan copy;
- Google OAuth production verification/branding;
- production AI budget/model routing;
- final Knowledge Library content;
- Privacy Policy / Terms / cookie configuration, including Resend/dedicated-email disclosure;
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

# Managed Rep Bureau creator email — Resend
MANAGED_EMAIL_PROVIDER=resend
MANAGED_EMAIL_DOMAIN=
RESEND_API_KEY=
RESEND_WEBHOOK_SECRET=
# Add other Resend server-only vars only if the current SDK/provider setup requires them.

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
