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

const schema = z.object({ full_name: z.string().min(2), email: z.string().email().optional().or(z.literal("")), phone: z.string().optional(), employment_status: z.string().default("active"), specializations: z.string().optional() });
type Values = z.infer<typeof schema>;

export default function NewTrainerPage() {
  const router = useRouter();
  const form = useForm<Values>({ resolver: zodResolver(schema) as any, defaultValues: { employment_status: "active" } });
  async function onSubmit(v: Values) {
    const supabase = createSupabaseBrowserClient();
    const { error } = await supabase.from("trainers").insert({
      full_name: v.full_name,
      email: v.email || null,
      phone: v.phone || null,
      employment_status: v.employment_status,
      specializations: v.specializations ? v.specializations.split(",").map((s) => s.trim()) : [],
    });
    if (error) { alert(error.message); return; }
    router.push("/app/trainers");
    router.refresh();
  }
  return (
    <div className="max-w-xl">
      <h1 className="text-2xl font-semibold mb-4">Add trainer</h1>
      <Card>
        <CardHeader><CardTitle>Trainer details</CardTitle></CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <div><Label>Name</Label><Input {...form.register("full_name")} /></div>
            <div><Label>Email</Label><Input type="email" {...form.register("email")} /></div>
            <div><Label>Phone</Label><Input {...form.register("phone")} /></div>
            <div><Label>Specializations (comma separated)</Label><Input {...form.register("specializations")} /></div>
            <Button type="submit" disabled={form.formState.isSubmitting}>Save</Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}