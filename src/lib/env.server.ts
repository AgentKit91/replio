import "server-only";
import { z } from "zod";

const serverSchema = z.object({
  APP_ENV: z.enum(["development", "test", "preview", "production"]).default("development"),
  SUPABASE_SECRET_KEY: z.string().min(1).optional(),
  GOOGLE_CLIENT_ID: z.string().min(1).optional(),
  GOOGLE_CLIENT_SECRET: z.string().min(1).optional(),
  GOOGLE_OAUTH_REDIRECT_URI: z.url().optional(),
  GOOGLE_PUBSUB_TOPIC: z.string().startsWith("projects/").optional(),
  GOOGLE_PUBSUB_AUDIENCE: z.url().optional(),
  GOOGLE_PUBSUB_PUSH_SERVICE_ACCOUNT_EMAIL: z.email().optional(),
  GMAIL_TOKEN_ENCRYPTION_KEY: z.string().min(1).optional(),
  GMAIL_TOKEN_ENCRYPTION_KEY_VERSION: z.string().min(1).default("v1"),
  INTERNAL_JOB_SECRET: z.string().min(24).optional(),
  STRIPE_SECRET_KEY: z.string().regex(/^(rk|sk)_test_/).optional(),
  STRIPE_WEBHOOK_SECRET: z.string().startsWith("whsec_").optional(),
  AI_GATEWAY_MODEL: z.string().regex(/^[a-z0-9-]+\/[a-z0-9.-]+$/).optional(),
  AI_GATEWAY_FALLBACK_MODEL: z.string().regex(/^[a-z0-9-]+\/[a-z0-9.-]+$/).optional(),
  AI_INPUT_COST_MICRO_PER_MILLION: z.coerce.number().nonnegative().optional(),
  AI_OUTPUT_COST_MICRO_PER_MILLION: z.coerce.number().nonnegative().optional(),
});

export const serverEnv = serverSchema.parse({
  APP_ENV: process.env.APP_ENV,
  SUPABASE_SECRET_KEY: process.env.SUPABASE_SECRET_KEY || undefined,
  GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID || undefined,
  GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET || undefined,
  GOOGLE_OAUTH_REDIRECT_URI: process.env.GOOGLE_OAUTH_REDIRECT_URI || undefined,
  GOOGLE_PUBSUB_TOPIC: process.env.GOOGLE_PUBSUB_TOPIC || undefined,
  GOOGLE_PUBSUB_AUDIENCE: process.env.GOOGLE_PUBSUB_AUDIENCE || undefined,
  GOOGLE_PUBSUB_PUSH_SERVICE_ACCOUNT_EMAIL: process.env.GOOGLE_PUBSUB_PUSH_SERVICE_ACCOUNT_EMAIL || undefined,
  GMAIL_TOKEN_ENCRYPTION_KEY: process.env.GMAIL_TOKEN_ENCRYPTION_KEY || undefined,
  GMAIL_TOKEN_ENCRYPTION_KEY_VERSION: process.env.GMAIL_TOKEN_ENCRYPTION_KEY_VERSION,
  INTERNAL_JOB_SECRET: process.env.INTERNAL_JOB_SECRET || undefined,
  STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY || undefined,
  STRIPE_WEBHOOK_SECRET: process.env.STRIPE_WEBHOOK_SECRET || undefined,
  AI_GATEWAY_MODEL: process.env.AI_GATEWAY_MODEL || undefined,
  AI_GATEWAY_FALLBACK_MODEL: process.env.AI_GATEWAY_FALLBACK_MODEL || undefined,
  AI_INPUT_COST_MICRO_PER_MILLION: process.env.AI_INPUT_COST_MICRO_PER_MILLION || undefined,
  AI_OUTPUT_COST_MICRO_PER_MILLION: process.env.AI_OUTPUT_COST_MICRO_PER_MILLION || undefined,
});

export function requireGmailServerEnv() {
  const required = serverSchema.required({
    SUPABASE_SECRET_KEY: true,
    GOOGLE_CLIENT_ID: true,
    GOOGLE_CLIENT_SECRET: true,
    GOOGLE_OAUTH_REDIRECT_URI: true,
    GOOGLE_PUBSUB_TOPIC: true,
    GMAIL_TOKEN_ENCRYPTION_KEY: true,
  });
  return required.parse(serverEnv);
}

export function requireStripeServerEnv(){
  return serverSchema.required({STRIPE_SECRET_KEY:true,STRIPE_WEBHOOK_SECRET:true}).parse(serverEnv);
}
