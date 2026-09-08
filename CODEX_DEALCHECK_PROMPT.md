# Codex kickoff prompt — copy/paste this into Codex

You are now responsible for completing DealCheck V1 in `AgentKit91/replio` on branch `dealcheck-v1`.

Start by reading `START_HERE_DEALCHECK.md`. Then follow `docs/27_DEALCHECK_V1.md`, `docs/28_DEALCHECK_INTELLIGENCE_V1.md`, and `docs/DEALCHECK_BUILD_LEDGER.md` as the locked founder specification and execution ledger.

The repository already contains mature Rep Bureau foundations. Reuse them. Do not restart the application, create another repo/project/backend, or spend time rebuilding auth, Supabase, Stripe, Vercel, AI Gateway, design tokens, CI or tests. Do not work on unrelated Rep Bureau backlog except where required to preserve/regression-test shared infrastructure.

Implement DealCheck continuously from D0 through D5 in dependency order. Do not stop after milestones to ask whether you should continue. Do not suggest or add nice-to-have features. Make ordinary engineering decisions yourself using the smallest secure maintainable implementation consistent with the spec. Keep `docs/DEALCHECK_BUILD_LEDGER.md` current after each coherent milestone so work can resume immediately if usage limits interrupt the session.

Use existing connected account access where available. If an external API is touched, verify its current official documentation rather than implementing from memory. If a production-only credential/legal/domain activation step is unavailable, complete and test everything possible in test/preview mode, record only the genuinely manual activation step, and continue with the rest of the build rather than stopping.

Throughout the build, run targeted tests and protect existing Rep Bureau behaviour. Before declaring completion, satisfy every applicable Definition of Done item in `docs/27_DEALCHECK_V1.md`, run the full `pnpm check`, verify Supabase RLS/security, verify Stripe credit webhook idempotency, and visually test the Vercel Preview at mobile and desktop widths with no obvious runtime/console errors.

Make coherent commits on `dealcheck-v1`. Do not merge to `main`. When all implementation/test gates pass, push the branch and provide a concise final handoff containing: completed Definition of Done, test results, preview URL if available, and only the founder-only production activation steps that genuinely remain.

Stop only for the blockers explicitly listed in `START_HERE_DEALCHECK.md`, an environment/usage limit, or full completion.