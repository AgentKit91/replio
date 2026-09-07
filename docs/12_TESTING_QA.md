# Testing, QA and Launch Gate

## Definition of Done

A feature is not complete because it renders or the happy path works. Every applicable category must pass:

- functional behaviour;
- agreed UX/design;
- performance/perceived performance;
- security/permissions;
- AI structured behaviour;
- error/retry/idempotency handling;
- accessibility;
- responsiveness;
- abuse/spam/cost controls where public inbound email is involved;
- automated tests;
- explicit acceptance criteria.

## Test layers

### Unit

- money/currency helpers;
- Deal/admin/payment status derivation;
- due-date/reminder calculations;
- invoice numbering/idempotency;
- entitlement checks;
- source-priority/field ownership/provenance;
- forwarded-message metadata parsing/trust classification;
- managed-email recipient/address routing validation;
- score component engine/version selection;
- EAE calculation/version;
- benchmark threshold logic;
- Gmail MIME normalization/sanitization helpers;
- managed-email inbound normalization/sanitization helpers;
- webhook signature/auth validation helpers;
- attachment size/type policy;
- AI schemas and validators.

### Database/RLS

Automated access matrix for at least:

- creator can read/write own workspace data;
- creator cannot access another workspace;
- creator cannot read another workspace's dedicated email address/messages/attachments/invoices/payments;
- ordinary founder/admin client cannot read private Deal/email/invoice/payment content;
- global brand identity is safe;
- benchmark contribution raw data is inaccessible;
- support access only works with active scoped grant;
- deleted/purged data and private object artifacts behave correctly.

### Integration — Gmail

- Google OAuth callback/token refresh (mock/test);
- label create/find;
- Gmail `history.list` incremental sync with fixture payloads;
- duplicate Pub/Sub notification/idempotency;
- outbound Gmail send retry safety.

### Integration — dedicated Rep Bureau email

- address allocation uniqueness/idempotency;
- authenticated inbound provider webhook;
- direct inbound routes to correct workspace/address;
- repeated inbound provider event/message is idempotent;
- ordinary inline forwarded email parsing;
- `.eml`/RFC822 forwarded fixture where supported;
- ambiguous forwarded reply-to fails closed/requires review;
- outbound send from dedicated address retry/reconciliation safety;
- response threading back into same Deal;
- generated invoice attachment send;
- inbound attachment private storage/limits/deletion;
- provider error/retry/dead-letter path;
- public-address rate/spam/cost controls;
- Gmail + managed-email duplicate/possible-same-Deal handling.

### Other integration

- Stripe checkout/webhook state projection;
- queue retries/dead-letter;
- Realtime updates;
- PostHog privacy allowlist/no private email or invoice content.

### AI contract tests

Every worker must return valid schema across fixture corpus. Test missing fields, malformed provider output, refusal, timeout and fallback. No raw prose accepted where structured output is required.

Forwarded messages must carry provenance that distinguishes creator-supplied forwarded headers from provider-verified transport metadata. AI must not upgrade uncertain forwarded metadata into verified fact.

### AI evaluation corpus

Create version-controlled synthetic/redacted scenarios with expected constraints. Include at least:

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
20. prompt-injection-like email text;
21. negotiation falls through;
22. final settlement captured;
23. unrelated Gmail email accidentally labelled;
24. duplicate notifications;
25. provider model failure/fallback;
26. billing entity/address/PO/payment terms appear late in thread;
27. invoice-ready Deal with all known data;
28. conflicting billing instructions;
29. promised later payment date suppresses inappropriate chase;
30. creator confirms `Still waiting` then later `Paid`;
31. direct brand enquiry to dedicated Rep Bureau address;
32. ordinary forwarded brand email with clear original sender;
33. forwarded message with ambiguous/missing original reply-to;
34. malicious forwarded headers attempting recipient confusion;
35. managed-address spam/bulk message that should not trigger full expensive analysis;
36. Gmail and managed-address copies that may represent same Deal and must not be silently merged when ambiguous.

Maintain/grow the existing 50+ corpus rather than replacing it.

Evaluate:

