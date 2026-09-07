# Phase 1 Dedicated Creator Email Address — Founder Scope Amendment

**Effective:** 7 September 2026  
**Status:** LOCKED — mandatory Phase 1 / launch scope  
**Product name:** Rep Bureau

This amendment adds a second first-class Deal email source for creators who do not want to connect Gmail. It supersedes earlier instructions that deferred a Rep Bureau-managed creator inbox/custom creator email.

## 1. Product decision

Every creator may optionally receive a dedicated Rep Bureau email address on a Rep Bureau-controlled domain.

The exact domain/subdomain is configuration and must not be hard-coded until the production domain is approved. Example shape only:

`creator-handle@inbox.repbureau.example`

The address is designed for commercial/brand-deal communication, not as a general-purpose personal mailbox.

A creator can use it in either of two ways:

1. **Direct brand contact** — publish the address on TikTok, Instagram, YouTube, Link-in-bio, media kit or elsewhere so brands email Rep Bureau directly.
2. **Forward-to-Rep-Bureau** — forward a brand email/thread from any existing mailbox to the dedicated address without granting Rep Bureau OAuth access to that mailbox.

## 2. Gmail becomes optional

Phase 1 supports two independent Deal-ingestion paths:

### A. Connected Gmail

The existing explicit-label flow remains unchanged:

- creator connects Gmail;
- only explicitly labelled Deal threads are imported;
- no whole-inbox scanning;
- future messages in known selected threads sync automatically.

### B. Dedicated Rep Bureau address

- no Gmail connection is required;
- inbound messages sent to the creator's Rep Bureau address are received by Rep Bureau directly;
- relevant brand communications create/update Deals;
- the creator can reply, negotiate, invoice and chase payment from Rep Bureau using the dedicated address;
- external sends still require creator approval under the 90/10 admin principle.

A creator may use Gmail, the dedicated address, or both. Rep Bureau must avoid duplicate Deals/messages when the same commercial conversation arrives through more than one source.

## 3. Creator experience

The user-facing choice should be simple and non-technical:

**How should brands reach Rep Bureau?**

- `Connect Gmail` — use the existing labelled-thread workflow.
- `Use my Rep Bureau email` — receive a dedicated commercial email address.

The dedicated address should be easy to copy and clearly presented as a business-contact address the creator may publish publicly.

Do not force Gmail OAuth merely because the user signs in with Google. Authentication and Deal-email source remain separate concepts.

## 4. Dedicated inbox is not a generic email client

Phase 1 does not need folders, arbitrary mailbox rules, personal-email management, contact-book replacement or full consumer email functionality.

The Rep Bureau address exists to support the commercial Deal lifecycle:

- brand enquiry;
- negotiation;
- contract/deliverable communication;
- invoice sending;
- payment queries/chasing;
- usage extensions and related Deal communication.

Inbound messages that are clearly spam, irrelevant or non-commercial should not automatically create noisy Deals.

## 5. Direct inbound flow

For a direct brand email to the dedicated address:

1. inbound email provider receives the message;
2. authenticated/verified provider webhook passes it to Rep Bureau;
3. persist provider message/thread identifiers idempotently;
4. sanitize/normalize content and attachments as untrusted input;
5. associate the recipient address with exactly one creator workspace;
6. create or update a Deal using the existing Deal-domain logic;
7. run incremental commercial/admin extraction;
8. surface the Deal and any creator-needed action;
9. continue future replies in the same provider thread/conversation.

A direct inbound email to the dedicated address is itself an explicit creator-authorized source: the creator chose to publish/use that address for Rep Bureau commercial correspondence. It does not constitute permission to access any other mailbox.

## 6. Forwarded-email flow

A creator may forward a brand email from Gmail, Outlook, Apple Mail or another mailbox to their Rep Bureau address.

Rep Bureau should attempt to identify:

- original sender/name/email;
- original subject;
- original sent timestamp where safely parseable;
- original recipients;
- forwarded body/content;
- attachments included with the forward;
- forwarding creator/account identity.

### Trust rule

Forwarded headers embedded in a message body are **evidence supplied by the creator**, not cryptographically verified original transport headers.

