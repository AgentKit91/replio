# Rep Bureau Build Status

> Repository/internal identifiers may still use the historical product name Replio.

**Overall:** M0–M4 COMPLETE; M5 consent-gated E2E pending; M6–M8 COMPLETE; pre-amendment hardening substantially completed; **new mandatory M9 expanded Phase 1 NEXT**; M10 final hardening follows.

## Current milestone

**M9 — Deal Operations, Admin Automation & Dedicated Creator Email (mandatory expanded Phase 1)**

Canonical scope:

- `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md`
- `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`

## 7 September 2026 founder scope amendments

Former Phase 1.5/post-launch operations have been promoted into Phase 1/launch:

- living operational Deal record and provenance;
- Kanban-esque Deal pipeline;
- deadlines/deliverable administration;
- invoice issuer profile;
- auto-prepared invoices using existing Deal/email information;
- versioned PDF invoice generation;
- creator-approved invoice send through Gmail or the Deal's dedicated Rep Bureau address;
- payment due/outstanding/overdue tracking;
- prepared payment reminders/chases with creator approval;
- creator `Paid` / `Still waiting` confirmation;
- creator financial states for agreed/invoiced/outstanding/overdue/received;
- optional dedicated Rep Bureau commercial email address per creator workspace;
- direct brand enquiries to that address;
- creator-forwarded brand emails from otherwise unconnected mailboxes;
- full no-Gmail Deal lifecycle through the dedicated address;
- managed-email attachment, spam/abuse, deliverability, privacy and idempotency controls.

Gmail remains a supported explicit-label source but is no longer required for creators using the dedicated Rep Bureau address. No external mailbox may be scanned automatically.

Existing pre-amendment hardening work remains valid but final affected gates must be rerun as M10 after M9 lands. Codex must not restart M0–M8.

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

### Pre-amendment hardening work already completed

- [x] Offline AI launch corpus expanded to 63 canonical/adversarial cases.
- [x] Evidence grounding and stronger AI-contract validation.
- [x] Desktop/mobile accessibility/responsive golden-path audit of existing surfaces.
- [x] Analytics privacy audit with no creator-content analytics path.
- [x] HTTP/browser security boundary hardening.
- [x] Performance review of server-rendered shell/client boundary.
- [x] Recovery runbook and clean schema/RLS rebuild in CI.
- [x] Closed-beta go/no-go structure.

These checks must be rerun/extended after M9 for new pipeline/invoice/payment/managed-email surfaces.

## M9 — Expanded Phase 1

- [ ] M9A Living operational Deal state/provenance/deadlines, source-neutral across Gmail/managed email.
- [ ] M9B Kanban-esque pipeline and Action Dashboard.
- [ ] M9C Invoice issuer profile and auto-prepared invoice review.
- [ ] M9D Versioned PDF generation + explicit provider-neutral invoice send.
- [ ] M9E Payment due/overdue tracking + prepared chase + Paid/Still waiting.
- [ ] M9F Creator financial overview.
- [ ] M9G Deal-ops RLS/privacy/idempotency/deletion/regression coverage.
- [ ] M9H Dedicated Rep Bureau creator email: allocation, direct inbound, forwarding, outbound, attachments, spam/abuse, deliverability, privacy and no-Gmail E2E.

## M10 — Final hardening + closed beta gate

- [ ] Rerun full unit/integration/RLS/E2E suite.
- [ ] Extend AI evals for billing/deadline/payment/forwarded-message extraction.
- [ ] Accessibility/mobile audit new pipeline/invoice/payment/email-source journeys.
- [ ] Performance/security/privacy/spam-abuse/deliverability/backup/rollback/analytics gates.
- [ ] Expanded release checklist passes.

## Tests last run

1 Sep 2026 (before the 7 Sep scope amendments):

- `pnpm lint` — pass.
- `pnpm typecheck` — pass.
- `pnpm test` — pass, later 106 tests across 17 files after M9-era hardening.
- `pnpm build` / `pnpm check` — pass after existing accessibility/security/performance changes.
- GitHub Actions `app` and `database` jobs — pass.
- CI clean database rebuild + pgTAP — pass.
- Production read-through — Deal Workspace renders; no real AI/email send was triggered during that verification.
- Hosted pgTAP Gmail idempotency transaction — pass.

These results establish the pre-amendment baseline; they do not mark the new M9 scope complete.

## Existing deployments/infrastructure

- Dedicated Supabase project, Vercel project, Google Cloud/Gmail/Pub-Sub integration and Stripe test integration are already configured as recorded in prior build history.
- M1–M4 migrations and later milestone migrations are applied to hosted Supabase as recorded in prior PRs.
- Existing Gmail watch/queue, AI queue, Gmail send, Stripe subscription and Founder OS foundations should be reused rather than replaced.
- Existing normalized Deal/message/composer/send foundations should be extended provider-neutrally for managed email rather than duplicated.
- Existing known-good Vercel deployments remain rollback points.

## Known blockers / production activation items

1. Google Auth/Gmail OAuth remains in Testing status and currently permits the founder test account; public Gmail use requires completing OAuth branding/policy/verification as applicable.
2. Privacy Policy/Terms and Google verification evidence remain founder/legal/activation work.
3. Dedicated Rep Bureau email requires a founder-approved production domain/subdomain and a verified current inbound/outbound email provider configuration before external beta; Codex should implement against safe test/dev configuration without repeatedly stopping for product questions.
4. Privacy/Terms must cover hosted processing of messages/attachments sent or forwarded to dedicated creator addresses.
5. Docker is unavailable on the founder host; database/pgTAP verification runs in GitHub Actions.
6. Any live proof that transmits a real selected thread to AI or sends a real Gmail/managed-email message remains consent-gated.

These are activation/verification blockers, not reasons to redesign/discard the existing foundation or stop implementing M9 locally/test-first.

## Next three tasks

1. Inspect existing Deal/Gmail/email-message/AI schema and implement **M9A** with the smallest safe migrations/services needed for living admin facts, provenance and deadlines; keep it provider-neutral from the start.
2. Continue through **M9B–M9H** autonomously, reusing current queue/Realtime/composer/send infrastructure and keeping external sends creator-approved. For M9H, verify current provider docs and implement the dedicated-address no-Gmail path.
3. After all M9 acceptance criteria pass, run **M10** final hardening and then complete remaining founder-owned Google/legal/email-domain/backup/live-billing gates.

## Decision log additions

- **7 Sep 2026 — Phase 1 scope expanded.** Former Phase 1.5 Deal operations are now mandatory launch scope; `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md` supersedes older invoice/payment deferrals.
- **7 Sep 2026 — dedicated creator email promoted.** `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md` supersedes the prior deferral of a Rep Bureau-managed creator email; Gmail is optional for this route.
- **7 Sep 2026 — 90/10 admin principle.** Rep Bureau handles internal admin automatically; creator reviews/approves consequential external actions.
- **7 Sep 2026 — user-facing name Rep Bureau.** Existing internal `replio` identifiers may remain until a safe dedicated rename is worthwhile; do not burn build credits on cosmetic internal renaming.

Historical implementation decisions from 27 Aug–1 Sep remain valid unless they conflict with the dated amendments.
