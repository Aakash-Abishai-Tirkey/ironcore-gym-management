import Link from "next/link";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { formatDate } from "@/lib/format";

export default async function ClassesPage() {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase.from("classes").select("id, name, starts_at, duration_minutes, capacity, trainers(full_name)").order("starts_at", { ascending: true });
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Classes & Schedule</h1>
        <Button render={<Link href="/app/classes/new" />}>New class</Button>
      </div>
      <div className="rounded border bg-white">
        <Table>
          <TableHeader><TableRow><TableHead>Name</TableHead><TableHead>Trainer</TableHead><TableHead>Starts</TableHead><TableHead>Duration</TableHead><TableHead>Capacity</TableHead></TableRow></TableHeader>
          <TableBody>
            {(data ?? []).map((c: any) => (
              <TableRow key={c.id}><TableCell>{c.name}</TableCell><TableCell>{c.trainers?.full_name ?? "—"}</TableCell><TableCell>{formatDate(c.starts_at)}</TableCell><TableCell>{c.duration_minutes} min</TableCell><TableCell>{c.capacity}</TableCell></TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}