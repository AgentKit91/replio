# Replio Build Status

**Overall:** M0–M4 COMPLETE; M5 consent-gated E2E pending; M6–M8 COMPLETE; M9 NEXT

## Current milestone

M9 — Hardening + closed beta gate

## Completed

### M0 — Repository + preflight

- [x] Repository inspected and implementation branch created.
- [x] Current framework/dependency mechanics verified against official Next.js and Supabase sources.
- [x] Next.js 16.3.3 / React 19 / TypeScript App Router scaffold established with Node 22 minimum and pinned pnpm lockfile.
- [x] Lint, typecheck, unit-test, production-build and aggregate `check` commands established.
- [x] Runtime environment validation and complete secret-name inventory established; values remain uncommitted.
- [x] GitHub Actions application and Supabase/RLS jobs established.
- [x] Connected services inspected without reusing City Seekers infrastructure.
- [x] Dedicated Replio Supabase project connected; City Seekers infrastructure was not reused.
- [x] Replio Vercel project connected to `AgentKit91/replio` through Git integration.

### M1 — Data foundation, Auth and design shell

- [x] Identity, hidden workspaces, memberships, creator profile/platform and foundational operations migration authored.
- [x] Every exposed M1 table has RLS plus explicit least-privilege grants.
- [x] Auth-user trigger atomically/idempotently creates one hidden creator workspace and creator profile.
- [x] pgTAP tenant-isolation access matrix authored and wired into CI.
- [x] Current Supabase SSR clients and Next.js `proxy.ts` session refresh implemented.
- [x] Google is the only visible sign-in method.
- [x] Responsive creator shell/navigation and calm configurable design tokens implemented.
- [x] Minimal onboarding captures only name, market, currency, niche, main platforms and explicit labelled-thread consent.
- [x] Empty states explain what appears next and provide a useful action.
- [x] Migration and pgTAP RLS suite pass in GitHub Actions local Supabase.
- [x] M1 migrations applied to the dedicated hosted Replio Supabase project.
- [x] Hosted Supabase security advisors pass with no findings; missing foreign-key indexes remediated.
- [x] Vercel Production and Preview configured with the Supabase URL/publishable key and environment-specific app URL.
- [x] Supabase Auth Site URL and exact localhost, Production and PR Preview callback URLs configured.
- [x] Dedicated Google Cloud project and web OAuth client configured with the Supabase callback; founder added as a test user.
- [x] Supabase Google provider enabled with credentials retained only in Google Cloud and Supabase.
- [x] Google sign-in/onboarding exercised end-to-end on Production.
- [x] Production Auth created exactly one user, hidden workspace, membership, complete required profile and platform record.

### M2 — Gmail connection + labelled-thread ingestion

- [x] Current Google Gmail scope, watch and authenticated Pub/Sub mechanics re-verified against official docs.
- [x] Gmail/deal/message foundation migration authored with tenant RLS and browser read-only grants.
- [x] Refresh-token ciphertext and sync-event internals isolated in the private schema.
- [x] Durable logged `gmail_sync` queue and idempotent event-enqueue boundary authored.
- [x] Separate Gmail OAuth with state, PKCE, offline consent and AES-256-GCM refresh-token encryption implemented.
- [x] Deterministic Replio label find/create and label-filtered Gmail watch setup implemented.
- [x] Authenticated Pub/Sub webhook verification and MIME normalization/security helpers implemented.
- [x] Incremental Gmail history worker persists only explicitly labelled new threads or later changes to known threads.
- [x] Repeated Pub/Sub history windows and repeated thread/message persistence are idempotent at the database boundary.
- [x] Gmail API and Pub/Sub API enabled in the dedicated Replio Google Cloud project.
- [x] Production Gmail OAuth callback added; a dedicated rotated client secret is stored only in Google Cloud and Vercel.
- [x] Vercel Preview/Production server configuration includes Supabase backend access, Gmail token encryption and internal-worker secrets.
- [x] Dedicated Pub/Sub topic, least-privilege Gmail publisher binding, authenticated push service account and push subscription created.
- [x] M2 merged in PR #2 and deployed READY to Production.
- [x] Low-cost Supabase Cron worker invocation authored at one queue poll per minute, inert until its Vault credential is installed.
- [x] Dedicated Supabase backend secret installed for Vercel Production and Preview; scheduled worker authentication verified with a 204 empty-queue response.
- [x] Founder added as the sole Google OAuth test user and separate Gmail consent completed on Production.
- [x] Production Gmail connection created the Replio label, active watch, expiry and exact history cursor; refresh token is stored encrypted server-side.
- [x] Authenticated Pub/Sub push accepted with HTTP 204 after preserving Gmail's unquoted 64-bit history ID without JavaScript number coercion.
- [x] Durable sync event completed, queue drained to zero, and the existing labelled fixture conversation produced exactly one Deal and one message.

