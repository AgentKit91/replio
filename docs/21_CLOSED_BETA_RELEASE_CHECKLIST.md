# Closed-beta release checklist

This is the authoritative go/no-go checklist for admitting creators beyond the founder account. A checked engineering item is supported by code, CI or recorded production verification; it is not a legal, tax or provider-approval claim.

## Existing foundation gate

The pre-7 September M0–M9 work remains valid only where unaffected by the expanded scope. Existing verified foundations include Google Auth, label-only Gmail ingestion, tenant RLS, AI structure/evidence, creator override priority, Founder OS privacy, Stripe test subscription billing, responsive shell/security and recovery foundations.

## Expanded Phase 1 engineering gate — must pass before external beta

- [ ] Selected Deal messages from either supported source automatically maintain fee/terms/deliverables/deadlines/billing facts with provenance.
- [ ] Creator overrides remain authoritative and duplicate CRM-style entry is avoided.
- [ ] Operational Deal pipeline works desktop/mobile/keyboard.
- [ ] Dashboard surfaces creator-needed actions rather than admin Rep Bureau can complete internally.
- [ ] Invoice issuer profile and invoice schemas/storage have tenant RLS and deletion coverage.
- [ ] Invoice-ready Deal opens with trusted known values pre-populated.
- [ ] Creator can review/edit/approve invoice; PDF generation is versioned/idempotent/private.
- [ ] Invoice email contains correct PDF and requires explicit send confirmation via Gmail or dedicated Rep Bureau email.
- [ ] Invoice send retries/reconciliation cannot duplicate messages/invoice numbers.
- [ ] Confirmed payment terms produce correct due dates.
- [ ] Outstanding/due/overdue states update without manual monitoring.
- [ ] Overdue state prepares a context-aware chase but never auto-sends it in Phase 1.
- [ ] Creator can mark `Paid` or `Still waiting`; received revenue is never inferred.
- [ ] Financial views distinguish agreed, invoiced, outstanding, overdue and received.
- [ ] New Deal/invoice/payment/email data is absent from analytics/logs and private in Founder OS without Support Mode.
- [ ] Existing critical Gmail/AI/negotiation/Stripe/Founder OS journeys remain green.

### Dedicated Rep Bureau email gate

- [ ] Creator can choose the dedicated-address route with no Gmail OAuth connection.
- [ ] One unique workspace-bound dedicated address is allocated/displayed.
- [ ] Direct external mail to it creates/updates the correct Deal idempotently.
- [ ] Ordinary forwarded brand email from an unconnected mailbox creates a usable Deal with forwarded-source provenance.
- [ ] Ambiguous forwarded sender/reply-to parsing cannot send to the wrong party.
- [ ] Creator-approved outbound negotiation reply from the dedicated address works and later brand reply returns to the same Deal.
- [ ] Invoice PDF can be explicitly sent from the dedicated address.
- [ ] Payment chase can be explicitly sent from the dedicated address.
- [ ] Gmail + managed-email coexistence does not silently duplicate/merge ambiguous Deals.
- [ ] Inbound attachments are private, safely handled, size/type limited and purgeable.
- [ ] Public-address spam/abuse/rate/cost controls prevent unbounded inbound processing/AI spend.
- [ ] Email-provider webhook authentication/idempotency passes.
- [ ] Sender-domain production authentication/deliverability configuration is verified for the intended beta domain/provider.
- [ ] A no-Gmail E2E test reaches creator-confirmed payment from a direct or forwarded enquiry.

- [ ] Final post-M9 accessibility, responsive, performance, security, backup/restore, abuse/spam and analytics privacy gates pass.

## Required before inviting the first external beta creator

- [ ] Founder approves Privacy Policy/Terms wording and publishes stable URLs.
- [ ] Google OAuth consent branding/policy URLs are complete; restricted Gmail-scope verification is submitted or Gmail beta remains limited to approved test users. This does not block dedicated-address-only users if all other legal/provider gates are met.
- [ ] Privacy/Terms accurately disclose Rep Bureau-hosted processing of communications sent/forwarded to dedicated creator addresses.
- [ ] Rep Bureau-controlled email domain/subdomain is approved and configured for the chosen inbound/outbound provider.
- [ ] Required current SPF/DKIM/DMARC/provider verification and inbound routing are validated.
- [ ] Fresh encrypted logical database backup/checksums are recorded outside repo.
- [ ] Isolated restore rehearsal completed.
- [ ] Founder selects beta participants and confirms support/contact route.
- [ ] Founder confirms provisional subscription catalogue remains suitable; no live charge enabled implicitly.
- [ ] Invoice issuer/legal/tax wording and generated-invoice behaviour are reviewed for intended launch markets; Rep Bureau does not claim to provide tax/accounting advice.

## Consent-gated real Gmail proof

Any live proof that transmits selected-thread content to AI or sends real Gmail requires explicit founder consent for the test thread/action.

- [ ] Safe labelled test thread identified.
- [ ] Founder explicitly authorizes AI transmission for that thread.
- [ ] Analysis/admin extraction completes with evidence.
- [ ] Founder reviews/edits a generated negotiation reply and explicitly confirms send.
- [ ] Later inbound reply syncs idempotently.
- [ ] Safe test Deal can exercise invoice review/PDF generation without exposing real sensitive bank/tax details unnecessarily.
- [ ] Any real invoice/chase Gmail send is separately and explicitly confirmed by the founder.

## Managed-email live proof

Use a safe test sender/address and do not publish a beta creator address until provider/domain controls are ready.

- [ ] Direct safe test email arrives through authenticated inbound provider webhook.
- [ ] Message creates the correct Deal once.
- [ ] Founder reviews/explicitly sends a reply from the dedicated address.
- [ ] Reply arrives externally with correct sender identity/threading.
- [ ] External reply returns to the same Deal.
- [ ] Forwarded-message fixture/live-safe test proves correct original-contact handling.
- [ ] Invoice attachment send and chase send each require explicit confirmation and remain retry-safe.

## Required before public paid launch

- [ ] Google restricted-scope verification approved for public Gmail use.
- [ ] Managed-email sender domain/provider remains healthy and deliverable at beta volume.
- [ ] Launch markets, tax registrations/product tax classification approved before changing Stripe Tax behaviour.
- [ ] Live Stripe products/prices/webhook/restricted key activated through reviewed sequence.
- [ ] Managed backup retention/restore objectives approved.
- [ ] Legal deletion/privacy-request/incident procedures reviewed for launch markets.
- [ ] Creator invoice templates/legal disclosures and treatment of tax/VAT fields reviewed for launch markets.

## No-go conditions

Do not invite or charge external creators if any of these is true:

- whole-external-inbox ingestion occurs;
- tenant isolation, queue/provider idempotency or encryption-key recovery is unverified;
- private creator email/attachment/invoice/payment data appears in analytics/logs/Founder OS without Support Mode;
- AI invents commercial/billing/payment facts or misrepresents forwarded metadata as verified;
- Gmail or managed-address send, invoice send, chase send or live platform billing can occur without the required confirmation boundary;
- ambiguous forwarding can cause a message to be sent to the wrong recipient;
- Rep Bureau can mark funds received without creator confirmation in Phase 1;
- managed-email or invoice artifacts can leak across workspaces or cannot be purged;
- public creator addresses can trigger uncontrolled processing/AI spend without abuse safeguards;
- dedicated-address sender authentication/routing is not production-verified;
- previous known-good deployment/current encrypted backup cannot be identified;
- required legal/provider/Google/tax approval for intended audience is missing.
