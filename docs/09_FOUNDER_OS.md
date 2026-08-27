# Founder OS Specification

## Purpose

Founder OS is the internal operating system for running Replio. It should reduce founder stress and context switching, not merely create awareness of more metrics. It deserves the same design quality as the creator product.

It is **not** a conversational Founder AI assistant in MVP. Any prioritisation/insights must be deterministic/rule-driven or clearly implemented without introducing an open-ended founder chatbot.

## The five questions it must answer within ~30 seconds

1. **Is the business healthy?**
2. **Does anything need my attention?**
3. **What should I do today?**
4. **What have we learned?**
5. **How do I fix things?**

## Primary sections

### 1. Today / Action Centre

Prioritised operational items:

- failed/poison queue jobs;
- Gmail watches/authorisations failing;
- Stripe/billing failures/refund requests;
- AI invalid-output/fallback spikes;
- critical system incidents;
- support requests/grants;
- launch/knowledge/config actions requiring approval.

Every item shows context, likely cause where known, recommended next step and the safest available action.

### 2. Business Intelligence

Where data exists:

- MRR / ARR;
- cash collected;
- refunds;
- trials;
- trial conversion;
- churn/cancellations;
- DAU/WAU/MAU;
- retention;
- plan mix;
- Stripe fees;
- AI cost;
- infrastructure/service cost inputs where available;
- gross margin / contribution metrics (clearly labelled according to data completeness).

Do not fabricate profit if all cost sources are not connected. Show `partial`/`not configured`.

### 3. AI & System Health

- queue depth/oldest job;
- job failure/retry rate;
- worker success/invalid schema rate;
- latency by worker;
- cost per analysis/user/worker/model;
- fallback rate;
- provider health;
- Gmail watch health;
- webhook failures;
- DB health indicators available safely;
- deployment/version metadata.

### 4. Commercial Intelligence

Privacy-safe aggregated learning only:

- benchmark sample growth;
- brand/niche/platform trends above evidence threshold;
- average/median deal uplift;
- negotiation behaviours;
- emerging commercial-term patterns.

Never expose a creator's private negotiation to the founder merely because the founder owns the company.

### 5. Customers & Support

Default view exposes operational/account metadata only:

- user id/email/name;
- plan/status;
- signup/last activity;
- Gmail connection health;
- usage;
- failed jobs;
- support-grant state.

Private deal/thread content is hidden unless the creator grants time-limited Support Mode access.

### 6. Company Controls

Versioned/configurable controls, with strong permissions/audit:

- feature flags;
- model/worker routing;
- AI budgets;
- active Knowledge versions;
- pricing/score framework versions;
- benchmark evidence threshold;
- public plan catalogue/entitlements;
- operational kill switches (e.g. pause outbound Gmail send or AI worker if incident).

## Action safety levels

### Immediate

Safe reversible actions: retry job, refresh/reconcile sync, disable a feature flag in an incident, acknowledge incident.

### Confirm

Financial/irreversible/security-sensitive actions: refund, permanent delete, user suspension, plan publication, destructive config change. Show impact and require explicit confirmation.

### Guided

Actions that must happen in a third-party console or require legal/account owner verification: present exact instructions/deep link and track status.

## Founder privacy model

Founder role gives operational control, **not blanket content access**. Support Mode is explicit, scoped, expiring and audited.
