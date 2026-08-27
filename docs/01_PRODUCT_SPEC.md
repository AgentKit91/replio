# Replio MVP Product Specification

## 1. Product definition

Replio is a **commercial intelligence and negotiation manager for individual creators**. It is not a chatbot, generic CRM, accounting product or automatic inbox scanner. The MVP helps a creator take a real brand collaboration email from first offer through negotiation while keeping the creator in control.

The long-term company vision is broader — an AI talent/commercial manager and creator operating system — but the MVP remains narrow. Agency mode and other roadmap ideas must not leak into this build.

### Primary promise

**More money. Better deals. Less stress.**

### Core success journey

A creator must be able to:

1. Sign in with Google.
2. Connect Gmail with explicit commercial-email permission.
3. Have Replio create/find a Gmail label named `Replio`.
4. Apply that label once to a brand collaboration thread.
5. Have Replio import only that chosen thread and begin analysis in the background.
6. Open a Deal Workspace where the thread is visible immediately and AI sections are already ready or progressively appear.
7. See the Replio Score, brand offer, three fee recommendations, commercial risks, negotiation strategy and a suggested reply.
8. Understand the evidence/rationale behind important recommendations without seeing chain-of-thought.
9. Edit or intentionally improve the reply.
10. Send the reply from Replio through the connected Gmail account.
11. Have future messages in the labelled thread sync automatically into the same Deal.
12. Continue the negotiation as a living Deal rather than creating new analyses each time.
13. Close the Deal with an outcome recap and structured commercial learning.
14. See an honest **Estimated Additional Earnings** value where it genuinely adds value.

## 2. Product constitution

The build must preserve these principles:

- **Replio advises. The creator decides.** Never instruct the user to accept or reject a deal as if Replio has authority.
- **Privacy is a feature.** Replio analyses only Gmail conversations the creator explicitly chooses with the Replio label.
- **Every important recommendation is explainable.** Use concise evidence/rationale, not hidden reasoning.
- **Never invent commercial facts.** Terms are Confirmed, Missing or Inferred internally. Inferred is never presented as confirmed.
- **User ownership always wins.** User input > approved AI suggestion > automatic AI extraction > imported data.
- **Every field must earn its place.** If Replio asks for information, it must be able to explain how it improves the product.
- **Replio earns information.** Collect richer context progressively and contextually rather than through a giant onboarding form.
- **Visual silence.** Fewer, better elements; generous whitespace; low cognitive load.
- **AI is almost invisible.** The product should feel like a proactive commercial manager, not an LLM interface.
- **Replio works while you are not looking.** Background jobs should start when the labelled thread changes.
- **Every AI call must justify its cost.** Cache, diff, route and reuse before generating again.
- **Evidence strength matters.** Weak benchmark evidence must not be presented as certainty.
- **No silent failures.** Important failures are surfaced clearly and recoverably.
- **No scope creep.** Roadmap items remain architecturally possible but unbuilt unless explicitly moved into MVP.

## 3. MVP navigation

Use creator mental models, not database terminology.

- **Dashboard** — priorities, active deals, meaningful notifications, Estimated Additional Earnings.
- **Deals** — active / awaiting reply / agreed / completed plus filters and search.
- **Brands** — brand history, contacts, private notes, relationship context.
- **Insights** — earnings uplift, negotiation outcomes, personal deal trends; no overwhelming BI dashboard.
- **Train Replio** — Creator Profile, goals, rate cards, non-negotiables, voice and preferences.
- **Settings** — billing, Gmail, notifications, security and account.

## 4. Onboarding

Target approximately two minutes to first useful state. Do not ask for every possible commercial detail upfront.

### Required early fields

- display/creator name;
- creator base currency;
- primary country/market;
- primary niche/category;
- main platforms (Instagram, TikTok, YouTube highlighted; Other supported in the data model);
- enough platform/account information to create the initial creator profile;
- Google/Gmail connection;
- explicit acceptance that Replio only processes threads labelled `Replio`.

### Progressive enrichment

Prompt later for engagement, average views, previous deal values, typical rates, rate cards, business goals, red lines, preferred payment/usage terms, voice and similar context.

Never show a generic `Profile 30% complete`. Frame enrichment by benefit, e.g. `Improve your fee recommendations` or `Unlock better negotiation advice`.

## 5. Dashboard

The Dashboard is an **Action Dashboard**, not a wall of charts. The first question is `What needs my attention right now?`

### Priority hierarchy

1. Action required (reply/decision/missing information).
2. Material commercial opportunity (e.g. meaningful scope to negotiate).
3. Risk.
4. Time-sensitive waiting state.
5. Understated success/win.

### Dashboard modules

- `Your priorities today` — maximum useful handful, not endless feed.
- `Estimated Additional Earnings` — signature ROI measure, clearly labelled as estimated.
- Active Deals — concise status + next action.
- Recent meaningful activity.
- High-value notifications only.

