# Source Authority and Precedence

This repository pack is an implementation translation of founder decisions. It is not permission to redesign the product.

## Current precedence

When instructions conflict, use this order:

1. **Dated founder scope amendments** — currently `docs/24_PHASE1_DEAL_OPERATIONS_ADMIN_AUTOMATION.md` (effective 7 September 2026). A dated amendment wins only where it explicitly changes/supersedes an older decision.
2. **Canonical Decision Register (`docs/17_DECISION_TRACEABILITY.md`)** — founder-approved historical product behaviour and reconciliations that have not been superseded by a dated amendment.
3. **Current engineering handoff/specification pack** — implementation translation of the current decisions.
4. **Technical implementation choices** — Codex may improve mechanics if observable behaviour/constraints stay intact.
5. **Old brainstorming examples** — non-authoritative unless promoted into a canonical decision.

## 7 September 2026 scope amendment

The founder has formally moved the former Phase 1.5 deal-operations scope into Phase 1/launch.

The amendment specifically supersedes older instructions that deferred:

- invoice generation/sending;
- payment tracking;
- payment reminders/overdue chasing;
- post-negotiation deliverable/deadline administration;
- creator-facing operational pipeline/financial status required to support those features.

The historical register remains intact for traceability. In particular, the older DR-041 deferral is no longer the current MVP boundary.

The amendment does **not** promote full accounting/tax, open banking/bank reconciliation, automatic payment detection, agency mode, full legal contract AI review/generation, whole-inbox opportunity detection or automatic external sending without creator approval.

## Non-negotiable conflict rules

- Creator input always outranks AI/imported data.
- Explicit Gmail labelling outranks automatic inbox-scanning ideas.
- Private permanent deletion outranks append-only retention for private creator data.
- Current dated scope amendments outrank old MVP exclusions they explicitly supersede.
- Internal AI confidence exists; a prominent creator-facing confidence score does not.
- There is no Creator Score. Rep Bureau/Replio Score belongs to the commercial opportunity.
- Do not store/expose model chain-of-thought. Store structured facts, evidence, confidence and concise rationale only.
- Automatic internal admin is encouraged; consequential external actions require creator approval in Phase 1.

## How Codex handles ambiguity

Do not stop for ordinary engineering ambiguity. Choose the simplest secure implementation that preserves product behaviour, document the choice and continue.

Only interrupt the founder when a legal/account-owner approval is required, a security/privacy blocker cannot be resolved safely, current canonical decisions genuinely contradict each other, or production activation requires a deliberately unresolved business value.

If a value is unresolved but the system can be built without it, create a configuration seam, seed a safe development/test value, keep it non-production/feature-flagged where appropriate and continue.
