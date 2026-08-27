# Build Plan and Codex Execution Model

## Operating model

Codex is expected to continue autonomously through the current milestone: inspect code, implement, migrate, test, fix, re-test, update documentation/status and make reviewable commits. Do not stop after generating scaffolding.

After every meaningful tranche update `docs/BUILD_STATUS.md` with:

- current milestone;
- completed acceptance items;
- tests run/results;
- migrations/deployments made;
- known issues;
- next three tasks;
- founder-owned blocker only if genuinely required.

## Branch/release discipline

- `main` = known deployable/stable state.
- Use small milestone/feature branches or Codex PRs.
- Preview deployment for review.
- Merge only with required CI green.
- Production releases reversible; retain ability to promote/rollback previous stable deployment.

## M0 — Repository + preflight

**Goal:** Codex can work without repeated access interruptions.

- create Next.js/TypeScript app with current verified Active LTS;
- package manager + pinned lockfile;
- lint/typecheck/test commands;
- env validation;
- Vercel/Supabase preview setup;
- install docs/AGENTS pack;
- CI;
- confirm owner actions still needed.

**Exit:** Preview builds; CI green; secrets absent; Build Status initialized.

## M1 — Data foundation, Auth and design shell

- Supabase migrations for identity/workspaces/creator profile + foundational operation tables;
- RLS and RLS test harness;
- Google Sign-In only;
- create hidden workspace on first login atomically/idempotently;
- creator app shell/navigation;
- design tokens/component primitives;
- minimal two-minute onboarding;
- mobile shell.

**Exit:** user can sign in, onboard and access only own workspace; cross-tenant tests fail closed.

## M2 — Gmail connection + labelled-thread ingestion

- separate Gmail OAuth;
- encrypted token storage;
- create/find Replio label;
- Pub/Sub authenticated webhook;
- Gmail watch + renewal;
- durable `gmail-sync` queue;
- incremental history sync;
- MIME normalization/security;
- deal/thread/message schema;
- duplicate/retry tests.

**Exit:** test labelled thread reliably creates one Deal; reply in same thread updates same Deal; no full-inbox scanning.

## M3 — Deal domain + workspace UX

- deals/list/filter/search;
- brands/contacts/private notes;
- Deal Workspace split layout;
- human-readable state engine;
- offers/terms/deliverables data;
- attachments refs;
- activity timeline;
- recycle bin.

**Exit:** complete non-AI Deal experience works with fixture data and mobile.

## M4 — AI pipeline

- provider/gateway adapter;
- orchestrator;
- five fixed workers;
- Zod/typed schemas;
- analysis snapshots/facts/evidence;
- worker-run cost ledger;
- background `ai-analysis`;
- worker-level retry/fallback;
- Realtime progressive updates;
- Knowledge Library/version structure;
- fixture knowledge only for tests.

**Exit:** core eval corpus passes fabrication/structure/error-handling gates; Deal stays usable during provider failure.

## M5 — Pricing, Score, strategy and reply/send

- three fee recommendations;
- configurable Score engine/version;
- risk/strategy presentation;
- `Why?` evidence navigation;
- native integrated composer;
- autosave/versioning;
- intentional rewrites preserving edits;
- respectful challenge once;
- Gmail send idempotency/threading;
- state transitions.

**Exit:** full labelled email → analysis → edit/rewrite → send → brand reply loop works E2E.

## M6 — Creator learning, insights and benchmark foundation

- goals, non-negotiables, rate cards, voice/preference structure;
- contextual profile prompts;
- completed Deal recap/outcome;
- EAE calculation/version;
- anonymised benchmark contribution pipeline;
- minimum evidence gate;
- personal Insights;
- no fake brand intelligence.

**Exit:** completed Deal produces private recap + safe aggregate contribution; deletion/re-identification tests pass.

## M7 — Stripe subscriptions

- plan catalogue + entitlement service;
- working Stripe test prices;
- Checkout + Customer Portal;
- 30-day trial config;
- signed webhook state projection;
- Standard usage limit;
- Pro cost/fair-use routing;
- billing Settings;
- failed payment states.

**Exit:** Stripe test journeys work and local access never trusts success URL alone.

## M8 — Founder OS

- founder role bootstrap;
- Today/Action Centre;
- business/usage/billing metrics;
- AI cost/quality/system health;
- queue/Gmail/Stripe incident visibility;
- customer operational metadata with private content shield;
- support-access grants/session;
- safe retry/reconcile actions;
- confirmation flow/audit for sensitive actions;
- feature/config/model controls scoped to MVP.

**Exit:** founder can operate/recover critical MVP systems without casually accessing private creator content.

## M9 — Hardening + closed beta gate

- full unit/integration/RLS/E2E suite;
- 50+ AI eval cases;
- accessibility/mobile audit;
- performance profiling;
- rate limits/abuse;
- security review;
- backup/restore/rollback test;
- analytics privacy audit;
- production monitoring;
- launch checklist;
- beta-user feedback fixes.

**Exit:** Launch Readiness Gate passes.

## Scope protection

If Codex discovers a roadmap item while implementing an interface, create the extension point/schema only when it is cheap and does not complicate MVP. Do not build the feature. Record it under `docs/15_ROADMAP_OUT_OF_SCOPE.md`.
