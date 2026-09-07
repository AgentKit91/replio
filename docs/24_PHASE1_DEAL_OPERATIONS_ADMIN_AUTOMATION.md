# Phase 1 Deal Operations & Admin Automation — Founder Scope Amendment

**Effective:** 7 September 2026  
**Status:** LOCKED — mandatory Phase 1 / launch scope  
**Product name:** Rep Bureau (existing internal `replio` repository, database, queue and code identifiers may remain unless changing them is low-risk and necessary for user-facing correctness)

This document is a founder-approved scope amendment. Where it conflicts with the earlier Canonical Decision Register or earlier MVP exclusions, **this document wins**. It specifically supersedes the earlier deferral of invoice generation, payment tracking/chasing and post-negotiation deal administration.

## 1. Product principle

**Rep Bureau does the admin. The creator makes the decisions.**

Target product behaviour is approximately **90% admin handled by Rep Bureau / 10% creator review and approval**.

The user should not have to operate a CRM manually. Rep Bureau must progressively construct, maintain and act on a structured Deal record from the selected Gmail conversation and creator-owned profile data.

### Automation boundary

**Automatic by default internally:**

- extract facts from selected Deal communications;
- create/update structured Deal fields;
- preserve source/evidence/provenance;
- calculate dates and payment deadlines;
- move safe internal lifecycle states;
- create reminders/tasks;
- update expected/outstanding/received financial views;
- prepare invoice data, invoice PDFs and draft emails;
- prepare payment-chase drafts;
- detect missing/conflicting information;
- surface only decisions/actions that need the creator.

**Creator approval by default externally:**

- send an email;
- issue/send an invoice;
- send a payment reminder/chase;
- accept or confirm a commercial term to a brand;
- make another consequential external representation on the creator's behalf.

Do not auto-send external communications in Phase 1 unless a later explicit founder decision adds an opt-in automation mode.

## 2. No duplicate admin

Manual data entry is a fallback, not the primary workflow.

> If information required to administer a Deal already exists in a selected email thread, a linked Deal thread, an approved creator profile field, a prior Deal record or another trusted Rep Bureau source, the creator must not be asked to enter it again.

Examples:

- if the brand agrees £2,200 in email, update the current/agreed fee automatically;
- if the brand says `draft by 10 October`, record the draft deadline;
- if the brand says `post by 14 October`, record the live date;
- if the brand says `invoice Example Ltd, 22 Example Street, PO 49284, Net 30`, populate the invoice record automatically;
- if the invoice is sent on 19 October on Net 30 terms, calculate the due date automatically;
- if the creator later corrects a field, the creator-owned value outranks future AI extraction unless the creator changes it again.

## 3. Living Deal Record

A Deal persists beyond negotiation and becomes the operational record for the collaboration.

### Commercial state

Track, where present:

- initial offer;
- current offer;
- agreed/final fee;
- currency;
- platforms;
- deliverables and quantities;
- usage/licensing duration;
- territory;
- exclusivity;
- paid media / whitelisting;
- revisions/approval rounds;
- expenses/additional fees;
- payment terms.

### People and billing

Track, where present:

- brand;
- agency/intermediary;
- primary contact;
- contact email;
- billing/legal entity;
- billing address;
- accounts-payable/billing contact;
- PO / purchase-order / campaign reference;
- brand-specific invoice instructions.

### Campaign operations

Track, where present:

- brief/status;
- content/draft deadline;
- approval deadline;
- posting/live date;
- campaign end date;
- deliverable completion status;
- live URLs where supplied/confirmed.

### Contract metadata

Phase 1 may track:

- contract requested/received;
- contract attachment reference;
- signed/awaiting-signature status;
- final contract date/version metadata.

A full legal contract AI review/generation product remains out of scope unless separately promoted. Do not present legal certainty.

### Invoice state

Track:

