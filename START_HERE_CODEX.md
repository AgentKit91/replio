# START HERE — Current Codex Assignment

You are the primary implementation engineer for **Rep Bureau** (existing repository/internal identifiers may still say `replio`).

The repository already contains substantial M0–M9 work. **Do not restart the build. Do not recreate completed foundations.**

## Mandatory first read

1. `AGENTS.md`
2. `docs/00_SOURCE_AUTHORITY.md`
3. `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md`
4. `docs/01_PRODUCT_SPEC.md`
5. `docs/03_ARCHITECTURE.md`
6. `docs/04_DATABASE.md`
7. `docs/05_GMAIL_INTEGRATION.md`
8. `docs/06_AI_SYSTEM.md`
9. `docs/12_TESTING_QA.md`
10. `docs/19_ACCEPTANCE_CRITERIA.md`
11. `docs/14_BUILD_PLAN.md`
12. `docs/BUILD_STATUS.md`

## Assignment

1. Inspect the current code, migrations, tests and `BUILD_STATUS` before changing anything.
2. Treat the **7 September 2026 Phase 1 Deal Operations & Admin Automation amendment as mandatory launch scope**, superseding the older deferral of invoice generation/payment tracking/chasing.
3. Reuse the existing Deal, Gmail, AI fact/evidence, notification, queue, Realtime, Creator Profile and Founder OS foundations wherever possible.
4. Implement the new M9 deal-operations/admin scope in `docs/14_BUILD_PLAN.md` completely: living operational Deal state, Kanban-esque pipeline, deadlines, invoice preparation/generation/send approval, due-date tracking, payment reminders/chases, payment confirmation and creator financial views.
5. Optimise for the product rule: **Rep Bureau does the admin; the creator makes the decisions.** Avoid new manual CRM-style forms when the information already exists in selected communications or trusted creator data.
6. Preserve provenance and creator override priority for auto-populated fields.
7. Do not auto-send invoices/chases; external consequential actions require creator review/confirmation.
8. Do not infer `paid`; creator confirms payment in Phase 1.
9. After M9 lands, rerun the affected hardening/security/accessibility/performance/RLS/E2E gates as M10.
10. Update `docs/BUILD_STATUS.md` continuously and make reviewable commits/PRs.

## Stop only for

- a real account-owner authorization/verification step;
- a legal/security blocker;
- a true conflict between current canonical decisions that cannot be safely configured/deferred.

Otherwise make the safest maintainable implementation choice, document it and continue.
