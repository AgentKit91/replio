# Build Plan and Codex Execution Model

## Operating model

Codex should continue autonomously through the current milestone: inspect existing code, implement, migrate, test, fix, re-test, update documentation/status and make reviewable commits. Do not restart completed foundations and do not stop after scaffolding.

After every meaningful tranche update `docs/BUILD_STATUS.md` with current milestone, completed acceptance items, tests/results, migrations/deployments, known issues, next tasks and genuine founder-owned blockers.

## Branch/release discipline

- `main` = known deployable/stable state.
- Use reviewable branches/PRs.
- Preview deployments for review.
- Merge only with required CI green.
- Production releases reversible.

## M0–M8 — Existing foundation

The repository already contains completed/substantially completed work for:

- M0 repository/preflight;
- M1 data/Auth/design shell;
- M2 Gmail label ingestion;
- M3 Deal domain/workspace UX;
- M4 AI pipeline;
- M5 pricing/Score/strategy/reply/send (live consent-gated proof may remain);
- M6 creator learning/Insights/benchmark foundation;
- M7 Stripe subscription billing;
- M8 Founder OS.

**Do not rebuild these.** Inspect `docs/BUILD_STATUS.md` and reuse their schema/services/components/tests.

## Pre-amendment M9 hardening work

Hardening work already completed before 7 September 2026 remains valuable and must not be discarded. Because Phase 1 scope has expanded, the final launch gate must be rerun after the new operational scope lands.

## M9 — Deal Operations & Admin Automation — MANDATORY PHASE 1

Canonical detail: `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md`.

### M9A — Living operational Deal state

- extend incremental extraction to capture structured Deal deltas for fee, terms, deliverables, contacts/billing instructions and deadlines;
- preserve evidence/provenance and creator override priority;
- implement structured deadlines/operational states;
- automatically derive safe lifecycle transitions;
- ensure new selected-thread messages update the existing Deal rather than forcing manual entry.

**Exit:** fixture/live-safe selected messages update the Deal record correctly without duplicate CRM entry; conflicts/missing facts surface rather than being guessed.

### M9B — Pipeline and Action Dashboard

- accessible Kanban-esque operational Deal pipeline;
- stages through negotiation → content → ready to invoice → awaiting payment → paid/complete;
- mobile non-drag alternative;
- Deal cards show value, next action/deadline and meaningful status;
- Dashboard surfaces only creator-needed decisions/actions plus useful due/overdue information.

**Exit:** creator can understand every active Deal and what needs them in seconds.

### M9C — Invoice issuer profile + invoice preparation

- versioned creator-owned invoice issuer/business profile;
- secure handling of bank/payment instructions and tax identifiers supplied by creator;
- invoice schema/line items/sequence/idempotency;
- auto-populate invoice from trusted Deal/profile facts;
- review UI flags missing/conflicting/uncertain fields;
- never guess legal/tax identity.

**Exit:** an invoice-ready Deal opens to a substantially completed invoice, not a blank form.

### M9D — PDF generation + Gmail invoice send

- versioned invoice PDF generation/storage or reproducible immutable artifact strategy;
- secure workspace-scoped access/deletion;
- draft invoice email in creator voice;
- attach PDF to correct Gmail Deal/payment thread;
- explicit creator review/confirmation before send;
- idempotent send and persistence of invoice/message state;
- automatic due-date calculation from confirmed payment terms.

**Exit:** review → approve invoice → review email+attachment → confirm send works end-to-end without duplicate invoice numbers/files/messages.

### M9E — Payment tracking/reminders/chasing

- outstanding/due-soon/overdue/paid state engine;
- configurable reminder thresholds;
- consider latest payment-thread context/promised payment dates before drafting a chase;
- prepare contextual chase drafts, never auto-send in Phase 1;
- log chase history;
- low-friction `Paid` / `Still waiting` creator confirmation;
- never infer funds received.

**Exit:** overdue invoice automatically creates the right review action; creator can confirm payment and close/update the Deal.

### M9F — Creator financial overview

- distinguish Agreed, Ready to invoice, Invoiced, Outstanding, Overdue and Received;
- keep currencies separate unless versioned FX source exists;
- update views from Deal/invoice/payment state automatically.

**Exit:** financial status is trustworthy and never treats expected money as cash received.

### M9G — Security/ops/tests

- RLS/access matrix for new tables/storage;
- deletion/purge of invoice/payment private data/artifacts;
- no private payment/bank details in logs/analytics/Founder OS without Support Mode;
- durable/idempotent jobs for Deal ops/invoice/reminders as required;
- unit/integration/E2E tests from `docs/24...` and `docs/19_ACCEPTANCE_CRITERIA.md`;
- update Founder OS operational health only as needed without exposing private content.

**Exit:** M9 acceptance suite green and existing M0–M8 critical journeys remain green.

## M10 — Final hardening + closed beta gate

Rerun/extend the prior hardening work after M9:

- full unit/integration/RLS/E2E suite;
- AI eval corpus including billing/payment extraction cases;
- accessibility/mobile audit including pipeline/invoice/payment journeys;
- performance profiling;
- rate limits/abuse;
- security/privacy review including generated invoice artifacts;
- backup/restore/rollback test;
- analytics privacy audit;
- production monitoring;
- release checklist;
- beta-user feedback fixes.

**Exit:** updated Launch Readiness Gate passes for the expanded Phase 1.

## Scope protection

The new M9 is **not roadmap feature creep**. It is founder-approved Phase 1 scope.

When Codex encounters features beyond `docs/24...`, create cheap extension points only when they do not complicate Phase 1 and record future items in `docs/15_ROADMAP_OUT_OF_SCOPE.md`.
