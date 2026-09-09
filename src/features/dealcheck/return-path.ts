export function safeRelativeReturnPath(value: string | null | undefined) {
  if (!value || !value.startsWith("/") || value.startsWith("//") || value.includes("\\") || /[\r\n]/.test(value)) return null;
  try {
    const url = new URL(value, "https://repbureau.invalid");
    if (url.origin !== "https://repbureau.invalid") return null;
    return `${url.pathname}${url.search}${url.hash}`;
  } catch { return null; }
}

export function isDealCheckReturnPath(value: string) {
  return value === "/dealcheck/resume" || value.startsWith("/dealcheck/resume?");
}
