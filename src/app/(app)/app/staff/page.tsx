import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

export default async function StaffPage() {
  const supabase = await createSupabaseServerClient();
  const { data } = await supabase.from("profiles").select("id, full_name, email, role, created_at").order("created_at", { ascending: false });
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Staff & Permissions</h1>
      <p className="text-sm text-muted-foreground">Manage staff roles from Supabase Auth admin or a secured server workflow. Role changes must be performed by owners/admins.</p>
      <div className="rounded border bg-white">
        <Table>
          <TableHeader><TableRow><TableHead>Name</TableHead><TableHead>Email</TableHead><TableHead>Role</TableHead><TableHead>Joined</TableHead></TableRow></TableHeader>
          <TableBody>
            {(data ?? []).map((p: any) => (
              <TableRow key={p.id}><TableCell>{p.full_name}</TableCell><TableCell>{p.email}</TableCell><TableCell>{p.role}</TableCell><TableCell>{new Date(p.created_at).toLocaleDateString()}</TableCell></TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}