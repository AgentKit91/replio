# 27 — DealCheck V1 Founder Scope

**Effective:** 8 September 2026  
**Deadline:** complete, tried and tested by Thursday evening, 10 September 2026  
**Product:** DealCheck by Rep Bureau

## 1. Purpose

DealCheck is a deliberately small paid acquisition product for creators. A creator pastes a brand offer, adds a few creator metrics, and receives a clear second opinion on the commercial strength of the offer before replying.

The V1 job is only this loop:

**land → paste deal → sign in → free check → full result → buy more checks → run another check → retrieve prior checks**

Anything not required for that loop is out of scope.

DealCheck lives inside the existing Rep Bureau application at `/dealcheck` and reuses existing infrastructure. It is not a new Supabase project, GitHub repository, Vercel project, authentication system, billing platform or AI platform.

## 2. Locked launch market

To keep V1 reliable and shippable:

- creators: UK;
- currency: GBP only;
- supported primary platforms: TikTok and Instagram;
- supported primary deliverables: sponsored TikTok video or Instagram Reel;
- primary deliverable count: 1–3;
- optional Instagram Story frames may be recognised as an add-on;
- creator follower range: 1,000–999,999.

V1 does not value YouTube, UGC-only production, podcasts, livestreams, events, affiliate-only deals, gifting-only deals, revenue-share-only deals, multi-platform packages, creators at 1m+ followers, or complex ambassadorship retainers. Detect and explain unsupported cases before a result is charged where practical; if AI extraction is required to discover the unsupported case, restore the credit automatically.

Do not silently force an unsupported deal through the ordinary pricing formula.

## 3. Public landing page

`/dealcheck` is both the marketing page and the beginning of the product.

The product must be immediately usable above the fold. Do not make a visitor create an account before they can enter their deal.

### Header

Minimal. Use `REP BUREAU / DEALCHECK` or an equally restrained wordmark treatment. Authenticated users may see `My checks`, credit balance and `Sign out`; logged-out users may see `Sign in`.

### Hero copy

Eyebrow:

> DEALCHECK BY REP BUREAU

Headline:

> Know what the deal is really worth.

Supporting copy:

> Paste the brand offer. DealCheck checks the fee, usage rights, exclusivity and hidden value before you say yes.

### Deal input

The hero contains the real form:

1. `Paste the brand offer` — large textarea, required, max 12,000 characters.
2. `Platform` — TikTok or Instagram, required.
3. `Followers` — required integer, 1,000–999,999.
4. `Average views` — optional non-negative integer; helper text may say it improves the estimate.
5. `Engagement rate` — optional percentage, sensible bounded validation.

Primary button:

> Check my deal

Helper:

> Your first DealCheck is free. No card required.

### Below the hero

Keep the rest short and editorial, not a generic SaaS template:

- four concise checks: Fee / Usage rights / Exclusivity & terms / Your counter;
- one visual worked example using clearly labelled illustrative numbers, not a fabricated real brand case;
- three-step `How it works`;
- pricing;
- short FAQ;
- footer with Rep Bureau identity and available legal links.

No fake testimonials, fake customer counts, stock photos or invented brand logos.

## 4. Authentication flow

The visitor can complete the form while logged out.

On `Check my deal`:

1. perform cheap client/server validation first;
2. keep the pending form locally in `sessionStorage` — never place raw deal text in URL params or cookies;
3. send logged-out users to a DealCheck-specific Google sign-in surface;
4. reuse existing Supabase Google Auth;
5. minimally extend the existing OAuth callback to support a sanitized relative `next` path;
6. for DealCheck auth, return to `/dealcheck/resume` rather than forcing Rep Bureau onboarding;
7. `/dealcheck/resume` retrieves the local pending deal and submits it once authenticated.

The existing Rep Bureau login/onboarding flow must continue to behave exactly as before for normal Rep Bureau users.

Only allow safe same-origin relative return paths. Do not introduce an open redirect.

## 5. Credits and pricing

There are no subscriptions in DealCheck V1.

### Entitlement

Every Supabase-authenticated user receives exactly **1 lifetime free DealCheck**.