- invoice issuer profile/version;
- invoice number;
- invoice date;
- billing entity/address;
- billing contact;
- PO/reference;
- line items/deliverable description;
- subtotal/tax/total as applicable;
- currency;
- payment terms;
- due date;
- invoice PDF version;
- draft/approved/sent date;
- Gmail message/thread reference.

### Payment state

Track:

- amount expected;
- amount invoiced;
- due date;
- outstanding amount;
- status: `not_ready`, `ready_to_invoice`, `invoice_draft`, `invoice_sent`, `awaiting_payment`, `due_soon`, `overdue`, `payment_query`, `paid`, `written_off` (written-off only by explicit creator action);
- reminder/chase history;
- any brand-promised payment date;
- user-confirmed received date;
- days-to-payment.

Do not infer that money has arrived merely because the due date passed or a brand says it has been processed. Final `paid` status requires creator confirmation in Phase 1 unless a later verified bank/payment integration is explicitly added.

## 4. Provenance and field ownership

Rep Bureau must know **why** a value exists.

Every material auto-populated field needs provenance sufficient to debug/review it:

- source type (`gmail_message`, `creator_profile`, `creator_edit`, `system_calculation`, `approved_ai`, etc.);
- source entity/message id where relevant;
- observed/extracted timestamp;
- internal confidence where AI-derived;
- short evidence locator/excerpt for AI-extracted material facts;
- ownership/priority.

Priority remains:

`creator explicit edit > creator-approved AI value > high-confidence current extraction > older extraction/import`.

When a new message appears to supersede an earlier term, preserve history rather than silently deleting the prior fact.

## 5. Deal pipeline / Kanban-esque UX

The Deals area must provide a calm operational pipeline. It may be implemented as a Kanban board, responsive stage groups, or an equivalent accessible layout; mobile must not rely on horizontal drag-only interaction.

Recommended creator-facing stages:

1. **New / Reviewing**
2. **Negotiating**
3. **Agreed / Contract**
4. **Content in progress**
5. **Ready to invoice**
6. **Awaiting payment**
7. **Paid / Complete**

Internal states may remain more granular. A Deal card should show only the most useful information: brand, value, next action/deadline, operational status and risk/action badge.

Safe state changes should happen automatically from evidence. The creator may always correct a stage/status.

## 6. Action Dashboard

The Dashboard should increasingly answer `What actually needs me?` rather than showing admin the system can handle itself.

Examples:

- `Approve invoice for £2,200 — all details found`;
- `Draft due tomorrow — no action needed from Rep Bureau`;
- `£2,200 due Friday — no action needed`;
- `£2,200 overdue by 2 days — payment chase drafted`;
- `Brand asked for a revised posting date — review change`;
- `Missing billing address — I couldn't safely find it`.

Do not create noisy reminders for information Rep Bureau can resolve itself.

## 7. Invoice workflow

### Invoice issuer profile

Collect creator/business invoice identity progressively and preferably once:

- legal/trading name;
- address;
- contact email;
- tax/VAT registration details where applicable;
- bank/payment instructions supplied by the creator;
- default invoice prefix/sequence rules;
- default payment terms if the brand has not specified different agreed terms.

Do not guess legal/tax identifiers. Missing legally/materially required issuer information should block final invoice approval with a concise request.

### Preparation

When a Deal becomes invoice-ready, Rep Bureau should assemble the invoice from existing Deal data. If all required data is present, the first creator-facing state should be **an already-prepared invoice**, not an empty form.

### Review

Present a concise review surface with source-aware warnings for uncertain/conflicting fields. The creator may edit any value before approval.

### Generation and sending

After explicit approval:

1. generate a versioned PDF invoice;
2. attach it to a drafted Gmail message in the appropriate Deal/payment thread;
3. generate a concise creator-voice invoice email;
4. show the draft and attachment for final send confirmation;
5. send only after explicit creator confirmation;
6. persist Gmail message id, invoice version and sent timestamp idempotently;
7. calculate and record the due date;
8. move the Deal/payment state to `awaiting_payment`.

