"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { createSupabaseBrowserClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export default function ResetPasswordPage() {
  const router = useRouter();
  const [password, setPassword] = useState("");
  const [msg, setMsg] = useState<string | null>(null);
  async function submit(e: React.FormEvent) {
    e.preventDefault();
    const supabase = createSupabaseBrowserClient();
    const { error } = await supabase.auth.updateUser({ password });
    setMsg(error ? error.message : "Password updated. Redirecting...");
    if (!error) setTimeout(() => router.push("/login"), 1200);
  }
  return (
    <Card>
      <CardHeader><CardTitle>Reset password</CardTitle></CardHeader>
      <CardContent>
        <form onSubmit={submit} className="space-y-4">
          <div><Label>New password</Label><Input type="password" value={password} onChange={(e) => setPassword(e.target.value)} /></div>
          <Button type="submit">Update password</Button>
          {msg && <p className="text-sm text-muted-foreground">{msg}</p>}
        </form>
      </CardContent>
    </Card>
  );
}