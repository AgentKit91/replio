# Stripe Billing and Entitlements

## Locked commercial direction

- 30-day free trial.
- recurring monthly subscription after trial.
- tier/entitlement system must be configuration-driven, not hard-coded across UI.

## Working Stripe TEST configuration

The canonical decision transcript did not lock final production prices. Later project discussions moved pricing upward. To keep Codex unblocked **without pretending that a business experiment is a permanent product decision**, seed Stripe **test-mode** and `plan_catalog` with the following current working configuration:

| Key | Working monthly price | Working entitlement | Production status |
|---|---:|---|---|
| `standard` | £14.99 | up to 10 analysed Deals / billing month; full core MVP | provisional |
| `pro` | £29.99 | core MVP + unlimited analysed Deals subject to internal profitability/fair-use routing; priority processing | provisional |
| `ultra` | £49.99 | reserved/highest internal limits; architecture slot for future premium capabilities | **do not expose publicly until final entitlement set is approved** |

Why Ultra is gated: old tier examples mention multi-business/team capabilities that conflict with the creator-first tight MVP/agency-mode exclusion. Do not smuggle those into MVP simply to justify a tier.

All prices/copy/limits live in the catalogue/config and Stripe Price ids so a final founder commercial sign-off can change them without code rewrites.

## Trial payment method

The source does not definitively lock whether a card is required at trial start. Stripe supports trial flows with or without an initial payment method. Build both behaviours behind configuration; use a non-production default and require a single pre-live sign-off. Do not block engineering.

## Stripe architecture

- Stripe Checkout for new subscription flow.
- Stripe Customer Portal for self-serve billing/cancel/payment method where appropriate.
- Server-only Stripe secret.
- Signed webhook verification.
- Idempotent `stripe_events`.
- Stripe is billing system of record; local `subscriptions` is the product-access projection.

Handle at minimum:

- checkout completion;
- subscription created/updated/deleted;
- trial state/end;
- invoice paid;
- payment failed;
- cancellation;
- refund/credit state if Founder OS provides that action.

Do not grant paid entitlements solely because a user returned to a success URL. Grant/update them from verified Stripe state/webhooks.

## Entitlements

Central function/service, e.g. `getEntitlements(workspace)`, returns:

- plan key;
- subscription/trial state;
- analysis limit / usage remaining if applicable;
- priority class;
- feature flags.

User-visible usage limits and internal AI cost budgets are separate concepts. Never display internal token/AI-credit accounting as the product experience.

## Trial UX

- clear trial end date;
- no dark patterns;
- clear what happens next based on configured payment-method rule;
- Stripe handles payment method/customer billing;
- billing failures surface in-app/settings and Founder OS.

## Founder OS billing actions

At minimum:

- view subscription state;
- open relevant Stripe record/link;
- retry/reconcile local projection where safe;
- issue refunds only through an explicit confirmation flow and audit log if implemented;
- never make irreversible/financial changes as a one-click accidental action.
