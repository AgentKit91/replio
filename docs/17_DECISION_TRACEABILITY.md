# Canonical Decision Traceability

This is a machine-friendly reproduction of the 136-item Canonical Decision Register. If wording here conflicts with the source DOCX, the source register is authoritative.

## DR-001 — Creators first; agencies later

*Status: LOCKED   •   Source: Exchange 1*

The MVP is built for individual creators. Agency functionality is a later expansion and must not distort the creator-first MVP.

## DR-002 — Narrow MVP, broad company vision

*Status: LOCKED   •   Source: Exchanges 4-5*

The MVP is an AI negotiation assistant focused on creator brand deals. The long-term company vision is an AI Talent Manager / creator operating system, but the broader vision must not be built into the MVP unless explicitly marked for later.

## DR-003 — Core commercial purpose

*Status: LOCKED   •   Source: Exchanges 5-6*

The MVP exists to make creators more money while helping them secure better, safer commercial terms. Features are subordinate to that purpose.

## DR-004 — Subscription model is trial then recurring tiers

*Status: LOCKED / PARTIALLY UNSPECIFIED   •   Source: Exchanges 1-2*

The decision phase locks a 30-day free trial followed by monthly subscription tiers. It does NOT lock exact tier names, prices, usage limits, annual pricing, or whether a payment card is required for the trial.
Reconciliation note: Exact Stripe products/prices must be reconciled from later Replio conversations before implementation.

## DR-005 — Final Gmail ingestion model: explicit Replio label only

*Status: LOCKED — SUPERSEDES EARLIER INGESTION IDEAS   •   Source: Exchanges 2-3 and 60-62   •   Gap corresponding to legacy Decision #21*

For the MVP, Replio does not scan the creator's full inbox or try to discover deals automatically. The creator connects Gmail and applies a Replio label to a collaboration thread once. Replio imports and analyses that thread, then future messages in the labelled thread sync automatically.
Reconciliation note: Supersedes the early 'all three if practical' ingestion preference and later automatic high-confidence deal detection. Paste/forward/automatic detection remain possible later, not the canonical MVP trigger.

## DR-006 — Replio Score is a signature deal output

*Status: LOCKED   •   Source: Exchanges 3 and 5-6*

Every analysed opportunity should have a Replio Score as an immediately understandable commercial health signal. The exact meaning is later refined by legacy Decision #67.

## DR-007 — Golden Path analysis order

*Status: LOCKED   •   Source: Exchanges 5-6*

Opening an analysed deal should prioritise: 1) Replio Score, 2) Brand Offer, 3) Replio Recommended Fee with the monetary difference/potential upside, 4) Biggest Risks / points worth flagging, 5) Suggested Reply, and 6) Negotiation Strategy.

## DR-008 — No prominent creator-facing confidence feature in MVP

*Status: LOCKED NEGATIVE CONSTRAINT   •   Source: Exchange 6; reconciled with Decisions #19 and #97*

The founder explicitly rejected a visible 'Confidence feature' in the signature analysis. Internal confidence is still required later and should drive system behaviour, but it is not a prominent user-facing score/widget in the MVP.
Reconciliation note: This is not a contradiction with internal AI confidence. It is a UI boundary.

## DR-009 — Progressive creator onboarding

*Status: LOCKED   •   Source: Exchanges 6-7*

Initial onboarding should take roughly two minutes and collect only the basics needed to reach value quickly. Richer creator context — engagement, audience, previous deals, rates, goals, preferences and similar data — is completed later in the profile.

## DR-010 — Profile completion is framed as value, not percentage

*Status: LOCKED   •   Source: Exchange 7*

Do not use a generic 'profile 30% complete' mechanic. Ask for additional information by explaining the benefit, such as improving fee recommendations or unlocking better negotiation advice.

## DR-011 — Negotiation outcomes become privacy-safe shared intelligence

*Status: LOCKED   •   Source: Exchanges 7-8; refined by Decision #66*

Replio should learn from completed deals: brand, niche, opening offer, negotiated outcome, response behaviour, negotiation difficulty, failure/success and other commercially useful signals. Creator identity/private content must not become shared intelligence. Brand-level patterns and anonymised aggregated benchmarks are allowed.

## DR-012 — Creators can edit and send from Replio through Gmail

*Status: LOCKED   •   Source: Exchanges 8-9*

The creator should be able to view Replio's suggested reply, edit it, and send it from inside Replio through the connected Gmail account. The Gmail thread remains visible and continues inside the Deal Workspace.

## DR-013 — Brand intelligence starts small and grows organically

*Status: LOCKED   •   Source: Exchanges 9-10; reinforced by Decision #85*

Do not spend the MVP building a giant pre-populated brand database. When a brand first appears, create a basic brand record and enrich it over time from completed negotiations and validated intelligence.

## DR-014 — Recommendation reasoning is collapsed by default

*Status: LOCKED   •   Source: Exchanges 10-11*

Show the recommendation clearly first. Put the explanation behind a small expandable 'Why?' control so the first impression stays simple while evidence remains accessible.

## DR-015 — Replio advises; the creator decides

*Status: LOCKED   •   Source: Exchanges 11-12*

Replio must not make the creator's commercial decision for them. It can say an offer is unlikely to be commercially worthwhile and recommend improvements, but it should not instruct the creator to accept or decline. The creator always retains agency.

## DR-016 — Design must be calm, minimal, premium and unmistakably human-designed

*Status: LOCKED   •   Source: Exchanges 12-13; reinforced by Decision #106*

The interface should be easy to read, use generous whitespace, feel clean, minimal, premium and confident, and absolutely must not look like a generic AI-generated SaaS. AI should feel almost invisible.

## DR-017 — Google Sign-In only for MVP, extensible later

*Status: LOCKED   •   Source: Exchange 14   •   Legacy Decision #1*

Use Google Sign-In as the only authentication method for the MVP, with architecture that can support Apple, Microsoft and email/password later.

## DR-018 — Four-week rule and hard scope discipline

*Status: LOCKED   •   Source: Exchanges 15-16 and 20-21; reinforced by Decision #104*

If a feature jeopardises the launch window, simplify it, defer it, or future-proof the architecture without building it. The MVP should contain only functionality that materially increases the chance a creator will pay for Replio. Future ideas must not leak into the MVP.

## DR-019 — Estimated Additional Earnings is the product north star

*Status: LOCKED   •   Source: Exchanges 16-17   •   Legacy Decision #53*

The primary value metric is Estimated Additional Earnings. Replio should make the commercial ROI of using the product tangible, while secondary metrics can include deal uplift, risky clauses improved and deals completed.

## DR-020 — Multi-platform schema; Instagram, TikTok and YouTube first

*Status: LOCKED   •   Source: Exchanges 17-18*

The data model supports multiple creator platforms from day one. The MVP UI and onboarding should focus on Instagram, TikTok and YouTube, with other platforms addable later without restructuring.

