import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";

import { legalPublicationConfig } from "@/lib/env.server";

export const metadata: Metadata = { title: "Terms of Service — Replio", robots: { index: true, follow: true } };

export default function TermsPage() {
  const legal = legalPublicationConfig();
  if (!legal) notFound();

  return <main className="legal-shell"><Link className="wordmark" href="/">Replio</Link><article className="legal-document">
    <p className="eyebrow">Effective {legal.LEGAL_EFFECTIVE_DATE}</p><h1>Terms of Service</h1>
    <p>These terms are between you and {legal.LEGAL_ENTITY_NAME}, at {legal.LEGAL_POSTAL_ADDRESS}. Contact <a href={`mailto:${legal.LEGAL_CONTACT_EMAIL}`}>{legal.LEGAL_CONTACT_EMAIL}</a>. By creating an account or using Replio, you agree to these terms.</p>
    <h2>The service</h2><p>Replio helps creators organise selected brand conversations, understand commercial terms and prepare replies. Replio processes only Gmail threads you label Replio. AI outputs are suggestions, may be incomplete or wrong, and are not legal, tax, financial or professional representation. You remain responsible for reviewing advice, contracts, facts and every message you send.</p>
    <h2>Your account and permissions</h2><p>You must be at least 18, provide accurate account information, protect access to your Google account and use Replio only for conversations you are entitled to process. Google and Gmail access is subject to Google’s terms. You can disconnect Gmail, but this may prevent further syncing or sending.</p>
    <h2>Creator control</h2><p>Replio will not send a Gmail reply without your explicit confirmation. Your edits, rules and non-negotiables outrank generated suggestions. Support cannot read private negotiations by default; scoped access requires your time-limited Support Mode grant and a separately audited support session.</p>
    <h2>Plans, trials and payment</h2><p>Plan features, monthly price, trial length, billing date and any taxes will be shown before you subscribe. Paid subscriptions renew monthly until cancelled through the billing portal. Cancellation stops future renewal and access continues through the paid period unless law requires otherwise. Trial and refund wording must be confirmed for the selected launch market before live billing is activated.</p>
    <h2>Acceptable use</h2><p>Do not use Replio unlawfully; infringe another person’s rights; upload malicious code; attempt to access another workspace; bypass limits or security controls; misrepresent AI output as guaranteed fact; or use the service to send spam, harassment or deceptive communications. We may restrict access proportionately to protect users, providers or the service.</p>
    <h2>Your content and Replio’s software</h2><p>You retain rights in your emails, drafts, notes and instructions. You give Replio a limited permission to process them only to provide, secure and support the service as described in the Privacy Policy. Replio and its licensors retain rights in the software, design and documentation. Feedback may be used without identifying you or exposing private content.</p>
    <h2>Availability and changes</h2><p>We aim to provide Replio with reasonable care and skill but do not promise uninterrupted availability or any particular negotiation outcome. We may make proportionate security, provider or product changes. Material changes to these terms will be explained in advance where required; changes will not remove accrued statutory rights.</p>
    <h2>Liability</h2><p>Nothing in these terms excludes liability that cannot lawfully be excluded, including liability for death or personal injury caused by negligence, fraud, or your mandatory statutory rights. Subject to that, the final liability cap and treatment of business losses require founder/legal approval before publication and must be fair for the launch audience.</p>
    <h2>Ending the agreement</h2><p>You may stop using Replio and cancel a paid subscription at any time. You may request account deletion, subject to limited lawful retention. We may suspend or terminate for material breach, security risk or legal necessity, normally with notice and a reasonable opportunity to remedy where appropriate.</p>
    <h2>Law and disputes</h2><p>These terms are governed by {legal.LEGAL_GOVERNING_LAW}. Mandatory consumer protections and rights to use local courts are not displaced. Please contact {legal.LEGAL_CONTACT_EMAIL} first so we can try to resolve concerns promptly.</p>
    <p><Link href="/privacy">Read the Privacy Policy</Link></p>
  </article></main>;
}

