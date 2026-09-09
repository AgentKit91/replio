import "server-only";
import {headers} from "next/headers";
import {publicEnv} from "@/lib/env";

export async function trustedRequestOrigin(){
  const requestHeaders=await headers();
  const host=requestHeaders.get("x-forwarded-host")?.split(",")[0]?.trim()??requestHeaders.get("host")?.trim();
  const configured=new URL(publicEnv.NEXT_PUBLIC_APP_URL);
  const trustedHosts=new Set([
    configured.host,
    process.env.VERCEL_URL,
    process.env.VERCEL_BRANCH_URL,
    process.env.VERCEL_PROJECT_PRODUCTION_URL,
    process.env.NODE_ENV==="development"?"localhost:3000":undefined,
  ].filter((value):value is string=>Boolean(value)));
  if(!host||!trustedHosts.has(host))return configured.origin;
  const forwarded=requestHeaders.get("x-forwarded-proto")?.split(",")[0]?.trim();
  const protocol=forwarded==="http"&&process.env.NODE_ENV==="development"?"http":"https";
  return `${protocol}://${host}`;
}
