# Gmail Integration Specification

## Product boundary

Rep Bureau must never scan the creator's whole inbox for deals in Phase 1. The user explicitly applies the configured Gmail label (historically named **Replio**; user-facing naming may become **Rep Bureau**). Only those chosen conversations are imported/analyzed. Once a thread is labelled, future messages in that thread sync automatically without re-labelling.

The selected Deal conversation is also the source for Phase 1 operational extraction: fee changes, deliverables, deadlines, billing instructions, payment terms and relevant payment updates should enrich the same living Deal automatically with provenance.

## Authentication design

Separate basic identity from Gmail authorization:

1. Supabase Auth Google Sign-In: ordinary identity (`openid`, email/profile as required).
2. Separate/incremental Google OAuth consent for Gmail commercial-email access.

This keeps Gmail consent explicit and easier to explain/revoke.

**Least-privilege rule:** use the narrowest current Gmail scope that supports the exact required read/label/compose/attachment/send operations. Re-check official Google scope definitions at implementation time and record the approved scope set.

Use OAuth state + PKCE where applicable, offline access/refresh token, encrypted token storage, and explicit disconnect/revoke support.

## Label setup

After Gmail authorization:

1. list labels;
2. find the configured user label deterministically;
3. create it if absent;
4. store the label id;
5. explain: apply this label once to a collaboration thread; Rep Bureau takes it from there.

Do not create Gmail filters that auto-label arbitrary mail in Phase 1.

## Push architecture

Use Gmail `users.watch` filtered to the selected label plus Google Cloud Pub/Sub.

- Webhook validates token audience/signature/expected service account/request shape.
- Webhook enqueues and acknowledges quickly.
- Watches are renewed before expiry and failures are visible in Founder OS.

## Incremental sync

On notification:

1. authenticate webhook;
2. decode user/history id safely;
3. locate Gmail connection;
4. enqueue idempotent `gmail-sync` work and acknowledge promptly;
5. call `history.list` from stored cursor;
6. identify changed messages/threads relevant to selected Deals;
7. fetch only necessary message/thread data;
8. normalize MIME to safe text + sanitized HTML;
9. upsert messages by provider id;
10. link to the existing Deal when known;
11. create a new Deal only for a newly selected labelled thread;
12. advance cursor only after persistence;
13. enqueue only analysis/admin workers whose dependencies changed.

If history is too old/invalid, perform a bounded recovery sync of the selected label, never a whole-inbox scrape.

## Thread-to-deal behaviour

- Unique `(workspace, gmail_thread_id)` prevents duplicate Deal creation.
- Known selected thread updates the same Deal.
- Ambiguous possible merge/continuation is never silently merged.
- One Deal may contain multiple explicitly linked threads with roles such as negotiation, contract, deliverables and payment.

## Operational fact extraction

After each relevant selected-thread change, Rep Bureau should reuse the validated fact/evidence pipeline to update the Deal with structured deltas for:

- commercial offer/settlement changes;
- deliverables/rights/payment terms;
- deadlines/posting/draft dates;
- contacts;
- billing entity/address/contact;
- PO/reference/invoice instructions;
- payment promises/status statements.

Creator-owned corrections outrank extraction. Ambiguous facts are surfaced, not guessed.

## Sending ordinary negotiation replies

1. Creator edits/autosaves reply.
2. Optional respectful challenge may fire once.
3. User presses Send.
4. Generate stable send intent/idempotency key.
5. Server validates ownership/connection/draft version.
6. Send through Gmail with correct threading.
7. Persist provider result idempotently.
8. UI shows sent message after confirmed send.
9. Deal status updates appropriately.
10. Never send twice on retry.

## Invoice and payment-chase sending

Mandatory Phase 1 behaviour is defined in `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md`.

- Rep Bureau prepares invoice/chase email content from trusted Deal data.
- Creator reviews before external send.
- Invoice PDF is attached to the correct Deal/payment thread after invoice approval.
- Send requires explicit creator confirmation.
- Stable send intent/reconciliation prevents duplicates.
- Sent invoice/chase message id is persisted against the relevant invoice/reminder record.

## Attachment rule

**Incoming/provider attachments:** remain Gmail references in Phase 1; store metadata/reference rather than duplicating arbitrary inbound files.

**System-generated invoice PDFs:** explicit Phase 1 exception. Rep Bureau may securely generate/store or reproducibly generate its own invoice artifact, attach it to the Gmail draft/send, and retain the workspace-private version/reference required for invoice history. These artifacts follow RLS, signed-access and deletion rules in the Phase 1 admin amendment.

## Email rendering security/privacy

- Sanitize HTML.
- Remote images/tracking pixels off by default.
- No automatic untrusted link fetching/previews.
- Email HTML/attachments are untrusted input.
- Prompt-like instructions inside correspondence are data, never system instructions.

## Disconnect

Disconnecting Gmail stops/abandons watch where practical, revokes/removes refresh token, marks connection disconnected and does not silently delete already imported Deal data. Creator manages Deal/account deletion through explicit controls.
