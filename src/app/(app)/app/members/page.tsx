import Link from "next/link";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { formatDate } from "@/lib/format";

export default async function MembersPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; status?: string; page?: string }>;
}) {
  const sp = await searchParams;
  const q = sp.q ?? "";
  const status = sp.status ?? "";
  const page = Math.max(1, Number(sp.page ?? "1"));
  const pageSize = 20;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  const supabase = await createSupabaseServerClient();
  let query = supabase.from("members").select("*", { count: "exact" }).order("created_at", { ascending: false }).range(from, to);
  if (q) query = query.or(`full_name.ilike.%${q}%,member_code.ilike.%${q}%,phone.ilike.%${q}%,email.ilike.%${q}%`);
  if (status) query = query.eq("status", status);
  const { data, count, error } = await query;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Members</h1>
          <p className="text-sm text-muted-foreground">{count ?? 0} total</p>
        </div>
        <Button render={<Link href="/app/members/new" />}>Add member</Button>
      </div>

      <form className="flex gap-2" action="/app/members" method="get">
        <input name="q" defaultValue={q} placeholder="Search name, ID, phone, email" className="border rounded px-3 py-2 flex-1" />
        <select name="status" defaultValue={status} className="border rounded px-3 py-2">
          <option value="">All statuses</option>
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
          <option value="expired">Expired</option>
          <option value="frozen">Frozen</option>
          <option value="cancelled">Cancelled</option>
          <option value="archived">Archived</option>
        </select>
        <Button type="submit" variant="outline">Filter</Button>
      </form>

      {error && <p className="text-sm text-red-600">{error.message}</p>}

      <div className="rounded-md border bg-white">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Member ID</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Phone</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Registered</TableHead>
              <TableHead></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {(data ?? []).length === 0 && (
              <TableRow>
                <TableCell colSpan={6} className="text-center text-muted-foreground py-8">
                  No members found.
                </TableCell>
              </TableRow>
            )}
            {(data ?? []).map((m: any) => (
              <TableRow key={m.id}>
                <TableCell className="font-mono text-xs">{m.member_code}</TableCell>
                <TableCell>{m.full_name}</TableCell>
                <TableCell>{m.phone ?? "—"}</TableCell>
                <TableCell><Badge variant={m.status === "active" ? "default" : "secondary"}>{m.status}</Badge></TableCell>
                <TableCell>{formatDate(m.created_at)}</TableCell>
                <TableCell>
                  <Link href={`/app/members/${m.id}`} className="text-blue-600 hover:underline">View</Link>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-between">
        {page > 1 ? (
          <Link href={`/app/members?page=${page - 1}&q=${encodeURIComponent(q)}&status=${status}`} className="text-sm text-blue-600">Previous</Link>
        ) : <span />}
        { (count ?? 0) > page * pageSize && (
          <Link href={`/app/members?page=${page + 1}&q=${encodeURIComponent(q)}&status=${status}`} className="text-sm text-blue-600">Next</Link>
        )}
      </div>
    </div>
  );
}