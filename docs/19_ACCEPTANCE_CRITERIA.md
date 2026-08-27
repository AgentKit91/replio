# Module Acceptance Criteria

## Auth/onboarding

- Google is the only visible MVP sign-in method.
- New user gets exactly one hidden creator workspace atomically.
- Two-minute onboarding is achievable with required fields only.
- More profile questions are value-framed and deferred.
- Cross-workspace access is impossible under client credentials.

## Gmail

- Replio does not import any unlabelled thread during normal MVP operation.
- Replio label can be created/found reliably.
- Labelled thread creates one Deal even if Pub/Sub event is repeated.
- New messages in the thread sync without re-labelling.
- Gmail push auth is verified.
- Watch renewal/recovery is observable.
- Sending a draft cannot duplicate on retry.

## Deal Workspace

- Email thread visible even while AI is running/failing.
- Golden Path information order is respected.
- Mobile journey is fully usable.
- `Why?` points to evidence.
- Human-readable status tells the user what is happening/whose move.
- Draft autosaves; user edits survive refresh and AI improvement.

## AI

- All workers return validated structured outputs.
- Important missing terms are not hallucinated.
- Low-confidence material facts trigger clarification.
- Worker failures retry/degrade without breaking Deal access.
- no chain-of-thought stored.
- model routing can be changed without feature code changes.
- cost per worker/run is measurable.

## Pricing/Score

- Ideal Ask / Expected Settlement / Minimum Worthwhile Fee always distinguished.
- Replio Score is dynamic commercial-strength metric and never framed as accept/decline.
- Every score explains what would improve it.
- Benchmark data below threshold cannot influence recommendation.
- EAE is always labelled estimated and calculation is reproducible/versioned.

## Creator learning

- creator owns explicit rules.
- learned patterns only become preferences after explicit acceptance.
- no Creator Score.
- Rate Card is private.

## Billing

- trial/subscription access comes from Stripe state, not redirect.
- test catalogue centralized.
- usage entitlement cannot be bypassed client-side.
- failed billing clearly surfaced.

## Founder OS

- five core questions can be answered quickly.
- critical failures/action items visible.
- raw private negotiations hidden by default.
- support access requires explicit active creator grant.
- sensitive actions confirmed/audited.

## Deletion

- deleted Deal disappears from normal views and is restorable for 30 days.
- automatic/explicit purge works.
- purge removes private source data.
- only irreversibly anonymised aggregates survive.