System-generated invoice PDFs are an explicit Phase 1 exception to the earlier `attachments remain in Gmail` rule. Store generated invoice artifacts in secure workspace-scoped storage with RLS/signed access or generate reproducibly from an immutable invoice snapshot; never expose one creator's invoice to another.

## 8. Payment tracking and chasing

### Due-date logic

Calculate due date from the approved invoice date and confirmed payment terms. Preserve both the rule (`Net 30`, explicit calendar date, etc.) and calculated date.

If payment terms are ambiguous, do not guess silently; surface a concise review item.

### Reminder ladder

Use configurable thresholds. A sensible Phase 1 default can prepare actions at:

- due soon (informational, no external message needed);
- first business day overdue;
- approximately 7 days overdue;
- later escalation as configured.

The reminder engine should consider the actual thread: if the brand has already promised payment on a later date, do not blindly produce an inappropriate chase. Surface the promised date and schedule the next sensible action.

### Drafting

Rep Bureau prepares the chase using:

- invoice number;
- amount;
- due date;
- days overdue;
- previous chase history;
- creator voice;
- latest relevant brand/payment message.

The creator reviews/tweaks and sends. Each sent reminder is logged against the Deal and updates the next review date.

### Confirming payment

At an appropriate point, surface a low-friction action:

`Has £2,200 from Example Ltd arrived?`

- `Yes — mark paid`
- `Still waiting`

`Yes` records creator-confirmed payment date, updates financial reporting and can complete the Deal when other requirements are satisfied. `Still waiting` keeps it outstanding and continues the reminder logic.

## 9. Creator financial overview

Creator-facing money views must distinguish:

- **Agreed** — commercial value agreed but not necessarily invoiced;
- **Ready to invoice**;
- **Invoiced**;
- **Outstanding**;
- **Overdue**;
- **Received** — creator-confirmed payment.

Never label expected/agreed money as cash received.

Keep currencies separate unless a versioned FX conversion source is intentionally used.

## 10. AI and cost architecture

Do not add a gratuitous expensive AI worker for every admin action.

Extend the existing incremental Commercial Extractor / analysis fact pipeline so new selected-thread messages can emit **structured Deal deltas** for commercial, campaign, billing and payment facts. Reuse those validated facts across analysis, pipeline, invoice and reminders.

Use deterministic code for:

- due-date calculations;
- state derivation where rules are unambiguous;
- invoice totals;
- invoice numbering/formatting;
- reminder scheduling;
- financial aggregation;
- idempotency.

Use AI where language understanding/drafting is genuinely needed:

- extracting facts from unstructured selected emails;
- detecting likely supersession/conflict;
- drafting invoice/payment emails in creator voice;
- deciding whether a generic chase would be contextually inappropriate (with deterministic guardrails).

Every AI call remains budgeted, cached/diff-aware and schema-validated.

## 11. Suggested data-model extension

Codex may adjust names to match existing migrations, but Phase 1 needs equivalent concepts.

### Deal operations

- `deal_deadlines` — type, date/time, status, source/evidence, confidence, current/version;
- extend `deal_deliverables` with operational completion/due status where not already present;
- extend `deal_terms`/facts for billing entity, payment terms, PO/reference and invoice instructions where appropriate.

### Invoice issuer

- `invoice_issuer_profiles` — workspace-scoped versioned creator-owned billing identity/payment instructions;
- never infer legal/tax identity.

### Invoices

- `deal_invoices` — immutable-ish approved invoice snapshot plus lifecycle state;
- `deal_invoice_line_items`;
- `invoice_artifacts` or secure generated-file reference/version;
- unique workspace invoice sequence/idempotency constraints.

### Payments

- `deal_payments` or equivalent payment-status record;
- `payment_status_events` preserving history;
- `payment_reminders` / chase records with scheduled/prepared/sent/cancelled states;
- creator-confirmed received timestamp and amount.