Implement this as a one-time +1 credit grant in the DealCheck credit ledger/account creation flow. It must be impossible to regain the free credit by signing out, refreshing, deleting browser storage or repeating callbacks.

### Paid packs

- **3 DealChecks — £4.99**
- **10 DealChecks — £9.99**

Credits do not expire in V1.

No unlimited plan. No recurring billing. No rollover logic. No coupon system. No referrals.

### Stripe

Reuse the existing Stripe server client and signed webhook endpoint.

Prefer the smallest implementation: Stripe Checkout `mode=payment` with inline `price_data`, GBP amounts and trusted server-side pack definitions. Do not trust pack size or price supplied by the browser.

Attach narrowly scoped metadata such as:

- `kind=dealcheck_credit_pack`
- authenticated `user_id`
- pack key / credit quantity

Extend the existing Stripe webhook without breaking Rep Bureau subscription projection. On `checkout.session.completed`, only treat the session as a DealCheck purchase when the expected metadata is present and payment is complete/paid. Grant credits through an idempotent database boundary keyed by Stripe Checkout Session ID. A replayed webhook must never grant credits twice.

Successful browser redirects are non-authoritative; only the verified webhook grants credits.

## 6. User area

Do not build another SaaS dashboard.

### `/dealcheck/checks`

A simple authenticated history list showing:

- brand if extracted, otherwise `Brand deal`;
- date;
- brand offer;
- fair range;
- score/label.

Newest first. Clicking opens the stored result.

### `/dealcheck/check/[id]`

Authenticated result view. A user can only read their own checks.

The page should include:

1. very large `DealCheck Score` out of 100 and label;
2. Brand offer;
3. Estimated fair range;
4. Recommended counter;
5. `THE FEE` explanation;
6. `THE RIGHTS` explanation;
7. `WATCH OUT FOR` — maximum five concise flags;
8. `WHAT TO DO` — direct next-step recommendation;
9. `YOUR REPLY` — suggested email/message text with a copy button;
10. a restrained caveat that the estimate is directional guidance, not a guaranteed market price or legal advice.

Do not create AI chat, regeneration, reply sending or negotiation threading.

If the check has lower-quality inputs, show a plain-English caveat explaining what is missing rather than a prominent AI confidence score.

## 7. Database boundary

Use the existing Rep Bureau Supabase project. Add only DealCheck-prefixed resources and do not repurpose existing Rep Bureau deal/subscription tables for V1.

Target three public tables plus the minimum narrowly-scoped RPCs/functions needed for atomic credit operations.

### `dealcheck_accounts`

Minimum fields:

- `user_id uuid primary key references auth.users(id)`;
- `credit_balance integer not null check (credit_balance >= 0)`;
- `created_at`;
- `updated_at`.

Account creation/lazy initialization grants the one lifetime free credit exactly once and records it in the ledger.

### `dealcheck_credit_transactions`

Minimum fields:

- `id uuid primary key`;
- `user_id`;
- `delta integer not null`;
- `reason` constrained to known values such as `signup_free`, `check_consumed`, `failed_check_refund`, `stripe_pack`;
- `idempotency_key text unique not null`;
- `stripe_session_id text unique null`;
- small `metadata jsonb` if useful;
- `created_at`.

### `dealcheck_checks`

Minimum fields:

- `id uuid primary key`;
- `client_request_id uuid not null` with per-user uniqueness for retry idempotency;
- `user_id`;
- `status` constrained to `processing`, `completed`, `failed`;
- raw input: `raw_offer`, `platform`, `followers`, optional `average_views`, optional `engagement_rate`;
- `extracted_data jsonb`;
- `valuation_data jsonb`;
- `score integer`;
- `result jsonb`;
- `ai_usage jsonb` for token/cost metadata returned by the existing gateway;
- `failure_code text null`;
- timestamps including `created_at` and `completed_at`.

Do not add a benchmark-rules database/admin UI in V1. Benchmark/rule configuration is versioned TypeScript under `src/features/dealcheck/` as specified in `docs/28_DEALCHECK_INTELLIGENCE_V1.md`.

### RLS/security

