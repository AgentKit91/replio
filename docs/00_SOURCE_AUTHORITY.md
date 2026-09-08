# Source Authority and Precedence

This repository pack is an implementation translation of founder decisions. It is not permission to redesign the product.

## Current precedence

When instructions conflict, use this order:

1. **Dated founder scope amendments** — currently:
   - `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md` (effective 7 September 2026);
   - `docs/25_PHASE1_CREATOR_EMAIL_ADDRESS.md` (effective 7 September 2026);
   - `docs/27_DEALCHECK_V1.md` (effective 8 September 2026; additive and authoritative only for the DealCheck product surface and DealCheck-prefixed resources).
   A dated amendment wins only where it explicitly changes/supersedes an older decision.
2. **Canonical Decision Register (`docs/17_DECISION_TRACEABILITY.md`)** — founder-approved historical product behaviour and reconciliations that have not been superseded by a dated amendment.
3. **Current engineering handoff/specification pack** — implementation translation of the current decisions.
4. **Technical implementation choices** — Codex may improve mechanics if observable behaviour/constraints stay intact.
5. **Old brainstorming examples** — non-authoritative unless promoted into a canonical decision.

## 7 September 2026 scope amendments

The founder has formally moved former Phase 1.5/post-launch operational features into Phase 1/launch.

### Deal Operations & Admin Automation

`docs/24...` supersedes older instructions that deferred:

- invoice generation/sending;
- payment tracking;
- payment reminders/overdue chasing;
- post-negotiation deliverable/deadline administration;
- creator-facing operational pipeline/financial status required to support those features.

The older DR-041 deferral is therefore no longer the current Phase 1 boundary.

### Dedicated Creator Email Address

`docs/25...` supersedes older instructions that deferred a Rep Bureau-managed creator inbox/custom creator email.

Current Phase 1 supports two first-class Deal email sources:

1. explicit Rep Bureau/Replio-labelled Gmail threads; and
2. an optional dedicated Rep Bureau commercial email address assigned to the creator.

Gmail OAuth is optional for creators using the dedicated address. The dedicated address may receive direct brand enquiries or forwarded brand emails and must support the full Deal lifecycle, including creator-approved outbound replies, invoice sends and payment chases.

This does **not** authorize scanning any external mailbox. It also does not promote Outlook OAuth, creator-owned custom-domain email hosting, arbitrary consumer mailbox functionality, automatic external sending, agency mode, full accounting/tax, open banking/bank reconciliation, automatic payment detection or full legal contract AI review/generation.

## 8 September 2026 DealCheck V1 amendment

`docs/27_DEALCHECK_V1.md` authorizes a small, isolated creator acquisition/product surface called **DealCheck by Rep Bureau** inside the existing application.

For DealCheck work only, `docs/27...`, `docs/28_DEALCHECK_INTELLIGENCE_V1.md` and `docs/DEALCHECK_BUILD_LEDGER.md` define the current product boundary, valuation heuristic and deadline-driven execution order.

This amendment is additive. It does **not** supersede or defer the existing Rep Bureau Phase 1 requirements in `docs/24...` or `docs/25...`, and DealCheck implementation must not destabilise those foundations. It specifically authorizes reuse of existing shared Supabase Auth, Stripe, Vercel AI Gateway, Vercel deployment and design foundations while keeping DealCheck tables/routes/credit logic isolated.

## Non-negotiable conflict rules

- Creator input always outranks AI/imported data.
- For Gmail, explicit labelling remains the only Phase 1 external-mailbox ingestion path; no whole-inbox scanning.
- Mail sent/forwarded to the creator's dedicated Rep Bureau address is an explicitly authorized Rep Bureau source and does not grant access to any other mailbox.
- Forwarded-message metadata is creator-supplied evidence unless independently provider-verified; preserve that provenance.
- Private permanent deletion outranks append-only retention for private creator data.
- Current dated scope amendments outrank old Phase 1/MVP exclusions they explicitly supersede.
- Internal AI confidence exists; a prominent creator-facing confidence score does not.
- There is no Creator Score. Rep Bureau/Replio Score and DealCheck Score belong to the commercial opportunity.
- Do not store/expose model chain-of-thought. Store structured facts, evidence, confidence and concise rationale only.
- Automatic internal admin is encouraged; consequential external actions require creator approval in Phase 1.

## How Codex handles ambiguity

Do not stop for ordinary engineering ambiguity. Choose the simplest secure implementation that preserves product behaviour, document the choice and continue.

Only interrupt the founder when a legal/account-owner approval is required, a security/privacy blocker cannot be resolved safely, current canonical decisions genuinely contradict each other, or production activation requires a deliberately unresolved business value.

If a value is unresolved but the system can be built without it, create a configuration seam, seed a safe development/test value, keep it non-production/feature-flagged where appropriate and continue.
