import { describe, expect, it } from "vitest";
import { calculateSubscriptionEndDate, daysRemaining, isSubscriptionExpired } from "@/lib/subscription";

describe("subscription date math", () => {
  it("calculates inclusive end date", () => {
    expect(calculateSubscriptionEndDate("2026-01-01", 30)).toBe("2026-01-30");
    expect(calculateSubscriptionEndDate("2026-01-01", 1)).toBe("2026-01-01");
  });
  it("throws on invalid inputs", () => {
    expect(() => calculateSubscriptionEndDate("bad", 30)).toThrow();
    expect(() => calculateSubscriptionEndDate("2026-01-01", 0)).toThrow();
  });
  it("daysRemaining for future end date", () => {
    const future = new Date();
    future.setDate(future.getDate() + 5);
    expect(daysRemaining(future)).toBeGreaterThanOrEqual(4);
  });
  it("isSubscriptionExpired", () => {
    const past = new Date("2020-01-01");
    expect(isSubscriptionExpired(past)).toBe(true);
    const future = new Date();
    future.setFullYear(future.getFullYear() + 1);
    expect(isSubscriptionExpired(future)).toBe(false);
  });
});