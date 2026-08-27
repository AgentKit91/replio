# Unresolved / Configurable Production Decisions

The build must not stall on these. Implement configuration seams and keep unsafe/unapproved behaviour gated until final production sign-off.

## Commercial sign-off (one pre-live session)

1. Final public plan names/prices/entitlements. Current working test seed: Standard £14.99, Pro £29.99, Ultra £49.99 with Ultra gated.
2. Whether trial starts without card or requires payment method.
3. Whether annual billing exists at launch (default: do not build unless confirmed; monthly only is sufficient).
4. Exact public fair-use wording, if any.

## Intelligence calibration

5. Replio Score v1 component weights/calibration. Meaning/components are locked; weights are not.
6. Minimum benchmark evidence/sample threshold and privacy cohort rules.
7. Exact confidence numeric cutoffs. Behavioural states are locked; numbers are not.
8. Pricing framework calibration values.

## Technical/config

9. Production AI provider/model routing (architecture must stay provider-agnostic).
10. Final Google Gmail scope list after current verification (least privilege).
11. Final production monitoring vendor beyond built-in logs/Founder OS, if any.
12. Brand accent/logo tokens/assets. UI system can be built without them.
13. FX data provider if multi-currency EAE aggregation is enabled at launch.

## Content/legal

14. Production Knowledge Library source set.
15. Privacy/Terms/cookie/legal-disclaimer wording.
16. Support contact and operational policy.

None of these is a reason for Codex to stop building the architecture and test-mode product.
