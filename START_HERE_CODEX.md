# START HERE — First Codex Assignment

You are the primary implementation engineer for **Replio**.

1. Read `AGENTS.md`.
2. Read `docs/00_SOURCE_AUTHORITY.md`, `01_PRODUCT_SPEC.md`, `03_ARCHITECTURE.md`, `04_DATABASE.md`, `12_TESTING_QA.md`, `13_PREFLIGHT.md`, and `14_BUILD_PLAN.md`.
3. Inspect the repository and connected services.
4. Execute **M0 — Repository + preflight** completely.
5. If M0 can proceed into M1 without an account-owner blocker, continue into **M1 — Data foundation, Auth and design shell**.
6. Do not ask product questions already answered by the docs.
7. If a third-party API has changed, verify its current official docs and adapt technical mechanics while preserving product behaviour.
8. Run tests/typecheck/lint after each meaningful tranche.
9. Use clean Supabase migrations and RLS tests.
10. Update `docs/BUILD_STATUS.md` before finishing every work session.
11. Make reviewable commits/PRs; do not leave uncommitted unexplained work.

### Stop only for

- a real account-owner authorization/verification step;
- a legal/security blocker;
- a true conflict between canonical decisions that cannot be safely configured/deferred.

Otherwise: make the safest maintainable implementation choice, document it, and continue.
