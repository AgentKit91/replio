import { randomBytes } from "node:crypto";
import { describe, expect, it } from "vitest";
import { decryptRefreshToken, encryptRefreshToken } from "./crypto";

describe("Gmail token encryption", () => {
  it("round trips with AES-256-GCM", () => {
    const key = randomBytes(32).toString("base64");
    const encrypted = encryptRefreshToken("refresh-secret", key);
    expect(encrypted.ciphertext).not.toContain("refresh-secret");
    expect(decryptRefreshToken(encrypted, key)).toBe("refresh-secret");
  });
});
