import Link from "next/link";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { formatDate } from "@/lib/format";

export default async function PaymentsPage() {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase
    .from("payments")
    .select("id, transaction_code, amount, method, status, paid_at, members(full_name, member_code)")
    .order("paid_at", { ascending: false })
    .limit(100);
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Payments</h1>
        <Button render={<Link href="/app/payments/new" />}>Record payment</Button>
      </div>
      <div className="rounded border bg-white overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Txn</TableHead><TableHead>Member</TableHead><TableHead>Amount</TableHead><TableHead>Method</TableHead><TableHead>Status</TableHead><TableHead>Date</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {(data ?? []).map((p: any) => (
              <TableRow key={p.id}>
                <TableCell className="font-mono text-xs">{p.transaction_code}</TableCell>
                <TableCell>{p.members?.full_name}</TableCell>
                <TableCell>₹{Number(p.amount).toLocaleString("en-IN")}</TableCell>
                <TableCell>{p.method}</TableCell>
                <TableCell>{p.status}</TableCell>
                <TableCell>{formatDate(p.paid_at)}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}