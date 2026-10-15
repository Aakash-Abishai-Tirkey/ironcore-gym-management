import Link from "next/link";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

export default async function TrainersPage() {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase.from("trainers").select("*").order("created_at", { ascending: false });
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Trainers</h1>
        <Button render={<Link href="/app/trainers/new" />}>Add trainer</Button>
      </div>
      <div className="rounded border bg-white">
        <Table>
          <TableHeader><TableRow><TableHead>Name</TableHead><TableHead>Email</TableHead><TableHead>Phone</TableHead><TableHead>Status</TableHead></TableRow></TableHeader>
          <TableBody>
            {(data ?? []).map((t: any) => (
              <TableRow key={t.id}><TableCell>{t.full_name}</TableCell><TableCell>{t.email ?? "—"}</TableCell><TableCell>{t.phone ?? "—"}</TableCell><TableCell>{t.employment_status}</TableCell></TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}