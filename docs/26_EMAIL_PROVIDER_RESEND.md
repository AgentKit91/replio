# Managed Creator Email Provider Decision — Resend

**Effective:** 7 September 2026  
**Status:** LOCKED IMPLEMENTATION CHOICE for Phase 1 unless a material technical/security/provider blocker is discovered  
**Scope:** Rep Bureau-managed creator email only

## Decision

Use **Resend** as the Phase 1 email infrastructure for Rep Bureau-managed creator commercial addresses.

Keep Rep Bureau's existing human/company mailbox such as `hello@repbureau.co.uk` on **Zoho Mail**. Do not migrate or disturb the root-domain business mailbox simply to implement creator email.

The managed creator address system must use a **dedicated Rep Bureau subdomain** so Resend receiving MX records do not conflict with the root-domain Zoho MX records.

The exact production subdomain is founder-configurable and must not be hard-coded until approved. Example shapes only:

- `creator@inbox.repbureau.co.uk`
- `creator@collab.repbureau.co.uk`

## Why Resend

Resend is API-first and supports the exact Phase 1 operating model:

- inbound email on a custom domain/subdomain;
- `email.received` webhook events;
- retrieval of received message body, headers and attachment data through the receiving APIs;
- outbound sending through API/SDK;
- sending from any address on a verified sending domain without pre-provisioning a traditional mailbox/user;
- receiving mail for arbitrary local parts on the configured receiving domain, allowing Rep Bureau to route by the `To` address rather than create a provider mailbox for every creator;
- webhook signature verification and retry/replay support;
- current Node/TypeScript SDK and agent/Codex tooling.

Do not model Resend addresses as conventional hosted mailboxes. The creator address is primarily a Rep Bureau routing identity backed by our own workspace/Deal/message records.

## Existing Zoho boundary

`repbureau.co.uk` already has normal business email hosted in Zoho.

Therefore:

- keep the root-domain inbound MX records for Zoho;
- do **not** point root `repbureau.co.uk` receiving MX at Resend;
- configure Resend receiving on a separate subdomain;
- add only the DNS records Resend requires for that chosen subdomain/sending identity;
- confirm DNS/provider records before changing anything in production.

## Address allocation

Rep Bureau owns allocation in Postgres; Resend does not need an individually created provider mailbox for every creator.

On creator opt-in:

1. choose/validate a unique local part under the configured managed-email domain;
2. save the mapping to the creator workspace;
3. display the active address in Settings/Profile;
4. route inbound messages by normalized recipient address;
5. permit creator-approved outbound messages from that address once the sending domain is verified.

Address aliases/renames must preserve safe historical routing and must never accidentally reassign an old public address to a different creator.

## Inbound implementation

Use Resend Receiving and a signed webhook endpoint for `email.received`.

Important implementation detail: the inbound webhook may contain message/attachment metadata rather than the complete body or file bytes. Workers should retrieve full content/headers/attachments from Resend's receiving APIs only when required, with bounded size/type/cost controls.

Flow:

1. Resend receives mail sent to the managed subdomain.
2. Resend emits signed `email.received` webhook.
3. Rep Bureau verifies the raw-body webhook signature before accepting it.
4. Persist an idempotency/provider event key and acknowledge quickly.
5. Resolve the recipient local part to exactly one workspace/address record.
6. Unknown/disabled recipients fail safely and must not create Deal data for another workspace.
7. Retrieve/normalize the message content required for Deal processing.
8. Sanitize HTML and treat all inbound text/attachments as untrusted.
9. Apply spam/abuse/size/rate controls before expensive AI analysis.
10. Normalize into the shared `email_messages` / `deal_threads` model used by Gmail.
11. Create/link/quarantine the Deal according to `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md`.

Repeated webhook events or provider retries must not duplicate the message or Deal.

## Outbound implementation

Use the Resend send API/SDK behind the existing provider-neutral outbound email abstraction.

- creator sees/edit/approves the draft in Rep Bureau;
- external send remains explicit user-confirmed;
- `From` uses the creator's active managed Rep Bureau address;
- preserve Reply-To/threading headers/provider references as required for reliable replies;
- store provider message id and delivery state;
- send retries/reconciliation are idempotent and cannot duplicate a creator-approved send;
- invoice PDFs and other allowed Phase 1 attachments follow the same workspace-private rules as the Gmail route.

Because Resend permits sending from any address at a verified domain, creator addresses should be database-allocated rather than individually provisioned as Resend users/mailboxes.

## Provider abstraction

Do not scatter Resend SDK calls throughout product features.

Maintain/extend an internal email-provider boundary supporting at least:

- Gmail-labelled connected threads;
- Resend-managed creator email.

Product features should operate on normalized Deal/message/draft/send concepts and choose the correct provider transport through the linked thread/source.

## Codex / agent integration

Resend currently provides official Codex/agent tooling. The founder should connect the Resend account/plugin/connector to Codex when available so Codex can inspect provider state, domains and relevant configuration rather than asking for repeated manual screenshots.

Secrets remain server-side. Plugin access does not justify committing API keys or DNS secrets to GitHub.

If the connected Resend tooling is unavailable in a given Codex environment, use the official current Resend API/SDK/CLI documentation rather than redesigning the provider choice.

## Production DNS / deliverability gate

Before external beta using managed email:

- approved creator-email subdomain chosen;
- receiving MX record verified by Resend;
- sending domain/subdomain fully verified;
- SPF/DKIM configured as required by Resend;
- DMARC policy/recommendation reviewed for the Rep Bureau domain setup;
- inbound webhook signing secret configured securely;
- production API credential configured server-side with least privilege where possible;
- real inbound direct-brand message tested;
- real forwarded-message flow tested;
- real outbound reply and reply-back threading tested;
- bounce/complaint/delivery failure visibility available to the application/Founder OS as appropriate.

Do not alter Zoho's existing root-domain MX records to achieve this.

## Cost and abuse controls

A public creator email address can receive arbitrary internet mail. Resend receipt is not permission to invoke AI automatically for every message.

Implement:

- recipient/address existence check first;
- spam/abuse classification/rules before expensive analysis;
- attachment limits;
- inbound rate/volume thresholds;
- duplicate suppression;
- quarantine/manual review path;
- per-workspace operational/AI budget protections;
- Founder OS visibility for abnormal inbound volume without exposing private email content.

## Future provider changes

Resend is the selected Phase 1 provider, but application data must remain portable through the provider abstraction.

Do not build:

- a generic IMAP server;
- conventional webmail folders/mailbox administration;
- one paid provider mailbox/user per creator;
- creator-owned custom-domain hosting in Phase 1.

A future provider migration must not require rebuilding the Deal domain or creator communication history.