### M3 — Deal domain + workspace UX

- [x] Deals list, search and status filters.
- [x] Brands, contacts and private notes.
- [x] Responsive Deal Workspace with conversation and commercial-detail panes.
- [x] Human-readable state transitions, offers, terms and deliverables.
- [x] Attachment references, activity timeline and 30-day recycle bin.
- [x] Consumer email providers are excluded from automatic brand inference.

### M4 — AI pipeline

- [x] Provider-neutral Vercel AI Gateway adapter and five fixed Zod-validated workers.
- [x] Immutable analysis snapshots, evidence-backed fact ledger and per-worker usage/cost records.
- [x] Durable AI queue, idempotent worker-level resume, three-attempt cap, optional fallback and progressive workspace updates.
- [x] Versioned, trust-tiered Knowledge Library structure with an explicitly non-production synthetic fixture corpus.
- [x] Fabrication/structure/error-handling eval fixtures; provider failure leaves the Deal and conversation usable.

### M5 — Pricing, Score, strategy and reply/send (in progress)

- [x] Versioned provisional Score and pricing configuration with deterministic component scoring.
- [x] Three ordered fee recommendations, risk/strategy presentation and message-linked evidence navigation.
- [x] Integrated composer with serialized optimistic autosave and immutable creator-edit versions.
- [x] Intentional targeted rewrites preserve the current creator draft and strategy; only explicit Start again may replace it wholesale.
- [x] One-time respectful challenge offers Review draft and Send anyway without overriding the creator.
- [x] Idempotent RFC-threaded Gmail delivery with reconciliation, bounded retries and explicit send confirmation.
- [x] Successful sends appear immediately and move the Deal to Waiting on brand; later inbound replies move it to Your reply needed.
- [ ] Consent-gated production E2E: labelled email → analysis → edit/rewrite → send → brand reply.

### M6 — Creator learning, insights and benchmark foundation (implementation complete)

- [x] Conservative, versioned Estimated Additional Earnings calculator with negative-uplift and zero-base safeguards.
- [x] Versioned benchmark evidence gate with no seeded/fake intelligence.
- [x] Creator-owned goals, non-negotiables, preferences, private rate cards and private voice-version schema.
- [x] Learned preferences remain pending suggestions until an explicit creator acceptance action.
- [x] Private outcome and de-identified benchmark contribution structures exclude creator, workspace, contact, message, Deal and raw-text identifiers.
- [x] Atomic, idempotent completed-Deal outcome transaction calculates versioned EAE and emits exactly one unlinkable contribution.
- [x] Creator-facing completed-Deal recap with clear private/aggregate-data disclosure and reproducible `How we estimated this` explanation.
- [x] Private personal Insights totals remain separated by currency until a versioned FX source exists.
- [x] Contextual Train Replio UI for creator-owned goals, red lines and private rate cards; observed suggestions require explicit acceptance.
- [x] Nightly low-cost benchmark aggregation publishes only coarse cells meeting the versioned minimum evidence threshold and removes cells that fall below it.
- [x] Richer private personal trends calculate success rate and median negotiation rounds without combining currencies.
- [x] Re-identification and threshold regression tests prove public cells exclude linkable identifiers and cannot survive with fewer than five contributions.

### M7 — Stripe subscriptions (complete)

