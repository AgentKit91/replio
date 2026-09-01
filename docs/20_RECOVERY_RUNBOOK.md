# Replio recovery runbook

This runbook covers application rollback, database rebuild and creator-data recovery. It is deliberately conservative: never restore over the production database as a rehearsal.

## Recovery objectives

- Restore a bad application release within 15 minutes by reassigning the production domain to the immediately previous known-good Vercel deployment.
- Rebuild the complete database schema from versioned migrations and rerun the pgTAP access matrix in CI on every change.
- Until Replio moves to a Supabase plan with managed daily backups, create an encrypted logical backup at least weekly and immediately before every hosted migration.
- Treat a logical production-data restore as an incident requiring a new isolated Supabase project, validation, and an explicit founder-approved cutover.

## What must be recoverable

1. GitHub `main`, migrations and application code.
2. Supabase roles, schema and data dumps.
3. Vercel environment-variable names and separately retained secret values.
4. Supabase Auth/provider configuration, redirect URLs, Cron/Vault configuration and Google Pub/Sub settings, which are not completely reconstructed by a database dump.
5. The Gmail token-encryption root key and key version. Database ciphertext is unusable without the matching key.
6. Stripe test catalogue IDs, webhook endpoint configuration and Google OAuth/Pub/Sub identifiers.

Never commit connection strings, database passwords, access tokens, encryption keys or backup contents to Git.

## Routine logical backup

Use the Supabase Dashboard **Connect** panel's Session pooler connection string and inject the password only for the current terminal session. Write the three files into a new encrypted, access-controlled backup directory outside the repository.

```text
supabase db dump --db-url <SOURCE_DATABASE_URL> -f roles.sql --role-only
supabase db dump --db-url <SOURCE_DATABASE_URL> -f schema.sql
supabase db dump --db-url <SOURCE_DATABASE_URL> -f data.sql --use-copy --data-only -x "storage.buckets_vectors" -x "storage.vector_indexes"
```

Record the UTC timestamp, source project ref, current `main` commit, latest migration name, file sizes and SHA-256 checksums next to the encrypted files. Do not copy raw creator data to a general-purpose shared drive or CI artifact.

Backup cadence:

- weekly during closed beta;
- immediately before every hosted migration;
- immediately before changing encryption, Auth, webhook or queue configuration;
- increase to daily or enable an appropriate managed backup plan before broader customer use.

## Non-destructive restore rehearsal

1. Create a temporary, isolated Supabase project in the same region. Never use the production project as the target.
2. Configure required extensions and obtain the target Session pooler URL.
3. Restore in one transaction with errors stopping the restore:

```text
psql --single-transaction --variable ON_ERROR_STOP=1 --file roles.sql --file schema.sql --command "SET session_replication_role = replica" --file data.sql --dbname <TARGET_DATABASE_URL>
```

4. Apply or reconcile the repository migration history as described in the current Supabase restore guide.
5. Configure Auth providers, allowed redirects, Vault/Cron, Pub/Sub and Vercel Preview variables against the temporary project.
6. Run the pgTAP suite, tenant-isolation checks and a read-only golden-path browser test.
7. Confirm counts for workspaces, memberships, labelled Gmail connections, Deals, messages, drafts, subscriptions and queues. Never print message bodies, drafts, private notes or refresh-token ciphertext into logs.
8. Verify the encryption key can decrypt one deliberately selected token in a private diagnostic process, without displaying the plaintext.
9. Delete the temporary project only after recording the rehearsal result and expiry date. Deletion is irreversible and requires exact target confirmation.

The CI `database` job separately performs a clean migration rebuild and repeats every pgTAP assertion. This proves schema reproducibility, not production-data recoverability; the isolated logical-restore rehearsal remains required before public launch and after material schema/encryption changes.

## Vercel application rollback

Before release, record the current production deployment URL and commit as the known-good target. On the Hobby plan, only the immediately previous production deployment is eligible for instant rollback.

Incident sequence:

```text
vercel logs --environment production --status-code 5xx --since 30m
vercel rollback
vercel rollback status
vercel logs --environment production --status-code 5xx --since 5m
```

Then inspect the bad deployment, fix on a branch, allow app/database/Vercel checks to pass, and deploy normally. A rollback restores the previous build but does not roll back the database. Never roll application code behind an incompatible migration; prefer backward-compatible expand/migrate/contract schema changes.

After Vercel rollback, automatic production-domain assignment is disabled. Restore normal Git deployment behaviour only after the fixed deployment is verified:

```text
vercel promote <VERIFIED_DEPLOYMENT_URL>
vercel promote status
```

## Database incident decision

- Application regression only: Vercel rollback; do not touch the database.
- Forward-compatible migration defect: disable affected workers/features, deploy a forward fix, verify advisors and pgTAP.
- Corrupt or deleted creator data: pause AI and Gmail-send workers, preserve evidence, take a fresh logical dump, restore the last safe backup into a new isolated project and assess data loss before any cutover.
- Credential exposure: rotate the affected credential first; a database restore does not revoke OAuth tokens, API keys or active sessions.

Every production restore or project cutover requires exact founder approval because it causes downtime and can lose or expose creator data.

## Quarterly recovery record

Record:

- rehearsal date and operator;
- source commit and migration;
- backup timestamps and checksum verification;
- clean-schema CI result;
- isolated restore result and duration;
- pgTAP and golden-path result;
- Vercel known-good/current deployment identifiers;
- issues, owners and retest date.

