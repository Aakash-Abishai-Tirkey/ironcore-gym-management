"use client";

import { useState } from "react";
import { createSupabaseBrowserClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export function CheckInForm({ onDone }: { onDone: () => void }) {
  const [query, setQuery] = useState("");
  const [msg, setMsg] = useState<string | null>(null);

  async function checkIn() {
    setMsg(null);
    const supabase = createSupabaseBrowserClient();
    const { data: member } = await supabase
      .from("members")
      .select("id, full_name, status")
      .or(`member_code.eq.${query},phone.eq.${query}`)
      .maybeSingle();
    if (!member) { setMsg("Member not found"); return; }
    if (member.status !== "active") { setMsg(`Member is ${member.status}`); return; }
    const { data: existing } = await supabase
      .from("attendance_records")
      .select("id")
      .eq("member_id", member.id)
      .is("check_out_at", null)
      .limit(1);
    if (existing && existing.length > 0) { setMsg("Active check-in already exists"); return; }
    const { error } = await supabase.from("attendance_records").insert({ member_id: member.id });
    if (error) { setMsg(error.message); return; }
    setMsg(`Checked in ${member.full_name}`);
    setQuery("");
    setTimeout(() => window.location.reload(), 400);
  }

  return (
    <div className="flex gap-2 items-center">
      <Input placeholder="Member ID or phone" value={query} onChange={(e) => setQuery(e.target.value)} />
      <Button onClick={checkIn}>Check in</Button>
      {msg && <span className="text-sm text-muted-foreground">{msg}</span>}
    </div>
  );
}