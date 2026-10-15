import Link from "next/link";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { formatDate } from "@/lib/format";

export default async function SubscriptionsPage() {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase
    .from("subscriptions")
    .select("id, member_id, plan_id, start_date, end_date, final_amount, status, payment_status, members(full_name, member_code), membership_plans(name)")
    .order("created_at", { ascending: false })
    .limit(100);
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Subscriptions</h1>
        <Button render={<Link href="/app/subscriptions/new" />}>Assign subscription</Button>
      </div>
      <div className="rounded border bg-white overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Member</TableHead><TableHead>Plan</TableHead><TableHead>Start</TableHead><TableHead>End</TableHead><TableHead>Amount</TableHead><TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {(data ?? []).map((s: any) => (
              <TableRow key={s.id}>
                <TableCell>{s.members?.full_name} ({s.members?.member_code})</TableCell>
                <TableCell>{s.membership_plans?.name}</TableCell>
                <TableCell>{formatDate(s.start_date)}</TableCell>
                <TableCell>{formatDate(s.end_date)}</TableCell>
                <TableCell>₹{Number(s.final_amount).toLocaleString("en-IN")}</TableCell>
                <TableCell><Badge>{s.status}</Badge></TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}