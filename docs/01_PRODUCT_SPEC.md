# Rep Bureau Phase 1 Product Specification

## 1. Product definition

Rep Bureau is an **AI commercial manager and deal-operations assistant for individual creators**. The existing codebase may still contain the historical name Replio.

The offer analyser/negotiation assistant is the entry point. The Phase 1 product must support the creator from selected brand email through negotiation, agreed terms, deliverables/deadlines, invoicing, payment tracking/chasing and creator-confirmed receipt.

It is not a chatbot, generic CRM, accounting product or automatic inbox scanner.

### Primary promise

**More money. Better deals. Less admin.**

### Core operating principle

**Rep Bureau does the admin. The creator makes the decisions.**

Target roughly 90% administrative work handled automatically and 10% creator review/approval.

- Internal/admin actions: automatic where safe.
- Consequential external actions: creator approval by default.
- Manual entry: fallback only when trusted information cannot be found or safely inferred.

### Core success journey

A creator can:

1. Sign in with Google and connect Gmail.
2. Apply the explicit Rep Bureau/Replio label to a real brand collaboration thread.
3. Have only that chosen thread imported and analysed.
4. Open a living Deal Workspace while analysis progresses.
5. See Rep Bureau Score, current offer, fee recommendations, risks, strategy and a suggested reply.
6. Edit/approve/send through Gmail.
7. Have future selected-thread messages update the same Deal automatically.
8. Have Rep Bureau continuously track fee, deliverables, rights, deadlines, contacts, billing instructions and payment terms with evidence/provenance.
9. See the Deal move through a calm operational pipeline from negotiation to paid/completed.
10. When invoice-ready, review an already-prepared invoice populated from existing Deal/profile information.
11. Approve invoice generation and then review/confirm the drafted Gmail send with PDF attached.
12. Have payment due date/status tracked automatically.
13. Receive a prepared overdue chase when needed rather than manually monitoring invoices.
14. Mark payment `Paid` or `Still waiting`; Rep Bureau never pretends expected money has been received.
15. See agreed, invoiced, outstanding, overdue and received values clearly distinguished.
16. Close the Deal with outcome recap and structured commercial learning.

The detailed operational requirements are canonical in `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md`.

## 2. Product constitution

- **Rep Bureau advises. The creator decides.**
- **Rep Bureau does the admin.** Do not turn automation into forms the creator must maintain.
- **Privacy is a feature.** Analyse only explicitly selected/labeled Gmail conversations.
- **Every important recommendation/fact is explainable.** Use concise evidence/provenance, not hidden reasoning.
- **Never invent commercial/billing/payment facts.** Confirmed, Missing and Inferred remain distinct.
- **User ownership always wins.** User input > approved AI > automatic extraction > imported/older data.
- **Every field must earn its place.** Ask only when necessary and explain why.
- **AI is almost invisible.** Product should feel like a proactive commercial manager.
- **Rep Bureau works while the creator is not looking.** Background jobs react to selected-thread changes and operational dates.
- **Every AI call must justify its cost.** Cache/diff/reuse and prefer deterministic code.
- **No silent failures.** Important failures are visible/recoverable.
- **No accidental scope creep beyond the current Phase 1.**

## 3. Navigation

Use creator mental models:

- **Dashboard** — what needs the creator now, active deadlines/payment actions, Estimated Additional Earnings.
- **Deals** — operational pipeline plus list/filter/search.
- **Brands** — brand history, contacts, private notes/context.
- **Insights** — earnings uplift, outcomes and creator financial/deal trends.
- **Train Rep Bureau** — creator profile, goals, rates, red lines, invoice issuer profile, voice/preferences.
- **Settings** — subscription billing, Gmail, notifications, security/account.

## 4. Onboarding and progressive enrichment

Target about two minutes to first value. Collect only essential creator identity/market/platform data, Gmail connection and explicit selected-thread consent.

Later prompts may collect engagement, average views, prior deals, rate cards, goals, red lines, voice, and invoice-issuer details when invoicing becomes relevant.

Never show a generic profile-completion percentage. Frame prompts by benefit.

## 5. Dashboard

The Dashboard is an **Action Dashboard**, not a chart wall.

Priority order:

