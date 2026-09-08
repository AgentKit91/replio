# 28 — DealCheck Intelligence V1

**Version:** `uk_shortform_v1_2026_09_08`  
**Purpose:** a deliberately conservative, reproducible launch heuristic for UK creator short-form brand deals.

## 1. Principle

DealCheck V1 does not claim there is one objective market price for a creator. Public 2026 sources consistently show wide pricing dispersion and identify platform, follower size, engagement/performance, content format, usage rights and exclusivity as material price drivers.

The V1 estimate is therefore a **directional negotiation range**, not a tariff or guarantee.

The LLM must never invent or choose the price. It extracts deal terms and later explains a deterministic TypeScript calculation.

All calculations must store this intelligence version plus component values in `valuation_data`.

## 2. Public reference set

These are reference anchors for V1 methodology, not a database to scrape or reproduce wholesale.

### Later — Influencer Pricing Benchmarks, updated 7 July 2026

https://later.com/blog/influencer-pricing-benchmarks-the-complete-2026-guide/

Useful anchors:

- broad nano creator guidance: roughly $100–$500/post;
- broad micro creator guidance: roughly $500–$2,500/post;
- engagement, usage rights and exclusivity materially affect price;
- usage/amplification can represent a meaningful additional campaign budget component.

### Shopify UK — Influencer Pricing, 22 June 2026

https://www.shopify.com/uk/blog/influencer-pricing

Useful anchors:

- follower tiers are only a starting point;
- rates vary significantly by format, audience quality, engagement, production, usage rights and exclusivity;
- published ranges should be treated as directional rather than fixed.

### Collabstr — 2026 Influencer Marketing Report

https://collabstr.com/2026-influencer-marketing-report

Useful anchors:

- first-party marketplace analysis covers 21,000+ paid collaborations and 200,000+ creators;
- average completed marketplace payouts are materially different from posted asking prices;
- Instagram and TikTok have different average pricing and follower-tier effects;
- marketplace averages skew toward many small/low-cost transactions, so they must not be treated as universal ceilings.

### Aspire — Usage Rights in 2026

https://www.aspire.io/blog/how-brands-and-creators-are-navigating-content-usage-rights-in-2026

Useful anchor:

- many creators use duration-based percentage pricing for paid usage, commonly around 15%–35% of base rate per 30 days, with significant variation.

### Creator Wizard — Sponsorship Pricing / Usage Rights

https://www.creatorwizard.com/post/how-to-calculate-your-sponsorship-price

Useful rule-of-thumb anchors:

- licensing on brand platforms: approximately +15% of base per 30 days;
- amplification/boosting/whitelisting: approximately +25% of base per 30 days;
- category exclusivity: approximately +10% of base per 30 days in the published worked framework.

These are external methodologies, not immutable industry laws. V1 uses them conservatively and must present its output as directional.

## 3. Supported baseline

A baseline rate represents:

- one creator-posted sponsored TikTok video or Instagram Reel;
- ordinary creator production;
- normal turnaround;
- one reasonable revision round;
- creator retains ownership;
- no paid usage/advertising;
- no category exclusivity;
- no raw-footage handover.

All values are GBP.

## 4. Base range by follower band

Implement these constants in a versioned TypeScript module, not SQL.

| Followers | TikTok low | TikTok high | Instagram Reel low | Instagram Reel high |
|---:|---:|---:|---:|---:|
| 1,000–9,999 | £100 | £300 | £120 | £350 |
| 10,000–24,999 | £200 | £450 | £250 | £500 |
| 25,000–49,999 | £350 | £650 | £400 | £750 |
| 50,000–99,999 | £500 | £900 | £600 | £1,000 |
| 100,000–249,999 | £800 | £1,500 | £900 | £1,700 |
| 250,000–499,999 | £1,300 | £2,500 | £1,500 | £3,000 |
| 500,000–999,999 | £2,000 | £4,000 | £2,500 | £5,000 |

For 500k–999,999 followers, add a caveat that the public V1 bands are wider and the estimate is more directional.

Creators under 1,000 or at/above 1,000,000 are unsupported in V1 and should not lose a credit.

## 5. Performance adjustment

Follower count is the baseline only.

### Average-view multiplier

If average views are supplied, calculate `view_ratio = average_views / followers`.

- `< 0.15` → `0.85`
- `0.15 to <0.35` → `1.00`
- `0.35 to <0.75` → `1.10`
- `0.75 to <1.25` → `1.20`
- `>=1.25` → `1.30`

