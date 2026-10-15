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

const schema = z.object({ name: z.string().min(2), description: z.string().optional(), trainer_id: z.string().optional(), starts_at: z.string(), duration_minutes: z.coerce.number().int().positive().default(60), capacity: z.coerce.number().int().positive().default(20) });
type Values = z.infer<typeof schema>;

export default function NewClassPage() {
  const router = useRouter();
  const [trainers, setTrainers] = useState<any[]>([]);
  const form = useForm<Values>({ resolver: zodResolver(schema) as any, defaultValues: { duration_minutes: 60, capacity: 20 } });
  useEffect(() => { createSupabaseBrowserClient().from("trainers").select("id, full_name").then(({ data }) => setTrainers(data ?? [])); }, []);
  async function onSubmit(v: Values) {
    const s = createSupabaseBrowserClient();
    const { error } = await s.from("classes").insert({ name: v.name, description: v.description || null, trainer_id: v.trainer_id || null, starts_at: v.starts_at, duration_minutes: v.duration_minutes, capacity: v.capacity });
    if (error) { alert(error.message); return; }
    router.push("/app/classes"); router.refresh();
  }
  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl font-semibold mb-4">New class</h1>
      <Card><CardHeader><CardTitle>Details</CardTitle></CardHeader><CardContent>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
          <div><Label>Name</Label><Input {...form.register("name")} /></div>
          <div><Label>Description</Label><Input {...form.register("description")} /></div>
          <div>
            <Label>Trainer</Label>
            <select {...form.register("trainer_id")} className="border rounded px-3 py-2 w-full">
              <option value="">Optional</option>
              {trainers.map((t) => <option key={t.id} value={t.id}>{t.full_name}</option>)}
            </select>
          </div>
          <div><Label>Starts at</Label><Input type="datetime-local" {...form.register("starts_at")} /></div>
          <div className="grid gap-4 md:grid-cols-2">
            <div><Label>Duration (min)</Label><Input type="number" {...form.register("duration_minutes")} /></div>
            <div><Label>Capacity</Label><Input type="number" {...form.register("capacity")} /></div>
          </div>
          <Button type="submit" disabled={form.formState.isSubmitting}>Save</Button>
        </form>
      </CardContent></Card>
    </div>
  );
}