# Commercial Logic: Offers, Benchmarks, Score and ROI

## Deal money model

Preserve the chronology of money:

- brand initial offer;
- creator counter(s);
- brand revised offers;
- agreed/final fee;
- Replio recommendation snapshots at each relevant stage.

All amounts carry currency and time/source.

## Three fee recommendations

Every pricing analysis returns:

1. **Ideal Ask** — ambitious but commercially reasoned opening/target ask.
2. **Expected Settlement** — where Replio believes the negotiation is reasonably likely to settle based on evidence.
3. **Minimum Worthwhile Fee** — creator-specific floor beneath which Replio believes the commercial exchange becomes unattractive, without making the decision for the creator.

The creator's explicit non-negotiables/minimums cannot be silently lowered by AI.

## Commercial Benchmark Engine

The moat is aggregated outcome intelligence, not exposure of individual creator deals.

Potential dimensions:

- brand;
- niche;
- platform;
- follower/creator-size bucket;
- engagement bucket;
- deliverable signature;
- usage rights;
- exclusivity;
- territory;
- campaign type;
- seasonality;
- currency/region.

Potential outputs:

- typical first-offer range;
- typical negotiated/settled range;
- median/percentile uplift;
- negotiation success/flexibility;
- typical response time;
- common commercial sticking points.

### Privacy threshold

A benchmark must not influence a recommendation below the configured minimum evidence threshold. Below it, say the evidence is insufficient. Do not reveal individual creator outcomes, tiny cohorts or data that could enable re-identification.

Exact minimum sample size is a production configuration requiring privacy/product calibration; implement the gate now and keep a conservative dev/test setting clearly labelled.

## Brand intelligence

Brand identity can be shared; creator relationships stay private. Learn aggregate brand behaviour only through privacy-safe benchmark contributions.

Do not seed made-up `Gymshark usually pays X` claims.

## Replio Score

Score semantics:

> A measure of the current commercial strength of the opportunity, based on everything Replio knows at that moment.

It is not:

- an accept/decline command;
- a brand reputation score;
- a creator score.

The Score changes when terms change. Every score has a concise `This score could improve if…` explanation.

## Estimated Additional Earnings (EAE)

This is Replio's North Star and must always be labelled **Estimated**.

### Conservative MVP calculation

Where an initial brand offer and later agreed/current negotiated offer exist, the simplest defensible attribution is the positive negotiated uplift while Replio was involved. Example from the decision source: £500 initial → £1,250 agreed = **£750 estimated additional earnings**.

Implementation requirements:

- store calculation method/version and inputs;
- never count negative uplift as positive earnings;
- avoid double-counting revised offers;
- distinguish `potential additional value` on an active Deal from `estimated additional earnings` after a negotiated outcome;
- provide a collapsed `How we estimated this` explanation;
- multi-currency totals must use explicit base currency and versioned FX snapshots, or remain separated by currency until a conversion source is configured. Never silently add GBP + USD.

### Secondary value measures

- deal uplift percentage;
- risky/missing terms improved;
- completed deals;
- negotiation rounds/time;
- creator personal commercial trends.

These support EAE; they do not replace it.
