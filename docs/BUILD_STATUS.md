# Replio Build Status

**Overall:** M0 COMPLETE; M1 FOUNDATION DEPLOYED, AUTH CONFIGURATION PENDING

## Current milestone

M1 — Data foundation, Auth and design shell

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
- [ ] Google provider configured and sign-in/onboarding exercised end-to-end.

## Tests last run

27 Aug 2026:

- `pnpm lint` — pass.
- `pnpm typecheck` — pass.
- `pnpm test` — pass (2 tests).
- `pnpm build` — pass (Next.js 16.3.3 production build).
- GitHub Actions `app` job — pass.
- GitHub Actions `database` job — pass (`supabase start` + `supabase test db`, 8 pgTAP assertions).

## Migrations/deployments

- Applied `identity_foundation` to Supabase project `Replio` in `eu-west-1`.
- Applied `add_foundation_foreign_key_indexes` after hosted performance-advisor review.
- Vercel `replio` project is linked to GitHub; its current production deployment is the pre-implementation `main` revision. Branch preview is pending the next push.

## Known blockers

1. Vercel Preview/Production still need `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `NEXT_PUBLIC_APP_URL` and `APP_ENV`. The connected Vercel API is read-only for environment variables and the available browser is not signed into Vercel.
2. Supabase Google Auth still needs founder-owned Google OAuth client credentials and provider activation before end-to-end sign-in can pass.
3. Docker is unavailable on this host; the same local Supabase/pgTAP flow is green in GitHub Actions.

These are external activation/verification blockers, not reasons to redesign or discard the local foundation.

## Next three tasks

1. Configure Vercel Preview/Production public Supabase environment values and the environment-specific app URL.
2. Configure Supabase Google Auth and allowed redirect URLs.
3. Verify sign-in → atomic workspace → onboarding → authenticated dashboard end-to-end.

## Decision log

- **27 Aug 2026 — Node 22 minimum.** Supabase client packages dropped Node 20 support; aligns with `docs/18_TECHNICAL_BASELINE.md` verification rule.
- **27 Aug 2026 — Next.js `proxy.ts`.** Uses current Next.js 16/Supabase SSR mechanics rather than deprecated middleware naming.
- **27 Aug 2026 — explicit Data API grants.** Current Supabase projects may not auto-expose new public tables; M1 grants are deliberately least-privilege and paired with RLS.
- **27 Aug 2026 — restrained configurable visual system.** Neutral green development accent is tokenized pending founder brand assets; no product behaviour depends on it.
