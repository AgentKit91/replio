# Rep Bureau Phase 1 Product Specification

## 1. Product definition

Rep Bureau is an **AI commercial manager and deal-operations assistant for individual creators**. The existing codebase may still contain the historical name Replio.

The offer analyser/negotiation assistant is the entry point. The Phase 1 product must support the creator from a selected brand conversation through negotiation, agreed terms, deliverables/deadlines, invoicing, payment tracking/chasing and creator-confirmed receipt.

It is not a chatbot, generic CRM, accounting product or automatic external-inbox scanner.

### Primary promise

**More money. Better deals. Less admin.**

### Core operating principle

**Rep Bureau does the admin. The creator makes the decisions.**

Target roughly 90% administrative work handled automatically and 10% creator review/approval.

- Internal/admin actions: automatic where safe.
- Consequential external actions: creator approval by default.
- Manual entry: fallback only when trusted information cannot be found or safely inferred.

### Supported Deal email sources

Phase 1 supports two first-class sources:

1. **Connected Gmail** — creator applies the explicit Rep Bureau/Replio label to a commercial thread; only labelled/known Deal threads are imported and synced.
2. **Dedicated Rep Bureau email** — creator receives an optional Rep Bureau-controlled commercial email address that brands can contact directly or that the creator can forward brand emails into. Gmail OAuth is not required for this route.

A creator may use Gmail, the dedicated address, or both. The detailed dedicated-address requirements are canonical in `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`.

### Core success journey

A creator can:

1. Sign in with Google.
2. Choose `Connect Gmail`, `Use my Rep Bureau email`, or both.
3. If using Gmail, apply the explicit Rep Bureau/Replio label to a real brand collaboration thread and have only that chosen thread imported.
4. If using the dedicated address, publish it for brands or forward a brand email to it without granting Rep Bureau access to the rest of their mailbox.
5. Open a living Deal Workspace while analysis progresses.
6. See Rep Bureau Score, current offer, fee recommendations, risks, strategy and a suggested reply.
7. Edit/approve/send using the Deal's active email source — Gmail or the dedicated Rep Bureau address.
8. Have future messages update the same Deal automatically.
9. Have Rep Bureau continuously track fee, deliverables, rights, deadlines, contacts, billing instructions and payment terms with evidence/provenance.
10. See the Deal move through a calm operational pipeline from negotiation to paid/completed.
11. When invoice-ready, review an already-prepared invoice populated from existing Deal/profile information.
12. Approve invoice generation and then review/confirm the drafted send with PDF attached via Gmail or the dedicated address.
13. Have payment due date/status tracked automatically.
14. Receive a prepared overdue chase when needed rather than manually monitoring invoices.
15. Mark payment `Paid` or `Still waiting`; Rep Bureau never pretends expected money has been received.
16. See agreed, invoiced, outstanding, overdue and received values clearly distinguished.
17. Close the Deal with outcome recap and structured commercial learning.

The detailed operational requirements are canonical in `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md` and `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`.

## 2. Product constitution

- **Rep Bureau advises. The creator decides.**
- **Rep Bureau does the admin.** Do not turn automation into forms the creator must maintain.
- **Privacy is a feature.** For Gmail, analyse only explicitly labelled/known Deal threads. For the dedicated address, process only mail sent/forwarded to that Rep Bureau-controlled address. Never scan an unrelated external inbox.
- **Every important recommendation/fact is explainable.** Use concise evidence/provenance, not hidden reasoning.
- **Never invent commercial/billing/payment facts.** Confirmed, Missing and Inferred remain distinct.
- **Forwarded-message metadata preserves provenance.** Inline forwarded headers are creator-supplied evidence unless independently provider-verified.
- **User ownership always wins.** User input > approved AI > automatic extraction > imported/older data.
- **Every field must earn its place.** Ask only when necessary and explain why.
- **AI is almost invisible.** Product should feel like a proactive commercial manager.
- **Rep Bureau works while the creator is not looking.** Background jobs react to selected-thread/managed-email changes and operational dates.
- **Every AI call must justify its cost.** Cache/diff/reuse and prefer deterministic code; public inbound email must not create unbounded AI spend.
- **No silent failures.** Important failures are visible/recoverable.
- **No accidental scope creep beyond the current Phase 1.**

## 3. Navigation

Use creator mental models:

- **Dashboard** — what needs the creator now, active deadlines/payment/new-message actions, Estimated Additional Earnings.
- **Deals** — operational pipeline plus list/filter/search.
- **Brands** — brand history, contacts, private notes/context.
- **Insights** — earnings uplift, outcomes and creator financial/deal trends.
- **Train Rep Bureau** — creator profile, goals, rates, red lines, invoice issuer profile, voice/preferences.
- **Settings** — subscription billing, Deal email source(s), dedicated Rep Bureau address, notifications, security/account.

## 4. Onboarding and progressive enrichment