Therefore:

- use them to construct the Deal and draft a response when reasonably clear;
- preserve provenance as `forwarded_message` / creator-supplied evidence;
- do not falsely label the original sender metadata as provider-verified;
- surface ambiguity when the real brand reply-to address cannot be identified safely;
- never accidentally send a proposed brand reply back to the forwarding creator because parsing failed.

Where supported and useful, attached `.eml` / RFC822 forwards may provide stronger structured metadata than inline forwarding, but ordinary inline forwarding must still be supported.

## 7. Outbound sending from dedicated address

Creators who choose not to connect Gmail must still be able to complete the entire Rep Bureau workflow.

Rep Bureau must therefore support outbound email **from the creator's dedicated Rep Bureau address**, including:

- negotiation replies;
- clarification emails;
- invoice emails with generated invoice PDF;
- payment reminders/chases;
- other Deal communications within Phase 1 scope.

The existing composer/review model applies:

1. Rep Bureau prepares the draft;
2. creator reviews/edits;
3. creator explicitly confirms Send;
4. provider send is idempotent/reconciled;
5. outbound message appears immediately in the Deal conversation after confirmed send;
6. Deal state/admin automation continues normally.

Do not auto-send merely because the address is managed by Rep Bureau.

## 8. Sender identity and deliverability

Codex must verify current official documentation for the chosen inbound/outbound email provider before implementation.

The implementation must support production-grade sender authentication and deliverability on the Rep Bureau-controlled domain, including the current appropriate SPF, DKIM and DMARC setup and provider verification requirements.

Do not invent provider mechanics from memory. Keep the integration behind an internal email-provider abstraction so a provider can be replaced without rewriting the Deal domain.

## 9. Address allocation

Requirements:

- exactly one active primary dedicated address per creator workspace in initial Phase 1 unless a simpler implementation naturally supports aliases;
- addresses are unique case-insensitively;
- allocation is idempotent;
- unsafe/reserved/system names are blocked;
- address changes/aliases must not reassign an old address to another creator while inbound mail could still arrive;
- production domain is configuration;
- user-facing address can be generated automatically with an optional safe availability-based handle choice if cheap to implement.

Do not make address vanity/customization a blocker to the core feature.

## 10. Data model extension

Codex may adapt names to existing migrations, but equivalent concepts are required.

### `creator_email_addresses`

Workspace-scoped record with at least:

- `id`;
- `workspace_id`;
- local part / normalized address;
- domain/config version;
- status (`active`, `disabled`, `retired`);
- provider routing identifier if required;
- created/updated/retired timestamps;
- unique normalized address.

### Provider-neutral Deal threads

Extend `deal_threads.provider` beyond Gmail to support a managed Rep Bureau email provider, e.g. `gmail` and `rep_bureau_email`.

Provider message/thread identifiers must remain unique within the appropriate connection/address boundary.

### Email messages

The existing normalized `email_messages` model should be reused wherever possible. Store:

- provider;
- provider message/thread id;
- direction;
- envelope/header sender and recipients;
- reply-to where present;
- normalized/sanitized body;
- source hash;
- whether source was direct inbound or forwarded;
- forwarding provenance where relevant.

Avoid creating a parallel second Deal/message model for the managed address.

## 11. Attachments

Inbound attachments to the Rep Bureau-managed address may need to be stored because there is no external Gmail provider reference to fall back to.

Requirements:

- treat all inbound attachments as untrusted;
- enforce conservative size/type limits;
- secure workspace-scoped object storage;
- no automatic execution/rendering of unsafe content;
- malware/file-safety protections appropriate to the chosen stack before public launch;
- signed/temporary access only;
- deletion/purge with the parent Deal/account;
- no attachment content in analytics/logs.

This is an explicit exception to the older Gmail-only attachment-reference rule.

## 12. Spam, abuse and public-address protection

Because creators may publish these addresses publicly, Phase 1 must include basic abuse controls.

At minimum:

