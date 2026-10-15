import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

export default async function AuditPage() {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase.from("audit_logs").select("*").order("created_at", { ascending: false }).limit(200);
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Audit Logs</h1>
      <div className="rounded border bg-white">
        <Table>
          <TableHeader><TableRow><TableHead>Action</TableHead><TableHead>Target</TableHead><TableHead>When</TableHead></TableRow></TableHeader>
          <TableBody>
            {(data ?? []).map((a: any) => (
              <TableRow key={a.id}><TableCell>{a.action}</TableCell><TableCell>{a.target_type} {a.target_id}</TableCell><TableCell>{new Date(a.created_at).toLocaleString()}</TableCell></TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}