Target about two minutes to first value. Collect only essential creator identity/market/platform data and a simple Deal-email-source choice.

Email-source setup:

- `Connect Gmail` uses the existing explicit-label flow; or
- `Use my Rep Bureau email` allocates/displays the creator's dedicated commercial address without requiring Gmail OAuth.

A creator may enable the second source later from Settings. Do not force Gmail connection simply because Google is used for sign-in.

Later prompts may collect engagement, average views, prior deals, rate cards, goals, red lines, voice, and invoice-issuer details when invoicing becomes relevant.

Never show a generic profile-completion percentage. Frame prompts by benefit.

## 5. Dashboard

The Dashboard is an **Action Dashboard**, not a chart wall.

Priority order:

1. Action required from creator.
2. Material commercial opportunity.
3. Risk/conflict/missing fact that cannot be safely resolved.
4. Time-sensitive deadline/payment/new-message state.
5. Understated success/win.

Examples of good cards:

- `New brand enquiry — reply drafted`;
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

- full selected Deal conversation oldest-to-newest regardless of source;
- sent replies appear after confirmed provider send;
- new messages update same Deal;
- evidence links can jump to relevant passages;
- composer integrated with thread;
- user does not need to understand whether normalized messages originated from Gmail or the dedicated Rep Bureau address unless provenance matters.

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

One Deal equals one commercial agreement and may link multiple related provider threads with explicit roles.

## 8. Invoicing and payment operations

Mandatory Phase 1 scope is defined in `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md`.

Key rules:

- invoice details are pre-populated from Deal/profile data;
- creator never re-enters information already known;
- uncertain legal/tax/billing details are not guessed;
- creator reviews invoice before approval;
- approved invoice generates a versioned PDF;
- invoice email is drafted with PDF attached and requires explicit send confirmation;
- send uses the Deal's supported email source: Gmail or the dedicated Rep Bureau address;
- payment terms calculate due date automatically;
- overdue states prepare contextual chase drafts;
- creator confirms `Paid` / `Still waiting`;
- received money is never inferred.

## 9. Creator Profile / Train Rep Bureau

Creator-owned facts include profile/platform metrics, currency, rate cards, goals, red lines, industries/categories, working/payment preferences and invoice issuer information.

Observed patterns never silently become creator rules. Rep Bureau may suggest a preference and the creator accepts/rejects.

Voice Profile remains private and learns from approved/sent emails and edits to reduce future editing.

No Creator Score.

## 10. Brands, contacts, notes, attachments and history

Global Brand records contain only safe shared identity/intelligence. Creator-specific contacts, notes, relationships, Deal content, invoices and payment history remain private/workspace-scoped.

Deal/Brand notes remain private/searchable.

- Gmail-originated inbound attachments remain provider references where practical.
- Inbound attachments received directly by the dedicated Rep Bureau address may be securely stored because no external mailbox reference exists; `docs/25...` defines the security/deletion requirements.
- System-generated invoice PDFs are securely stored/reproducible private artifacts under `docs/24...`.

Meaningful AI analyses are immutable snapshots; significant actions create traceable events subject to deletion/privacy rules.

## 11. Notifications and search

Only notify for Action Required, Opportunity, Risk or Success. New managed-address Deal messages, payment and deadline notifications must be actionable and non-noisy.

Search remains deterministic across Deals, Brands, Contacts and Notes with useful filters; AI/natural-language search remains future scope.

## 12. Dedicated Rep Bureau address

Mandatory Phase 1 scope is defined in `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`.

Key rules:

- optional, one primary dedicated commercial address per creator workspace in initial Phase 1;
- creators may publish it publicly or forward brand emails into it;
- no Gmail OAuth required;
- direct inbound and forwarded messages create/update normal Deals, not a reduced secondary product path;
- outbound negotiation replies, invoice emails and chases can be creator-approved and sent from that address;
- forwarded headers are not falsely treated as provider-verified;
- ambiguous forwarding must never cause a reply to the wrong recipient;
- public-address spam/abuse/cost controls are required;
- sender/domain deliverability/authentication must be production-ready before external beta;
- full arbitrary consumer mailbox functionality is not required.

## 13. Phase 1 exclusions that remain

Do not build:

- whole-external-inbox automatic opportunity detection/scanning;
- Outlook OAuth/inbox integration;
- creator-owned custom-domain email hosting/bring-your-own-domain sending;
- arbitrary general-purpose mailbox folders/rules/personal email management;
- agency/team/shared-workspace UI;
- full accounting/bookkeeping/general ledger;
- tax filing/advice;
- expense accounting;
- open banking/bank reconciliation/automatic payment detection;
- full legal contract AI review/generation;
- automatic external email/invoice/chase sending without creator approval;
- calendar integration beyond internal Deal deadlines;
- media kit generation;
- opportunity discovery/outreach;
- natural-language/AI search;
- Creator Score;
- fine-tuning;
- Founder AI/chat assistant.
