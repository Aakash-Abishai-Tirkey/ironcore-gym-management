"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
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
  full_name: z.string().min(2),
  phone: z.string().min(6),
  email: z.string().email().optional().or(z.literal("")),
  status: z.string(),
  fitness_goals: z.string().optional(),
  internal_notes: z.string().optional(),
});
type Values = z.infer<typeof schema>;

export default function EditMemberPage() {
  const params = useParams();
  const id = params.id as string;
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const form = useForm<Values>({ resolver: zodResolver(schema) as any });

  useEffect(() => {
    (async () => {
      const supabase = createSupabaseBrowserClient();
      const { data } = await supabase.from("members").select("*").eq("id", id).single();
      if (data) {
        form.reset({
          full_name: data.full_name,
          phone: data.phone ?? "",
          email: data.email ?? "",
          status: data.status,
          fitness_goals: data.fitness_goals ?? "",
          internal_notes: data.internal_notes ?? "",
        });
      }
      setLoading(false);
    })();
  }, [id, form]);

  async function onSubmit(values: Values) {
    const supabase = createSupabaseBrowserClient();
    const { error } = await supabase
      .from("members")
      .update({
        full_name: values.full_name,
        phone: values.phone,
        email: values.email || null,
        status: values.status,
        fitness_goals: values.fitness_goals || null,
        internal_notes: values.internal_notes || null,
      })
      .eq("id", id);
    if (error) {
      alert(error.message);
      return;
    }
    router.push(`/app/members/${id}`);
    router.refresh();
  }

  if (loading) return <p>Loading...</p>;

  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl font-semibold mb-4">Edit member</h1>
      <Card>
        <CardHeader><CardTitle>Member details</CardTitle></CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <div><Label>Full name *</Label><Input {...form.register("full_name")} /></div>
            <div><Label>Phone *</Label><Input {...form.register("phone")} /></div>
            <div><Label>Email</Label><Input type="email" {...form.register("email")} /></div>
            <div><Label>Status</Label>
              <select {...form.register("status")} className="border rounded px-3 py-2 w-full">
                <option value="active">active</option>
                <option value="inactive">inactive</option>
                <option value="expired">expired</option>
                <option value="frozen">frozen</option>
                <option value="cancelled">cancelled</option>
                <option value="archived">archived</option>
              </select>
            </div>
            <div><Label>Fitness goals</Label><Textarea {...form.register("fitness_goals")} /></div>
            <div><Label>Internal notes</Label><Textarea {...form.register("internal_notes")} /></div>
            <Button type="submit" disabled={form.formState.isSubmitting}>
              {form.formState.isSubmitting ? "Saving..." : "Save changes"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}