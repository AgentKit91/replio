# Replio Build Status

**Overall:** M0 AND M1 COMPLETE; M2 IN PROGRESS

## Current milestone

M2 — Gmail connection + labelled-thread ingestion

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

## Tests last run

28 Aug 2026:

- `pnpm lint` — pass.
- `pnpm typecheck` — pass.
- `pnpm test` — pass (7 tests).
- `pnpm build` — pass (Next.js 16.3.3 production build).
- GitHub Actions `app` job — pass.
- GitHub Actions `database` job — pass (`supabase start` + `supabase test db`, 8 pgTAP assertions).
- Hosted pgTAP Gmail idempotency transaction — pass (6 assertions; rolled back).

## Migrations/deployments

- Applied `identity_foundation` to Supabase project `Replio` in `eu-west-1`.
- Applied `add_foundation_foreign_key_indexes` after hosted performance-advisor review.
- Applied `gmail_ingestion_foundation` and `gmail_sync_worker_boundary` to the dedicated hosted Supabase project.
- Hosted security advisor reports no M2 schema/RLS findings; the remaining leaked-password warning does not apply to Google-only authentication.
- Vercel `replio` project is linked to GitHub; the PR branch preview is READY. A configuration-aware rebuild is triggered by the status commit that records the environment setup.

## Known blockers

1. Google Auth remains in Testing status and currently permits the founder test account; public launch will require completing OAuth branding/policy URLs and publishing review as applicable.
2. Gmail end-to-end activation will require enabling Gmail/Pub/Sub APIs, adding the Gmail callback, and creating the topic/authenticated subscription after the M2 preview endpoint is available.
3. Docker is unavailable on this host; database/pgTAP verification runs in GitHub Actions.

These are external activation/verification blockers, not reasons to redesign or discard the local foundation.

## Next three tasks

1. Validate and apply the M2 migration, including RLS and advisor review.
2. Implement the durable history-sync worker and idempotent labelled-thread ingestion.
3. Deploy an M2 Preview, then configure Google Cloud Gmail/Pub/Sub resources for end-to-end testing.

## Decision log

- **27 Aug 2026 — Node 22 minimum.** Supabase client packages dropped Node 20 support; aligns with `docs/18_TECHNICAL_BASELINE.md` verification rule.
- **27 Aug 2026 — Next.js `proxy.ts`.** Uses current Next.js 16/Supabase SSR mechanics rather than deprecated middleware naming.
- **27 Aug 2026 — explicit Data API grants.** Current Supabase projects may not auto-expose new public tables; M1 grants are deliberately least-privilege and paired with RLS.
- **27 Aug 2026 — restrained configurable visual system.** Neutral green development accent is tokenized pending founder brand assets; no product behaviour depends on it.
