# START HERE — DealCheck V1

You are implementing **DealCheck V1 by Rep Bureau** inside the existing Rep Bureau repository.

This is a deadline-driven founder assignment effective **8 September 2026**. The target is a complete, visually polished, tested product by **Thursday evening, 10 September 2026**.

## First rule

**Do not restart, fork, rename, or recreate existing Rep Bureau foundations.** Reuse the current Next.js app, Supabase project/auth, Vercel AI Gateway, Stripe integration, Vercel deployment, design tokens, tests and CI.

DealCheck is an isolated acquisition/product surface at `/dealcheck`. It must not expand or destabilise the main Rep Bureau Phase 1 scope.

## Read only what is needed, in this order

1. `AGENTS.md`
2. `docs/00_SOURCE_AUTHORITY.md`
3. `docs/27_DEALCHECK_V1.md`
4. `docs/28_DEALCHECK_INTELLIGENCE_V1.md`
5. `docs/DEALCHECK_BUILD_LEDGER.md`
6. Inspect the current implementations of Supabase auth, `/auth/callback`, the Vercel AI Gateway, Stripe Checkout/billing, the Stripe webhook, global design tokens and the current test setup.
7. Consult existing architecture/security/testing docs only where the implementation touches those boundaries.

Do **not** spend context or credits rereading every historical product document unless a real conflict requires it.

## Execution instruction

Implement the complete V1 continuously in dependency order. Do not stop after a milestone to ask whether to continue. Do not propose optional features. Do not redesign the product. Make the simplest secure maintainable choice consistent with the locked spec and continue.

Keep `docs/DEALCHECK_BUILD_LEDGER.md` current as work lands. If a session or usage limit stops execution, the ledger is the resume point: continue from the first incomplete item without revisiting completed work.

Run relevant tests throughout and run the full repository `pnpm check` before declaring completion. Verify database/RLS changes and Stripe webhook idempotency. Use a Vercel Preview deployment for end-to-end and responsive verification when available.

## Stop only for

- a real account-owner authorization/verification step that cannot be performed with existing access;
- a missing production secret/credential that actually blocks the next implementation step;
- a legal/security blocker that cannot safely be deferred behind configuration;
- a genuine contradiction in the locked DealCheck specification;
- environment/usage limits;
- or the complete Definition of Done in `docs/27_DEALCHECK_V1.md` has been satisfied.

Ordinary engineering ambiguity is not a reason to stop. Choose the smallest safe solution, document it in the ledger, and continue.

## Branch and delivery

Work on `dealcheck-v1`. Make coherent reviewable commits. Do not merge to `main` until the complete Definition of Done passes. At completion, push the branch and prepare a concise final handoff/PR summary with any founder-only production activation steps still required.