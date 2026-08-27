# Gmail Integration Specification

## Product boundary

Replio must never scan the creator's whole inbox for deals in MVP. The user explicitly applies a Gmail label named **Replio**. Only those chosen conversations are imported/analyzed. Once a thread is labelled, future messages in that thread sync automatically without re-labelling.

## Authentication design

Separate basic identity from Gmail authorization:

1. Supabase Auth Google Sign-In: ordinary identity (`openid`, email/profile as required).
2. A separate/incremental Google OAuth consent flow for Gmail commercial-email access.

This keeps Gmail consent explicit and makes it easier to explain/revoke.

**Current least-privilege implementation choice:** use the single Gmail `gmail.modify` restricted scope if current Google documentation confirms it covers the exact required read/label/compose/send operations. Do not request `mail.google.com` unless a required operation cannot be achieved more narrowly. Re-check Google scope definitions during implementation and record the approved scope set in docs.

Use OAuth state + PKCE where applicable, offline access/refresh token, encrypted token storage, and explicit disconnect/revoke support.

## Label setup

After Gmail authorization:

1. list labels;
2. find an existing user label named `Replio` (case handling defined deterministically);
3. if absent, create it;
4. store the label id;
5. explain to the creator: apply this label once to a collaboration thread; Replio takes it from there.

Do not create Gmail filters that auto-label arbitrary mail in MVP.

## Push architecture

Use Gmail `users.watch` with `labelIds=[replio_label_id]` and Google Cloud Pub/Sub.

### Cloud resources

- Google Cloud project with Gmail API + Pub/Sub enabled.
- Topic owned by the same Google developer project used for the watch request.
- Gmail service identity granted publish permission on the topic as required by current Gmail docs.
- Pub/Sub push subscription to Replio's HTTPS webhook.
- Push authentication enabled using a dedicated service account/OIDC token.
- Webhook validates token audience, signature, expected service account identity and request shape before acknowledging.

### Watch lifecycle

Gmail watches expire. Store `watch_expiration` and renew well before expiry (daily renewal is a safe operational cadence if still recommended by current docs).

Founder OS alerts when a watch is expired, renewal repeatedly fails or Gmail authorization is invalid.

## Incremental sync

Pub/Sub tells Replio that mailbox history advanced; it does not contain the full email.

On notification:

1. authenticate webhook;
2. decode user identity/history id;
3. locate the Gmail connection;
4. enqueue an idempotent `gmail-sync` message and acknowledge promptly;
5. worker calls `history.list` from stored `last_history_id`;
6. identify changed messages/threads relevant to the Replio label;
7. fetch only the necessary thread/message data;
8. normalize MIME content to safe plain text + sanitized HTML;
9. upsert messages by provider id;
10. link to existing Deal when thread is already known;
11. create a new Deal only for a newly selected labelled thread;
12. advance `last_history_id` only after the change set is safely persisted;
13. enqueue/re-run only analysis workers whose dependencies changed.

If history is too old/invalid, perform a bounded recovery sync of the Replio label, never a whole-inbox scrape.

Google notes that push notifications can occasionally be delayed/dropped; use reconciliation/fallback incremental sync for labelled threads rather than assuming every event arrives.

## Thread-to-deal behaviour

- Unique `(workspace, gmail_thread_id)` prevents duplicate Deal creation.
- An existing labelled thread always updates the same Deal unless creator explicitly relinks/splits through a future supported action.
- If another thread appears to belong to an existing Deal but confidence is not high, do not silently merge.

## Sending from Replio

1. Creator edits/autosaves reply.
2. Optional respectful challenge fires once if applicable.
3. User presses Send.
4. Generate stable send intent/idempotency key.
5. Server validates workspace ownership, active Gmail connection and draft version.
6. Send through Gmail into the correct thread with proper threading headers/reference.
7. Persist result/message id atomically/idempotently.
8. UI shows sent message immediately after confirmed send.
9. Deal status becomes `awaiting_brand` unless other state logic applies.
10. Do not send twice on retry.

## Email rendering security/privacy

- Sanitize HTML.
- Disable remote images/tracking pixels by default; optional `Load images` can be explicit.
- No automatic link fetching/previews from untrusted email content.
- Treat email HTML/attachments as untrusted input.
- Attachments remain Gmail references in MVP.

## Disconnect

Disconnecting Gmail:

- stops/abandons watch where practical;
- revokes/removes refresh token;
- marks connection disconnected;
- does not silently delete already imported Replio Deal data (creator manages that through delete/recycle-bin controls).
