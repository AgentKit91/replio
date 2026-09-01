# Live billing activation runbook

Status: code-ready behind a fail-closed live-mode flag; Stripe live configuration is intentionally empty.

## Audit (1 September 2026)

- Stripe account: Replio (`acct_1UAeABLU3Hc8FOCf`).
- Test mode has active monthly Standard (£14.99) and Pro (£29.99) prices, one enabled production-URL test webhook, and a customer portal that supports payment updates, invoices, customer details and cancellation at period end.
- Live mode has no prices, webhook endpoints or portal configuration.
- Test prices and the 30-day trial are provisional and are not authority for launch pricing.
- Stripe Tax remains disabled; test price tax behaviour is unspecified.

## Technical safety gate

`STRIPE_LIVE_BILLING_ENABLED=false` is the default. The server accepts test or live restricted/secret keys but refuses to start billing when the key mode and flag disagree. Use a least-privilege live restricted key where Stripe permissions allow, store it as a Vercel sensitive environment variable, and use separate webhook secrets per environment.

## Founder decisions required before creating live objects

- Launch countries/territories and whether customers are consumers, businesses, or both.
- Final plan names, included limits, monthly prices/currencies and whether annual billing exists.
- Trial length, whether a payment method is required to start it, and what happens at trial end.
- Cancellation, cooling-off, refund and failed-payment policy for the launch audience.
- Legal business name, customer support contact and statement descriptor.
- Tax registrations and product tax classification. Enabling Stripe Tax alone does not register or collect tax where no active registration exists.

## Activation order after approval

1. Complete Stripe business/identity, bank, support and statement-descriptor requirements; require passkey or authenticator-app 2FA.
2. Obtain tax advice/registrations for the approved territories. Only then decide whether to enable Stripe Tax and set explicit tax behaviour.
3. Create one live Product per approved plan and its approved recurring Price(s). Record IDs in `plan_catalog`; never copy test IDs.
4. Configure the live customer portal with approved cancellation and legal URLs.
5. Create the live webhook endpoint at `/api/webhooks/stripe` for the existing allowlisted events and store its distinct signing secret.
6. Store a least-privilege live restricted key and webhook secret as Vercel sensitive Production variables. Set `STRIPE_LIVE_BILLING_ENABLED=true` in Production only.
7. Redeploy, perform one founder-authorised low-value live subscription/refund/cancellation test, reconcile Stripe with Replio, and review Workbench logs.
8. Roll back by setting the flag false and redeploying; this prevents new checkout/portal operations while preserving webhook history and existing Stripe subscriptions.

## Non-negotiable checks

- Never hard-code keys, log secrets, or share live keys in chat/source control.
- Verify webhook signatures before processing; Replio already does this.
- Checkout remains the hosted subscription surface and payment methods remain dynamic.
- Customer access changes only after signed webhook projection, never from the Checkout return URL.
- Do not enable tax, live charges or new pricing without the founder decisions above.


