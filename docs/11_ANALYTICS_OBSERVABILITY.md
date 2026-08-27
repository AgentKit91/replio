# Analytics, Observability and Notifications

## Product analytics principles

Use PostHog (through an adapter) for behavioural/product analytics. Never send raw email body, reply content, private notes, contract content or sensitive commercial text to product analytics.

Useful event taxonomy:

```text
user_signed_up
onboarding_completed
gmail_oauth_started
gmail_connected
replio_label_ready
first_labelled_thread_imported
deal_created
analysis_started
analysis_completed
analysis_failed
deal_opened
why_expanded
reply_draft_ready
reply_edited
reply_rewrite_requested
reply_sent
deal_status_changed
deal_agreed
deal_completed
outcome_captured
profile_value_prompt_shown
profile_value_prompt_completed
trial_started
checkout_started
trial_converted
subscription_updated
subscription_cancelled
billing_failed
```

Allowed event properties are low-risk dimensions: plan, platform, status, worker version, latency bucket, generic error class. Brand name should be omitted from third-party analytics unless privacy review explicitly allows it; internal DB analytics can hold appropriate operational dimensions.

## Funnel metrics

- signup → onboarding;
- onboarding → Gmail connected;
- Gmail connected → first labelled Deal;
- first Deal → first analysis opened;
- analysis → reply sent;
- trial → paid conversion;
- activation/retention by user cohorts.

## AI economics

Internal DB/Founder OS:

- cost per analysis;
- cost per active user;
- cost by worker/model/provider;
- invalid output rate;
- fallback rate;
- cache/reuse rate;
- gross contribution after AI.

## Operational observability

Every critical integration reports health:

- Gmail watch valid/expiry;
- Gmail incremental sync lag/errors;
- Pub/Sub webhook auth/errors;
- Stripe webhook processing;
- queue depth/oldest message/retry count;
- AI provider errors;
- database/Realtime issues where observable;
- scheduled jobs last success.

No silent failures. Critical incidents create Founder OS items; creator-facing impact is surfaced only where relevant.

## Notifications

User notifications remain high-value (Action, Opportunity, Risk, Success). Build in-app notifications first. Add external delivery channels only if explicitly in scope later.
