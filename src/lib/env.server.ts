import "server-only";
import { z } from "zod";

const serverSchema = z.object({
  APP_ENV: z.enum(["development", "test", "preview", "production"]).default("development"),
  SUPABASE_SECRET_KEY: z.string().min(1).optional(),
});

export const serverEnv = serverSchema.parse({
  APP_ENV: process.env.APP_ENV,
  SUPABASE_SECRET_KEY: process.env.SUPABASE_SECRET_KEY || undefined,
});
