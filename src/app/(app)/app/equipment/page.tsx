import Link from "next/link";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

export default async function EquipmentPage() {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase.from("equipment").select("*").order("created_at", { ascending: false });
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Equipment & Maintenance</h1>
        <Button render={<Link href="/app/equipment/new" />}>Add equipment</Button>
      </div>
      <div className="rounded border bg-white">
        <Table>
          <TableHeader><TableRow><TableHead>Name</TableHead><TableHead>Category</TableHead><TableHead>Qty</TableHead><TableHead>Condition</TableHead><TableHead>Next maintenance</TableHead></TableRow></TableHeader>
          <TableBody>
            {(data ?? []).map((e: any) => (
              <TableRow key={e.id}><TableCell>{e.name}</TableCell><TableCell>{e.category ?? "—"}</TableCell><TableCell>{e.quantity}</TableCell><TableCell>{e.condition}</TableCell><TableCell>{e.next_maintenance_date ?? "—"}</TableCell></TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}