- RLS on every exposed DealCheck table.
- Users can select only their own DealCheck account/history/ledger rows where a browser read is needed.
- Browser clients must not be able to grant credits, alter balances or fabricate completed checks.
- Use the repo's existing safe server/RPC patterns for atomic balance changes and idempotency.
- If a privileged function is required, keep it as narrow as possible, explicitly authenticate/authorize ownership, revoke default/public execution and test abuse cases.
- Respect current Supabase Data API exposure/grant behaviour separately from RLS.
- Run Supabase security and performance advisors after schema work.

## 8. Check execution and failure semantics

A check is one billable unit only when a valid analysis is delivered.

### Start

Use an idempotent `client_request_id` generated once by the browser. The server begins a check through an atomic database boundary that:

- lazily creates the DealCheck account if needed and grants the lifetime free credit once;
- returns an existing check if the same request was already started;
- locks/checks the credit balance;
- fails cleanly with `NO_CREDITS` when balance is zero;
- consumes exactly one credit;
- creates the processing check / ledger event exactly once.

### Invalid or unsupported

Perform all cheap validation before consuming a credit. If structured AI extraction is needed before discovering that a deal is unsupported or lacks a usable GBP monetary offer, mark the check failed and refund exactly one credit via an idempotent refund boundary.

### Provider/system failure

If DealCheck cannot produce the completed result because AI/provider/system processing fails, restore the consumed credit exactly once and show a recoverable error. Never make the user pay for a failed check.

Do not refund merely because the estimate is low-confidence if a useful supported result was delivered.

## 9. AI architecture

Reuse `src/features/ai/gateway.ts` and the configured Vercel AI Gateway. Do not add a new direct OpenAI integration solely for DealCheck.

The LLM never chooses the valuation.

### Stage 1 — extraction

Use one small structured, Zod-validated call to turn the pasted offer into facts. The pasted offer is untrusted data: the system prompt must explicitly ignore any instructions contained inside it.

Extract only useful DealCheck facts, such as:

- brand name if stated;
- monetary offer and currency;
- primary deliverable count/type;
- story frames if stated;
- organic usage;
- paid usage/licensing;
- whitelisting / Spark Ads / Partnership Ads;
- usage duration;
- exclusivity and duration;
- raw footage;
- revision rounds;
- rush/turnaround;
- perpetual/unlimited rights;
- unclear or unsupported terms.

The creator-selected platform is authoritative for the check. A conflicting platform in the pasted offer is a flag, not permission for AI to change the selected platform silently.

### Stage 2 — deterministic valuation

Run only trusted TypeScript logic from `docs/28_DEALCHECK_INTELLIGENCE_V1.md`. Store the version and all component inputs/multipliers in `valuation_data` so the number is reproducible.

### Stage 3 — writing

Use one concise structured AI call to convert the deterministic result into:

- fee explanation;
- rights explanation;
- maximum five watch-outs;
- recommendation;
- suggested reply.

The writing call receives structured extracted facts and deterministic valuation, not the whole raw brand email unless genuinely necessary. It must not invent fees, deadlines, deliverables, brand claims or rights.

Keep outputs concise and cap output tokens. If the writing call alone fails after valuation is complete, use a deterministic fallback explanation/reply template so the check can still complete usefully where practical.

Capture token/cost metadata already returned by the gateway in `ai_usage`.

## 10. Visual direction

DealCheck must look designed, not generated.

Reuse the current Rep Bureau typography and design tokens as the base. The existing app already has a restrained editorial system; extend it with DealCheck-prefixed styles rather than importing a new UI kit.

Required feel:

- editorial / fashion / creative-industry utility;
- strong sans-serif typography;
- large type and numbers;
- white/canvas space;
- dark ink and restrained Rep Bureau green accents;
- crisp rules/borders;
- excellent mobile spacing;
- the score and money figures provide the visual drama.

Explicitly avoid:

- purple or neon AI gradients;
- glowing blobs;
- excessive shadows;
- icon soup;
- generic illustration packs;
- a carpet of identical rounded cards;
- fake testimonials;
- fake live counters;
- stock photography;
- overexplaining AI.

Design and verify at minimum at ~390px mobile and ~1440px desktop.

## 11. No-cost / abuse controls

