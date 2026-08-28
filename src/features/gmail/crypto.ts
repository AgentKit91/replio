import { createCipheriv, createDecipheriv, randomBytes } from "node:crypto";

function decodeKey(encoded: string) {
  const key = Buffer.from(encoded, "base64");
  if (key.length !== 32) throw new Error("GMAIL_TOKEN_ENCRYPTION_KEY must be a base64-encoded 32-byte key");
  return key;
}

export function encryptRefreshToken(token: string, encodedKey: string) {
  const iv = randomBytes(12);
  const cipher = createCipheriv("aes-256-gcm", decodeKey(encodedKey), iv);
  const encrypted = Buffer.concat([cipher.update(token, "utf8"), cipher.final()]);
  return { ciphertext: encrypted.toString("base64"), iv: iv.toString("base64"), authTag: cipher.getAuthTag().toString("base64") };
}

export function decryptRefreshToken(payload: { ciphertext: string; iv: string; authTag: string }, encodedKey: string) {
  const decipher = createDecipheriv("aes-256-gcm", decodeKey(encodedKey), Buffer.from(payload.iv, "base64"));
  decipher.setAuthTag(Buffer.from(payload.authTag, "base64"));
  return Buffer.concat([decipher.update(Buffer.from(payload.ciphertext, "base64")), decipher.final()]).toString("utf8");
}
