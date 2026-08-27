import Link from "next/link";
import { completeOnboarding } from "./actions";
import { requireUser } from "@/features/auth/require-user";

export default async function Onboarding({ searchParams }: { searchParams: Promise<{ error?: string }> }) {
  await requireUser();
  const { error } = await searchParams;
  return <main className="auth-page"><section className="auth-panel onboarding-panel">
    <Link className="wordmark" href="/">Replio</Link><p className="eyebrow form-eyebrow">Your commercial baseline</p>
    <h1>Make advice yours</h1><p className="muted">Just the essentials for now. You can teach Replio more when it becomes useful.</p>
    {error ? <p className="error-text" role="alert">Please check your answers and try again.</p> : null}
    <form action={completeOnboarding} className="form-stack">
      <label>Creator name<input name="creatorName" required autoComplete="name" /></label>
      <div className="form-row"><label>Country<input name="countryCode" required minLength={2} maxLength={2} placeholder="GB" /></label><label>Currency<input name="baseCurrency" required minLength={3} maxLength={3} placeholder="GBP" /></label></div>
      <label>Primary niche<input name="niche" required placeholder="Beauty, gaming, travel…" /></label>
      <fieldset><legend>Main platforms</legend><div className="choice-row">{["instagram", "tiktok", "youtube", "other"].map((platform) => <label className="choice" key={platform}><input type="checkbox" name="platforms" value={platform} />{platform}</label>)}</div></fieldset>
      <label className="consent"><input type="checkbox" name="gmailConsent" required />I understand Replio only processes Gmail threads I explicitly label “Replio”.</label>
      <button className="button button-primary" type="submit">Create my workspace</button>
    </form>
  </section></main>;
}
