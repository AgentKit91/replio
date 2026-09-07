# Stripe Subscription Billing and Entitlements

## Important terminology boundary

This document covers **Rep Bureau charging the creator for the SaaS subscription through Stripe**.

It does **not** define creator-to-brand Deal invoices. Creator invoice generation, invoice PDFs, payment due tracking and payment chasing are mandatory Phase 1 operations defined in `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md` and must use separate domain records from Rep Bureau's Stripe subscription billing.

Do not confuse:

- `subscriptions` / Stripe invoices = Rep Bureau SaaS billing;
- `deal_invoices` / creator payment state = money a brand owes the creator.

## Locked commercial direction

- 30-day free trial.
- recurring monthly subscription after trial.
- tier/entitlement system is configuration-driven, not hard-coded across UI.

## Working Stripe TEST configuration

Final production prices are not permanently locked. Current test configuration:

| Key | Working monthly price | Working entitlement | Production status |
|---|---:|---|---|
| `standard` | £14.99 | up to 10 analysed Deals / billing month; full core Phase 1 | provisional |
| `pro` | £29.99 | full core Phase 1 + unlimited analysed Deals subject to internal profitability/fair-use routing; priority processing | provisional |
| `ultra` | £49.99 | reserved/highest internal limits; architecture slot for future premium capabilities | **do not expose publicly until final entitlement set is approved** |

Do not smuggle agency/team functionality into Phase 1 merely to justify a tier.

All prices/copy/limits live in catalogue/config and Stripe Price ids so founder sign-off can change them without code rewrites.

## Trial payment method

Card-at-trial-start remains configurable until pre-live sign-off. Build the supported behaviour behind configuration and do not block engineering.

## Stripe architecture

- Stripe Checkout for new subscription flow.
- Stripe Customer Portal for self-serve billing/cancel/payment method where appropriate.
- Server-only Stripe secret.
- Signed webhook verification.
- Idempotent `stripe_events`.
- Stripe is SaaS billing system of record; local `subscriptions` is product-access projection.

Handle at minimum checkout completion, subscription created/updated/deleted, trial state/end, Stripe invoice paid/payment failed, cancellation and founder-approved refunds/credits.

Do not grant paid entitlements from a success URL alone; use verified Stripe state/webhooks.

## Entitlements

Central service returns plan key, subscription/trial state, usage remaining where applicable, priority class and feature flags.

User-visible usage limits and internal AI cost budgets are separate. Never expose internal token/AI-credit accounting as the primary product experience.

## Trial UX

- clear trial end date;
- no dark patterns;
- clear configured next step;
- Stripe handles creator payment method/customer SaaS billing;
- failures surface in Settings/Founder OS.

## Founder OS subscription actions

At minimum: view SaaS subscription state, open Stripe record, retry/reconcile safe projection, use confirmation/audit for refunds or other consequential financial actions.

Founder OS must not expose creators' private brand invoices/payment details merely because both areas contain the word `billing`.
