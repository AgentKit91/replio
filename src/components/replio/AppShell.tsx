import Link from "next/link";

import { CreatorNavigation } from "./CreatorNavigation";

export function AppShell({ children }: { children: React.ReactNode }) {
  return <div className="app-grid"><a className="skip-link" href="#main-content">Skip to main content</a><aside className="sidebar">
    <Link className="wordmark" href="/dashboard">Replio</Link>
    <CreatorNavigation />
  </aside><main className="app-main" id="main-content" tabIndex={-1}>{children}</main></div>;
}

