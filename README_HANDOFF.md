# Rep Bureau Codex Handoff Pack

This repository began under the product name Replio. The user-facing product is now **Rep Bureau**; internal `replio` identifiers may remain where renaming would add risk without user value.

## What is authoritative

See `docs/00_SOURCE_AUTHORITY.md`.

The **7 September 2026 founder amendment** in `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md` formally moves deal operations/admin automation into Phase 1 and supersedes older deferrals of invoice/payment operations.

The historical 136-decision register remains traceability, not permission to ignore the newer amendment.

## Current build objective

A production-ready creator-first Phase 1 where a user:

- connects Gmail and explicitly labels a commercial thread;
- receives a living Deal Workspace and commercial analysis;
- negotiates through Rep Bureau;
- has Rep Bureau automatically maintain the structured Deal/admin record;
- sees an operational pipeline and deadlines;
- reviews/approves pre-populated invoices;
- generates/sends invoice PDFs through Gmail with explicit confirmation;
- has due dates/outstanding/overdue states tracked;
- reviews/sends prepared payment chases;
- confirms payment and sees trustworthy financial status;
- benefits from an operational Founder OS with strict privacy boundaries.

## Pack map

- `AGENTS.md` — standing Codex rules and read order.
- `START_HERE_CODEX.md` — current assignment; do not restart M0.
- `docs/00_SOURCE_AUTHORITY.md` — current precedence/amendment rules.
- `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md` — mandatory expanded Phase 1 admin-automation specification.
- `docs/01_PRODUCT_SPEC.md` — current product requirements/boundary.
- `docs/02_UX_DESIGN.md` — design/responsiveness/accessibility.
- `docs/03_ARCHITECTURE.md` — existing runtime/jobs architecture; extended by doc 24.
- `docs/04_DATABASE.md` — existing schema/RLS model; extended by doc 24.
- `docs/05_GMAIL_INTEGRATION.md` — label-only Gmail flow; invoice/chase extension defined by doc 24.
- `docs/06_AI_SYSTEM.md` — workers/schemas/gateway; incremental admin fact extraction extension defined by doc 24.
- `docs/07_COMMERCIAL_LOGIC.md` — pricing/benchmarks/Score/EAE.
- `docs/08_BILLING.md` — Rep Bureau subscription billing; distinct from creator-to-brand invoices.
- `docs/09_FOUNDER_OS.md` — internal operating system.
- `docs/10_SECURITY_PRIVACY.md` — data access/OAuth/deletion/support mode; extended to invoice/payment privacy by doc 24.
- `docs/11_ANALYTICS_OBSERVABILITY.md` — analytics/ops/health.
- `docs/12_TESTING_QA.md` — base tests/launch gate; expanded acceptance in docs 19/24.
- `docs/13_PREFLIGHT.md` — accounts/secrets/founder actions.
- `docs/14_BUILD_PLAN.md` — current M9 admin-operations + M10 final-hardening plan.
- `docs/15_ROADMAP_OUT_OF_SCOPE.md` — what remains future after the amendment.
- `docs/16_UNRESOLVED_CONFIG.md` — pre-live sign-offs.
- `docs/17_DECISION_TRACEABILITY.md` — historical 136 decisions, subject to dated amendments.
- `docs/18_TECHNICAL_BASELINE.md` — technical verification rules.
- `docs/19_ACCEPTANCE_CRITERIA.md` — expanded module gates.
- `docs/21_CLOSED_BETA_RELEASE_CHECKLIST.md` — expanded release go/no-go.
- `docs/BUILD_STATUS.md` — Codex updates continuously with implementation progress.
