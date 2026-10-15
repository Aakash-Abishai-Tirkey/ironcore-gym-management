"use client";

import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { createSupabaseBrowserClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

const schema = z.object({
  name: z.string().min(2),
  description: z.string().optional(),
  duration_days: z.coerce.number().int().positive(),
  price: z.coerce.number().nonnegative(),
  benefits: z.string().optional(),
  session_limit: z.coerce.number().int().optional(),
  freeze_days: z.coerce.number().int().optional(),
  active: z.boolean().default(true),
});
type Values = z.infer<typeof schema>;

export default function NewPlanPage() {
  const router = useRouter();
  const form = useForm<Values>({ resolver: zodResolver(schema) as any, defaultValues: { active: true, freeze_days: 0 } });
  async function onSubmit(v: Values) {
    const supabase = createSupabaseBrowserClient();
    const { error } = await supabase.from("membership_plans").insert({
      name: v.name,
      description: v.description || null,
      duration_days: v.duration_days,
      price: v.price,
      benefits: v.benefits || null,
      session_limit: v.session_limit ?? null,
      freeze_days: v.freeze_days ?? 0,
      active: v.active,
    });
    if (error) { alert(error.message); return; }
    router.push("/app/plans");
    router.refresh();
  }
  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl font-semibold mb-4">New membership plan</h1>
      <Card>
        <CardHeader><CardTitle>Plan details</CardTitle></CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <div><Label>Name</Label><Input {...form.register("name")} /></div>
            <div><Label>Description</Label><Textarea {...form.register("description")} /></div>
            <div className="grid gap-4 md:grid-cols-2">
              <div><Label>Duration days</Label><Input type="number" {...form.register("duration_days")} /></div>
              <div><Label>Price (INR)</Label><Input type="number" step="0.01" {...form.register("price")} /></div>
              <div><Label>Session limit</Label><Input type="number" {...form.register("session_limit")} /></div>
              <div><Label>Freeze days</Label><Input type="number" {...form.register("freeze_days")} /></div>
            </div>
            <div><Label>Benefits</Label><Textarea {...form.register("benefits")} /></div>
            <Button type="submit" disabled={form.formState.isSubmitting}>Save plan</Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}