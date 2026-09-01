import { describe, expect, it } from "vitest";

import nextConfig, { securityHeaders } from "./next.config";

describe("HTTP security headers", () => {
  it("applies the hardened header set to every route", async () => {
    expect(nextConfig.poweredByHeader).toBe(false);
    await expect(nextConfig.headers?.()).resolves.toEqual([
      { source: "/:path*", headers: securityHeaders },
    ]);
  });

  it("blocks framing, content sniffing and unneeded browser capabilities", () => {
    const values = Object.fromEntries(securityHeaders.map(({ key, value }) => [key, value]));
    expect(values["Content-Security-Policy"]).toContain("frame-ancestors 'none'");
    expect(values["Content-Security-Policy"]).toContain("object-src 'none'");
    expect(values["X-Content-Type-Options"]).toBe("nosniff");
    expect(values["Permissions-Policy"]).toContain("camera=()");
  });
});

