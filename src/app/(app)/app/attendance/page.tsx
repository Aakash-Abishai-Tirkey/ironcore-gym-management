import { createSupabaseServerClient } from "@/lib/supabase/server";
import { CheckInForm } from "@/components/checkin-form";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { formatDate } from "@/lib/format";

export default async function AttendancePage() {
  const supabase = await createSupabaseServerClient();
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const { data } = await supabase
    .from("attendance_records")
    .select("id, check_in_at, check_out_at, members(full_name, member_code)")
    .gte("check_in_at", today.toISOString())
    .order("check_in_at", { ascending: false });

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Attendance</h1>
      <CheckInForm onDone={() => {}} />
      <div className="rounded border bg-white">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Member</TableHead><TableHead>Check in</TableHead><TableHead>Check out</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {(data ?? []).map((a: any) => (
              <TableRow key={a.id}>
                <TableCell>{a.members?.full_name} ({a.members?.member_code})</TableCell>
                <TableCell>{formatDate(a.check_in_at)} {new Date(a.check_in_at).toLocaleTimeString()}</TableCell>
                <TableCell>{a.check_out_at ? new Date(a.check_out_at).toLocaleTimeString() : "—"}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}