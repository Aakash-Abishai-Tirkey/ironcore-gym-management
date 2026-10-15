"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { createSupabaseBrowserClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

const schema = z.object({
  member_id: z.string().uuid(),
  subscription_id: z.string().optional(),
  amount: z.coerce.number().nonnegative(),
  method: z.string(),
  reference: z.string().optional(),
  notes: z.string().optional(),
});
type Values = z.infer<typeof schema>;

export default function NewPaymentPage() {
  const router = useRouter();
  const [members, setMembers] = useState<any[]>([]);
  const [subs, setSubs] = useState<any[]>([]);
  const form = useForm<Values>({ resolver: zodResolver(schema) as any, defaultValues: { method: "cash", amount: 0 } });

  useEffect(() => {
    const supabase = createSupabaseBrowserClient();
    supabase.from("members").select("id, full_name, member_code").order("full_name").then(({ data }) => setMembers(data ?? []));
  }, []);

  useEffect(() => {
    const mid = form.watch("member_id");
    if (!mid) return;
    const supabase = createSupabaseBrowserClient();
    supabase.from("subscriptions").select("id, membership_plans(name)").eq("member_id", mid).then(({ data }) => setSubs(data ?? []));
  }, [form.watch("member_id")]);

  async function onSubmit(v: Values) {
    const supabase = createSupabaseBrowserClient();
    const { data: { user } } = await supabase.auth.getUser();
    let profileId: string | null = null;
    if (user) {
      const { data: p } = await supabase.from("profiles").select("id").eq("id", user.id).single();
      profileId = p?.id ?? null;
    }
    const { error } = await supabase.from("payments").insert({
      member_id: v.member_id,
      subscription_id: v.subscription_id || null,
      amount: v.amount,
      method: v.method,
      reference: v.reference || null,
      notes: v.notes || null,
      recorded_by: profileId,
      status: "completed",
    });
    if (error) { alert(error.message); return; }
    router.push("/app/payments");
    router.refresh();
  }

  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl font-semibold mb-4">Record payment</h1>
      <Card>
        <CardHeader><CardTitle>Payment details</CardTitle></CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <div>
              <Label>Member</Label>
              <select {...form.register("member_id")} className="border rounded px-3 py-2 w-full">
                <option value="">Select member</option>
                {members.map((m) => (<option key={m.id} value={m.id}>{m.full_name} ({m.member_code})</option>))}
              </select>
            </div>
            {subs.length > 0 && (
              <div>
                <Label>Subscription (optional)</Label>
                <select {...form.register("subscription_id")} className="border rounded px-3 py-2 w-full">
                  <option value="">None</option>
                  {subs.map((s: any) => (<option key={s.id} value={s.id}>{s.membership_plans?.name ?? s.id}</option>))}
                </select>
              </div>
            )}
            <div><Label>Amount (INR)</Label><Input type="number" step="0.01" {...form.register("amount")} /></div>
            <div>
              <Label>Method</Label>
              <select {...form.register("method")} className="border rounded px-3 py-2 w-full">
                <option value="cash">Cash</option>
                <option value="upi">UPI</option>
                <option value="card">Card</option>
                <option value="bank_transfer">Bank transfer</option>
                <option value="other">Other</option>
              </select>
            </div>
            <div><Label>Reference</Label><Input {...form.register("reference")} /></div>
            <div><Label>Notes</Label><Input {...form.register("notes")} /></div>
            <Button type="submit" disabled={form.formState.isSubmitting}>Record payment</Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}