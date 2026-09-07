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

The repository already contains completed/substantially completed work for M0 repository/preflight, M1 data/Auth/design shell, M2 Gmail label ingestion, M3 Deal domain/workspace UX, M4 AI pipeline, M5 pricing/Score/strategy/reply/send, M6 creator learning/Insights/benchmark foundation, M7 Stripe subscription billing and M8 Founder OS.

**Do not rebuild these.** Inspect `docs/BUILD_STATUS.md` and reuse their schema/services/components/tests.

## Pre-amendment hardening work

Hardening work already completed before 7 September 2026 remains valuable and must not be discarded. Because Phase 1 scope has expanded, the final launch gate must be rerun after the new operational/email scope lands.

## M9 — Expanded Phase 1: Deal Operations, Admin Automation & Dedicated Creator Email — MANDATORY

Canonical detail:

- `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md`
- `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`

### M9A — Living operational Deal state

- extend incremental extraction to capture structured Deal deltas for fee, terms, deliverables, contacts/billing instructions and deadlines;
- preserve evidence/provenance and creator override priority;
- implement structured deadlines/operational states;
- automatically derive safe lifecycle transitions;
- ensure new selected Deal messages update the existing Deal rather than forcing manual entry;
- make fact/admin processing source-neutral across Gmail and dedicated Rep Bureau email.

**Exit:** selected messages from either supported source update the Deal correctly without duplicate CRM entry; conflicts/missing facts surface rather than being guessed.

### M9B — Pipeline and Action Dashboard

- accessible Kanban-esque operational Deal pipeline;
- stages through negotiation → content → ready to invoice → awaiting payment → paid/complete;
- mobile non-drag alternative;
- Deal cards show value, next action/deadline and meaningful status;
- Dashboard surfaces only creator-needed decisions/actions plus useful due/overdue/new-message information.

**Exit:** creator can understand every active Deal and what needs them in seconds.

### M9C — Invoice issuer profile + invoice preparation

- versioned creator-owned invoice issuer/business profile;
- secure handling of bank/payment instructions and tax identifiers supplied by creator;
- invoice schema/line items/sequence/idempotency;
- auto-populate invoice from trusted Deal/profile facts;
- review UI flags missing/conflicting/uncertain fields;
- never guess legal/tax identity.

**Exit:** an invoice-ready Deal opens to a substantially completed invoice, not a blank form.

### M9D — PDF generation + provider-neutral invoice send

- versioned invoice PDF generation/storage or reproducible immutable artifact strategy;
- secure workspace-scoped access/deletion;
- draft invoice email in creator voice;
- attach PDF to the correct Deal/payment conversation;
- send through Gmail when the Deal uses Gmail or from the creator's dedicated Rep Bureau address when it uses managed email;
- explicit creator review/confirmation before send;
- idempotent send and persistence of invoice/message state;
- automatic due-date calculation from confirmed payment terms.

**Exit:** review → approve invoice → review email+attachment → confirm send works end-to-end for both supported email sources without duplicate invoice numbers/files/messages.

### M9E — Payment tracking/reminders/chasing

- outstanding/due-soon/overdue/paid state engine;
- configurable reminder thresholds;
- consider latest payment-thread context/promised payment dates before drafting a chase;
- prepare contextual chase drafts, never auto-send in Phase 1;
- send through the Deal's active supported email source after creator confirmation;
- log chase history;
- low-friction `Paid` / `Still waiting` creator confirmation;
- never infer funds received.

**Exit:** overdue invoice automatically creates the right review action; creator can send a reviewed chase from Gmail or the dedicated address and can confirm payment.

### M9F — Creator financial overview

- distinguish Agreed, Ready to invoice, Invoiced, Outstanding, Overdue and Received;
- keep currencies separate unless versioned FX source exists;
- update views from Deal/invoice/payment state automatically.

**Exit:** financial status is trustworthy and never treats expected money as cash received.

### M9G — Deal-ops security/ops/tests

- RLS/access matrix for new Deal/invoice/payment tables/storage;
- deletion/purge of invoice/payment private data/artifacts;
- no private payment/bank details in logs/analytics/Founder OS without Support Mode;
- durable/idempotent jobs for Deal ops/invoice/reminders as required;
- unit/integration/E2E tests from `docs/24...` and `docs/19_ACCEPTANCE_CRITERIA.md`;
- update Founder OS operational health only as needed without exposing private content.

**Exit:** Deal-ops acceptance suite green and existing M0–M8 critical journeys remain green.

### M9H — Dedicated Rep Bureau creator email address

- choose/verify a current provider or provider combination supporting authenticated inbound webhooks and reliable outbound sending on a Rep Bureau-controlled domain;
- keep provider mechanics behind an internal managed-email abstraction;
- add configurable inbound domain/address allocation with one active primary address per creator workspace;
- support direct inbound brand enquiries and ordinary forwarded brand emails without Gmail OAuth;
- extend `deal_threads` / normalized email records provider-neutrally rather than creating a parallel Deal system;
- preserve direct-vs-forwarded provenance and prevent ambiguous forwarded parsing from sending to the wrong recipient;
- support creator-approved outbound negotiation replies, invoice sends and payment chases from the dedicated address;
- preserve threading/message-idempotency and duplicate protection when Gmail and managed email coexist;
- securely handle inbound attachments with conservative size/type limits, workspace isolation, signed access and deletion;
- implement public-address spam/abuse/rate/cost controls so arbitrary inbound mail cannot trigger unbounded AI spend;
- configure/verify current production sender authentication/deliverability requirements (including appropriate SPF/DKIM/DMARC) before external beta;
- add Founder OS health/volume/error visibility without exposing message bodies;
- update onboarding/settings to offer `Connect Gmail` or `Use my Rep Bureau email`, with Gmail optional for the latter.

**Exit:** a creator with no Gmail OAuth connection can receive or forward a brand enquiry, negotiate, send an invoice, chase payment and reach creator-confirmed payment entirely through the dedicated Rep Bureau address; all tests in `docs/25...` pass.

## M10 — Final hardening + closed beta gate

Rerun/extend the prior hardening work after all of M9:

- full unit/integration/RLS/E2E suite;
- AI eval corpus including billing/payment and forwarded-message extraction cases;
- accessibility/mobile audit including pipeline/invoice/payment/email-source journeys;
- performance profiling;
- inbound/outbound email rate limits, spam and abuse/cost controls;
- security/privacy review including managed-email attachments and generated invoice artifacts;
- sender-domain deliverability configuration verification;
- backup/restore/rollback test;
- analytics privacy audit;
- production monitoring;
- release checklist;
- beta-user feedback fixes.

**Exit:** updated Launch Readiness Gate passes for the expanded Phase 1.

## Scope protection

The new M9 features are **not roadmap feature creep**. They are founder-approved Phase 1 scope.

When Codex encounters features beyond `docs/24...` and `docs/25...`, create cheap extension points only when they do not complicate Phase 1 and record future items in `docs/15_ROADMAP_OUT_OF_SCOPE.md`.
