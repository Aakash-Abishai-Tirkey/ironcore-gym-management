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

const schema = z.object({ name: z.string().min(2), member_id: z.string().uuid(), trainer_id: z.string().optional(), objective: z.string().optional(), start_date: z.string().optional(), end_date: z.string().optional() });
type Values = z.infer<typeof schema>;

export default function NewWorkoutPage() {
  const router = useRouter();
  const [members, setMembers] = useState<any[]>([]);
  const [trainers, setTrainers] = useState<any[]>([]);
  const form = useForm<Values>({ resolver: zodResolver(schema) as any });
  useEffect(() => {
    const s = createSupabaseBrowserClient();
    s.from("members").select("id, full_name, member_code").order("full_name").then(({ data }) => setMembers(data ?? []));
    s.from("trainers").select("id, full_name").order("full_name").then(({ data }) => setTrainers(data ?? []));
  }, []);
  async function onSubmit(v: Values) {
    const s = createSupabaseBrowserClient();
    const { error } = await s.from("workout_plans").insert({
      name: v.name,
      member_id: v.member_id,
      trainer_id: v.trainer_id || null,
      objective: v.objective || null,
      start_date: v.start_date || null,
      end_date: v.end_date || null,
    });
    if (error) { alert(error.message); return; }
    router.push("/app/workouts");
    router.refresh();
  }
  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl font-semibold mb-4">New workout plan</h1>
      <Card><CardHeader><CardTitle>Details</CardTitle></CardHeader><CardContent>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
          <div><Label>Name</Label><Input {...form.register("name")} /></div>
          <div>
            <Label>Member</Label>
            <select {...form.register("member_id")} className="border rounded px-3 py-2 w-full">
              <option value="">Select</option>
              {members.map((m) => <option key={m.id} value={m.id}>{m.full_name} ({m.member_code})</option>)}
            </select>
          </div>
          <div>
            <Label>Trainer</Label>
            <select {...form.register("trainer_id")} className="border rounded px-3 py-2 w-full">
              <option value="">Optional</option>
              {trainers.map((t) => <option key={t.id} value={t.id}>{t.full_name}</option>)}
            </select>
          </div>
          <div><Label>Objective</Label><Input {...form.register("objective")} /></div>
          <div className="grid gap-4 md:grid-cols-2">
            <div><Label>Start</Label><Input type="date" {...form.register("start_date")} /></div>
            <div><Label>End</Label><Input type="date" {...form.register("end_date")} /></div>
          </div>
          <Button type="submit" disabled={form.formState.isSubmitting}>Save</Button>
        </form>
      </CardContent></Card>
    </div>
  );
}