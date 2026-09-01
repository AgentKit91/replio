import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";

import { legalPublicationConfig } from "@/lib/env.server";

export const metadata: Metadata = { title: "Privacy Policy — Replio", robots: { index: true, follow: true } };

export default function PrivacyPage() {
  const legal = legalPublicationConfig();
  if (!legal) notFound();

  return <main className="legal-shell"><Link className="wordmark" href="/">Replio</Link><article className="legal-document">
    <p className="eyebrow">Effective {legal.LEGAL_EFFECTIVE_DATE}</p><h1>Privacy Policy</h1>
    <p>{legal.LEGAL_ENTITY_NAME} (“Replio”, “we”, “us”) is the controller of personal information handled through Replio. Contact us at <a href={`mailto:${legal.LEGAL_CONTACT_EMAIL}`}>{legal.LEGAL_CONTACT_EMAIL}</a> or {legal.LEGAL_POSTAL_ADDRESS}.</p>
    <h2>What Replio processes</h2><p>We process account and profile details, subscription and operational records, support requests, and the Gmail conversations you explicitly select by applying the Replio label. For selected conversations this can include participants, addresses, subjects, message text, attachment metadata, commercial terms, private notes, drafts and analysis. Replio does not scan or import your whole inbox.</p>
    <h2>Why we use it</h2><ul><li>Provide, secure and support the service and perform our contract with you.</li><li>Analyse only selected commercial conversations, create editable advice and send a reply only when you confirm.</li><li>Operate billing, prevent abuse, diagnose generic failures and meet legal obligations.</li><li>Improve your private experience from instructions you explicitly save. Observed preferences do not become rules without your acceptance.</li><li>Create aggregate commercial benchmarks only from unlinkable structured contributions that meet our minimum privacy threshold.</li></ul>
    <p>The proposed lawful bases are contract, legal obligation and our legitimate interests in securing and operating the service. Any processing described as consent-based can be withdrawn prospectively. These bases require founder/legal approval before publication.</p>
    <h2>AI and automated processing</h2><p>Selected-thread content is sent to configured AI infrastructure only when you request analysis or a rewrite. AI provides advice and drafts; it does not make solely automated decisions with legal or similarly significant effects. You decide whether to rely on, edit or send any output.</p>
    <h2>Who receives information</h2><p>Service providers include Supabase for database and authentication, Vercel for application hosting and AI routing, Google for sign-in and Gmail access, configured AI model providers for requested analysis, and Stripe for subscription billing. Access is limited to what each service needs. Replio does not sell personal information.</p>
    <h2>Google user data</h2><p>Replio uses Google user data only to provide the user-facing Gmail features you request. We do not use or transfer Google user data for personalised advertising, credit decisions, or to train generalised AI or machine-learning models. Human access is prohibited except with your affirmative, time-limited Support Mode permission, for security or abuse investigation, to comply with law, or where the data has been aggregated and anonymised. Replio’s use and transfer of information received from Google APIs adheres to the <a href="https://developers.google.com/terms/api-services-user-data-policy">Google API Services User Data Policy</a>, including the Limited Use requirements.</p>
    <h2>International transfers</h2><p>Some providers may process information outside the UK. We use the provider and contractual safeguards applicable to each transfer. Before publication, Replio will document the relevant destinations, adequacy decisions and UK transfer safeguards and explain how to request a copy.</p>
    <h2>Retention and deletion</h2><p>Active account and selected Deal information is kept while needed to provide Replio. Deleted Deals remain recoverable for 30 days and are then purged with associated private messages, notes, drafts and analysis, unless an earlier permanent deletion is requested or law requires retention. Billing, security and audit records are retained only for applicable legal, fraud-prevention and accountability periods. Irreversibly de-identified aggregate contributions may remain because they cannot be linked back to a creator.</p>
    <h2>Your choices and rights</h2><p>You can remove the Replio Gmail label, disconnect Gmail, revoke Support Mode and request access, correction, deletion, restriction, portability or objection where applicable. You can withdraw consent where consent is the basis used. Contact {legal.LEGAL_CONTACT_EMAIL}. You may also complain to the UK Information Commissioner’s Office at <a href="https://ico.org.uk/make-a-complaint/">ico.org.uk</a>.</p>
    <h2>Security and changes</h2><p>We use tenant access controls, encrypted OAuth tokens, authenticated webhooks, audited privileged actions and explicit send confirmation. No internet service is risk-free. We will update this notice when our processing materially changes and show a new effective date.</p>
    <p><Link href="/terms">Read the Terms of Service</Link></p>
  </article></main>;
}

