import { createSupabaseServerClient } from "@/lib/supabase/server";
import { KpiCard } from "@/components/kpi-card";
import { Users, UserCheck, UserPlus, Clock, AlertTriangle, CalendarCheck, IndianRupee, CreditCard } from "lucide-react";

async function safeQuery<T>(fn: () => Promise<T>): Promise<{ data: T | null; error: string | null }> {
  try {
    const data = await fn();
    return { data, error: null };
  } catch (e) {
    return { data: null, error: e instanceof Error ? e.message : "Unknown error" };
  }
}

export default async function DashboardPage() {
  const result = await safeQuery(async () => {
    const supabase = await createSupabaseServerClient();
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1).toISOString();
    const endSoon = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000).toISOString();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString();

    const [
      totalMembersRes,
      activeMembersRes,
      newMembersRes,
      expiringRes,
      expiredRes,
      todayAttendanceRes,
      revenueRes,
      outstandingRes,
    ] = await Promise.all([
      supabase.from("members").select("id", { count: "exact", head: true }),
      supabase.from("members").select("id", { count: "exact", head: true }).eq("status", "active"),
      supabase.from("members").select("id", { count: "exact", head: true }).gte("created_at", startOfMonth),
      supabase.from("subscriptions").select("id", { count: "exact", head: true }).eq("status", "active").lte("end_date", endSoon).gte("end_date", now.toISOString()),
      supabase.from("subscriptions").select("id", { count: "exact", head: true }).eq("status", "expired"),
      supabase.from("attendance_records").select("id", { count: "exact", head: true }).gte("check_in_at", todayStart),
      supabase.from("payments").select("amount").eq("status", "completed").gte("paid_at", startOfMonth),
      supabase.from("subscriptions").select("outstanding_amount"),
    ]);

    const revenue = (revenueRes.data ?? []).reduce((sum, r: any) => sum + Number(r.amount ?? 0), 0);
    const outstanding = (outstandingRes.data ?? []).reduce((sum, r: any) => sum + Number(r.outstanding_amount ?? 0), 0);

    return {
      totalMembers: totalMembersRes.count ?? 0,
      activeMembers: activeMembersRes.count ?? 0,
      newMembers: newMembersRes.count ?? 0,
      expiring: expiringRes.count ?? 0,
      expired: expiredRes.count ?? 0,
      todayAttendance: todayAttendanceRes.count ?? 0,
      revenue,
      outstanding,
    };
  });

  if (result.error) {
    return (
      <div className="rounded-lg border bg-white p-6">
        <h1 className="text-xl font-semibold">Dashboard</h1>
        <p className="text-sm text-red-600 mt-2">
          Unable to load dashboard data: {result.error}. Configure Supabase environment variables and run migrations.
        </p>
      </div>
    );
  }

  const d = result.data!;
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Dashboard</h1>
        <p className="text-sm text-muted-foreground">Live metrics from your database.</p>
      </div>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KpiCard title="Total members" value={d.totalMembers} icon={Users} />
        <KpiCard title="Active members" value={d.activeMembers} icon={UserCheck} />
        <KpiCard title="New this month" value={d.newMembers} icon={UserPlus} />
        <KpiCard title="Expiring in 7 days" value={d.expiring} icon={Clock} />
        <KpiCard title="Expired memberships" value={d.expired} icon={AlertTriangle} />
        <KpiCard title="Today attendance" value={d.todayAttendance} icon={CalendarCheck} />
        <KpiCard title="Revenue this month (INR)" value={`₹${d.revenue.toLocaleString("en-IN")}`} icon={IndianRupee} />
        <KpiCard title="Outstanding (INR)" value={`₹${d.outstanding.toLocaleString("en-IN")}`} icon={CreditCard} />
      </div>
    </div>
  );
}