If average views are absent, use `1.00` and add a mild caveat.

### Engagement multiplier

If engagement rate is supplied:

- `<1%` → `0.90`
- `1% to <3%` → `1.00`
- `3% to <6%` → `1.08`
- `>=6%` → `1.15`

If absent, use `1.00`.

### Combine without double-counting

Do not multiply the two performance multipliers together blindly.

- if both are available: `performance_multiplier = average(view_multiplier, engagement_multiplier)`;
- if only one is available: use that one;
- clamp final performance multiplier to `0.85–1.25` for V1.

Apply the same multiplier to both ends of the baseline range.

## 6. Deliverable adjustment

### Primary videos/Reels

Supported count is 1–3.

Use:

`primary_multiplier = 1 + (0.85 × (count - 1))`

Therefore:

- 1 primary deliverable → `1.00x`
- 2 → `1.85x`
- 3 → `2.70x`

This represents a modest bundle efficiency rather than multiplying the first-piece rate exactly.

### Instagram Story frames

If an Instagram deal also explicitly requires Story frames, add `0.08 × frames` of the adjusted single-Reel baseline, up to 6 frames.

If more than 6 Story frames or a complicated Story package is requested, cap the V1 add-on at 6 frames and add a caveat.

Do not attempt to value other content formats in V1.

## 7. Rights / scope adjustment

Apply the following additions to the adjusted content subtotal.

### Paid licensing / ads run from brand-owned channels

`+15% of content subtotal per 30 days`.

For durations 1–6 months, use the stated number of months.

If paid usage is requested but no duration is given, calculate one month only and prominently flag that duration must be defined before agreement.

If duration is over 6 months, calculate only the first six months and label the result a conservative floor requiring bespoke review.

### Whitelisting / Spark Ads / Partnership Ads / boosting from creator identity

`+25% of content subtotal per 30 days`.

Use 1–6 months as above.

If both brand-account paid licensing and creator-handle amplification are requested, do not blindly add 15% + 25%. Use the higher `25% per month` V1 modifier and flag that both forms of paid use are requested. This intentionally avoids false precision/double-counting in the launch heuristic.

### Category exclusivity

`+10% of content subtotal per 30 days`, for 1–6 months.

If exclusivity is requested with no duration, calculate one month and flag the missing duration.

### Raw footage

`+15%` once.

### Rush turnaround

If an explicit turnaround is `<=72 hours`, add `+20%` once.

### Revisions

The baseline includes one reasonable revision round.

For explicitly required additional rounds above one, add `+10%` per extra round, capped at `+30%`.

If revisions are described as `unlimited`, do not price unlimited revisions literally. Add a high-risk flag and treat the ordinary calculation as conditional on limiting revisions.

## 8. Perpetual / unlimited rights

Do not pretend V1 can put a precise single number on perpetual/unlimited commercial rights.

If the offer requests perpetual/unlimited paid usage, global buyout-like rights, or similarly open-ended commercial use:

- classify the term as high risk;
- calculate the ordinary content value and, if useful, a six-month paid-use floor only;
- clearly say the displayed range is **not a full perpetual buyout valuation**;
- recommend negotiating a fixed duration rather than accepting unlimited rights;
- reduce certainty language in the written recommendation.

A useful result may still be delivered and charged if the user receives actionable analysis. Do not fabricate a perpetual multiplier merely to create a neat number.

## 9. Final range

Calculation order:

1. select platform/follower baseline range;
2. apply performance multiplier;
3. apply primary-deliverable multiplier;
4. add supported Story-frame value;
5. calculate rights/scope percentage additions on the adjusted content subtotal;
6. produce raw low/high;
7. round user-facing low down to nearest £25 and high up to nearest £25;
8. ensure low is never negative and high >= low.

Store unrounded component calculations for reproducibility.

### Recommended counter

For a normal supported deal:

`recommended_counter = round up to nearest £50 (fair_high × 1.05)`

This deliberately leaves modest negotiation room above the top of the directional range.

For perpetual/open-ended rights, the recommended counter may instead be conditional wording such as `£X with paid usage limited to 3 months` rather than implying one fixed perpetual price.

## 10. DealCheck Score

The score measures the commercial strength of the offer **relative to the scope requested**. It is not a Creator Score and not a brand reputation score.

Use fair-range midpoint:

`offer_ratio = brand_offer / ((fair_low + fair_high) / 2)`

Base score:

