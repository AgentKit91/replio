# Current Technical Baseline and Verification Rules

Third-party platforms change. Codex must verify current official documentation immediately before implementing each integration and pin package versions/lockfiles.

## Verified at specification date: 27 Aug 2026

- Next.js 16.3.3 is the current Active LTS/security release; use the current Active LTS when implementation starts.
- Next.js App Router is the chosen application architecture.
- Supabase supports Next.js server-side cookie auth via current SSR guidance and RLS-backed authorization.
- Supabase Queues provides Postgres-native durable queues; Supabase Cron can invoke functions/endpoints on recurring/sub-minute schedules subject to platform/project capabilities.
- Gmail `users.watch` can restrict notifications by `labelIds`; watch expires and must be renewed; incremental `history.list` reconciliation is required because notifications can be delayed/dropped.
- Google Pub/Sub push subscriptions support OIDC-authenticated push; the endpoint must validate the JWT/audience/expected service account.
- Gmail `gmail.modify` is currently described by Google as permitting reading/composing/sending and modifying mail; re-check scope needs during implementation.
- Re-verified 28 Aug 2026: `gmail.modify` covers read, compose, send, label list/create and label-filtered watch without granting immediate permanent deletion. M2 requests only this restricted Gmail scope. Current watch requests use `labelFilterBehavior: INCLUDE` (the older `labelFilterAction` field is deprecated).
- Stripe supports subscription trials and webhook-driven subscription state; payment method at trial start is configurable.
- Vercel Git Preview deployments and promote/rollback flows support safe release discipline.

## Official docs to re-check

```text
https://nextjs.org/docs
https://supabase.com/docs/guides/auth/server-side/nextjs
https://supabase.com/docs/guides/database/postgres/row-level-security
https://supabase.com/docs/guides/queues
https://supabase.com/docs/guides/cron
https://developers.google.com/workspace/gmail/api/guides/push
https://developers.google.com/identity/protocols/oauth2/scopes
https://cloud.google.com/pubsub/docs/authenticate-push-subscriptions
https://docs.stripe.com/billing/subscriptions/trials
https://docs.stripe.com/billing/subscriptions/build-subscriptions
https://docs.stripe.com/webhooks
https://vercel.com/docs/deployments/overview
```

If docs contradict this baseline, prefer the current official docs for technical mechanics **without changing the founder-approved product behaviour**.
