import { createSupabaseServerClient } from "@/lib/supabase/server";
import { formatCurrencyInr } from "@/lib/format";

export default async function ReportsPage() {
  const supabase = await createSupabaseServerClient();
  const [{ count: activeSubs }, { count: expiredSubs }, { data: payments }, { count: totalMembers }] = await Promise.all([
    supabase.from("subscriptions").select("id", { count: "exact", head: true }).eq("status", "active"),
    supabase.from("subscriptions").select("id", { count: "exact", head: true }).eq("status", "expired"),
    supabase.from("payments").select("amount, method, status"),
    supabase.from("members").select("id", { count: "exact", head: true }),
  ]);
  const completed = (payments ?? []).filter((p: any) => p.status === "completed");
  const revenue = completed.reduce((s: number, p: any) => s + Number(p.amount), 0);
  const byMethod = completed.reduce((acc: any, p: any) => {
    acc[p.method] = (acc[p.method] ?? 0) + Number(p.amount);
    return acc;
  }, {});

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold">Reports & Analytics</h1>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Stat label="Total members" value={totalMembers ?? 0} />
        <Stat label="Active subscriptions" value={activeSubs ?? 0} />
        <Stat label="Expired subscriptions" value={expiredSubs ?? 0} />
        <Stat label="Revenue collected" value={formatCurrencyInr(revenue)} />
      </div>
      <div className="rounded border bg-white p-4">
        <h2 className="font-medium mb-2">Revenue by payment method</h2>
        {Object.keys(byMethod).length === 0 && <p className="text-sm text-muted-foreground">No data.</p>}
        <ul className="text-sm space-y-1">
          {Object.entries(byMethod).map(([m, v]) => (
            <li key={m}>{m}: {formatCurrencyInr(Number(v))}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}

function Stat({ label, value }: { label: string; value: any }) {
  return (
    <div className="rounded border bg-white p-4">
      <div className="text-sm text-muted-foreground">{label}</div>
      <div className="text-xl font-semibold">{value}</div>
    </div>
  );
}