1. Action required from creator.
2. Material commercial opportunity.
3. Risk/conflict/missing fact that cannot be safely resolved.
4. Time-sensitive deadline/payment state.
5. Understated success/win.

Examples of good cards:

- `Approve invoice for £2,200 — all details found`;
- `£2,200 due Friday — no action needed`;
- `£2,200 overdue — chase drafted`;
- `Draft due tomorrow`;
- `Billing address missing — review needed`.

Do not notify the creator about admin Rep Bureau can complete itself.

## 6. Deal Workspace

Desktop may use analysis/operations + conversation panes; mobile must provide equivalent information without cramped side-by-side panes.

### Analysis order

1. Rep Bureau/Replio Score
2. Brand Offer
3. Recommended Fee: Ideal Ask / Expected Settlement / Minimum Worthwhile Fee
4. Biggest Risks / Missing Terms
5. Suggested Reply
6. Negotiation Strategy

Important outputs have collapsed `Why?` evidence.

### Conversation

- full selected Gmail thread oldest-to-newest;
- sent replies appear after confirmed Gmail send;
- new messages update same Deal;
- evidence links can jump to relevant passages;
- composer integrated with thread.

### Operations

The same Deal also exposes, progressively and without duplicative entry:

- current fee/terms/deliverables;
- deadlines;
- contract metadata/status;
- invoice readiness/status;
- payment due/status;
- next action;
- provenance when a value is uncertain/conflicting.

## 7. Deal lifecycle and pipeline

Internal state can remain granular. Creator-facing operational stages should cover:

- New / Reviewing
- Negotiating
- Agreed / Contract
- Content in progress
- Ready to invoice
- Awaiting payment
- Paid / Complete

The pipeline may be Kanban-esque but must remain accessible and usable on mobile without drag-only interaction.

Safe internal state transitions happen automatically from evidence/rules; creator correction always remains possible.

One Deal equals one commercial agreement and may link multiple related Gmail threads with explicit roles.

## 8. Invoicing and payment operations

Mandatory Phase 1 scope is defined in `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md`.

Key rules:

- invoice details are pre-populated from Deal/profile data;
- creator never re-enters information already known;
- uncertain legal/tax/billing details are not guessed;
- creator reviews invoice before approval;
- approved invoice generates a versioned PDF;
- invoice email is drafted with PDF attached and requires explicit send confirmation;
- payment terms calculate due date automatically;
- overdue states prepare contextual chase drafts;
- creator confirms `Paid` / `Still waiting`;
- received money is never inferred.

## 9. Creator Profile / Train Rep Bureau

Creator-owned facts include profile/platform metrics, currency, rate cards, goals, red lines, industries/categories, working/payment preferences and invoice issuer information.

Observed patterns never silently become creator rules. Rep Bureau may suggest a preference and the creator accepts/rejects.

Voice Profile remains private and learns from approved/sent emails and edits to reduce future editing.

No Creator Score.

## 10. Brands, contacts, notes and history

Global Brand records contain only safe shared identity/intelligence. Creator-specific contacts, notes, relationships, Deal content, invoices and payment history remain private/workspace-scoped.

Deal/Brand notes remain private/searchable.

Incoming Gmail attachments remain provider references in Phase 1. **System-generated invoice PDFs are the explicit exception** defined in the Phase 1 admin amendment.

Meaningful AI analyses are immutable snapshots; significant actions create traceable events subject to deletion/privacy rules.

## 11. Notifications and search

Only notify for Action Required, Opportunity, Risk or Success. Payment/deadline notifications must be actionable and non-noisy.

Search remains deterministic across Deals, Brands, Contacts and Notes with useful filters; AI/natural-language search remains future scope.

## 12. Phase 1 exclusions that remain

Do not build:

- whole-inbox automatic opportunity detection;
- Rep Bureau-managed custom inbox addresses;
- Outlook;
- agency/team/shared-workspace UI;
- full accounting/bookkeeping/general ledger;
- tax filing/advice;
- expense accounting;
- open banking/bank reconciliation/automatic payment detection;
- full legal contract AI review/generation;
- automatic external email/invoice/chase sending without creator approval;
- calendar integration;
- media kit generation;
- opportunity discovery/outreach;
- natural-language/AI search;
- Creator Score;
- fine-tuning;
- Founder AI/chat assistant.
