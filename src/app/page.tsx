import Link from "next/link";

export default function Home() {
  return (
    <main className="landing-shell">
      <nav className="landing-nav" aria-label="Primary navigation">
        <Link className="wordmark" href="/">Replio</Link>
        <Link className="button button-secondary" href="/login">Sign in</Link>
      </nav>
      <section className="hero" aria-labelledby="hero-title">
        <p className="eyebrow">Commercial intelligence for creators</p>
        <h1 id="hero-title">Better deals.<br />Less guesswork.</h1>
        <p className="hero-copy">
          Replio turns the brand emails you choose into clear commercial advice,
          stronger replies, and a living record of every negotiation.
        </p>
        <div className="hero-actions">
          <Link className="button button-primary" href="/login">Get started with Google</Link>
          <span className="privacy-note">Only emails you label Replio are processed.</span>
        </div>
      </section>
    </main>
  );
}