## DR-021 — Three-part fee recommendation framework

*Status: LOCKED   •   Source: Exchanges 18-19   •   Legacy Decision #5*

Pricing advice should use three figures: Ideal Ask, Expected Settlement, and Minimum Worthwhile Fee. The product should avoid anchoring creators to a bare 'minimum fee' and should explain why the figures differ.

## DR-022 — One strong reply draft, refined intentionally

*Status: LOCKED   •   Source: Exchanges 19-20*

Replio should present one high-quality suggested reply rather than multiple ChatGPT-like variants. The creator can edit it or ask AI for targeted changes. AI must preserve the commercial intent and change only what the creator requested.

## DR-023 — Evidence-backed launch intelligence and knowledge library

*Status: LOCKED   •   Source: Exchanges 21-22*

Day-one recommendations can use commercial rules plus curated public case studies, creator interviews, agency guidance, published rate guides and similar sourced material. Knowledge should be source-tagged and confidence-aware, kept in an updatable Knowledge Library rather than hard-coded into prompts.

## DR-024 — A Deal is a living negotiation, not a one-off analysis

*Status: LOCKED   •   Source: Exchange 23*

A deal persists through the entire negotiation. New messages update the same deal, timeline, commercial terms, score, strategy and suggested reply rather than restarting analysis as a new object.

## DR-025 — Hidden workspace architecture

*Status: LOCKED   •   Source: Exchange 25   •   Legacy Decision #2*

The MVP should look like a simple single-creator product, while the underlying architecture uses a workspace boundary so team/agency use can be added later without rebuilding the tenancy model.

## DR-026 — Global brand records with private workspace context

*Status: LOCKED   •   Source: Exchanges 26-27   •   Legacy Decision #3*

Brands should exist as global shared entities for non-private brand identity/intelligence, while creator-specific contacts, notes, negotiations and private commercial context remain scoped to the creator/workspace.

## DR-027 — One Deal equals one commercial agreement

*Status: LOCKED   •   Source: Exchanges 27-28*

A multi-platform campaign is one Deal with multiple deliverables and commercial terms, not separate deals per platform or deliverable.

## DR-028 — Completed deals generate a closing commercial recap

*Status: LOCKED   •   Source: Exchanges 28-29*

When a negotiation closes, Replio should capture a concise outcome summary: original offer, final fee, uplift, negotiation rounds, major term improvements and the structured learning generated by the outcome.

## DR-029 — Brand Intelligence Graph is future-proofed, not built as an MVP feature

*Status: LOCKED FUTURE-PROOFING   •   Source: Exchanges 31-32*

The schema may store simple brand metadata and relationships that allow future brand similarity/behaviour intelligence, but the graph-style intelligence is not surfaced until sufficient real data exists.

## DR-030 — Creator Voice Profile is private and adaptive

*Status: LOCKED   •   Source: Exchanges 33-34*

Replio should maintain a private, evolving voice profile based on onboarding preferences, approved emails, edits and instructions. It should reduce editing, not impersonate the creator, and must never be shared across creators.

## DR-031 — Memory Engine supplies only task-relevant context

*Status: LOCKED   •   Source: Exchanges 34-35*

Workers should not receive the entire creator/deal/brand history by default. A Memory Engine selects only the context required for the current task, reducing cost and noise.

## DR-032 — Every AI call must justify its cost

*Status: LOCKED   •   Source: Exchanges 36-38; reinforced by Decision #64*

Use ordinary code, cached data and cheaper/smaller workers wherever they can do the job. Avoid re-analysing unchanged information. Distinguish cheap quick updates from deeper analysis, and treat AI cost per active user as a core internal metric.

## DR-033 — Deal status vocabulary is explicit and human-readable

*Status: LOCKED   •   Source: Exchanges 44 and 52   •   Related to Decision #52*

The deal lifecycle uses explicit states such as New, Reviewing, Negotiating, Awaiting Brand, Awaiting Creator, Agreed, Declined, Lost, Completed and Archived. UI wording should remain human-readable even if internal state codes differ.

## DR-034 — MVP deal creation is label-led; schema may support more sources later

*Status: LOCKED WITH SUPERSESSION   •   Source: Exchanges 45 and 60-62*

The data model can remain capable of manual or alternative-source deals, but the canonical MVP ingestion path is an explicitly Replio-labelled Gmail thread. Automatic inbox detection/candidate creation is not MVP.

## DR-035 — Never silently merge ambiguous deals

*Status: LOCKED   •   Source: Exchange 46*

Replio may auto-associate content with an existing deal only when confidence is high. If a possible duplicate/continuation is ambiguous, ask the creator. Separate deals must never be silently merged.

## DR-036 — One deal can contain multiple email threads

*Status: LOCKED   •   Source: Exchange 47*

A deal may link multiple email threads with roles such as outreach, negotiation, contract, deliverables, payment, usage extension or other. One thread can be the primary negotiation thread. Linking/unlinking does not delete email.

## DR-037 — Contracts are versionable children of the deal

*Status: LOCKED ARCHITECTURE; AI CONTRACT FEATURES DEFERRED   •   Source: Exchange 48*

A deal can have zero, one or multiple contracts, revisions and amendments. Preserve the original file and structured metadata. Contract AI extraction/generation is not required for the tight MVP.

## DR-038 — Deliverables are structured first-class records

*Status: LOCKED   •   Source: Exchange 49*

Do not treat a deal as a blob of text. Represent content deliverables and commercial rights/terms as structured records so changes can update valuation, risks, strategy and score.

## DR-039 — Deal finances preserve the commercial story

*Status: LOCKED   •   Source: Exchange 50*

Do not use a single fee field. Preserve structured offer evolution and financial values such as initial/current/final offer, AI fee recommendations, currency and related commercial payment information needed to understand the deal.

## DR-040 — Contacts belong to brands, not only to individual deals

*Status: LOCKED   •   Source: Exchanges 51-52*

Use a reusable Contact entity associated with a Brand so relationship history can span multiple deals. Creator/workspace-specific relationship context remains private.

## DR-041 — Replio may later manage getting paid, but it is not accounting software

*Status: LOCKED BOUNDARY   •   Source: Exchanges 51-53*

Future Replio can own creator-partnership operations such as invoice creation/sending, payment reminders, overdue chasing and revenue reporting. It should not become tax/accounting software. These payment-operation features are explicitly deferred from the tight MVP.

## DR-042 — Attachments (MVP)

*Status: LOCKED   •   Source: Exchange 55   •   Legacy Decision #16*

Attachments remain in Gmail.
Replio stores references/metadata, not duplicate files.
Attachments are linked to the relevant deal.
Future versions can support importing/storing documents if there's a clear user need.
This keeps the MVP lean while preserving the architecture for later expansion.

## DR-043 — Notes

*Status: LOCKED   •   Source: Exchange 56   •   Legacy Decision #17*