- provider/webhook authentication;
- inbound rate limiting / abuse thresholds where appropriate;
- size limits;
- sender/domain reputation signals available from the provider may be used as non-authoritative inputs;
- basic spam suppression/quarantine strategy;
- do not automatically run expensive AI on obvious spam/bulk mail;
- do not let arbitrary inbound email trigger unbounded cost;
- Founder OS should show operational volume/failures without exposing private message bodies.

Do not silently discard plausible legitimate brand enquiries solely because an automated spam heuristic is uncertain. Prefer a quiet review/quarantine state for ambiguous cases.

## 13. Threading and duplicate protection

Rep Bureau must preserve conversation continuity and avoid duplicate Deals.

- direct managed-address messages use provider thread/message identifiers plus RFC message headers where available;
- outbound replies preserve correct reply threading;
- retries never double-send;
- repeated inbound webhooks never duplicate messages;
- forwarded messages can be matched to an existing Deal when evidence is strong;
- if a Gmail-labelled copy and a forwarded/managed-address copy appear to be the same Deal, do not silently merge unless confidence/rules are sufficiently strong; otherwise ask the creator;
- never lose the original provenance/source when records are linked.

## 14. Privacy and security boundary

The dedicated address is intentionally narrower than Gmail OAuth:

- Rep Bureau receives only mail sent/forwarded to that address;
- it does not gain access to the creator's unrelated mailbox;
- workspace isolation/RLS applies to all address, message and attachment records;
- founder/admin cannot read private content without Support Mode;
- email bodies/attachments are excluded from analytics;
- permanent deletion purges private managed-email data and stored attachments according to policy;
- secrets/provider credentials are server-side only.

Privacy/Terms must accurately disclose that Rep Bureau hosts/processes communications received at the dedicated address.

## 15. Notifications

The creator should receive useful in-app notification/action state for new managed-address brand messages.

Phase 1 does not require forwarding every managed-address message back out to the creator's personal mailbox. If notification-email forwarding is added, it must be optional and must not create reply/thread confusion.

## 16. Financial/admin integration

A Deal originating from the dedicated address must have the **same capabilities** as a Gmail Deal:

- analysis and Rep Bureau Score;
- fee recommendations;
- negotiation drafting;
- living Deal/admin extraction;
- deadlines;
- invoice preparation/PDF;
- invoice send from dedicated address;
- payment tracking;
- chase draft/send from dedicated address;
- creator-confirmed payment;
- Insights/benchmark contribution under existing privacy rules.

There must not be a lower-feature 'email-only' Deal path.

## 17. Phase 1 exclusions that remain

This amendment does **not** add:

- full arbitrary consumer mailbox functionality;
- access to an unconnected Gmail/Outlook inbox;
- Outlook OAuth integration;
- creator-owned custom-domain email hosting;
- multiple team inboxes/agency routing;
- automatic outbound sending without creator approval;
- cold outbound/opportunity discovery;
- open tracking/read receipts as a product requirement;
- marketing-email/newsletter tooling.

## 18. Definition of done

This feature is not complete until:

1. Creator can choose the Rep Bureau-address route without connecting Gmail.
2. A unique dedicated address is allocated and displayed clearly.
3. Direct external email to that address creates/updates the correct creator Deal idempotently.
4. Creator can forward a brand email from an unconnected mailbox and Rep Bureau creates a usable Deal while preserving forwarded-source provenance.
5. Ambiguous forwarded sender/reply-to information cannot cause an email to be sent to the wrong party.
6. Creator can review and send a negotiation reply from the dedicated address.
7. Subsequent inbound reply returns to the same Deal/thread.
8. Deal receives the same AI/admin/pipeline capabilities as a Gmail-originated Deal.
9. Creator can generate and explicitly send an invoice from the dedicated address with the correct PDF.
10. Payment reminder/chase can be reviewed and explicitly sent from the dedicated address.
11. Repeated inbound webhook/send retries cannot duplicate messages/Deals.
12. Gmail and managed-address sources can coexist without silently duplicating/merging ambiguous Deals.
13. RLS, attachment storage, deletion, privacy, spam/abuse and cost controls pass tests.
14. A creator with no Gmail OAuth connection can complete the whole selected brand Deal from enquiry through creator-confirmed payment.
