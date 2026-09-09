# DealCheck V1 Build Ledger

**Branch:** `dealcheck-v1`  
**Resume rule:** start at the first incomplete checkbox. Do not redo completed milestones unless a regression proves they are broken.

## D0 — Inspect and preserve foundations

- [x] Confirm branch starts from current `main` and working tree is clean.
- [x] Inspect existing auth callback/login, Supabase clients/RLS conventions, AI gateway, Stripe Checkout/billing actions, Stripe webhook, design tokens and tests.
- [x] Verify current official docs only for APIs actually touched.
- [x] Record any implementation choice that differs from `docs/27...` before continuing; do not expand scope.

Implementation note: no product-scope difference. Atomic mutations use narrowly granted, schema-qualified `SECURITY DEFINER` RPCs because the app's established browser/server split and Supabase Data API require a single transaction for credit/check idempotency. The paid grant remains service-role-only and webhook-authoritative.

## D1 — DealCheck data + auth return path

- [x] Add one reviewable migration for the three `dealcheck_*` tables, constraints, indexes, RLS/grants and narrowly-scoped atomic credit functions.
- [x] Add RLS/idempotency tests.
- [x] Implement DealCheck account lazy initialization with exactly one lifetime +1 free-credit grant.
- [x] Add safe sanitized OAuth `next` support without changing normal Rep Bureau onboarding behaviour.
- [x] Add DealCheck-specific Google sign-in/resume flow using `sessionStorage` for pending raw form data.
- [x] Run targeted tests, lint and typecheck.

**D1 exit gate:** an unauthenticated valid pending form can sign in and return to `/dealcheck/resume`; no AI yet; free balance initializes exactly once.

## D2 — Public product surface

- [x] Build `/dealcheck` responsive editorial landing page using existing Rep Bureau tokens/typography.
- [x] Put the real DealCheck form above the fold.
- [x] Add short below-fold sections: what it checks, illustrative example, how it works, pricing, FAQ, footer.
- [x] Add authenticated header state, balance and `My checks` link.
- [x] Add validation/loading/error states and basic metadata/SEO.
- [x] Verify at ~390px and ~1440px.

**D2 exit gate:** the page looks intentional and production-quality before AI/payment complexity is added.

## D3 — Extraction + deterministic valuation + result

- [x] Add `src/features/dealcheck/` domain with Zod input/output contracts.
- [x] Implement exact versioned deterministic engine from `docs/28...`.
- [x] Implement all required deterministic fixtures.
- [x] Add AI extraction using existing Vercel AI Gateway; pasted text is explicitly untrusted.
- [x] Add deterministic valuation after extraction; LLM never chooses price.
- [x] Add concise AI writing pass with deterministic fallback copy.
- [x] Implement atomic check start/consume, completion and idempotent failed-check refund.
- [x] Build private result route/UI with giant score, offer, range, counter, fee/rights, watch-outs, action and copyable reply.
- [x] Record AI usage/cost metadata.
- [x] Run prompt-injection and unsupported/no-offer failure tests.

**D3 exit gate:** authenticated user with one credit can run a real supported check end-to-end; a failed/unsupported check does not cost a credit.

## D4 — Paid credit loop

- [x] Add server-authoritative pack catalog: 3 for £4.99 and 10 for £9.99.
- [x] Add one-time Stripe Checkout creation using trusted server price/quantity definitions.
- [x] Extend existing signed Stripe webhook for `dealcheck_credit_pack` without changing subscription projection.
- [x] Add idempotent Stripe session → credit grant boundary.
- [x] Add zero-credit purchase prompt / pricing actions.
- [ ] Verify 3-pack test purchase grants exactly 3.
- [ ] Verify 10-pack test purchase grants exactly 10.
- [ ] Replay webhook and prove no duplicate credits.
- [x] Verify another completed check consumes exactly one purchased credit.

**D4 exit gate / FEATURE FREEZE:** the full money loop works in Stripe test mode. From here, add no product features.

## D5 — History + hardening + release test

- [x] Build minimal `/dealcheck/checks` history list and own-result navigation.
- [x] Prove cross-user result/account/ledger access is denied.
- [x] Prove duplicate submission cannot double-consume.
- [x] Prove invalid/unsupported/provider-failure paths preserve/refund credits correctly.
- [x] Verify existing Rep Bureau auth/onboarding regression.
- [x] Verify existing Stripe subscription webhook regression.
- [x] Run Supabase security/performance advisors and fix new actionable findings.
- [x] Run `pnpm lint`.
- [x] Run `pnpm typecheck`.
- [x] Run `pnpm test`.
- [x] Run `pnpm build`.
- [x] Run `pnpm check`.
- [x] Verify Vercel Preview at mobile and desktop widths; inspect console/runtime errors.
- [x] Update this ledger and `docs/BUILD_STATUS.md` with final state.
- [x] Push final branch and prepare reviewable PR/handoff.

Verification note (9 Sep 2026): hosted Supabase transactions proved one lifetime free grant, exact 3/10 pack grants, replay-safe pack/refund boundaries, one-credit consumption and duplicate-request reuse; cross-user reads and browser mutations were denied. The final preview is READY and was checked at 390×844 and 1440×1000 with zero horizontal overflow and no browser/Vercel runtime errors. `pnpm check` passed with 139 tests. The three Stripe Checkout journey boxes above remain deliberately open until the account owner signs into the protected preview and confirms the test-mode payment step; automated implementation evidence is not being mislabeled as a completed purchase.

## Founder-only activation checklist

These are not reasons to leave implementation unfinished. Complete everything possible in code/test mode first.

- [ ] Confirm final public URL/domain route for DealCheck.
- [ ] Confirm approved legal entity/contact/governing-law values and publish existing legal pages if required for public sale.
- [ ] Confirm Stripe live-mode key/webhook configuration and intentionally enable live payment collection.
- [ ] Perform one small real live purchase after founder activation, then confirm credits are granted once.

## Completion

- [ ] Every applicable Definition of Done item in `docs/27_DEALCHECK_V1.md` passes.
- [x] No known P0/P1 defect remains.
- [x] No out-of-scope feature was added.
- [x] No manual founder step is being used to hide unfinished engineering.
