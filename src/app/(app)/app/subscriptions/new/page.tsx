"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { addDays, format } from "date-fns";
import { createSupabaseBrowserClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

const schema = z.object({
  member_id: z.string().uuid(),
  plan_id: z.string().uuid(),
  start_date: z.string(),
  discount: z.coerce.number().nonnegative().default(0),
});
type Values = z.infer<typeof schema>;

export default function NewSubscriptionPage() {
  const router = useRouter();
  const [members, setMembers] = useState<any[]>([]);
  const [plans, setPlans] = useState<any[]>([]);
  const form = useForm<Values>({ resolver: zodResolver(schema) as any, defaultValues: { start_date: format(new Date(), "yyyy-MM-dd"), discount: 0 } });

  useEffect(() => {
    const supabase = createSupabaseBrowserClient();
    supabase.from("members").select("id, full_name, member_code").order("full_name").then(({ data }) => setMembers(data ?? []));
    supabase.from("membership_plans").select("id, name, duration_days, price").eq("active", true).then(({ data }) => setPlans(data ?? []));
  }, []);

  async function onSubmit(v: Values) {
    const supabase = createSupabaseBrowserClient();
    const plan = plans.find((p) => p.id === v.plan_id);
    if (!plan) { alert("Select a plan"); return; }
    const startDate = new Date(v.start_date);
    const endDate = addDays(startDate, plan.duration_days - 1);
    const finalAmount = Number(plan.price) - Number(v.discount);
    const { error } = await supabase.from("subscriptions").insert({
      member_id: v.member_id,
      plan_id: v.plan_id,
      start_date: v.start_date,
      end_date: format(endDate, "yyyy-MM-dd"),
      amount_charged: plan.price,
      discount: v.discount,
      final_amount: finalAmount,
      payment_status: "pending",
      status: "active",
    });
    if (error) { alert(error.message); return; }
    router.push("/app/subscriptions");
    router.refresh();
  }

  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl font-semibold mb-4">Assign subscription</h1>
      <Card>
        <CardHeader><CardTitle>Subscription details</CardTitle></CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <div>
              <Label>Member</Label>
              <select {...form.register("member_id")} className="border rounded px-3 py-2 w-full">
                <option value="">Select member</option>
                {members.map((m) => (<option key={m.id} value={m.id}>{m.full_name} ({m.member_code})</option>))}
              </select>
            </div>
            <div>
              <Label>Plan</Label>
              <select {...form.register("plan_id")} className="border rounded px-3 py-2 w-full">
                <option value="">Select plan</option>
                {plans.map((p) => (<option key={p.id} value={p.id}>{p.name} — ₹{Number(p.price).toLocaleString("en-IN")}</option>))}
              </select>
            </div>
            <div><Label>Start date</Label><Input type="date" {...form.register("start_date")} /></div>
            <div><Label>Discount (INR)</Label><Input type="number" step="0.01" {...form.register("discount")} /></div>
            <Button type="submit" disabled={form.formState.isSubmitting}>Assign</Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}