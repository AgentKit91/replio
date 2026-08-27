import Link from "next/link";
import { hasSupabaseConfig } from "@/lib/env";
import { signInWithGoogle } from "./actions";

export default async function Login({ searchParams }: { searchParams: Promise<{ error?: string }> }) {
  const { error } = await searchParams;
  const configured = hasSupabaseConfig();
  return <main className="auth-page"><section className="auth-panel">
    <Link className="wordmark" href="/">Replio</Link>
    <h1>Welcome to Replio</h1>
    <p className="muted">Sign in with Google to build your private commercial workspace.</p>
    {error ? <p className="error-text" role="alert">We couldn&apos;t sign you in. Please try again.</p> : null}
    <form action={signInWithGoogle}><button className="button button-primary" disabled={!configured} type="submit">Continue with Google</button></form>
    {!configured ? <p className="muted" role="status">Google sign-in will be available once the Supabase project is connected.</p> : null}
  </section></main>;
}