- extraction precision on key terms;
- provenance correctness;
- no fabricated facts;
- appropriate missing-term detection;
- fee recommendation range sanity;
- strategy adherence to non-negotiables;
- reply does not invent leverage/facts;
- evidence points to relevant normalized messages;
- score direction changes sensibly when offer improves/worsens;
- forwarded-contact safety;
- cost/latency envelope.

### End-to-end browser tests (Playwright)

Critical shared journeys:

- Google sign-in mocked/test fixture → onboarding;
- creator chooses Gmail or dedicated-address source;
- Deal page loads before AI complete and progressively updates;
- analysis present with Golden Path order;
- evidence/Why navigation;
- edit/autosave/reload draft;
- intentional rewrite preserves edits;
- send once;
- inbound reply updates same Deal;
- operational pipeline/status/deadlines;
- invoice preparation/review/PDF/send;
- payment due/overdue/chase/`Paid`/`Still waiting`;
- complete outcome/EAE;
- search/filters;
- recycle bin restore/purge;
- plan entitlement boundary;
- Founder OS operational view;
- support privacy grant/revoke;
- mobile critical journey.

Gmail E2E:

- Gmail connected state;
- labelled thread webhook fixture creates exactly one Deal;
- later reply updates same Deal;
- invoice/chase Gmail sends preserve threading and confirmation/idempotency.

Dedicated-address E2E:

- creator with **no Gmail OAuth connection** gets a dedicated address;
- direct inbound external message creates exactly one Deal;
- creator-approved reply sends from dedicated address;
- external reply returns into same Deal;
- forwarded brand email from unconnected mailbox creates a safe Deal;
- invoice PDF sends from dedicated address after explicit confirmation;
- payment chase sends after explicit confirmation;
- creator-confirmed payment completes/updates Deal;
- same no-Gmail journey works on representative mobile.

## Security tests

- IDOR/BOLA across workspace ids;
- RLS/storage cross-tenant attempts;
- CSRF/OAuth state;
- untrusted email HTML/XSS;
- prompt injection in Gmail/managed-email text/attachments cannot alter system instructions;
- Pub/Sub unauthenticated/replayed payload;
- managed-email webhook forged/replayed payload;
- malicious/ambiguous forwarded headers cannot redirect outbound mail silently;
- oversized/unsafe managed-email attachment handling;
- Stripe forged/replayed webhook;
- secrets absent from client bundle/logs;
- private email/attachment/invoice/payment data absent from analytics;
- permanent deletion verified, including private object storage.

## Performance and cost targets

Use measurable budgets and refine with telemetry:

- creator shell/navigation acknowledges action immediately;
- cached ordinary pages target sub-second server response where feasible;
- non-AI first-party API p95 target <500ms when external dependencies are not involved;
- inbound webhooks acknowledge quickly after durable persistence/enqueue;
- new selected Deal analysis normally becomes visible in the intended ~20–60s window;
- no blocking screen while AI runs;
- duplicate/spam managed-email events do not trigger repeated expensive AI;
- public inbound volume has bounded message/attachment/AI processing;
- Core Web Vitals target `good` thresholds on representative mobile.

## Launch Readiness Gate

Codex may not mark Phase 1 production-ready until:

- all current Phase 1 requirements in docs 24/25 implemented;
- no Critical/High open security defects;
- critical Gmail and no-Gmail dedicated-address E2E suites green;
- RLS/private-storage test matrix green;
- AI eval minimum quality thresholds agreed/met;
- score version calibrated/reviewed;
- Gmail OAuth + Pub/Sub production configuration verified for Gmail users;
- Google verification status sufficient for intended Gmail users;
- dedicated Rep Bureau email domain/provider inbound + outbound configuration verified;
- current sender authentication/deliverability requirements verified for the managed-email domain;
- public-address spam/abuse/rate/cost controls verified;
- managed-email attachment safety/privacy/deletion verified;
- Stripe live catalogue/trial sign-off complete;
- billing webhooks verified;
- deletion/support privacy flows verified;
- analytics privacy audit passed;
- Knowledge Library has real approved sources sufficient for launch claims;
- Founder OS can detect/recover critical Gmail/managed-email/queue/Stripe integrations without exposing private content;
- rollback procedure tested;
- production environment/secrets/backups reviewed;
- legal/privacy/terms founder-owned launch checks complete, including hosted dedicated-address communication disclosures.