✅ Deal Notes
✅ Brand Notes
✅ Private to the creator/workspace
✅ Searchable
✅ Not included in shared intelligence
✅ Simple rich text for the MVP (no fancy collaboration features)

## DR-044 — AI Analysis History

*Status: LOCKED   •   Source: Exchange 57   •   Legacy Decision #18*

Every meaningful re-analysis creates a new immutable snapshot.
Previous analyses are never overwritten.
The UI shows the latest snapshot by default.
Historical snapshots remain available for future features and debugging.
Snapshots store structured outputs and evidence, not model chain-of-thought.

## DR-045 — AI Confidence

*Status: LOCKED   •   Source: Exchange 58   •   Legacy Decision #19*

Every significant AI conclusion includes an internal confidence value.
Confidence drives behaviour rather than being a prominent UI feature in the MVP.
High confidence → automate low-risk actions.
Medium confidence → recommend and ask for review.
Low confidence → ask the creator instead of guessing.
Replio never invents commercial facts when confidence is low.
That decision is going to underpin a lot of the AI orchestration later.

## DR-046 — Append-only Audit/Event Log

*Status: LOCKED   •   Source: Exchange 59   •   Legacy Decision #20*

Every significant system and user action creates an event.
Events are append-only (never edited or deleted).
Primarily for debugging, traceability and future features.
Mostly hidden from creators in the MVP.
Supports future activity feeds, AI debugging and support.

## DR-047 — Modular AI Workers

*Status: LOCKED   •   Source: Exchange 63   •   Legacy Decision #22*

For the MVP, Replio will use an AI Orchestrator that coordinates a small number of specialist workers.
Rather than one massive prompt, each worker has a single responsibility.
For example:
Commercial Extractor
Extracts structured deal terms from the email thread.
Pricing Engine
Produces the three fee recommendations.
Risk Engine
Identifies commercial risks and missing terms.
Strategy Engine
Recommends the negotiation approach.
Reply Engine
Drafts the suggested reply.
The orchestrator decides:
Which workers need to run.
What context each receives.
How their outputs are combined.
Each worker returns structured JSON, not prose. That makes the outputs much easier to validate before anything is shown to the user.

## DR-048 — No Invented Commercial Terms

*Status: LOCKED   •   Source: Exchange 65   •   Legacy Decision #24*

The AI must never present assumptions as facts.
Every extracted commercial term is classified as:
✅ Confirmed — explicitly stated by the brand or creator.
⚠️ Missing — required information that hasn't been provided.
🤔 Inferred — a reasonable inference, clearly marked internally and never treated as confirmed.
When important information is missing, Replio's job is not to guess. Its job is to help the creator obtain it.
For example:
"Before agreeing, you should clarify:
- Usage duration
- Territory
- Payment terms"
That behaviour is going to make Replio much more trustworthy than tools that confidently hallucinate missing details.

## DR-049 — Purpose-Built AI Context

*Status: LOCKED   •   Source: Exchange 66   •   Legacy Decision #25*

Every AI worker receives a tailored context, not the entire deal history.
The AI Orchestrator is responsible for assembling the smallest, most relevant context for each worker.
This gives us:
✅ Lower AI costs
✅ Faster responses
✅ More consistent outputs
✅ Easier model upgrades in the future
✅ Better security (workers only see what they need)
I genuinely think this principle will save you a lot of money as Replio grows.

## DR-050 — AI Outputs Are Structured

*Status: LOCKED   •   Source: Exchange 67   •   Legacy Decision #26*

Every AI worker returns structured JSON that conforms to a predefined schema.
The backend validates every response before it is accepted.
Natural language explanations are generated from the structured data, not the other way around.
This gives us:
Deterministic outputs.
Validation before saving.
Easier debugging.
Better versioning.
Easier testing.
Simpler model replacement in the future.
This is exactly how I want Claude to think when it's building Replio.

## DR-051 — Graceful AI Failure

*Status: LOCKED   •   Source: Exchange 68   •   Legacy Decision #27*

AI failures never break the application.
Deals, emails and data remain accessible.
Failed analyses are never silently discarded.
Invalid outputs are rejected.
Failed jobs are queued for retry.
The user sees a clear, honest status message.
AI is an enhancement, not a dependency for basic product functionality.

## DR-052 — AI Workers Have Fixed Roles

*Status: LOCKED   •   Source: Exchange 69   •   Legacy Decision #28*

