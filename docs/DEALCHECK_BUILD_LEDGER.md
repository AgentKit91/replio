# DealCheck V1 Build Ledger

**Branch:** `dealcheck-v1`  
**Resume rule:** start at the first incomplete checkbox. Do not redo completed milestones unless a regression proves they are broken.

## D0 — Inspect and preserve foundations

- [ ] Confirm branch starts from current `main` and working tree is clean.
- [ ] Inspect existing auth callback/login, Supabase clients/RLS conventions, AI gateway, Stripe Checkout/billing actions, Stripe webhook, design tokens and tests.
- [ ] Verify current official docs only for APIs actually touched.
- [ ] Record any implementation choice that differs from `docs/27...` before continuing; do not expand scope.

## D1 — DealCheck data + auth return path

- [ ] Add one reviewable migration for the three `dealcheck_*` tables, constraints, indexes, RLS/grants and narrowly-scoped atomic credit functions.
- [ ] Add RLS/idempotency tests.
- [ ] Implement DealCheck account lazy initialization with exactly one lifetime +1 free-credit grant.
- [ ] Add safe sanitized OAuth `next` support without changing normal Rep Bureau onboarding behaviour.
- [ ] Add DealCheck-specific Google sign-in/resume flow using `sessionStorage` for pending raw form data.
- [ ] Run targeted tests, lint and typecheck.

**D1 exit gate:** an unauthenticated valid pending form can sign in and return to `/dealcheck/resume`; no AI yet; free balance initializes exactly once.

## D2 — Public product surface

- [ ] Build `/dealcheck` responsive editorial landing page using existing Rep Bureau tokens/typography.
- [ ] Put the real DealCheck form above the fold.
- [ ] Add short below-fold sections: what it checks, illustrative example, how it works, pricing, FAQ, footer.
- [ ] Add authenticated header state, balance and `My checks` link.
- [ ] Add validation/loading/error states and basic metadata/SEO.
- [ ] Verify at ~390px and ~1440px.

**D2 exit gate:** the page looks intentional and production-quality before AI/payment complexity is added.

## D3 — Extraction + deterministic valuation + result

- [ ] Add `src/features/dealcheck/` domain with Zod input/output contracts.
- [ ] Implement exact versioned deterministic engine from `docs/28...`.
- [ ] Implement all required deterministic fixtures.
- [ ] Add AI extraction using existing Vercel AI Gateway; pasted text is explicitly untrusted.
- [ ] Add deterministic valuation after extraction; LLM never chooses price.
- [ ] Add concise AI writing pass with deterministic fallback copy.
- [ ] Implement atomic check start/consume, completion and idempotent failed-check refund.
- [ ] Build private result route/UI with giant score, offer, range, counter, fee/rights, watch-outs, action and copyable reply.
- [ ] Record AI usage/cost metadata.
- [ ] Run prompt-injection and unsupported/no-offer failure tests.

**D3 exit gate:** authenticated user with one credit can run a real supported check end-to-end; a failed/unsupported check does not cost a credit.

## D4 — Paid credit loop

- [ ] Add server-authoritative pack catalog: 3 for £4.99 and 10 for £9.99.
- [ ] Add one-time Stripe Checkout creation using trusted server price/quantity definitions.
- [ ] Extend existing signed Stripe webhook for `dealcheck_credit_pack` without changing subscription projection.
- [ ] Add idempotent Stripe session → credit grant boundary.
- [ ] Add zero-credit purchase prompt / pricing actions.
- [ ] Verify 3-pack test purchase grants exactly 3.
- [ ] Verify 10-pack test purchase grants exactly 10.
- [ ] Replay webhook and prove no duplicate credits.
- [ ] Verify another completed check consumes exactly one purchased credit.

**D4 exit gate / FEATURE FREEZE:** the full money loop works in Stripe test mode. From here, add no product features.

## D5 — History + hardening + release test

- [ ] Build minimal `/dealcheck/checks` history list and own-result navigation.
- [ ] Prove cross-user result/account/ledger access is denied.
- [ ] Prove duplicate submission cannot double-consume.
- [ ] Prove invalid/unsupported/provider-failure paths preserve/refund credits correctly.
- [ ] Verify existing Rep Bureau auth/onboarding regression.
- [ ] Verify existing Stripe subscription webhook regression.
- [ ] Run Supabase security/performance advisors and fix new actionable findings.
- [ ] Run `pnpm lint`.
- [ ] Run `pnpm typecheck`.
- [ ] Run `pnpm test`.
- [ ] Run `pnpm build`.
- [ ] Run `pnpm check`.
- [ ] Verify Vercel Preview at mobile and desktop widths; inspect console/runtime errors.
- [ ] Update this ledger and `docs/BUILD_STATUS.md` with final state.
- [ ] Push final branch and prepare reviewable PR/handoff.

## Founder-only activation checklist

These are not reasons to leave implementation unfinished. Complete everything possible in code/test mode first.

- [ ] Confirm final public URL/domain route for DealCheck.
- [ ] Confirm approved legal entity/contact/governing-law values and publish existing legal pages if required for public sale.
- [ ] Confirm Stripe live-mode key/webhook configuration and intentionally enable live payment collection.
- [ ] Perform one small real live purchase after founder activation, then confirm credits are granted once.

## Completion

- [ ] Every applicable Definition of Done item in `docs/27_DEALCHECK_V1.md` passes.
- [ ] No known P0/P1 defect remains.
- [ ] No out-of-scope feature was added.
- [ ] No manual founder step is being used to hide unfinished engineering.