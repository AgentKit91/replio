# Closed-beta release checklist

This is the authoritative go/no-go checklist for admitting creators beyond the founder account. A checked engineering item is supported by code, CI or a recorded production verification; it is not a legal, tax or provider-approval claim.

## Engineering gate

- [x] Google-only Supabase Auth and creator onboarding work in production.
- [x] Gmail ingestion is restricted to explicitly labelled `Replio` threads.
- [x] Durable Gmail, AI and send queues are idempotent, bounded and operationally visible.
- [x] Tenant RLS and service-only boundaries pass the pgTAP suite before and after a clean database rebuild.
- [x] AI outputs are schema-validated, evidence-grounded and covered by the offline launch corpus.
- [x] Creator edits, rules and send decisions outrank AI suggestions.
- [x] Founder OS hides private content unless scoped Support Mode is explicitly granted and separately activated.
- [x] Stripe test Checkout, webhook projection and Customer Portal work; Stripe Tax remains off.
- [x] Golden-path accessibility and responsive audits pass at desktop and mobile widths.
- [x] The application shell remains server-rendered with a minimal navigation-only client boundary.
- [x] HTTP security and analytics-privacy audits pass; no creator-content analytics path exists.
- [x] Recovery runbook is versioned and CI proves clean schema/RLS reconstruction.
- [x] Previous known-good Vercel production deployments remain available for instant application rollback.

## Required before inviting the first external beta creator

- [ ] Founder approves the exact Privacy Policy and Terms wording and publishes stable URLs.
- [ ] Google OAuth consent branding/policy URLs are complete; restricted Gmail-scope verification is submitted or the beta remains limited to explicitly approved test users. The audited gaps and exact submission evidence are recorded in `docs/22_GOOGLE_OAUTH_VERIFICATION.md`.
- [ ] A fresh encrypted logical database backup is created and its SHA-256 checksums are recorded outside the repository.
- [ ] A temporary isolated Supabase project is used for the first production-data restore rehearsal; no production cutover is made during the rehearsal.
- [ ] Founder selects the named beta participants and confirms the support/contact route.
- [ ] Founder confirms the provisional Standard/Pro test catalogue remains suitable for the beta; no live charge is enabled implicitly.

## Consent-gated M5 production proof

The final live loop transmits selected labelled-thread content to the configured AI provider and sends a real Gmail reply. It must not be started from a general instruction to continue.

- [ ] Founder identifies a safe labelled test thread.
- [ ] Founder explicitly authorizes transmission of that thread to the AI provider.
- [ ] Analysis completes and every material fact links to selected-thread evidence.
- [ ] Founder reviews/edits the generated draft and explicitly confirms Gmail send.
- [ ] The real reply arrives in the original Gmail thread with correct RFC threading.
- [ ] A later inbound reply syncs idempotently and moves the Deal to `Your reply needed`.

## Required before public paid launch

- [ ] Google restricted-scope verification is approved for public use.
- [ ] Launch markets, tax registrations and product tax classification are approved; only then reconsider Stripe Tax.
- [ ] Live Stripe products/prices, webhook secret and restricted server key replace the test catalogue through a separately reviewed activation.
- [ ] Managed backup retention and restore objectives are approved for the expected customer/data volume.
- [ ] Legal deletion, privacy-request and incident-response procedures are reviewed for the chosen launch markets.
- [ ] Live billing is activated only after the founder decisions and gated sequence in `docs/23_LIVE_BILLING_ACTIVATION.md`.

## No-go conditions

Do not invite or charge external creators if any of these is true:

- whole-inbox access or ingestion occurs;
- tenant isolation, queue idempotency or encryption-key recovery is unverified;
- private creator content appears in analytics, logs or Founder OS without Support Mode;
- AI invents commercial facts or acts without creator confirmation;
- Gmail send or live billing can occur without an explicit confirmation boundary;
- the previous known-good deployment or a current encrypted backup cannot be identified;
- required legal, Google or tax approval for the intended audience is missing.

