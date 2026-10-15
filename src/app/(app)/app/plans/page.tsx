import Link from "next/link";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { formatCurrencyInr } from "@/lib/format";

export default async function PlansPage() {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase.from("membership_plans").select("*").order("created_at", { ascending: false });
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Membership Plans</h1>
        <Button render={<Link href="/app/plans/new" />}>Add plan</Button>
      </div>
      <div className="rounded border bg-white">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead><TableHead>Duration (days)</TableHead><TableHead>Price</TableHead><TableHead>Active</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {(data ?? []).map((p:any) => (
              <TableRow key={p.id}>
                <TableCell>{p.name}</TableCell>
                <TableCell>{p.duration_days}</TableCell>
                <TableCell>{formatCurrencyInr(Number(p.price))}</TableCell>
                <TableCell><Badge variant={p.active ? "default":"secondary"}>{p.active ? "Active":"Inactive"}</Badge></TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}