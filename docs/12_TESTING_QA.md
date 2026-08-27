# Testing, QA and Launch Gate

## Definition of Done

A feature is not complete because it renders or the happy path works. Every applicable category must pass:

- functional behaviour;
- agreed UX/design;
- performance/perceived performance;
- security/permissions;
- AI structured behaviour;
- error/retry handling;
- accessibility;
- responsiveness;
- automated tests;
- explicit acceptance criteria.

## Test layers

### Unit

- money/currency helpers;
- status derivation;
- entitlement checks;
- source-priority/field ownership;
- score component engine/version selection;
- EAE calculation/version;
- benchmark threshold logic;
- Gmail MIME normalization/sanitization helpers;
- webhook signature/JWT validation helpers;
- AI schemas and validators.

### Database/RLS

Automated access matrix for at least:

- creator can read/write own workspace data;
- creator cannot access another workspace;
- ordinary founder/admin client cannot read private deal messages;
- global brand identity is safe;
- benchmark contribution raw data is inaccessible;
- support access only works with active scoped grant;
- deleted/purged data behaves correctly.

### Integration

- Google OAuth callback/token refresh (mock/test);
- label create/find;
- Gmail `history.list` incremental sync with fixture payloads;
- duplicate Pub/Sub notification/idempotency;
- outbound Gmail send retry safety;
- Stripe checkout/webhook state projection;
- queue retries/dead-letter;
- Realtime updates;
- PostHog privacy allowlist.

### AI contract tests

Every worker must return valid schema across fixture corpus. Test missing fields, malformed provider output, refusal, timeout and fallback. No raw prose accepted where structured output is required.

### AI evaluation corpus

Create version-controlled synthetic/redacted scenarios with expected constraints rather than pretending there is one mathematically exact fee answer. Include at least:

1. clean straightforward paid Instagram Reel offer;
2. severe lowball;
3. gifted-only offer;
4. perpetual paid usage;
5. missing usage duration;
6. broad territory;
7. exclusivity conflict;
8. slow/unclear payment terms;
9. multiple deliverables/platforms;
10. brand improves fee mid-thread;
11. brand worsens rights mid-thread;
12. creator counter included;
13. ambiguous currency;
14. creator non-negotiable conflict;
15. creator rate card materially above brand offer;
16. strong/fair opening offer;
17. insufficient benchmark data;
18. strong benchmark data;
19. conflicting messages/terms;
20. thread includes prompt-injection-like text;
21. negotiation falls through;
22. final settlement captured;
23. unrelated email accidentally labelled (must still treat as user-chosen but avoid inventing a deal);
24. duplicate notifications;
25. provider model failure/fallback.

Grow toward 50+ before production.

Evaluate:

- extraction precision on key terms;
- no fabricated facts;
- appropriate missing-term detection;
- fee recommendation range sanity;
- strategy adherence to non-negotiables;
- reply does not invent leverage/facts;
- evidence points to relevant messages;
- score direction changes sensibly when offer improves/worsens;
- cost/latency envelope.

### End-to-end browser tests (Playwright)

Critical journeys:

- Google sign-in mocked/test fixture → onboarding;
- Gmail connected state;
- labelled thread webhook fixture creates exactly one Deal;
- Deal page loads before AI complete and progressively updates;
- analysis present with Golden Path order;
- evidence/Why navigation;
- edit/autosave/reload draft;
- intentional rewrite preserves edits;
- send once;
- inbound reply updates same Deal;
- status changes;
- complete outcome/EAE;
- search/filters;
- recycle bin restore/purge;
- plan entitlement boundary;
- Founder OS operational view;
- support privacy grant/revoke;
- mobile critical journey.

## Security tests

- IDOR/BOLA across workspace ids;
- RLS bypass attempts;
- CSRF/OAuth state;
- untrusted email HTML/XSS;
- Pub/Sub unauthenticated/replayed payload;
- Stripe forged/replayed webhook;
- secrets absent from client bundle/logs;
- prompt injection in email text cannot alter system instructions;
- permanent deletion verified.

## Performance targets (engineering targets, not founder product decisions)

Use measurable budgets and refine with production telemetry:

- creator shell/navigation acknowledges action immediately;
- cached ordinary pages target sub-second server response where feasible;
- non-AI first-party API p95 target <500ms when external dependencies are not involved;
- webhook acknowledgement target <2s after durable enqueue;
- new labelled Deal analysis target normally visible within the product's intended ~20–60s window, tracked by p50/p95;
- no blocking screen while AI runs;
- Core Web Vitals target `good` thresholds on representative mobile.

## Launch Readiness Gate

Codex may not mark MVP production-ready until:

- all MVP requirements implemented;
- no Critical/High open security defects;
- critical E2E suite green;
- RLS test matrix green;
- AI eval minimum quality thresholds agreed/met;
- score version calibrated/reviewed;
- Gmail OAuth + Pub/Sub production configuration verified;
- Google verification status sufficient for intended users;
- Stripe live catalogue/trial sign-off complete;
- billing webhooks verified;
- deletion/support privacy flows verified;
- analytics privacy audit passed;
- Knowledge Library has real approved sources sufficient for launch claims;
- Founder OS can detect/recover the critical integrations;
- rollback procedure tested;
- production environment/secrets/backups reviewed;
- legal/privacy/terms founder-owned launch checks complete.