- [x] Configuration-driven provisional Standard/Pro catalogue with hidden Ultra architecture slot.
- [x] Server-authoritative subscription projection, period usage counters and private idempotent Stripe-event ledger.
- [x] Analysis entitlement is consumed atomically at the database queue boundary; redirects and browser calls cannot grant access.
- [x] Pinned current Stripe Node SDK, test-mode Checkout and Customer Portal server actions, and raw-body signed webhook projection.
- [x] Idempotent and out-of-order Stripe subscription event tests; successful redirects remain non-authoritative.
- [x] Stripe test Products/Prices and signed webhook endpoint configuration.
- [x] Failed-payment and processing-state Settings UX.
- [x] Full Stripe test Checkout, 30-day trial, signed webhook projection and Customer Portal journey.

### M8 — Founder OS (complete)

- [x] Founder-only role bootstrap and server-side operational read boundary.
- [x] Privacy-shielded Today / Action Centre for billing, Gmail, AI/send queues, recorded AI cost and active support grants.
- [x] Founder health, incident, audited-action and versioned feature-flag foundations.
- [x] Creator-controlled support grants are scoped, expire within seven days, revoke immediately and do not grant access without an active audited founder session.
- [x] Privacy-shielded customer operational directory excludes messages, drafts, notes and analysis output.
- [x] Versioned, audited AI and outbound-Gmail worker kill switches fail closed at the queue-claim boundary; resuming requires explicit confirmation.
- [x] Creator-facing Support Mode grant/revoke controls and separately confirmed, audited founder session start/end lifecycle.
- [x] Safe, audited incident acknowledgement and labelled-Gmail sync retry with attempt caps, reauthorization blocks and queue idempotency.
- [x] AI and outbound-send generic retries deliberately remain blocked when creator consent or provider reconciliation is unresolved.

### M9 — Hardening + closed beta gate (in progress)

- [x] Version-controlled offline AI launch corpus expanded to 63 named canonical and adversarial cases without transmitting creator data.
- [x] Evidence grounding validates that every cited excerpt exists in its referenced selected-thread message.
- [x] AI contracts reject empty evidence, malformed currencies, blank rationales/strategies/replies, invented reply facts and malformed/refusal provider output.
- [x] Production accessibility and responsive golden-path audit at 1440px and 390px covers Dashboard, Deals, Deal Workspace, Brands, Insights, Train Replio, Settings and Founder OS; active navigation now uses `aria-current` and keyboard users can skip directly to main content.
- [ ] Accessibility, responsive, performance, security, backup/restore, rollback and analytics privacy gates.

## Tests last run

1 Sep 2026:

- `pnpm lint` — pass.
- `pnpm typecheck` — pass.
- `pnpm test` — pass (101 tests across 15 files, including 63 M9 AI launch-eval cases).
- `pnpm build` — pass (Next.js 16.3.3 production build).
- `pnpm lint` and `pnpm typecheck` — pass after M9 navigation accessibility hardening.
- `pnpm test` — pass (104 tests across 16 files, including active/nested navigation regression coverage).
- `pnpm build` — pass after M9 navigation accessibility hardening; the first sandboxed attempt was network-blocked while fetching Geist and passed when verification network access was granted.
- `pnpm check` — pass after M8 worker controls (lint, typecheck, 37 unit tests, production build).
- GitHub Actions `app` job — pass.
- GitHub Actions `database` job — pass (`supabase start` + `supabase test db`, including M4 retry and tenant-isolation assertions).
- PRs #9 and #10 — app, database and Vercel checks pass.
- Production read-through — Deal Workspace renders and the AI activation control is enabled; it was not clicked, so no real email was sent to an AI provider during verification.
- Hosted pgTAP Gmail idempotency transaction — pass (6 assertions; rolled back).

## Migrations/deployments

