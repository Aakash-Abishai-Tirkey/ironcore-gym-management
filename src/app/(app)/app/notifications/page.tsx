import { createSupabaseServerClient } from "@/lib/supabase/server";
import { Bell } from "lucide-react";

export default async function NotificationsPage() {
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  const { data } = user
    ? await supabase.from("notifications").select("*").eq("user_id", user.id).order("created_at", { ascending: false })
    : { data: [] };
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Notifications</h1>
      {(data ?? []).length === 0 && <p className="text-muted-foreground">No notifications.</p>}
      <div className="space-y-2">
        {(data ?? []).map((n: any) => (
          <div key={n.id} className="rounded border bg-white p-3">
            <div className="font-medium">{n.title}</div>
            <div className="text-sm text-muted-foreground">{n.message}</div>
            <div className="text-xs text-muted-foreground mt-1">{new Date(n.created_at).toLocaleString()}</div>
          </div>
        ))}
      </div>
    </div>
  );
}