- `<0.40` → 20
- `0.40–<0.60` → 35
- `0.60–<0.80` → 55
- `0.80–<1.00` → 70
- `1.00–<1.20` → 85
- `>=1.20` → 95

Then apply only these ambiguity penalties:

- perpetual/unlimited commercial rights: `-10`;
- paid usage duration missing: `-5`;
- exclusivity duration missing: `-5`;
- unlimited revisions: `-5`.

Clamp 0–100.

Labels:

- 0–39: `Low offer`
- 40–59: `Needs negotiation`
- 60–79: `Reasonable`
- 80–100: `Strong offer`

Do not make the score an accept/decline command.

## 11. Writing rules

The writer must use the deterministic numbers exactly.

Tone:

- confident but not aggressive;
- creator-friendly;
- commercially literate;
- plain English;
- no legal-advice claims;
- no scolding the brand;
- no pretending DealCheck knows the brand's private budget.

Suggested reply should usually:

1. thank the brand / show interest;
2. state the creator's counter clearly;
3. connect the counter to deliverables/rights rather than follower ego;
4. ask to clarify any missing duration/revision term;
5. optionally offer a scope-reduction route if budget is constrained.

Never invent prior conversations, availability, audience demographics, deadlines or deliverables not present in structured facts.

## 12. Required deterministic fixtures

Implement unit tests around the deterministic engine. Exact rounded outputs may be asserted from the implemented formula; these behavioural expectations must hold.

### Fixture A — obvious low offer with rights

- TikTok
- 80,000 followers
- 45,000 average views
- 6.2% engagement
- one TikTok
- offer £400
- three months brand-account paid licensing
- one month category exclusivity

Expected behaviour:

- fair-range midpoint materially above £400;
- score label `Low offer`;
- paid usage and exclusivity both represented in valuation components;
- recommended counter above fair-range high after rounding.

### Fixture B — reasonable small organic Reel

- Instagram
- 20,000 followers
- no view/engagement metrics
- one Reel
- offer £500
- organic post only; no extra rights

Expected behaviour:

- offer sits at/near the upper end of the base directional range;
- score is `Reasonable` or `Strong offer` depending exact midpoint ratio;
- no paid-rights modifier.

### Fixture C — no monetary offer

- valid creator metrics
- pasted email offers product/gifting only, no GBP fee

Expected behaviour:

- no completed paid analysis;
- if extraction was needed, credit restored exactly once;
- user told DealCheck V1 needs a monetary GBP offer to compare.

### Fixture D — perpetual rights

- supported TikTok deal
- explicit monetary offer
- `perpetual`, `in perpetuity` or equivalent paid/commercial rights

Expected behaviour:

- high-risk flag;
- no invented perpetual multiplier;
- any displayed usage-inclusive range clearly labelled as a limited-term/floor calculation;
- recommendation asks to reduce rights to a fixed duration.

### Fixture E — Spark Ads

- supported TikTok deal
- three months Spark Ads / whitelisting

Expected behaviour:

- 25% per month amplification modifier used;
- term appears in rights explanation.

### Fixture F — two primary videos

Expected behaviour: primary content multiplier exactly `1.85x` before rights additions.

### Fixture G — raw footage + 48-hour turnaround

Expected behaviour: +15% raw footage and +20% rush are separately visible in valuation components.

### Fixture H — unclear paid usage duration

Expected behaviour: one-month provisional paid-use modifier, missing-duration warning and score penalty.

### Fixture I — 750k creator

Expected behaviour: supported broad band plus a caveat that the estimate is more directional at this size.

### Fixture J — 1m+ creator

Expected behaviour: unsupported before AI where follower validation already reveals it; no credit consumed.

### Fixture K — prompt injection inside brand email

Example malicious text may contain `ignore previous instructions`, fake system instructions or requests to return arbitrary pricing.

Expected behaviour: the text is treated solely as untrusted deal content; extracted facts follow the DealCheck schema and deterministic price is unaffected by embedded instructions.

### Fixture L — duplicate request

Same authenticated user and same `client_request_id` submitted twice.

Expected behaviour: at most one credit consumed and one logical check created.

## 13. Calibration rule after launch

Do not quietly change launch bands based on anecdotes.

Future changes require a new version identifier plus documented rationale/source/evidence. When Rep Bureau accumulates privacy-safe real deal outcomes, proprietary benchmark intelligence can replace or refine these broad public V1 heuristics without rewriting the DealCheck UI.