- Applied `identity_foundation` to Supabase project `Replio` in `eu-west-1`.
- Applied `add_foundation_foreign_key_indexes` after hosted performance-advisor review.
- Applied `gmail_ingestion_foundation` and `gmail_sync_worker_boundary` to the dedicated hosted Supabase project.
- Hosted security advisor reports no M2 schema/RLS findings; the remaining leaked-password warning does not apply to Google-only authentication.
- PR #2 Preview deployment and both GitHub Actions jobs are green.
- PR #2 merged as `86ac5eec`; its Vercel Production deployment is READY.
- Google Cloud billing is linked under the free trial. A £5 monthly budget alert is configured; this is an alert rather than a hard spending cap.
- Pub/Sub topic `replio-gmail-events` and authenticated push subscription `replio-gmail-push` are active with acknowledged-message retention disabled and 31-day inactivity expiry.
- PRs #4–#6 added privacy-safe webhook diagnostics and the 64-bit-safe Gmail history parser; all app/database CI checks passed.
- Production deployment `a3e600c` is READY; webhook, queue and worker completed the first labelled-thread sync end to end.
- M3 migrations applied to hosted Supabase; one active fixture Deal remains intact, brand/contact inference is intentionally skipped for consumer email domains, and the daily expired-deal purge is scheduled.
- PR #7 merged and production deployment `68dae27` reached READY; PR #8 merged the consumer-domain data-quality correction.
- M4 pipeline and retry-cap migrations are applied to hosted Supabase; the AI queue remains empty until a creator explicitly requests analysis.
- PR #10 merged as `4a9583d`; Production deployment `dpl_7A2byt9wL6nLK2ERVoaoJ9xPE4ss` is READY with the low-cost AI model configuration.
- M5 score/composer and Gmail-send foundations merged in PRs #12–#14; the send queue remains empty and no production email has been sent.
- PR #15 remediated every Supabase-advised missing foreign-key index; hosted performance advisor reports zero unindexed foreign keys.
- PR #21 completed M6 threshold aggregation and personal trends; the hosted database has no benchmark contributions or cells and its nightly refresh is active but inert until real outcomes exist.
- PR #24 added test-mode Checkout, Customer Portal, signed webhooks and the idempotent subscription projection; Stripe test Products/Prices and the test webhook are now configured with restricted server credentials stored only as Vercel Production secrets.
- Stripe Managed Payments is explicitly disabled for the test Checkout because tax registrations and product tax classification are not yet approved; Stripe Tax remains off rather than silently collecting nothing.
- PRs #25–#26 activated the hosted Standard/Pro test catalogue and kept Checkout outside Managed Payments; both merged green and deployed READY.
- The hosted Standard sandbox journey completed on 1 Sep 2026: Checkout created a 30-day trial, the signed `customer.subscription.created` event projected a `trialing` subscription, duplicate-safe event records were retained, Settings reflected access, and the Stripe Customer Portal opened successfully.
- PR #27 started M8 with a founder-only operational dashboard and private-control schema; the hosted foundation migration is applied and the sole Replio account is bootstrapped as founder.
- PRs #28–#31 hardened Support Mode, replaced private-schema reads with service-only RPCs, added the privacy-shielded customer directory and cleared all advised unindexed foreign keys.

## Known blockers

1. Google Auth remains in Testing status and currently permits the founder test account; public launch will require completing OAuth branding/policy URLs and publishing review as applicable.
2. Public launch still requires founder-approved Privacy Policy/Terms wording and completing Google verification for the restricted Gmail scope.
3. Docker is unavailable on this host; database/pgTAP verification runs in GitHub Actions.

These are external activation/verification blockers, not reasons to redesign or discard the local foundation.

## Next three tasks

1. Complete the performance portion of the golden-path hardening gate.
2. Complete the security and analytics privacy audit.
3. Test backup/restore and release rollback procedures while keeping the M5 production loop consent-gated.

## Decision log

- **27 Aug 2026 — Node 22 minimum.** Supabase client packages dropped Node 20 support; aligns with `docs/18_TECHNICAL_BASELINE.md` verification rule.
- **27 Aug 2026 — Next.js `proxy.ts`.** Uses current Next.js 16/Supabase SSR mechanics rather than deprecated middleware naming.
- **27 Aug 2026 — explicit Data API grants.** Current Supabase projects may not auto-expose new public tables; M1 grants are deliberately least-privilege and paired with RLS.
- **27 Aug 2026 — restrained configurable visual system.** Neutral green development accent is tokenized pending founder brand assets; no product behaviour depends on it.

