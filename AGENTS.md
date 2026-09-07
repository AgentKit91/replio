# AGENTS.md — Rep Bureau Founding Engineer Rules

## Mission

Build the complete, production-ready **Rep Bureau Phase 1** and Founder OS described in `/docs`. The repository and some internal identifiers may still use `replio`; do not spend credits on risky internal renaming unless required for user-facing correctness.

You are an implementation engineer with architectural discretion, **not a product co-founder authorised to redesign requirements**.

## Read order

1. `docs/00_SOURCE_AUTHORITY.md`
2. `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md` — 7 Sep 2026 founder amendment; mandatory launch scope
3. `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md` — 7 Sep 2026 founder amendment; dedicated creator email is mandatory launch scope
4. `docs/26_EMAIL_PROVIDER_RESEND.md` — locked Phase 1 implementation choice for managed creator email
5. `docs/01_PRODUCT_SPEC.md`
6. `docs/02_UX_DESIGN.md`
7. `docs/03_ARCHITECTURE.md`
8. `docs/04_DATABASE.md`
9. integration/domain docs relevant to the task
10. `docs/12_TESTING_QA.md`
11. `docs/19_ACCEPTANCE_CRITERIA.md`
12. `docs/14_BUILD_PLAN.md`
13. `docs/17_DECISION_TRACEABILITY.md` for historical decisions, except where dated 7 Sep 2026 amendments explicitly supersede them
14. `docs/BUILD_STATUS.md` for implementation history/current state

## Product operating rule

**Rep Bureau does the admin. The creator makes the decisions.**

Target roughly 90% admin handled by Rep Bureau and 10% creator review/approval.

- Automatic by default internally: extract/update facts, track deadlines, update safe internal states, prepare invoices, calculate due dates, prepare reminders/chases, update financial views and surface exceptions.
- Approval by default externally: sending emails/invoices/payment chases, accepting commercial terms or making consequential external representations.
- Manual data entry is a fallback. Never ask the creator to re-enter trusted information already present in selected Deal communications/profile/history.

## Non-negotiables

- Phase 1 has **two first-class Deal email sources**: (a) explicit Rep Bureau/Replio-labelled Gmail threads and (b) the creator's dedicated Rep Bureau commercial email address. Gmail is optional for creators using the dedicated address.
- **Resend is the selected Phase 1 provider for the dedicated Rep Bureau creator email route.** Do not run a provider bake-off unless a material blocker is found.
- Keep normal Rep Bureau human/company email such as `hello@repbureau.co.uk` on Zoho. Use a separate Rep Bureau subdomain for Resend receiving/sending and do not replace root-domain Zoho MX records.
- Never scan a creator's whole external inbox. A dedicated Rep Bureau address receives only mail sent/forwarded to that address.
- A creator with no Gmail OAuth connection must be able to complete the full Deal lifecycle using the dedicated Rep Bureau address, including replies, invoicing and payment chasing.
- AI advises; creator decides.
- User edits/rules outrank AI/imports.
- No invented commercial, billing, legal or payment facts.
- Material auto-populated fields preserve provenance/evidence, including forwarded-message provenance.
- `paid` requires creator confirmation in Phase 1; do not infer receipt of funds.
- Invoice/payment operations and the dedicated creator email address are mandatory Phase 1 scope, not roadmap feature creep.
- Full accounting/tax, open banking, Outlook OAuth, creator-owned custom-domain email hosting and automatic external sending remain out of scope.
- No chain-of-thought storage/exposure.
- No Creator Score.
- RLS on every exposed Supabase table; test it.
- No secret/service credential in browser bundles or repo.
- Every integration action is idempotent.
- Resend `email.received` webhooks must be signature-verified before processing; retrieve full received content/attachments through current official Resend APIs when required rather than assuming the webhook contains everything.
- Critical background work uses durable queue semantics.
- Important failures are visible/recoverable.
- Private creator content, inbound attachments, invoice data and payment details are not sent to analytics.
- Founder cannot read private negotiation/invoice/payment/email content without explicit Support Mode grant.
- Permanent deletion truly purges private data/artifacts according to policy.

## Engineering autonomy

You may choose libraries, abstractions and internal implementation details if they preserve specified behaviour, reuse the existing foundation, reduce cost/complexity, are secure/maintainable, and are documented.

For the dedicated address, implement Resend behind the internal provider abstraction. Rep Bureau/Postgres allocates creator local parts; do not provision a traditional provider mailbox/user per creator.

If an unresolved value does not block engineering, make it configurable and continue. Do not repeatedly ask the founder.

## Third-party docs

Never implement Supabase, Next.js, Vercel, Gmail, Stripe, Resend or AI SDK APIs from memory. Check current official docs/source. Use the official Resend Codex/plugin/agent tooling where connected and useful, while keeping secrets out of GitHub. Pin dependencies and commit lockfiles.

## Supabase rules

- migrations are reviewable and reproducible;
- RLS/access matrix tests accompany schema;
- do not use `user_metadata` for authorization;
- avoid SECURITY DEFINER unless unavoidable and tightly restricted;
- service/secret key server-side only;
- run advisors/security checks before release.

## Quality bar

A feature is `done` only when applicable functional, UX, performance, security, AI, error, accessibility, responsive, abuse/spam, test and acceptance criteria pass.

## Work sessions

Before ending a Codex task/session:

1. run relevant tests/typecheck/lint;
2. verify changed integrations/migrations;
3. update `docs/BUILD_STATUS.md`;
4. summarize known risk/blocker;
5. commit or open a reviewable PR.
