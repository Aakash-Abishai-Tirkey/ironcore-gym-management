import { addDays, format } from "date-fns";

export function calculateSubscriptionEndDate(startDate: Date | string, durationDays: number): string {
  const start = typeof startDate === "string" ? new Date(startDate) : startDate;
  if (Number.isNaN(start.getTime()) || durationDays <= 0) throw new Error("Invalid subscription inputs");
  // Inclusive end date: start day counts as day 1.
  return format(addDays(start, durationDays - 1), "yyyy-MM-dd");
}

export function daysRemaining(endDate: string | Date, now: Date = new Date()): number {
  const end = typeof endDate === "string" ? new Date(endDate) : endDate;
  const diff = end.getTime() - now.getTime();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}

export function isSubscriptionExpired(endDate: string | Date, now: Date = new Date()): boolean {
  const end = typeof endDate === "string" ? new Date(endDate) : endDate;
  end.setHours(23, 59, 59, 999);
  return now.getTime() > end.getTime();
}