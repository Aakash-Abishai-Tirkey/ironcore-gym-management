import Link from "next/link";
import { notFound } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { formatDate } from "@/lib/format";

export default async function MemberDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createSupabaseServerClient();
  const { data: member } = await supabase.from("members").select("*").eq("id", id).single();
  if (!member) return notFound();

  const [{ data: subs }, { data: attendance }, { data: payments }, { data: progress }] = await Promise.all([
    supabase.from("subscriptions").select("*, membership_plans(name)").eq("member_id", id).order("created_at", { ascending: false }),
    supabase.from("attendance_records").select("*").eq("member_id", id).order("check_in_at", { ascending: false }).limit(20),
    supabase.from("payments").select("*").eq("member_id", id).order("paid_at", { ascending: false }).limit(20),
    supabase.from("fitness_progress_entries").select("*").eq("member_id", id).order("recorded_at", { ascending: false }).limit(20),
  ]);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold">{member.full_name}</h1>
          <div className="flex gap-2 items-center mt-1">
            <Badge>{member.member_code}</Badge>
            <Badge variant="secondary">{member.status}</Badge>
          </div>
        </div>
        <Button variant="outline" render={<Link href={`/app/members/${id}/edit`} />}>Edit</Button>
      </div>

      <Tabs defaultValue="overview">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="memberships">Memberships</TabsTrigger>
          <TabsTrigger value="attendance">Attendance</TabsTrigger>
          <TabsTrigger value="payments">Payments</TabsTrigger>
          <TabsTrigger value="progress">Progress</TabsTrigger>
        </TabsList>
        <TabsContent value="overview" className="space-y-2">
          <div className="grid gap-3 md:grid-cols-2">
            <Info label="Phone" value={member.phone} />
            <Info label="Email" value={member.email} />
            <Info label="DOB" value={formatDate(member.date_of_birth)} />
            <Info label="Gender" value={member.gender} />
            <Info label="Address" value={member.address} />
            <Info label="Fitness goals" value={member.fitness_goals} />
            <Info label="Registered" value={formatDate(member.created_at)} />
          </div>
        </TabsContent>
        <TabsContent value="memberships">
          <TableSimple rows={subs ?? []} cols={["start_date","end_date","status","final_amount"]} />
        </TabsContent>
        <TabsContent value="attendance">
          <TableSimple rows={attendance ?? []} cols={["check_in_at","check_out_at"]} />
        </TabsContent>
        <TabsContent value="payments">
          <TableSimple rows={payments ?? []} cols={["transaction_code","amount","method","status","paid_at"]} />
        </TabsContent>
        <TabsContent value="progress">
          <TableSimple rows={progress ?? []} cols={["recorded_at","weight","body_fat","notes"]} />
        </TabsContent>
      </Tabs>
    </div>
  );
}

function Info({ label, value }: { label: string; value: any }) {
  return (
    <div className="rounded border bg-white p-3">
      <div className="text-xs text-muted-foreground">{label}</div>
      <div className="text-sm font-medium">{value ?? "—"}</div>
    </div>
  );
}

function TableSimple({ rows, cols }: { rows: any[]; cols: string[] }) {
  if (rows.length === 0) return <p className="text-sm text-muted-foreground">No records.</p>;
  return (
    <div className="rounded border bg-white overflow-x-auto">
      <table className="w-full text-sm">
        <thead><tr>{cols.map((c) => <th key={c} className="text-left p-2 border-b">{c}</th>)}</tr></thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.id}>
              {cols.map((c) => (
                <td key={c} className="p-2 border-b">{formatDate(r[c]) === "—" && typeof r[c] !== "string" ? r[c] : (String(r[c] ?? "—").includes("T") ? formatDate(r[c]) : r[c])}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}