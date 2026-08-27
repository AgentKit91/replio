# Pre-flight: Accounts, Connections and Founder Actions

Codex should complete everything it can before interrupting the founder. Separate **build blockers** from **production activation blockers**.

## Build-start required

### GitHub

- dedicated Replio repository;
- Codex access;
- branch/PR permissions;
- main protected from accidental force push where feasible.

### Supabase

- dedicated Replio project (do not reuse City Seekers DB);
- project URL + publishable key;
- server-side secret/service credential;
- local/preview DB workflow chosen;
- Queues/Cron modules available/enabled when milestone reaches jobs.

### Vercel

- Replio project linked to GitHub repo;
- Preview + Production environments;
- Supabase env vars configured;
- domain can wait.

### AI

- at least one provider/gateway credential for integration testing;
- model routing remains config-driven.

Build can begin with AI mocks before a paid provider is connected.

## Required before Gmail end-to-end testing

### Google Cloud

Founder/account-owner work:

- create/select Replio Google Cloud project;
- configure OAuth consent/branding;
- enable Gmail API;
- create OAuth web client;
- add localhost/Preview/Production redirect URIs as needed;
- enable Pub/Sub;
- create Gmail events topic;
- grant Gmail publish permission required by official docs;
- create authenticated push subscription/service account for Replio webhook;
- configure allowed/test users during development;
- begin required Google verification/restricted-scope process early because this can outlast coding.

Codex work:

- callback/PKCE/state;
- encrypted token storage;
- label creation;
- watch setup/renewal;
- authenticated push verification;
- incremental sync.

## Required before billing E2E

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

- live domain/DNS;
- Stripe live prices/keys;
- final public plan copy;
- Google OAuth production verification/branding;
- production AI budget/model routing;
- final Knowledge Library content;
- Privacy Policy / Terms / cookie configuration;
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

# Stripe
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_STANDARD_PRICE_ID=
STRIPE_PRO_PRICE_ID=
STRIPE_ULTRA_PRICE_ID=

# AI gateway/provider
AI_GATEWAY_API_KEY=
# provider-specific keys only if chosen behind gateway

# Analytics
NEXT_PUBLIC_POSTHOG_KEY=
NEXT_PUBLIC_POSTHOG_HOST=

# Internal jobs
INTERNAL_JOB_SECRET=

# Founder bootstrap (server only, replace with role record after bootstrap)
FOUNDER_BOOTSTRAP_EMAIL=
```
