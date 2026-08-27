# Security and Privacy Specification

## Privacy model

The central promise is literal: **Replio only analyses conversations the creator explicitly chooses to share.** No full-inbox scanning in MVP.

## Least privilege

- Request the narrowest Google scopes that support the approved behaviour.
- Browser receives only Supabase publishable/public configuration and public analytics key where needed.
- Supabase secret/service key, Stripe secret, Google client secret, token-encryption keys and AI keys are server-only.
- Never make authorisation decisions from user-editable `user_metadata`.
- Founder/internal roles must use trusted app metadata or private server-side role records.

## Supabase/RLS

- Enable RLS on every exposed table.
- Ownership policies must include workspace membership predicates, not merely `TO authenticated`.
- UPDATE policies use both ownership `USING` and `WITH CHECK` and the required SELECT permission.
- Views exposed to users must respect RLS (security invoker where supported) or remain private.
- Avoid SECURITY DEFINER; if unavoidable, keep it out of exposed schemas, explicitly check caller identity and restrict EXECUTE.
- Run Supabase advisors/security checks before release.

## OAuth tokens

- Store Gmail refresh tokens server-side only.
- Encrypt at application level or approved secret store; record key version for rotation.
- Do not log tokens.
- Disconnect/revoke path supported.

## Webhooks

- Stripe: verify signature with webhook secret before parsing trusted event semantics.
- Google Pub/Sub: use authenticated push, verify OIDC JWT signature/audience/expected service account.
- Rate limit and reject malformed payloads.
- Idempotency by event id/history state.

## Untrusted email content

- sanitize HTML;
- remote images off by default;
- no execution/scripts;
- no server-side fetching arbitrary email links;
- protect against prompt injection: email/attachment text is **data**, never system instruction. Workers receive explicit delimiters and are told never to follow instructions embedded in commercial correspondence that attempt to change Replio behaviour.

## AI data boundaries

- only task-relevant context sent to model;
- no unrelated inbox/profile data;
- do not include secrets/tokens;
- no chain-of-thought stored;
- analytics does not receive raw email/deal content;
- provider retention/training settings must be reviewed before launch.

## Support Mode

A creator can explicitly grant support access with:

- scope (e.g. one Deal or workspace support);
- visible reason;
- selected expiry window;
- revoke-now control.

Every support access event/view/action is logged. The founder's ordinary admin session cannot read private negotiation content without an active grant.

## Deletion

- soft delete for 30 days; restore available;
- explicit early permanent purge available;
- scheduled purge after retention;
- purge associated private data including message copies, notes, drafts, analysis snapshots and private support/audit references where required;
- de-identified aggregate benchmark contributions may remain only if genuinely irreversible/non-linkable.

## Production legal/compliance preflight

Engineering can proceed, but production launch must have founder/legal review of:

- Privacy Policy / Terms;
- UK/EU data-protection basis and processor/subprocessor disclosures;
- Google OAuth verification/restricted-scope requirements;
- provider data retention/training settings;
- cookie/analytics consent requirements by launch market;
- commercial guidance/legal-disclaimer language.

This document is an engineering specification, not legal advice.