Each AI worker consists of:
Permanent role (identity, expertise, non-negotiable rules)
Task (what it's being asked to do this time)
Relevant knowledge (only what's needed)
Structured input
Required output schema
This also gives us something really valuable for the future:
If six months from now we discover the Pricing Engine isn't good enough, we improve one worker. We don't risk breaking the Reply Engine, Risk Engine or Commercial Extractor.
That's exactly the modularity we want.

## DR-053 — Improve the System, Not the Model

*Status: LOCKED   •   Source: Exchange 70   •   Legacy Decision #29*

Replio improves primarily by evolving:
Worker instructions
Knowledge library
Decision rules
Retrieval strategy
Output schemas
Orchestration logic
Fine-tuning is explicitly *not* part of the MVP.
Only consider it once there's strong evidence that prompt, knowledge and orchestration improvements have reached their limit.
That keeps Replio:
Cheaper to improve
Faster to iterate
Less tied to any single AI provider
Easier to test and roll back

## DR-054 — Explain Every Important Recommendation

*Status: LOCKED   •   Source: Exchange 71   •   Legacy Decision #30*

Replio doesn't just provide recommendations—it explains them.
Every significant recommendation should answer:
"Why is Replio telling me this?"
For the MVP, that includes things like:
Pricing recommendations
Commercial risks
Negotiation strategy
Suggested clarification questions
Deal score
These explanations are:
Generated from validated structured data.
Concise and easy to understand.
Never chain-of-thought.
Never fabricated.
Updated whenever the underlying analysis changes.

## DR-055 — Creator Preferences Are Learned, Never Assumed

*Status: LOCKED   •   Source: Exchange 72   •   Legacy Decision #31*

Replio distinguishes between:
Permanent Creator Preferences
Explicitly set by the creator.
Examples:
Minimum fee
Payment terms
Travel policy
Industries to avoid
Standard negotiation preferences
Only the creator can change these.

## DR-056 — Living Creator Profile

*Status: LOCKED   •   Source: Exchange 74   •   Legacy Decision #32*

The Creator Profile is a living business profile, not a one-time onboarding form.
Creator owns
Follower counts
Goals
Minimum fees
Preferences
Industries
Policies
Replio observes
Negotiation behaviour
Average deal values
Platform growth
Brand categories
Commercial patterns
Replio suggests
Examples:
"Your average deal value has increased 42%. Consider increasing your minimum worthwhile fee."
"Your follower count hasn't been updated in 4 months."
"Adding your engagement rate could improve pricing recommendations."
The creator always chooses whether to accept or ignore suggestions.

## DR-057 — Hybrid Creator Data

*Status: LOCKED   •   Source: Exchange 75   •   Legacy Decision #33*

Replio uses a hybrid profile.
Automatically import (where practical)
Public follower/subscriber counts
Connected platform metadata
Basic account information
Creator enters manually
Average views
Engagement rate
Typical rates
Audience insights
Business preferences
Goals
Minimum fees
Future
As APIs improve (or new integrations become available), Replio can automatically populate more fields without changing the underlying profile structure.

## DR-058 — Creator Business Strategy

*Status: LOCKED   •   Source: Exchange 76   •   Legacy Decision #34*

The Creator Profile includes a Business Strategy section.
Primary Goals
The creator can select up to three.
Examples:
Maximise income
Increase average deal value
Build long-term partnerships
Work with premium brands
Grow audience
Build credibility
Become more selective
Increase recurring campaigns
Expand internationally
Increase YouTube partnerships
Increase TikTok partnerships
Secure ambassador roles
The AI understands these are priorities, not absolute rules.

## DR-059 — Every Field Must Earn Its Place

*Status: LOCKED   •   Source: Exchange 77   •   Legacy Decision #35*

If Replio asks the creator for information, it must be able to explain exactly how that information improves the product.
No field exists "just because."

## DR-060 — Creator Non-Negotiables

*Status: LOCKED   •   Source: Exchange 78   •   Legacy Decision #36*

The Creator can define:
Commercial red lines
Brand red lines
Personal red lines
Working preferences
Replio never overrides them.
It negotiates within them.

## DR-061 — Progressive Learning

*Status: LOCKED   •   Source: Exchange 79   •   Legacy Decision #37*

Replio collects information over time, not all at once.
Instead of asking 100 questions during onboarding, it asks the right question at the right moment.
Examples:
After a negotiation:
Did the brand pay on time?
After a completed campaign:
Was the final agreed fee accurate?
After three negotiations:
We've noticed you usually negotiate for shorter usage periods. Make this one of your standard preferences?
Everything is contextual.
Everything is optional.
Everything has an obvious benefit.

## DR-062 — No Creator Score

*Status: LOCKED NEGATIVE CONSTRAINT   •   Source: Exchange 80   •   Legacy Decision #38*

Replio will not create a Creator Commercial Score.
Instead, it will rely on:
Rich creator context
Business strategy
Negotiation history
Voice profile
Learned preferences
Brand intelligence
The only score the user sees is the Replio Score for each deal.
Simple.
Focused.

## DR-063 — Creator Rate Cards

*Status: LOCKED   •   Source: Exchange 81   •   Legacy Decision #39*

Every creator has a private Rate Card that grows over time.
It is populated through:
Progressive questions (never a giant form)
Manual updates
Creator-approved suggestions based on completed deals
Examples:
Instagram Reel
Instagram Story
TikTok
YouTube Integration
YouTube Short
UGC
Event appearance
Day rate
Hourly rate (if relevant)
The creator always owns and edits their Rate Card.

## DR-064 — Verified vs Self-Reported Data

*Status: LOCKED   •   Source: Exchange 82   •   Legacy Decision #40*

Every important piece of creator information has a source.
For example:
✅ Verified (connected platform/API)
✍️ Self-reported (entered by creator)
🤖 AI-estimated (future, if applicable)
The AI understands the difference internally.
That means if a creator manually enters 250,000 followers but the connected Instagram account shows 180,000, Replio doesn't accuse them of anything—it simply knows which value is verified and can politely prompt:
We've noticed your connected Instagram account now shows 180,241 followers. Would you like to update your profile?
Again, the creator stays in control.

## DR-065 — Tiered Knowledge Trust

*Status: LOCKED   •   Source: Exchange 83   •   Legacy Decision #41*

Every piece of knowledge has a trust classification.
Tier 1 — Authoritative
Official sources.
Examples:
Platform policies
Government guidance
ASA/FTC rules
Official documentation

## DR-066 — Versioned Knowledge

*Status: LOCKED   •   Source: Exchange 84   •   Legacy Decision #42*

Every knowledge document is versioned.
Each version stores:
Version number
Created date
Effective date
Author/source
Change summary
Trust tier
Status (Draft, Current, Deprecated, Archived)
Most importantly:
Every AI analysis records which knowledge versions it used.
So if someone asks in 18 months:
"Why did Replio recommend £2,400 on this deal?"
We can answer:
"Because it was based on Knowledge v2.3 and Pricing Framework v1.8."
That's proper engineering.

## DR-067 — Action Dashboard

*Status: LOCKED   •   Source: Exchange 85   •   Legacy Decision #43*

The dashboard is not a reporting dashboard.
It is an Action Dashboard.
The first question Replio answers is:
"What needs my attention right now?"
Not:
"Here's a graph."

## DR-068 — Navigation Reflects the User's Mental Model

*Status: LOCKED   •   Source: Exchange 86   •   Legacy Decision #44*

Navigation should reflect how creators think, not how the database is organised.
MVP Navigation
🏠 Dashboard
Priorities
Active deals
Opportunities
Notifications
💼 Deals
Active
Awaiting reply
Agreed
Completed
Search & filters
🏢 Brands
Brand history
Contacts
Notes
Relationship history
📈 Insights
Earnings uplift
Negotiation success
Deal trends
Personal business insights
🤖 Train Replio
Creator Profile
Business Goals
Rate Cards
Non-Negotiables
Voice
Preferences
Connected Accounts
⚙️ Settings
Billing
Gmail
Notifications
Security
Account

## DR-069 — Search

*Status: LOCKED   •   Source: Exchange 87   •   Legacy Decision #45*

MVP
Use fast structured database search, not AI.
Search across:
Deals
Brands
Contacts
Notes
Support useful filters such as:
Status
Platform
Date
Brand
Deal value
No natural language search in the MVP.

## DR-070 — Empty States Teach, They Don't Apologise

*Status: LOCKED   •   Source: Exchange 88   •   Legacy Decision #46*

Every empty state should:
Explain what this area will eventually contain.
Tell the creator exactly what to do next.
Reinforce the value they'll receive.
Contain one clear call to action.
Never show:
"No data."
Instead show:
Here's how to unlock this.

## DR-071 — High-Value Notifications Only

*Status: LOCKED   •   Source: Exchange 89   •   Legacy Decision #47*

Every notification must fall into one of four categories:
🚨 Action Required
A reply is needed.
Missing information needs clarification.
A decision is required.
💰 Opportunity
A better fee may be achievable.
Better commercial terms can likely be negotiated.
A new opportunity has been identified.
⚠️ Risk
Commercial risks.
Missing contract terms.
Potentially unfair conditions.
(Future) Late payments.
🎉 Success
Deal agreed.
Negotiation improved.
Important milestone reached.
If a notification doesn't fit one of those categories...
Don't send it.

## DR-072 — Split Workspace

*Status: LOCKED   •   Source: Exchange 90   •   Legacy Decision #48*

The Deal page is a commercial workspace, not an email client.
Left panel (primary)
AI recommendations
Replio Score
Recommended fee
Risks
Strategy
Suggested reply
Deal information
Right panel (secondary but always visible)
Full email thread
Chat-style layout
Oldest → newest
Auto-scroll to latest message
Fully scrollable
No need to leave Replio
AI evidence
Every significant recommendation should be able to link directly to the supporting email(s), automatically scrolling and highlighting the relevant section when selected.

## DR-073 — Native Reply Composer

*Status: LOCKED   •   Source: Exchange 91   •   Legacy Decision #49*

The suggested reply is not a separate card.
Instead, Replio behaves like a modern messaging app.
┌──────────────────────────────────────────────┐ │ Email Thread                                 │ │                                              │ │ Brand                                        │ │                                              │ │ You                                          │ │                                              │ │ Brand                                        │ │                                              │ │ Brand (latest)                               │ ├──────────────────────────────────────────────┤ │ ✨ Replio has prepared a reply               │ │                                              │ │ [Editable message box...]                    │ │                                              │ │             [Regenerate] [Send]              │ └──────────────────────────────────────────────┘
The flow becomes incredibly natural:
Brand emails.
Replio analyses the deal.
Left panel updates with recommendations.
Reply box is automatically populated.
Creator edits if they want.
Creator presses Send.
Email sends via Gmail.
That message immediately appears in the conversation history.
The deal status changes to Awaiting Brand.
It feels less like "AI generated an email" and more like you're having a conversation with a manager who's already drafted the response for you.

## DR-074 — Integrated Reply Composer

*Status: LOCKED   •   Source: Exchange 92   •   Legacy Decision #50*

The reply composer lives inside the conversation panel, not as a separate feature.
Workflow:
Brand email arrives.
Replio analyses it.
AI recommendations appear in the left panel.
The reply composer is automatically populated.
Creator edits if desired.
Creator presses Send.
Email is sent via Gmail.
The sent message immediately appears in the thread.
Deal status updates automatically.
The composer includes lightweight improvement actions rather than a chatbot.
This keeps the experience focused on negotiation rather than chatting with AI.

## DR-075 — Intentional Regeneration

*Status: LOCKED   •   Source: Exchange 93   •   Legacy Decision #51*

Replio never randomly regenerates replies.
Every rewrite has a clear purpose.
Quick actions
More assertive
More collaborative
Shorter
More detailed
More professional
More friendly
Push harder on price
Focus on usage rights
Focus on payment terms
Start again
Custom instruction
A simple prompt box:
"Mention that I'll need 50% upfront."
"Sound less formal."
"Don't close the door completely."
Replio then rewrites the draft while keeping the overall negotiation strategy intact.

## DR-076 — Human-Readable Deal Status

*Status: LOCKED   •   Source: Exchange 94   •   Legacy Decision #52*

The database stores structured statuses.
The UI translates them into plain English.
Examples:
🟡 Your move
Waiting for you to reply.
🔵 Brand reviewing
Waiting for Gymshark to respond.
🟢 Commercial terms agreed
Awaiting contract.
🟣 Campaign in progress
Deliverables underway.
⚫ Completed
Everything finished.
The creator shouldn't have to interpret system statuses. Replio should tell them what's actually happening.

## DR-077 — The North Star Metric

*Status: LOCKED   •   Source: Exchange 95   •   Legacy Decision #53*

Estimated Additional Earnings becomes Replio's signature metric.
It appears throughout the product whenever it genuinely adds value.
Examples:
Dashboard
Deal page
Deal completion
Monthly insights
Annual review
It is always presented honestly as an estimate, with a clear explanation available of how it was calculated.

## DR-078 — Proactive Analysis

*Status: LOCKED   •   Source: Exchange 97   •   Legacy Decision #54*

Label email.
Replio starts immediately.
Creator continues with their day.
When they open Replio, the analysis is ideally already complete.
If it's still running:
The deal page loads normally.
The email thread is immediately available.
AI sections progressively populate as they're completed.
No fake "thinking" animation.
No blocking loading screen.
Principle:
Replio works while you're not looking.
Reconciliation note: This is the final wording of the earlier 'Asynchronous Analysis' decision: Replio begins work in the background as soon as the labelled thread changes.

## DR-079 — Respectful Challenge

*Status: LOCKED   •   Source: Exchange 98   •   Legacy Decision #55*

Replio acts like a great manager.
If it detects the creator is about to make a decision that clearly conflicts with:
Their own non-negotiables.
Their minimum fees.
Their business goals.
A significantly stronger commercial recommendation.
…it politely intervenes once.
For example:
Before you send...
Based on this deal, we think there's a good chance you're leaving approximately £900 on the table.
If that's intentional, no problem—we just wanted to make sure.
Buttons:
Review Recommendation
Send Anyway
If the creator chooses Send Anyway, Replio respects that decision completely.
No repeated warnings.
No nagging.
No guilt.

## DR-080 — Replio's Personality

*Status: LOCKED   •   Source: Exchange 99   •   Legacy Decision #56*

Replio has a consistent commercial voice across the entire product.
It is:
Calm
Confident
Clear
Premium
Professional
Honest
Commercially astute
Supportive without being overly familiar
It is not:
Robotic
Overly enthusiastic
Salesy
Corporate jargon-heavy
Patronising
Pushy
A generic AI assistant
Think of it as:
The commercial manager every creator wishes they had.

## DR-081 — Human Confidence

*Status: LOCKED   •   Source: Exchange 100   •   Legacy Decision #57*

Internally:
Every AI worker stores a numeric confidence value.
Confidence influences orchestration, validation and automation.
Externally:
The creator never sees:
Confidence: 82%
Instead, Replio communicates confidence naturally.
Examples:
High confidence
We're confident this recommendation is well supported by the available information.
Medium confidence
This recommendation is based on the information currently available and may change if additional commercial terms are confirmed.
Low confidence
We'd recommend clarifying a few important details before relying on this recommendation.

## DR-082 — Queue-First Backend Architecture

*Status: LOCKED   •   Source: Exchange 101   •   Legacy Decision #58*

Replio adopts a queue-first architecture from day one.
Immediate actions
Open app
View deal
Edit reply
Send email
Navigate
These should feel instant.

## DR-083 — Idempotency by Default

*Status: LOCKED   •   Source: Exchange 102   •   Legacy Decision #59*

Every important backend action must be idempotent.
Examples:
One email is never sent twice.
One Gmail thread never creates two deals.
One AI job never creates duplicate analyses.
One webhook never creates duplicate records.
Retrying a failed job is always safe.
This isn't a feature—it's an engineering standard that applies across the whole system.

## DR-084 — Soft Delete with Recycle Bin

*Status: LOCKED   •   Source: Exchange 103   •   Legacy Decision #60*

Deleting a deal removes it from normal views.
Deleted items move to a recycle bin.
The creator can restore them.
Permanent deletion happens only after a defined retention period or when the creator explicitly empties the bin.
Related records follow the same lifecycle.
Audit events remain traceable until final purge.
Backend Question #4 — Recycle-bin retention
My recommendation for the MVP is 30 days before automatic permanent deletion.
That is long enough to recover mistakes without keeping deleted data indefinitely.
Shall we lock in 30 days?

## DR-085 — 30-Day Recycle Bin

*Status: LOCKED   •   Source: Exchange 104   •   Legacy Decision #61*

Deleted items stay recoverable for 30 days.
Creators can restore them during that period.
After 30 days, they are permanently purged.
Creators can also empty the recycle bin earlier.
Permanent deletion must remove associated private data in line with the retention policy.
Backend Question #5 — Real-time updates
When a new email arrives or an analysis finishes, should the open deal page update automatically, or require a manual refresh?
My recommendation: automatic real-time updates for key events only:
New email received
Analysis completed
Suggested reply ready
Deal status changed
Notification created
No constant polling of the entire app. Use targeted subscriptions so it stays efficient.
Lock that in?

## DR-086 — Real-Time Updates

*Status: LOCKED   •   Source: Exchange 105   •   Legacy Decision #62*

The app updates automatically when it matters.
Real-time events
📩 New email arrives
🧠 Analysis completes
💬 Reply draft is ready
🔄 Deal status changes
🔔 New notification
✏️ User edits (where relevant)
No manual refresh.
No "Refresh Analysis" button.
The creator should feel like Replio is quietly working alongside them.

## DR-087 — Intelligent Draft Management

*Status: LOCKED   •   Source: Exchange 106   •   Legacy Decision #63*

This is one of my favourite decisions so far.
Auto-save
Every draft auto-saves continuously.
No Save button.
No lost work.
Drafts are restored instantly.

## DR-088 — AI Profitability Guardrails

*Status: LOCKED   •   Source: Exchange 107   •   Legacy Decision #64*

Replio is engineered so that:
Every AI request has a cost budget.
Every user has an internal monthly AI budget.
The AI Gateway optimises usage automatically.
The product degrades gracefully rather than abruptly limiting users.
AI costs are continuously monitored as a core business KPI.
The goal is for the average user to cost substantially less in AI than they pay in subscription fees.
One refinement I'd add for the future: if we eventually introduce enterprise or agency plans with extremely heavy usage, we can offer fair usage policies or custom pricing rather than weakening the experience for everyone else. That keeps individual creator plans simple while ensuring the business remains sustainable as Replio grows.

## DR-089 — Provider-Agnostic AI

*Status: LOCKED   •   Source: Exchange 109   •   Legacy Decision #65*

Replio will never be tied to a single AI provider.
The architecture separates:
AI Workers (what needs to be done)
AI Gateway (who does it)
The Gateway chooses the most appropriate model based on:
Capability
Cost
Speed
Reliability
Availability
The rest of Replio doesn't know—or care—which provider is being used.
This is one of those decisions that founders almost never regret.

## DR-090 — Commercial Benchmark Engine

*Status: LOCKED   •   Source: Exchange 111   •   Legacy Decision #66*

Replio learns from every completed negotiation.
It does not expose creator-specific outcomes.
Instead, it builds an anonymised, aggregated benchmark engine.
Benchmarks are based on combinations such as:
Brand
Niche
Platform
Creator size
Engagement rate
Deliverables
Usage rights
Exclusivity
Territory
Campaign type
Seasonality
From that, Replio can estimate things like:
Typical first offer
Typical negotiated range
Average uplift
Negotiation success rate
Brand flexibility
Commercial fairness
Typical response times
Every benchmark carries an evidence strength internally (and can be surfaced appropriately when useful), so recommendations are proportional to the amount of supporting data.
Reconciliation note: Refines the earlier brand-memory concept into aggregated, privacy-preserving commercial benchmarks rather than creator-specific exposed outcomes.

## DR-091 — What the Replio Score Represents

*Status: LOCKED   •   Source: Exchange 112   •   Legacy Decision #67*

The Replio Score is not a quality score.
It is not a brand score.
It is not a creator score.
It is:
A measure of the current commercial strength of this opportunity, based on everything Replio knows at this moment in time.
That wording is important because the score is dynamic.
If the brand improves the offer...
The score improves.
If they add perpetual usage...
The score drops.
If payment terms become clearer...
The score rises.
The score evolves with the negotiation.

## DR-092 — Celebrate Meaningful Wins

*Status: LOCKED   •   Source: Exchange 113   •   Legacy Decision #68*

Replio acknowledges meaningful commercial successes.
Not with confetti.
Not with badges.
Not with streaks.
Instead, like a great manager would.
Examples:
Excellent result.
You increased the agreed fee by £800.

## DR-093 — Founder Admin Console ("Replio OS")

*Status: LOCKED   •   Source: Exchange 115   •   Legacy Decision #69*

The founder dashboard is not an admin panel.
It's an operating system for the company.
The same design principles apply:
Beautiful
Calm
Minimal
Apple-inspired
Information-dense without feeling cluttered
Fast
Designed for decision making, not data dumping

## DR-094 — Actionable Founder OS

*Status: LOCKED   •   Source: Exchange 116   •   Legacy Decision #70*

Whenever Replio detects a problem, the alert should include the most relevant safe action beside it.
Examples:
Refund failed → Retry refund
Stripe webhook failed → Replay webhook
Gmail token expired → Send reconnect request
AI job failed → Retry analysis
Queue item stuck → Requeue job
Subscription status mismatch → Resync from Stripe
User access issue → Restore access
Knowledge document outdated → Open review
Provider outage → Switch fallback provider where configured
The aim is:
See the issue, understand it, act immediately.
No hunting through Stripe, Supabase, logs and five browser tabs for routine problems.
Important boundary
Not every problem can safely be fixed with one click. Some actions could:
send money,
delete data,
email a customer,
change billing,
expose private information,
affect many users.
So Replio OS should use three levels:
Immediate action Safe, reversible actions run instantly.
Confirm action Financial or customer-impacting actions require a clear confirmation showing exactly what will happen.
Guided resolution When Replio cannot safely fix something automatically, it should explain the cause, show the affected records, and provide the shortest possible route to resolve it.
No vague red error banners. Every issue must answer:
What happened?
Who or what is affected?
Is money or data at risk?
What should I do?
Can Replio do it for me?
Next question — destructive actions
For refunds, account suspension, permanent deletion and similar high-impact actions, should Replio OS require:
A. One confirmation click
or
B. Confirmation plus typing a short phrase for only the most serious actions, such as permanently deleting user data?
My recommendation is B: fast confirmation for ordinary actions, stronger protection only for irreversible ones.

## DR-095 — Founder OS Philosophy

*Status: LOCKED   •   Source: Exchange 117   •   Legacy Decision #71*

The Founder OS exists for one purpose:
Everything needed to operate, support, improve and grow Replio should be available from one place.
That means it isn't just:
Reporting
or
Operations
It's both.

## DR-096 — Founder OS

*Status: LOCKED   •   Source: Exchange 117   •   Legacy Decision #72*

Founder OS is a complete operating system for Replio.
It combines:
Action Centre
Business Intelligence
Commercial Intelligence
Company Controls
Everything needed to run Replio should be accessible from one interface wherever it's technically and securely appropriate.
It should minimise context switching, surface meaningful insights, and allow the founder to take action with as few clicks as possible.

## DR-097 — Founder OS Principles

*Status: LOCKED   •   Source: Exchange 118   •   Legacy Decision #73*

Founder OS must answer five questions within 30 seconds of opening it:
1️⃣ Is the business healthy?
Revenue
Profit
AI costs
Growth
Churn

## DR-098 — Definition of Done

*Status: LOCKED   •   Source: Exchange 119   •   Legacy Decision #74*

From now on, "it works" is not enough.
A feature is only complete when it satisfies every applicable category:
✅ Functional
✅ UX
✅ Performance
✅ Security
✅ AI behaviour
✅ Error handling
✅ Accessibility
✅ Responsiveness
✅ Tests
✅ Acceptance criteria
If one of those fails...
The feature is not done.

## DR-099 — Least-Privilege Architecture

*Status: LOCKED   •   Source: Exchange 126   •   Legacy Decision #75*

Every integration follows the principle of least privilege.
Replio only requests the minimum permissions needed to deliver the current feature.
Examples
Gmail (MVP)
Only the permissions genuinely required to detect and process emails the user has intentionally marked for Replio.
No unnecessary access to unrelated emails or account data.
Future platform integrations
Only request additional permissions when a new feature genuinely requires them.
Explain clearly:
What permission is being requested.
Why it's needed.
What benefit the creator receives.
Creators should always feel they're granting permissions to unlock value, not surrendering privacy.

## DR-100 — Support Mode

*Status: LOCKED   •   Source: Exchange 127   •   Legacy Decision #76*

By default, not even the founder has access to a creator's private commercial data.
If support is needed:
The creator grants temporary support access.
Access is limited to the minimum data required.
Every action is logged.
Access automatically expires.
The creator can revoke access at any time.
Audit Trail
Every support session records:
Who accessed the account
When
Why
What was viewed
What actions were taken
When access ended
This protects:
The creator
Replio
You as founder

## DR-101 — Evidence Transparency

*Status: LOCKED   •   Source: Exchange 128   •   Legacy Decision #77*

Replio explains what informed its recommendation, not its internal reasoning process.
For every important recommendation, the creator should be able to see:
Recommendation
Suggested fee: £2,400
Evidence
Commercial Benchmark Engine
Brand Intelligence
Creator Rate Card
Creator Goals
Non-Negotiables
Knowledge Base
Current Deal Terms
Missing Information (where relevant)
Replio should also say:
This recommendation could become more accurate if we knew:
• Paid usage duration
• Territory
• Budget
• Deliverable deadlines
That turns uncertainty into a helpful action list instead of hiding it.

## DR-102 — Core + Modules Architecture

*Status: LOCKED   •   Source: Exchange 129   •   Legacy Decision #78*

Replio will be built as a modular platform.
Core (MVP and always central)
Deal Workspace
Negotiation AI
Brand Intelligence
Commercial Benchmark Engine
Creator Profile
Knowledge Engine
Founder OS
Notifications
AI Gateway
This is the heart of Replio and should remain fast, focused and polished.

## DR-103 — Graceful AI Degradation

*Status: LOCKED   •   Source: Exchange 130   •   Legacy Decision #79*

If AI providers are unavailable:
Replio continues functioning wherever possible.
Existing analyses remain available.
AI jobs queue automatically.
Automatic retries occur.
The creator is informed clearly but calmly.
Founder OS shows the provider status and queue health.

## DR-104 — Implementation Freedom, Product Fidelity

*Status: LOCKED   •   Source: Exchange 130   •   Legacy Decision #80*

Claude has complete freedom to improve:
Architecture
Performance
Maintainability
Code quality
Testing
Cost optimisation
Claude does not have authority to change:
Product philosophy
User journeys
UX behaviour
Founder principles
Core workflows
Commercial logic
Without explicitly documenting the proposed change and why it's materially better.

## DR-105 — Worker-Level Recovery

*Status: LOCKED   •   Source: Exchange 131   •   Legacy Decision #81*

Every AI worker is independent.
If one fails:
Completed work is preserved.
Failed work retries independently.
No duplicated processing.
No duplicated AI cost.
This fits perfectly with our AI Gateway and queue-first architecture.

## DR-106 — Version Critical Intelligence

*Status: LOCKED   •   Source: Exchange 131   •   Legacy Decision #82*

Replio versions not just knowledge, but also:
Prompt templates
Pricing frameworks
Benchmark methodology
AI worker versions
AI model used
Key commercial rules
This creates a complete audit trail for important AI decisions.

## DR-107 — Orchestrator Resolves Conflicts

*Status: LOCKED   •   Source: Exchange 132   •   Legacy Decision #83*

Individual workers never present recommendations directly.
The Orchestrator:
Resolves conflicting outputs.
Requests another worker if needed.
Produces one coherent recommendation.
Adjusts confidence appropriately.

## DR-108 — Progressive Analysis

*Status: LOCKED   •   Source: Exchange 132   •   Legacy Decision #84*

Replio analyses whatever information is available.
It never waits for a "perfect" email.
As more information arrives:
Analysis updates.
Recommendations improve.
Confidence increases.
Missing items disappear automatically.

## DR-109 — Brand Intelligence Starts Empty

*Status: LOCKED   •   Source: Exchange 132   •   Legacy Decision #85*

Unknown brands are treated normally.
The only difference is:
Brand Intelligence initially has no historical evidence.
As Replio processes more negotiations, the profile naturally grows.
Reconciliation note: Reinforces the earlier decision that brand intelligence grows organically rather than being pre-populated.

## DR-110 — Intelligent Notifications

*Status: LOCKED   •   Source: Exchange 133   •   Legacy Decision #86*

Group related events.
Suppress temporary technical events.
Notify only when the creator needs to know or act.

## DR-111 — UTC as the Source of Truth

*Status: LOCKED   •   Source: Exchange 133   •   Legacy Decision #87*

All timestamps are stored in UTC and only converted for display.

## DR-112 — Configuration First

*Status: LOCKED   •   Source: Exchange 133   •   Legacy Decision #88*

Business settings live outside the application code wherever practical.
That reduces deployments and gives you more control.

## DR-113 — Every Empty State Has a Purpose

*Status: LOCKED   •   Source: Exchange 133   •   Legacy Decision #89*

No blank tables.
No "0 items."
Every empty state explains:
Why it's empty.
What happens next.
How to get value.
Reconciliation note: Refines Decision #46: every zero-data state must explain why it is empty and what the user should do next.

## DR-114 — Single Source of Truth

*Status: LOCKED   •   Source: Exchange 134   •   Legacy Decision #90*

Every important business object has one authoritative location.
Everything else references it.
No duplicated editable data.

## DR-115 — Atomic Critical Actions

*Status: LOCKED   •   Source: Exchange 134   •   Legacy Decision #91*

Critical workflows either complete fully or roll back safely.
Never leave the system half-finished.

## DR-116 — No Silent Failures

*Status: LOCKED   •   Source: Exchange 134   •   Legacy Decision #92*

Important failures are always surfaced appropriately.
Not dramatically.
Just clearly.

## DR-117 — Self-Monitoring Platform

*Status: LOCKED   •   Source: Exchange 134   •   Legacy Decision #93*

Every critical service continuously reports its own health.
Problems are detected proactively.

## DR-118 — Safe Releases

*Status: LOCKED   •   Source: Exchange 134   •   Legacy Decision #94*

Every deployment should be reversible.
The previous stable version should be restorable quickly.

## DR-119 — Launch Readiness Gate

*Status: LOCKED   •   Source: Exchange 134   •   Legacy Decision #95*

Claude may not declare Replio complete until every launch checklist item has passed.

## DR-120 — Field Ownership

*Status: LOCKED   •   Source: Exchange 135   •   Legacy Decision #96*

Every editable field has a defined owner.
User edits are never silently overwritten by AI or future imports.

## DR-121 — Confidence Drives Behaviour

*Status: LOCKED   •   Source: Exchange 135   •   Legacy Decision #97*

Confidence doesn't just change wording.
It determines whether Replio:
Auto-populates.
Asks for confirmation.
Flags uncertainty.
Waits for user review.

## DR-122 — Immutable Activity Timeline

*Status: LOCKED   •   Source: Exchange 135   •   Legacy Decision #98*

Every significant event is appended to a chronological timeline.
History is never rewritten.
Only appended.

## DR-123 — Universal Search

*Status: LOCKED   •   Source: Exchange 135   •   Legacy Decision #99*

One search bar.
Searches all relevant creator data.
Returns grouped, prioritised results.
No separate searches.
Reconciliation note: Broadens the earlier MVP search decision into a unified cross-entity search behaviour.

## DR-124 — Respect Permanent Deletion

*Status: LOCKED   •   Source: Exchange 135   •   Legacy Decision #100*

Permanent deletion removes the creator's private data.
Only irreversibly anonymised aggregate intelligence may remain where it cannot be linked back to any individual creator.
Reconciliation note: Where this conflicts with earlier 'append-only' language, permanent deletion of private creator data takes precedence; only irreversibly anonymised aggregate intelligence may remain.

## DR-125 — User Ownership Always Wins

*Status: LOCKED   •   Source: Exchange 136   •   Legacy Decision #101*

Hierarchy:
User input
Approved AI suggestion
Automatic AI extraction
Imported system data
Higher levels never get silently overwritten by lower ones.
That single rule removes dozens of edge cases.
Reconciliation note: Master precedence rule resolving any earlier ambiguity between imported data, AI extraction and creator edits.

## DR-126 — Speed Without Recklessness

*Status: LOCKED   •   Source: Exchange 136   •   Legacy Decision #102*

Founder OS optimises for speed.
Never at the expense of irreversible actions.

## DR-127 — Minimum Evidence Threshold

*Status: LOCKED   •   Source: Exchange 136   •   Legacy Decision #103*

Benchmarks require a minimum amount of supporting data before influencing recommendations.
Below that threshold:
Replio simply says:
We don't yet have enough evidence to draw reliable conclusions.
This aligns perfectly with our evidence transparency principle.

## DR-128 — Roadmap Separation

*Status: LOCKED   •   Source: Exchange 136   •   Legacy Decision #104*

Every future idea must be explicitly marked as:
MVP
Phase 2
Future Vision
Claude only builds MVP unless instructed otherwise.
This is probably the single biggest protection against scope creep.
Reconciliation note: Reinforces the Four-Week Rule / no-feature-creep mandate.

## DR-129 — Progressive Disclosure

*Status: LOCKED   •   Source: Exchange 136   •   Legacy Decision #105*

Homepage:
Only the most important information.
Everything else is one click deeper.
No overwhelming dashboards.

## DR-130 — Visual Silence

*Status: LOCKED   •   Source: Exchange 136   •   Legacy Decision #106*

Every screen should feel quieter than competitors.
Whitespace is intentional.
The UI should reduce cognitive load, not maximise information density.
As someone with ADHD, I actually think this will benefit everyone, not just you.
Reconciliation note: Reinforces the founder's original premium/minimal/whitespace design constraint.

## DR-131 — Perceived Performance

*Status: LOCKED   •   Source: Exchange 136   •   Legacy Decision #107*

The interface should acknowledge user actions immediately.
If work takes longer:
Show meaningful progress.
Never leave the user wondering whether anything happened.
This aligns perfectly with our queue-first architecture.

## DR-132 — Builder should need little to no founder product input

*Status: LOCKED   •   Source: Exchanges 120-121 and 136*

The purpose of the blueprint/register is to remove product ambiguity before coding. The builder should continue autonomously through implementation, testing, fixing, polishing and internal audit, interrupting the founder only for genuine account-owner actions, legal/security blockers, or true specification contradictions.

## DR-133 — Pre-flight access checklist before build

*Status: LOCKED   •   Source: Exchanges 113-114 and 121*

Before coding, the build specification should state every account, connection, permission, API key and founder-owned setup action required so work is not repeatedly blocked later.

## DR-134 — Build cost must be aggressively controlled without sacrificing launch quality

*Status: LOCKED   •   Source: Exchanges 122-123*

Use free/lowest-cost tiers during development wherever practical, minimise paid AI test runs, use reusable test fixtures and mocks, and spend only where it materially improves the product. Cost-cutting must not remove essential testing, security or polish.

## DR-135 — Fast build target through specification and parallelism, not quality shortcuts

*Status: LOCKED TARGET   •   Source: Exchanges 123-124*

Aim to compress the polished MVP build toward roughly 21 days by making requirements exhaustive, preparing assets up front, building a reusable design system, parallelising independent workstreams and testing continuously. Do not trade away the Definition of Done or launch-readiness gates merely to hit the date.

## DR-136 — The finished result includes both customer MVP and Founder OS

*Status: LOCKED   •   Source: Exchange 136*

The handover is intended to end with a fully completed, tested, production-ready Replio MVP and Founder OS, not a partial codebase or prototype.
