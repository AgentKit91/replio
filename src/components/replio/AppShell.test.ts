import { describe, expect, it } from "vitest";

import { navigationItemIsCurrent } from "./CreatorNavigation";

describe("navigationItemIsCurrent", () => {
  it("marks exact top-level routes as current", () => {
    expect(navigationItemIsCurrent("/deals", "/deals")).toBe(true);
    expect(navigationItemIsCurrent("/deals", "/dashboard")).toBe(false);
  });

  it("keeps a section current on nested routes", () => {
    expect(navigationItemIsCurrent("/deals/123", "/deals")).toBe(true);
    expect(navigationItemIsCurrent("/deals/recycle-bin", "/deals")).toBe(true);
  });

  it("does not mark Dashboard current outside its exact route", () => {
    expect(navigationItemIsCurrent("/dashboard/example", "/dashboard")).toBe(false);
    expect(navigationItemIsCurrent("/brands", "/dashboard")).toBe(false);
  });
});

