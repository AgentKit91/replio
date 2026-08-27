import { describe, expect, it } from "vitest";
import { hasSupabaseConfig, publicEnv } from "./env";

describe("environment validation", () => {
  it("uses a safe local app URL by default", () => {
    expect(publicEnv.NEXT_PUBLIC_APP_URL).toBe("http://localhost:3000");
  });

  it("does not pretend Supabase is configured", () => {
    expect(hasSupabaseConfig()).toBe(false);
  });
});