Progressive disclosure: the homepage contains only what matters now; detail is one click deeper.

## 6. Deal Workspace

Desktop: split workspace. Mobile: equivalent information without cramming two panes side-by-side.

### Primary analysis area

Order matters:

1. **Replio Score** — 0–100 current commercial strength of the opportunity, never an accept/decline instruction.
2. **Brand Offer** — current structured commercial offer.
3. **Recommended Fee** — Ideal Ask, Expected Settlement, Minimum Worthwhile Fee, plus potential uplift.
4. **Biggest Risks / Missing Terms** — prioritised, actionable.
5. **Suggested Reply** — editable composer within the thread experience.
6. **Negotiation Strategy** — concise recommended approach.

Important outputs get a collapsed `Why?` explanation that points to the evidence used.

### Conversation area

- Full imported Gmail thread, oldest to newest.
- Sent Replio replies appear immediately after Gmail confirms send.
- New Gmail messages appear without manual refresh.
- Evidence links can jump/scroll/highlight the relevant email passage.
- Composer lives at the bottom of the thread.

### Composer

One strong draft, not three variants. Auto-save continuously.

Intentional rewrite actions include:

- More assertive
- More collaborative
- Shorter
- More detailed
- More professional
- More friendly
- Push harder on price
- Focus on usage rights
- Focus on payment terms
- Custom instruction
- Start again

Creator edits must be preserved unless `Start again` is explicitly chosen.

### Respectful challenge

If the user is about to send something that materially conflicts with their own non-negotiables, minimums, goals or a much stronger recommendation, Replio may intervene **once** with a calm warning and two obvious options: review or send anyway. If they send anyway, respect it completely.

## 7. Deal lifecycle

Canonical internal states should cover at least:

- new
- reviewing
- negotiating
- awaiting_brand
- awaiting_creator
- agreed
- declined
- lost
- completed
- archived

UI labels translate these into human language such as `Your move`, `Brand reviewing`, `Commercial terms agreed`, `Completed`. Do not make creators interpret database statuses.

One Deal equals one commercial agreement, even when it contains multiple platforms/deliverables. One Deal may link multiple email threads with explicit roles.

## 8. Creator Profile / Train Replio

### Creator-owned facts

- profile and platform metrics;
- creator base currency;
- rate cards;
- business goals (up to three primary goals);
- non-negotiables / red lines;
- industries/categories to prefer/avoid;
- travel/working/payment preferences;
- explicit standard negotiation preferences.

### Replio-observed context

- negotiation patterns;
- typical outcome ranges;
- frequently edited reply characteristics;
- repeated commercial preferences;
- brand/category patterns.

Observed patterns **never silently become creator rules**. Replio may ask `We've noticed X. Make this a standard preference?` and the creator explicitly accepts/rejects.

### Voice Profile

Private to the creator. Learn from approved/sent emails and edits to reduce future editing, but do not impersonate the creator outside requested drafting. Never share voice data across creators.

### No Creator Score

Do not build one.

## 9. Brands and contacts

A Brand is a shared global identity containing only non-private brand identity/intelligence. Workspace-specific notes, contacts, relationship history and negotiations remain private.

Brand Intelligence starts empty and becomes useful through structured completed Deal outcomes. Do not seed a fake giant brand database.

Contacts are reusable Brand children, not duplicated for each Deal.

## 10. Notes, attachments and history

- Deal Notes and Brand Notes: private, searchable, basic rich text.
- Gmail attachments remain in Gmail during MVP. Store references/metadata, not duplicate files.
- AI re-analysis creates immutable analysis snapshots. Latest shown by default; old snapshots retained for traceability/debugging subject to permanent deletion rules.
- Significant user/system actions create timeline/audit events.

## 11. Notifications

Only notify when the item is:

- Action Required
- Opportunity
- Risk
- Success

If it does not fit one of those categories, do not generate noise.

## 12. Search

MVP search is deterministic database search, not AI search. Search Deals, Brands, Contacts and Notes with filters such as status, platform, date, brand and value. Universal search returns grouped/prioritised results.

## 13. Empty states

Never show `No data` as the whole experience. Every empty state explains what will appear, why it is empty, what the user should do next and the value that action unlocks. One clear CTA.

## 14. MVP exclusions

Do not build these into the customer MVP:

- automatic full-inbox opportunity detection;
- Replio-managed inbox/custom email addresses;
- Outlook;
- agency mode;
- visible team/shared workspace UI;
- invoice automation;
- payment chasing;
- tax/accounting;
- contract generation;
- full contract AI extraction/review pipeline;
- calendar integration;
- media kit generation;
- opportunity discovery/outreach;
- natural-language/AI search;
- Creator Score;
- fine-tuning;
- Founder AI/chat assistant.

Architecture may anticipate these, but there must be no accidental UI or half-built feature.
