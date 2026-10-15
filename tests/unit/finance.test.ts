import { describe, expect, it } from "vitest";
import { calculateFinalAmountPaise, inrToPaise, paiseToInr, sumPaise, calculateRefundPaise } from "@/lib/finance";

describe("finance", () => {
  it("converts inr to paise without floats", () => {
    expect(inrToPaise(1500)).toBe(150000);
    expect(inrToPaise(12.34)).toBe(1234);
    expect(paiseToInr(1234)).toBe(12.34);
  });
  it("sums safely", () => {
    expect(sumPaise([150000, 420000])).toBe(570000);
  });
  it("final amount", () => {
    expect(calculateFinalAmountPaise(1500, 100)).toBe(140000);
  });
  it("rejects discount exceed", () => {
    expect(() => calculateFinalAmountPaise(100, 150)).toThrow();
  });
  it("refund", () => {
    expect(calculateRefundPaise(1000, 300)).toBe(700);
    expect(() => calculateRefundPaise(100, 200)).toThrow();
  });
});