import Link from "next/link";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

export default async function WorkoutsPage() {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase.from("workout_plans").select("id, name, status, members(full_name), trainers(full_name)").order("created_at", { ascending: false });
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Workout Plans</h1>
        <Button render={<Link href="/app/workouts/new" />}>New plan</Button>
      </div>
      <div className="rounded border bg-white">
        <Table>
          <TableHeader><TableRow><TableHead>Name</TableHead><TableHead>Member</TableHead><TableHead>Trainer</TableHead><TableHead>Status</TableHead></TableRow></TableHeader>
          <TableBody>
            {(data ?? []).map((w: any) => (
              <TableRow key={w.id}><TableCell>{w.name}</TableCell><TableCell>{w.members?.full_name}</TableCell><TableCell>{w.trainers?.full_name ?? "—"}</TableCell><TableCell>{w.status}</TableCell></TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}