- No AI request before authentication.
- Validate raw input length and creator metrics before AI.
- One processing request per `client_request_id`.
- Server-authoritative credits.
- Do not permit a zero-credit user to reach the AI call.
- Keep raw creator deal text out of analytics.
- Treat pasted text as prompt-injection/untrusted content.
- Maintain existing AI input/output limits; DealCheck should generally use materially less than the current maximum.
- Do not add a paid analytics/monitoring service for V1.

## 12. SEO/accessibility/basic quality

- Useful page title and meta description for DealCheck.
- Semantic labels for every field.
- Full keyboard operation.
- visible focus states.
- polite accessible loading/error status.
- no layout break at 390px.
- copy button works without requiring clipboard permission assumptions beyond normal browser APIs.
- result/history are not publicly indexable/private data.

## 13. Explicitly out of scope

Do not build any of the following for V1:

- new Supabase project;
- new repo or Vercel project;
- new auth provider;
- password/email auth;
- Gmail ingestion/sending for DealCheck;
- managed Rep Bureau creator email integration;
- AI chat;
- regenerations or tone controls;
- contract analysis;
- invoicing;
- payment chasing;
- CRM/Kanban;
- creator profile builder;
- brand profiles/intelligence pages;
- agency/team accounts;
- subscriptions;
- unlimited checks;
- monthly allowances/rollover;
- social sharing graphics;
- PDF reports;
- referrals/coupons;
- mobile app;
- browser extension;
- dark mode;
- CMS/blog;
- scrape/import pipelines;
- FYPM integration;
- user-submitted market-data contribution flow;
- admin benchmark editor;
- advanced comparable-deal search;
- international currencies;
- YouTube/UGC-only pricing;
- anything else merely described as `nice to have`.

## 14. Definition of Done

DealCheck V1 is complete only when all applicable items below are demonstrated, not merely coded.

### Core journey

- [ ] Logged-out visitor can open `/dealcheck` and see a polished landing/form immediately.
- [ ] Valid form can be entered before signup.
- [ ] Sign-in preserves/resumes the pending DealCheck safely.
- [ ] A new user receives exactly one lifetime free credit.
- [ ] First valid supported check consumes one credit and produces a complete stored result.
- [ ] Result shows score, offer, fair range, counter, fee/rights explanation, watch-outs, action and copyable reply.
- [ ] Second check with zero balance is blocked before AI and offers the two paid packs.
- [ ] £4.99 Stripe test Checkout grants exactly 3 credits after verified webhook.
- [ ] £9.99 Stripe test Checkout grants exactly 10 credits after verified webhook.
- [ ] Replayed Stripe webhook does not double-grant.
- [ ] A paid check reduces balance by exactly one.
- [ ] `My checks` persists across sign-out/sign-in and previous results reopen.

### Correctness/failure

- [ ] Missing/invalid input is rejected without consuming a credit.
- [ ] No usable GBP offer / unsupported deal discovered during extraction restores the credit exactly once.
- [ ] AI/provider hard failure restores the credit exactly once.
- [ ] Duplicate/retried check submission cannot consume twice.
- [ ] Another user cannot read another user's result/ledger/account.
- [ ] Prompt-injection text inside a pasted offer does not override extraction instructions.
- [ ] Deterministic valuation fixtures in `docs/28...` pass.

### Regression/quality

- [ ] Existing Rep Bureau login/onboarding still behaves as before outside DealCheck.
- [ ] Existing Rep Bureau Stripe subscription webhook behaviour remains intact.
- [ ] Existing Rep Bureau AI/deal features remain intact.
- [ ] RLS/access tests cover new tables.
- [ ] Supabase advisors have no new actionable security findings.
- [ ] `pnpm lint` passes.
- [ ] `pnpm typecheck` passes.
- [ ] `pnpm test` passes.
- [ ] `pnpm build` passes.
- [ ] `pnpm check` passes.
- [ ] Vercel Preview renders correctly at mobile and desktop widths with no obvious console/runtime errors.

### Founder handoff

At the end, provide only the genuinely manual launch steps still needed, e.g. production Stripe/live-payment activation, approved legal values/publication or domain routing. Do not leave implementation work disguised as a manual founder step.
