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

const schema = z.object({ name: z.string().min(2), category: z.string().optional(), quantity: z.coerce.number().int().positive().default(1), condition: z.string().default("good"), location: z.string().optional(), next_maintenance_date: z.string().optional() });
type Values = z.infer<typeof schema>;

export default function NewEquipmentPage() {
  const router = useRouter();
  const form = useForm<Values>({ resolver: zodResolver(schema) as any, defaultValues: { quantity: 1, condition: "good" } });
  async function onSubmit(v: Values) {
    const s = createSupabaseBrowserClient();
    const { error } = await s.from("equipment").insert({ name: v.name, category: v.category || null, quantity: v.quantity, condition: v.condition, location: v.location || null, next_maintenance_date: v.next_maintenance_date || null });
    if (error) { alert(error.message); return; }
    router.push("/app/equipment"); router.refresh();
  }
  return (
    <div className="max-w-xl">
      <h1 className="text-2xl font-semibold mb-4">Add equipment</h1>
      <Card><CardHeader><CardTitle>Details</CardTitle></CardHeader><CardContent>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
          <div><Label>Name</Label><Input {...form.register("name")} /></div>
          <div><Label>Category</Label><Input {...form.register("category")} /></div>
          <div className="grid gap-4 md:grid-cols-2">
            <div><Label>Quantity</Label><Input type="number" {...form.register("quantity")} /></div>
            <div><Label>Condition</Label><Input {...form.register("condition")} /></div>
          </div>
          <div><Label>Location</Label><Input {...form.register("location")} /></div>
          <div><Label>Next maintenance</Label><Input type="date" {...form.register("next_maintenance_date")} /></div>
          <Button type="submit" disabled={form.formState.isSubmitting}>Save</Button>
        </form>
      </CardContent></Card>
    </div>
  );
}