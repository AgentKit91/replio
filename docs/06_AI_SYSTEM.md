# AI System Specification

## Objective

AI is a modular commercial reasoning subsystem, not the application architecture and not a chatbot. The rest of Replio should continue to function when AI is unavailable.

## Orchestrator and fixed workers

MVP worker set:

1. **Commercial Extractor** — extracts structured commercial facts from the selected thread.
2. **Pricing Engine** — generates Ideal Ask, Expected Settlement and Minimum Worthwhile Fee using validated context.
3. **Risk Engine** — identifies material commercial risks, missing terms and clarification needs.
4. **Strategy Engine** — recommends negotiation approach consistent with creator goals/non-negotiables.
5. **Reply Engine** — produces one strong editable draft consistent with strategy and creator voice.

The orchestrator decides which workers run and provides each the smallest context required. Do not send the entire creator history to every worker.

## Worker contract

Every worker has:

- permanent role/version;
- non-negotiable behavioural rules;
- task-specific instruction;
- typed structured input;
- relevant knowledge/version references;
- required JSON output schema;
- internal confidence output;
- evidence references;
- explicit error/fallback behaviour.

Validate output with schema code before accepting/saving. Invalid structured output is a failed run, not a best-effort blob.

## Provider abstraction

Application features call an internal interface, e.g. `AiGateway.run(worker, input, budget)`. No product feature imports a provider SDK directly.

Routing may consider:

- capability;
- cost;
- speed;
- structured-output reliability;
- availability;
- worker-specific evaluation performance.

Provider/model ids are configuration and must be fetched/verified at implementation time.

## Cost ledger and guardrails

For every model call record worker, model/provider, usage, estimated cost, latency, retries and outcome.

Guardrails:

- per-action budget;
- per-account internal monthly target/budget;
- cached/input-hash reuse;
- skip unchanged workers;
- cheaper models for lower-risk rewrites/extractions when evals allow;
- fallback provider/model when primary is unavailable;
- graceful degradation rather than user-facing `AI credits` where possible.

If a plan has a hard deal-analysis entitlement, enforce the plan entitlement separately from internal cost routing.

## Commercial extraction schema

At minimum:

```json
{
  "brand": {"name": "string|null", "domain": "string|null", "confidence": 0.0},
  "campaign_type": "string|null",
  "platforms": [],
  "deliverables": [],
  "offers": [],
  "terms": [
    {
      "type": "usage_duration|territory|exclusivity|payment_terms|...",
      "state": "confirmed|missing|inferred",
      "value": {},
      "confidence": 0.0,
      "evidence": [{"message_id":"...","locator":"...","excerpt":"short"}]
    }
  ],
  "missing_material_terms": []
}
```

Exact schema lives in code (Zod or equivalent) with versioning and tests.

## No invented facts

If a required term is absent, mark it missing and recommend clarification. Inferred values are internal hypotheses only and must not be displayed as confirmed facts.

## Pricing Engine input sources

Use only relevant, permitted sources:

- current confirmed Deal facts;
- creator Rate Card;
- creator goals/non-negotiables/preferences;
- creator's own completed Deal history;
- thresholded aggregated Benchmark Engine outputs;
- versioned Knowledge Library;
- global safe Brand Intelligence.

Every fee recommendation returns:

- Ideal Ask;
- Expected Settlement;
- Minimum Worthwhile Fee;
- currency;
- concise rationale;
- evidence categories;
- confidence/evidence strength;
- any missing facts that could materially alter the answer.

Do not rely on a single LLM-generated number without deterministic validation/range sanity checks.

## Replio Score

The Score is **current commercial strength of the opportunity**, dynamic over time. It may consider:

- commercial value/fairness;
- benchmark position;
- deliverables/usage/exclusivity;
- term completeness;
- risk;
- creator fit/goals/non-negotiables;
- brand intelligence/reliability.

Every score must also answer `What would improve this?`

### Calibration rule

The founder decisions define the meaning and components, **not exact weights**. Therefore:

- implement a versioned, component-based score engine;
- keep weights/config in `score_versions`;
- create a documented provisional test calibration for fixtures;
- do not treat that calibration as immutable truth;
- production launch requires a score-version calibration review against the AI eval corpus.

Codex does not need to stop coding for this; it builds the mechanism and tests now.

## Risk Engine

Prioritise material commercial risks rather than dumping every possible concern. Typical categories include fee mismatch, missing rights duration/territory, perpetual or broad paid usage, exclusivity, payment terms, unclear deliverables/approval rounds and creator-specific red-line conflicts.

Replio is commercial guidance, not a law firm. Where interpretation depends on law/legal enforceability, clearly frame the limitation and recommend appropriate professional review rather than pretending certainty.

## Strategy Engine

Output structured objectives and negotiation sequence, not an essay. It should know:

- what to push first;
- target/settlement/minimum values;
- which terms need clarification;
- which creator goals/red lines matter;
- what concessions may be acceptable;
- respectful challenge triggers.

It must not make the final accept/decline decision.

## Reply Engine

- one primary draft;
- creator voice context;
- commercial strategy preserved;
- no fabricated facts/leverage;
- intentional rewrites;
- preserve creator edits unless `Start again`;
- custom instruction modifies requested aspects without silently weakening the commercial strategy.

## Confidence

Store internal numeric confidence per significant output, but map behaviour into meaningful states. Do not show `82% confidence` to creators.

- High: safe low-risk automation/clear language.
- Medium: recommendation with visible caveat/review.
- Low: ask for missing clarification rather than guessing.

Exact numeric cutoffs remain configuration/eval-driven.

## Failure/degradation

- Failed AI never hides email/deal data.
- Reject invalid output.
- Retry through durable job orchestration.
- Retry worker-level failure rather than re-running the whole pipeline when possible.
- Fall back to another configured model/provider if eval-compatible.
- UI says analysis could not complete / is retrying, never fakes a result.

## Knowledge system

Knowledge is versioned and trust-tiered. Each analysis records the versions used. Fine-tuning is out of MVP; improve workers, knowledge, schemas, retrieval and decision rules first.

No launch claim can rely on invented/sample knowledge. Test fixtures may be synthetic but must be clearly marked. Production Knowledge Library requires real sourced material.
