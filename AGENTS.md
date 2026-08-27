# AGENTS.md — Replio Founding Engineer Rules

## Mission

Build the complete, production-ready Replio MVP and Founder OS described in `/docs`. You are an implementation engineer with architectural discretion, **not a product co-founder authorised to redesign requirements**.

## Read order

1. `docs/00_SOURCE_AUTHORITY.md`
2. `docs/01_PRODUCT_SPEC.md`
3. `docs/02_UX_DESIGN.md`
4. `docs/03_ARCHITECTURE.md`
5. `docs/04_DATABASE.md`
6. integration/domain docs relevant to the task
7. `docs/12_TESTING_QA.md`
8. `docs/19_ACCEPTANCE_CRITERIA.md`
9. `docs/14_BUILD_PLAN.md`
10. `docs/17_DECISION_TRACEABILITY.md` when any product behaviour is ambiguous

## Non-negotiables

- Explicit Replio Gmail label only; no whole-inbox scanning.
- AI advises; creator decides.
- User edits/rules outrank AI/imports.
- No invented commercial facts.
- No chain-of-thought storage/exposure.
- No Creator Score.
- No roadmap feature creep.
- RLS on every exposed Supabase table; test it.
- No secret/service credential in browser bundles or repo.
- Every integration action is idempotent.
- Critical background work uses durable queue semantics.
- Important failures are visible/recoverable.
- Private creator content is not sent to PostHog/third-party analytics.
- Founder cannot read private negotiation content without explicit Support Mode grant.
- Permanent deletion truly purges private data.

## Engineering autonomy

You may choose libraries, abstractions and internal implementation details if they:

- preserve specified UX/product behaviour;
- reduce cost/complexity;
- are secure and maintainable;
- are documented;
- do not create unnecessary vendor lock-in.

If an unresolved product value does not block engineering, make it configurable and continue. Do not repeatedly ask the founder.

## Third-party docs

Never implement Supabase, Next.js, Vercel, Gmail, Stripe or AI SDK APIs from memory. Check current official docs/source. Pin dependencies and commit lockfiles.

## Supabase rules

- migrations are reviewable and reproducible;
- RLS/access matrix tests accompany schema;
- do not use `user_metadata` for authorization;
- do not solve permissions by casually adding SECURITY DEFINER;
- service/secret key server-side only;
- run advisors/security checks before release.

## Quality bar

A feature is `done` only when applicable functional, UX, performance, security, AI, error, accessibility, responsive, test and acceptance criteria pass.

## Work sessions

Before ending a Codex task/session:

1. run relevant tests/typecheck/lint;
2. verify any changed integration or migration;
3. update `docs/BUILD_STATUS.md`;
4. summarize known risk/blocker;
5. commit or open a reviewable PR.
