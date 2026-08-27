# Source Authority and Precedence

This repository pack is an implementation translation of the founder's Replio decision work. It is not permission to redesign the product.

## Precedence

When two instructions appear to conflict, use this order:

1. **Canonical Decision Register (`docs/17_DECISION_TRACEABILITY.md`)** — founder-approved product behaviour and explicit reconciliations.
2. **This engineering handoff pack** — the implementation translation of those decisions.
3. **Later-source amendments explicitly labelled as such** — only to fill a genuine gap; they may not revive a feature that the canonical register excludes from MVP.
4. **Technical implementation choices** — Codex may improve these if the observable product behaviour and constraints stay intact.
5. **Old brainstorming examples** — non-authoritative unless promoted into a canonical decision.

## Non-negotiable conflict rules

- Creator input always outranks AI/imported data.
- Explicit Gmail `Replio` labelling outranks earlier automatic inbox-scanning ideas.
- Private permanent deletion outranks append-only retention for private creator data.
- Tight MVP scope outranks old pricing examples that mention Phase 2 features.
- Internal AI confidence exists; a prominent creator-facing confidence score does not.
- There is no Creator Score. Replio Score belongs to the commercial opportunity.
- Do not store or expose model chain-of-thought. Store structured facts, evidence, confidence and concise rationale only.

## How Codex handles ambiguity

Do **not** stop for ordinary engineering ambiguity. Choose the simplest secure implementation that preserves product behaviour, document the choice, and continue.

Only interrupt the founder when one of these is true:

- a legal/account-owner approval is required;
- a security/privacy blocker cannot be resolved safely;
- two canonical product decisions genuinely contradict each other;
- production activation requires a business value that has deliberately been left for final sign-off.

If a value is unresolved but the system can be built without it, create a configuration seam, seed a safe development/test value, keep it non-production or feature-flagged where appropriate, and continue.
