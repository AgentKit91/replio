# Security and Privacy Specification

## Privacy model

The central promise is literal: **Rep Bureau only processes commercial conversations the creator explicitly routes into Rep Bureau.**

Phase 1 supports two authorized routes:

1. explicitly labelled/known Gmail Deal threads; and
2. mail sent or forwarded to the creator's dedicated Rep Bureau commercial email address.

Rep Bureau must never scan the creator's whole external inbox. A dedicated Rep Bureau address does not grant access to Gmail, Outlook or any unrelated mailbox.

## Least privilege

- Request the narrowest Google scopes that support the approved Gmail behaviour.
- The dedicated Rep Bureau address must not require external mailbox OAuth.
- Browser receives only Supabase publishable/public configuration and public analytics key where needed.
- Supabase secret/service key, Stripe secret, Google client secret, token-encryption keys, managed-email provider credentials and AI keys are server-only.
- Never make authorisation decisions from user-editable `user_metadata`.
- Founder/internal roles must use trusted app metadata or private server-side role records.

## Supabase/RLS and private storage

- Enable RLS on every exposed table.
- Ownership policies must include workspace membership predicates, not merely `TO authenticated`.
- UPDATE policies use both ownership `USING` and `WITH CHECK` and the required SELECT permission.
- Views exposed to users must respect RLS (security invoker where supported) or remain private.
- Avoid SECURITY DEFINER; if unavoidable, keep it out of exposed schemas, explicitly check caller identity and restrict EXECUTE.
- Managed-email addresses, messages, attachments, invoices and payment records are workspace-private.
- Any object storage for managed-email attachments or generated invoice PDFs must enforce equivalent tenant isolation and signed/temporary access.
- Run Supabase advisors/security checks before release.

## OAuth tokens

- Store Gmail refresh tokens server-side only.
- Encrypt at application level or approved secret store; record key version for rotation.
- Do not log tokens.
- Disconnect/revoke path supported.
- Managed-email provider credentials are server-side integration secrets, not creator OAuth tokens.

## Webhooks

- Stripe: verify signature with webhook secret before parsing trusted event semantics.
- Google Pub/Sub: use authenticated push, verify OIDC JWT signature/audience/expected service account.
- Managed-email inbound provider: verify the provider's current supported webhook signature/authentication mechanism before accepting message semantics.
- Rate limit and reject malformed/replayed payloads.
- Idempotency by event/provider message/history state.
- Do not trust a recipient address supplied only in an unverified request body to determine workspace routing.

## Dedicated creator address privacy boundary

The creator may publicly share their dedicated Rep Bureau address. Messages reaching it are intentionally routed into Rep Bureau for commercial processing.

Requirements:

- exactly map an active dedicated address to the correct workspace;
- do not expose address-to-workspace mappings publicly beyond the email address itself;
- do not reassign retired addresses casually where stale senders may still use them;
- treat direct sender/envelope/provider metadata according to provider trust guarantees;
- treat inline forwarded headers as creator-supplied evidence unless independently verified;
- never claim Rep Bureau has authenticated the original sender of a forwarded message when it has not;
- ambiguous forwarded recipient/sender extraction must block or require review before external send rather than risk emailing the wrong person.

## Untrusted email and attachment content

All Gmail and managed-email content is untrusted input.

- sanitize HTML;
- remote images off by default;
- no execution/scripts;
- no server-side fetching arbitrary email links;
- protect against prompt injection: email/attachment text is **data**, never system instruction;
- workers receive explicit delimiters and never follow embedded instructions that attempt to alter Rep Bureau behaviour;
- managed-email inbound attachments require conservative size/type limits;
- do not execute macros/scripts or unsafe active content;
- use file-safety/malware controls appropriate to the chosen stack/provider before public launch;
- attachment downloads use signed/temporary access and creator authorization;
- reject/quarantine malformed or oversized input safely.

## Spam, abuse and cost protection

Public creator addresses create an abuse surface. At minimum:

- authenticate inbound provider events;
- apply bounded message/attachment sizes;
- rate-limit abusive patterns where appropriate;
- use provider spam/reputation signals as non-authoritative inputs where available;
- obvious bulk/spam mail should not trigger expensive AI by default;
- uncertain plausible brand enquiries should prefer a review/quarantine state over silent deletion;
- prevent mail bombs/replayed webhooks from creating unbounded rows/jobs/AI spend;
- expose aggregate operational health/volume to Founder OS without message bodies.

## Outbound email safety

Whether sending through Gmail or the dedicated Rep Bureau address:

- external sends require explicit creator confirmation in Phase 1;
- recipient/thread/provider state is validated immediately before send;
- stable send intent/idempotency prevents duplicate sends;
- ambiguous forwarded-recipient resolution must fail closed;
- invoice/chase emails use the same confirmation boundary;
- provider response/message id is persisted for reconciliation.

For managed email, production sender-domain authentication/deliverability requirements must be verified against current provider/domain guidance before external beta.

## AI data boundaries

- only task-relevant context sent to model;
- no unrelated inbox/profile data;
- no provider secrets/tokens;
- no chain-of-thought stored;
- analytics does not receive raw email/attachment/Deal/invoice/payment content;
- provider retention/training settings must be reviewed before launch;
- avoid expensive AI on obvious spam/duplicates/unchanged messages.

## Support Mode

A creator can explicitly grant support access with:

- scope (e.g. one Deal or workspace support);
- visible reason;
- selected expiry window;
- revoke-now control.

Every support access event/view/action is logged. The founder's ordinary admin session cannot read private negotiation content, managed-email bodies/attachments, invoice details or payment instructions without an active grant.

## Deletion

- soft delete for 30 days; restore available where product rules allow;
- explicit early permanent purge available;
- scheduled purge after retention;
- purge associated private data including Gmail/managed-email message copies, stored managed-email attachments, notes, drafts, analysis snapshots, generated invoice artifacts, private payment records and private support/audit references where required;
- retired creator email addresses must follow a safe retention/non-reassignment policy without retaining unnecessary private content;
- de-identified aggregate benchmark contributions may remain only if genuinely irreversible/non-linkable.

## Production legal/compliance preflight

Engineering can proceed, but production launch must have founder/legal review of:

- Privacy Policy / Terms;
- UK/EU data-protection basis and processor/subprocessor disclosures;
- disclosure that Rep Bureau hosts/processes mail sent or forwarded to dedicated creator addresses;
- Google OAuth verification/restricted-scope requirements for Gmail users;
- managed-email provider/data-processing terms and retention;
- AI provider data retention/training settings;
- cookie/analytics consent requirements by launch market;
- invoice/payment-data handling disclosures;
- commercial guidance/legal-disclaimer language.

This document is an engineering specification, not legal advice.