### Admin actions

- `deal_admin_actions` or reuse `notifications/activity_events` to represent system-prepared review/approval tasks without building a generic task manager.

Every exposed row must be workspace-isolated by RLS. Generated invoice files must follow the same tenancy/deletion boundary as Deal data.

## 12. Background jobs / realtime / idempotency

Extend durable job semantics for:

- incremental Deal fact extraction after selected Gmail changes;
- deadline/reminder scheduling;
- invoice PDF generation if not synchronous/reliably bounded;
- payment status review/reminder preparation.

Suggested existing/new queue concepts can include `deal-ops`, `invoice-generation`, `payment-reminders`, but prefer reusing the current worker infrastructure when that reduces complexity.

Idempotency examples:

- one approved invoice version must not generate multiple invoice numbers/files on retry;
- one send intent must not send the invoice twice;
- a reminder retry must not send twice;
- repeated Gmail messages/history events must not duplicate facts/deadlines;
- state transitions must be replay-safe.

Realtime should update pipeline/status, action cards, invoice readiness and payment status without full-page polling.

## 13. Security, privacy and deletion

Invoice issuer details, bank/payment instructions, invoices and payment history are private creator business data.

- keep them workspace-scoped;
- exclude raw/private values from analytics;
- founder cannot inspect them without valid Support Mode where private content access is required;
- do not log bank/payment details;
- signed/temporary file URLs only where applicable;
- permanent Deal/account purge removes generated invoice artifacts and private payment records subject to legally required product policies decided before launch;
- no bank scraping/open-banking integration in this scope.

## 14. Phase 1 exclusions that remain

Still out of scope unless separately promoted:

- full-inbox automatic opportunity discovery;
- Outlook;
- agency/team mode;
- full accounting/bookkeeping/general ledger;
- tax filing/advice;
- expense accounting;
- bank reconciliation/open banking;
- automatic detection of received funds from bank accounts;
- full legal contract AI review/generation;
- automatic external sending without creator approval;
- opportunity discovery/outreach;
- generic task/project-management product;
- Creator Score.

## 15. Definition of done / acceptance

The expanded Phase 1 is not done until all of the following work end-to-end:

1. A selected brand thread automatically updates fee, deliverables, material terms and deadlines as messages arrive.
2. Billing instructions contained in the selected Deal conversation populate the invoice record without duplicate creator entry.
3. Creator corrections override AI/imports and remain authoritative.
4. A Deal can move through an operational pipeline from negotiation to paid/completed.
5. When invoice-ready, Rep Bureau presents a substantially completed invoice for review rather than a blank form.
6. Creator approval produces the correct versioned PDF and a drafted email with the PDF attached.
7. Sending is explicit, idempotent and persists the message/invoice state.
8. Payment terms automatically produce the correct due date.
9. Due/overdue states surface without the creator manually monitoring dates.
10. Overdue payment produces an appropriate pre-drafted chase for review; it is not auto-sent.
11. Creator can mark `Paid` or `Still waiting`; received revenue never changes to paid merely from inference.
12. Dashboard/pipeline financial summaries distinguish agreed, invoiced, outstanding, overdue and received.
13. Critical flows work on mobile and are keyboard accessible; Kanban cannot be drag-only.
14. RLS/security/idempotency/deletion tests cover invoices/payment operations.
15. Existing Gmail, negotiation, AI, billing and Founder OS functionality remains green.
16. Impacted M9 hardening/security/performance/accessibility checks are rerun after this scope lands.

## 16. Codex execution rule

This amendment is **not a roadmap suggestion**. It is mandatory launch scope.

Codex should inspect the existing M0–M9 implementation, reuse what already exists, add the smallest maintainable schema/worker/UI extensions necessary, test them thoroughly, update `docs/BUILD_STATUS.md`, and continue autonomously until a genuine founder-owned authorization/legal blocker is reached.
