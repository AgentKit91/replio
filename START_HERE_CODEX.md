# START HERE — Current Codex Assignment

You are the primary implementation engineer for **Rep Bureau** (existing repository/internal identifiers may still say `replio`).

The repository already contains substantial M0–M9 work. **Do not restart the build. Do not recreate completed foundations.**

## Mandatory first read

1. `AGENTS.md`
2. `docs/00_SOURCE_AUTHORITY.md`
3. `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md`
4. `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`
5. `docs/01_PRODUCT_SPEC.md`
6. `docs/03_ARCHITECTURE.md`
7. `docs/04_DATABASE.md`
8. `docs/05_GMAIL_INTEGRATION.md`
9. `docs/06_AI_SYSTEM.md`
10. `docs/12_TESTING_QA.md`
11. `docs/19_ACCEPTANCE_CRITERIA.md`
12. `docs/14_BUILD_PLAN.md`
13. `docs/BUILD_STATUS.md`

## Assignment

1. Inspect the current code, migrations, tests and `BUILD_STATUS` before changing anything.
2. Treat **both 7 September 2026 founder amendments as mandatory launch scope**:
   - Deal Operations & Admin Automation (`docs/24...`);
   - Dedicated Creator Email Address (`docs/25...`).
3. Reuse the existing Deal, Gmail, normalized email-message, AI fact/evidence, notification, queue, Realtime, Creator Profile, composer/send and Founder OS foundations wherever possible.
4. Implement the expanded M9 scope in `docs/14_BUILD_PLAN.md` completely: living operational Deal state, Kanban-esque pipeline, deadlines, invoice preparation/generation/send approval, due-date tracking, payment reminders/chases, payment confirmation, creator financial views **and the optional dedicated Rep Bureau email address**.
5. Gmail must remain supported through the explicit-label flow, but it is no longer mandatory for creators who choose the Rep Bureau-address route.
6. A creator with no Gmail OAuth connection must be able to receive/forward a brand enquiry, negotiate, send an invoice and chase payment using their dedicated Rep Bureau address from inside the product.
7. Preserve source/provenance and creator override priority for auto-populated fields. Forwarded-message headers are creator-supplied evidence, not provider-verified transport metadata.
8. Optimise for **Rep Bureau does the admin; the creator makes the decisions.** Avoid manual CRM-style entry when trusted information already exists.
9. Do not auto-send negotiation emails, invoices or chases; consequential external actions require creator review/confirmation.
10. Do not infer `paid`; creator confirms payment in Phase 1.
11. Verify current official docs for any inbound/outbound email provider chosen. Keep provider mechanics behind an abstraction and include deliverability, spam/abuse, attachment, privacy and idempotency controls.
12. After M9 lands, rerun affected hardening/security/accessibility/performance/RLS/E2E gates as M10.
13. Update `docs/BUILD_STATUS.md` continuously and make reviewable commits/PRs.

## Stop only for

- a real account-owner authorization/verification step;
- a legal/security blocker;
- a true conflict between current canonical decisions that cannot be safely configured/deferred.

Otherwise make the safest maintainable implementation choice, document it and continue.
