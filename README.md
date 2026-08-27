# Replio

Commercial intelligence and negotiation management for individual creators. Replio only processes Gmail threads a creator explicitly labels `Replio`; AI advises and the creator decides.

## Local development

Requirements: Node.js 22+, pnpm 11.19, Docker (for local Supabase tests).

```bash
cp .env.example .env.local
pnpm install --frozen-lockfile
pnpm dev
```

Run the application quality gate with `pnpm check`. Run database migrations and RLS tests with `supabase start` and `supabase test db`.

Environment values are documented in `.env.example`. Never commit local values or server credentials.

Implementation authority and milestone status live in `AGENTS.md`, `START_HERE_CODEX.md`, and `docs/BUILD_STATUS.md`.
