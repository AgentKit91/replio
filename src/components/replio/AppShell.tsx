import Link from "next/link";

const navigation = ["Dashboard", "Deals", "Brands", "Insights", "Train Replio", "Settings"];

export function AppShell({ children }: { children: React.ReactNode }) {
  return <div className="app-grid"><aside className="sidebar">
    <Link className="wordmark" href="/dashboard">Replio</Link>
    <nav aria-label="Creator navigation">{navigation.map((item) => <Link className="nav-link" href={item === "Dashboard" ? "/dashboard" : `/${item.toLowerCase().replace(" ", "-")}`} key={item}>{item}</Link>)}</nav>
  </aside><main className="app-main">{children}</main></div>;
}
