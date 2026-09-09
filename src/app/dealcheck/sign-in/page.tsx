import Link from "next/link";
import {hasSupabaseConfig} from "@/lib/env";
import {signInToDealCheck} from "./actions";

export const dynamic="force-dynamic";

export default async function DealCheckSignIn({searchParams}:{searchParams:Promise<{error?:string}>}){
  const {error}=await searchParams;
  return <main className="dealcheck-auth"><section className="dealcheck-auth-panel">
    <Link className="dealcheck-wordmark" href="/dealcheck">REP BUREAU / DEALCHECK</Link>
    <p className="dealcheck-kicker">Your first check is free</p><h1>Save your deal, then see what it is worth.</h1>
    <p>Continue with Google. Your pasted offer stays in this browser until you return.</p>
    {error?<p role="alert">We couldn&apos;t sign you in. Please try again.</p>:null}
    <form action={signInToDealCheck}><button className="dealcheck-button" disabled={!hasSupabaseConfig()}>Continue with Google</button></form>
  </section></main>;
}
