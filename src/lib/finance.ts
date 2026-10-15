// Currency helpers using integer paise (1 INR = 100 paise) to avoid float errors.
export function inrToPaise(inr: number): number {
  return Math.round(inr * 100);
}

export function paiseToInr(paise: number): number {
  return paise / 100;
}

export function sumPaise(values: number[]): number {
  return values.reduce((s, v) => s + Math.round(v), 0);
}

export function calculateFinalAmountPaise(priceInr: number, discountInr: number): number {
  const price = inrToPaise(priceInr);
  const discount = inrToPaise(discountInr);
  if (discount > price) throw new Error("Discount cannot exceed price");
  if (discount < 0 || price < 0) throw new Error("Negative amounts not allowed");
  return price - discount;
}

export function calculateRefundPaise(originalPaise: number, refundedPaise: number): number {
  if (refundedPaise > originalPaise) throw new Error("Refund exceeds original");
  return originalPaise - refundedPaise;
}