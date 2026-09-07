# Rep Bureau Codex Handoff Pack

This repository began under the product name Replio. The user-facing product is now **Rep Bureau**; internal `replio` identifiers may remain where renaming would add risk without user value.

## What is authoritative

See `docs/00_SOURCE_AUTHORITY.md`.

Two **7 September 2026 founder amendments** are mandatory Phase 1 scope:

- `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md` — promotes end-to-end Deal admin, invoicing and payment operations;
- `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md` — adds an optional dedicated Rep Bureau commercial email address so Gmail is not required.

The historical 136-decision register remains traceability, not permission to ignore newer amendments.

## Current build objective

A production-ready creator-first Phase 1 where a user can choose either/both supported email routes:

- **Gmail:** connect Gmail and explicitly label a commercial thread; or
- **Rep Bureau email:** receive a dedicated commercial address that brands can contact directly or that the creator can forward brand emails into, without Gmail OAuth.

From either source the creator receives the same product journey:

- living Deal Workspace and commercial analysis;
- negotiation drafting/sending with explicit creator approval;
- automatic structured Deal/admin maintenance;
- operational pipeline and deadlines;
- pre-populated invoice review;
- versioned invoice PDF generation and creator-approved send through the Deal's email source;
- due-date/outstanding/overdue tracking;
- prepared payment chases with creator-approved send;
- creator-confirmed payment and trustworthy financial status;
- operational Founder OS with strict privacy boundaries.

A creator using only the dedicated Rep Bureau address must be able to complete the whole Deal lifecycle without connecting Gmail.

## Pack map

- `AGENTS.md` — standing Codex rules and read order.
- `START_HERE_CODEX.md` — current assignment; do not restart M0.
- `docs/00_SOURCE_AUTHORITY.md` — current precedence/amendment rules.
- `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md` — mandatory expanded Phase 1 admin-automation specification.
- `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md` — mandatory dedicated creator email specification.
- `docs/01_PRODUCT_SPEC.md` — current product requirements/boundary.
- `docs/02_UX_DESIGN.md` — design/responsiveness/accessibility.
- `docs/03_ARCHITECTURE.md` — existing runtime/jobs architecture; extended by docs 24/25.
- `docs/04_DATABASE.md` — existing schema/RLS model; extended by docs 24/25.
- `docs/05_GMAIL_INTEGRATION.md` — Gmail-specific label-only flow; it is one supported email source, not the only Phase 1 source.
- `docs/06_AI_SYSTEM.md` — workers/schemas/gateway; incremental admin fact extraction applies to normalized Deal messages from either source.
- `docs/07_COMMERCIAL_LOGIC.md` — pricing/benchmarks/Score/EAE.
- `docs/08_BILLING.md` — Rep Bureau subscription billing; distinct from creator-to-brand invoices.
- `docs/09_FOUNDER_OS.md` — internal operating system; managed-email provider health is added by doc 25.
- `docs/10_SECURITY_PRIVACY.md` — data access/OAuth/deletion/support mode; docs 24/25 add invoice/payment/managed-email privacy requirements.
- `docs/11_ANALYTICS_OBSERVABILITY.md` — analytics/ops/health.
- `docs/12_TESTING_QA.md` — base tests/launch gate; expanded acceptance in docs 19/24/25.
- `docs/13_PREFLIGHT.md` — accounts/secrets/founder actions; managed email requires provider/domain configuration before live use.
- `docs/14_BUILD_PLAN.md` — current M9 expanded Phase 1 + M10 final-hardening plan.
- `docs/15_ROADMAP_OUT_OF_SCOPE.md` — what remains future after both amendments.
- `docs/16_UNRESOLVED_CONFIG.md` — pre-live sign-offs.
- `docs/17_DECISION_TRACEABILITY.md` — historical 136 decisions, subject to dated amendments.
- `docs/18_TECHNICAL_BASELINE.md` — technical verification rules.
- `docs/19_ACCEPTANCE_CRITERIA.md` — expanded module gates.
- `docs/21_CLOSED_BETA_RELEASE_CHECKLIST.md` — expanded release go/no-go.
- `docs/BUILD_STATUS.md` — Codex updates continuously with implementation progress.
