# Module Acceptance Criteria

## Auth/onboarding

- Google is the only visible Phase 1 sign-in method.
- New user gets exactly one hidden creator workspace atomically.
- Two-minute onboarding is achievable with required fields only.
- Creator can choose Gmail, dedicated Rep Bureau email, or both without duplicative onboarding.
- Gmail OAuth is not required for creators using only the dedicated Rep Bureau address.
- More profile/invoice-issuer questions are value-framed and deferred until useful.
- Cross-workspace access is impossible under client credentials.

## Gmail

- No unlabelled external Gmail thread is imported during normal Phase 1 operation.
- Rep Bureau/Replio label can be created/found reliably.
- Labelled thread creates one Deal even with repeated Pub/Sub events.
- New messages sync without re-labelling and update the same Deal.
- Gmail push auth/watch recovery is verified/observable.
- Sending a draft/invoice/chase cannot duplicate on retry.

## Dedicated Rep Bureau creator email

- Creator can receive one active primary dedicated commercial email address without connecting Gmail.
- Address allocation is unique, idempotent and workspace-bound.
- Direct inbound email to that address creates/updates the correct Deal idempotently.
- Creator can forward a brand email from an otherwise unconnected mailbox and receive a usable Deal.
- Forwarded sender/reply-to details preserve `forwarded_message` provenance and are not falsely presented as provider-verified.
- Ambiguous forwarded parsing cannot cause an outbound email to be sent to the wrong recipient.
- Creator can review/edit/send a negotiation reply from the dedicated address.
- Subsequent brand reply threads back into the same Deal.
- Creator can generate and explicitly send an invoice with the correct PDF from the dedicated address.
- Creator can review and explicitly send a payment chase from the dedicated address.
- A no-Gmail creator can complete the entire Deal from enquiry/forward through creator-confirmed payment.
- Gmail and dedicated-address sources can coexist without duplicate messages/Deals or unsafe silent merges.
- Provider retries/webhook replays cannot duplicate inbound or outbound messages.
- Inbound attachment storage is workspace-private, size/type controlled, safely handled and purgeable.
- Basic spam/abuse/rate/cost controls prevent public inbound mail causing unbounded AI processing.
- Sender-domain authentication/deliverability configuration is verified before external beta.

## Living Deal / admin automation

- Selected Deal messages from either supported source automatically update relevant fee, terms, deliverables, contacts/billing instructions and deadlines.
- Material auto-populated facts preserve source/evidence/provenance.
- Creator edits outrank later automatic extraction until creator changes them.
- Missing/ambiguous material facts are surfaced rather than guessed.
- User is not asked to re-enter trusted information already present in selected communications/profile/history.
- Safe internal lifecycle changes can happen automatically; creator can correct status.

## Deal Workspace / pipeline

- Deal conversation remains visible while AI/admin work runs or fails.
- Analysis Golden Path remains intact regardless of email source.
- Operational status/deadline/payment state is understandable in human language.
- Kanban-esque pipeline works with keyboard/mobile and is not drag-only.
- Dashboard asks the creator only for actions Rep Bureau cannot safely complete itself.
- Draft autosaves and user edits survive refresh/AI improvement.

## AI

- Workers return validated structured outputs.
- Important missing terms/billing facts are not hallucinated.
- Low-confidence material facts trigger review/clarification.
- Forwarded-message extraction distinguishes transport-verified fields from creator-forwarded evidence.
- New admin extraction reuses incremental fact infrastructure; unnecessary AI calls are avoided.
- Obvious spam/bulk managed-address mail does not trigger expensive full analysis by default.
- Worker failures retry/degrade without breaking Deal access.
- No chain-of-thought stored.
- Model routing/cost per worker remains measurable/configurable.

## Pricing/Score

- Ideal Ask / Expected Settlement / Minimum Worthwhile Fee remain distinct.
- Rep Bureau/Replio Score is dynamic commercial strength, never accept/decline command.
- Every score explains what would improve it.
- Benchmark data below threshold cannot influence recommendation.
- Estimated Additional Earnings is labelled estimated and reproducible/versioned.

## Invoice preparation

- Invoice issuer profile is creator-owned/versioned; legal/tax/bank details are never guessed.
- Billing entity/address/contact, PO/reference, amount, currency, line items and payment terms auto-populate when trusted data exists.
- Invoice-ready flow presents a substantially completed review, not a blank form.
- Uncertain/conflicting fields are clearly flagged before approval.
- Creator can edit every invoice value before approval.
- One approved invoice version gets one stable invoice number/version; retries do not duplicate it.
- Generated PDF is correct, workspace-private and purgeable.

## Invoice send

- After invoice approval, Rep Bureau drafts the email and attaches the correct PDF.
- Creator explicitly confirms external send.
- Correct threading is preserved for Gmail and dedicated Rep Bureau email.
- Retry/reconciliation cannot double-send.
- Sent provider message id, invoice version/date and sent timestamp persist.
- Confirmed payment terms calculate the due date deterministically.

## Payment tracking/chasing

- Financial state distinguishes agreed, invoiced, outstanding, overdue and received.
- Due/overdue state updates without manual date monitoring.
- If a brand has promised a later payment date, reminder logic considers it rather than blindly chasing.
- Overdue state can prepare a context-aware chase draft; it is not auto-sent.
- Reminder history is preserved and retry-safe.
- Creator can choose `Paid` or `Still waiting` with low friction.
- Rep Bureau never marks paid merely from elapsed time or an unverified brand statement.
- Creator-confirmed payment updates received totals and completion state appropriately.

## Creator learning

- Creator owns explicit rules.
- Learned patterns become preferences only after explicit acceptance.
- No Creator Score.
- Rate Card and invoice issuer/payment instructions remain private.

## Subscription billing

- Trial/subscription access comes from Stripe state, not redirect.
- Platform subscription billing remains separate from creator-to-brand Deal invoices.
- Usage entitlement cannot be bypassed client-side.
- Failed platform billing is surfaced.

## Founder OS/privacy

- Critical operational/email-provider failures and action items are visible without exposing private Deal/invoice/payment/email content.
- Raw private negotiations, managed-email bodies/attachments and invoice/payment details are hidden by default.
- Support access requires explicit active creator grant.
- Sensitive founder actions are confirmed/audited.

## Security/deletion

- New invoice/payment/managed-email tables and storage pass tenant RLS/access tests.
- Provider credentials, private email content, attachments and bank/payment instructions never appear in analytics/logs.
- Dedicated-address webhooks authenticate/verify provider origin/signature per current provider guidance.
- Deleted Deal disappears from normal views and remains restorable during configured recycle period.
- Permanent purge removes private messages, managed-email attachments, invoice artifacts, payment records and associated private data according to policy.
- Only genuinely irreversible anonymised aggregates may survive.

## Regression / release

- Existing Gmail negotiation, AI, creator learning, subscription billing and Founder OS critical journeys remain green.
- Dedicated-address no-Gmail E2E journey is green.
- Accessibility/mobile/performance/security/spam-abuse/deliverability checks are rerun after expanded Phase 1 lands.
