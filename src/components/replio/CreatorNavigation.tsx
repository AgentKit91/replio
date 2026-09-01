"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navigation = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/deals", label: "Deals" },
  { href: "/brands", label: "Brands" },
  { href: "/insights", label: "Insights" },
  { href: "/train-replio", label: "Train Replio" },
  { href: "/settings", label: "Settings" },
];

export function navigationItemIsCurrent(pathname: string, href: string) {
  return pathname === href || (href !== "/dashboard" && pathname.startsWith(`${href}/`));
}

export function CreatorNavigation() {
  const pathname = usePathname();

  return <nav aria-label="Creator navigation">{navigation.map((item) => {
    const isCurrent = navigationItemIsCurrent(pathname, item.href);
    return <Link aria-current={isCurrent ? "page" : undefined} className={`nav-link${isCurrent ? " nav-link-current" : ""}`} href={item.href} key={item.href}>{item.label}</Link>;
  })}</nav>;
}

