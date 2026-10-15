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
  full_name: z.string().min(2),
  phone: z.string().min(6),
  email: z.string().email().optional().or(z.literal("")),
  date_of_birth: z.string().optional(),
  gender: z.string().optional(),
  address: z.string().optional(),
  emergency_contact_name: z.string().optional(),
  emergency_contact_phone: z.string().optional(),
  fitness_goals: z.string().optional(),
  internal_notes: z.string().optional(),
});

type Values = z.infer<typeof schema>;

export default function NewMemberPage() {
  const router = useRouter();
  const form = useForm<Values>({ resolver: zodResolver(schema) as any, defaultValues: {} });

  async function onSubmit(values: Values) {
    const supabase = createSupabaseBrowserClient();
    const { error } = await supabase.from("members").insert({
      full_name: values.full_name,
      phone: values.phone,
      email: values.email || null,
      date_of_birth: values.date_of_birth || null,
      gender: values.gender || null,
      address: values.address || null,
      emergency_contact_name: values.emergency_contact_name || null,
      emergency_contact_phone: values.emergency_contact_phone || null,
      fitness_goals: values.fitness_goals || null,
      internal_notes: values.internal_notes || null,
    });
    if (error) {
      alert(error.message);
      return;
    }
    router.push("/app/members");
    router.refresh();
  }

  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl font-semibold mb-4">Add member</h1>
      <Card>
        <CardHeader><CardTitle>Member details</CardTitle></CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <div className="grid gap-4 md:grid-cols-2">
              <div><Label>Full name *</Label><Input {...form.register("full_name")} />{form.formState.errors.full_name && <p className="text-xs text-red-600">{form.formState.errors.full_name.message}</p>}</div>
              <div><Label>Phone *</Label><Input {...form.register("phone")} />{form.formState.errors.phone && <p className="text-xs text-red-600">{form.formState.errors.phone.message}</p>}</div>
              <div><Label>Email</Label><Input type="email" {...form.register("email")} /></div>
              <div><Label>Date of birth</Label><Input type="date" {...form.register("date_of_birth")} /></div>
              <div><Label>Gender</Label><Input {...form.register("gender")} /></div>
              <div><Label>Emergency contact</Label><Input {...form.register("emergency_contact_name")} /></div>
            </div>
            <div><Label>Address</Label><Textarea {...form.register("address")} /></div>
            <div><Label>Fitness goals</Label><Textarea {...form.register("fitness_goals")} /></div>
            <div><Label>Internal notes</Label><Textarea {...form.register("internal_notes")} /></div>
            <Button type="submit" disabled={form.formState.isSubmitting}>
              {form.formState.isSubmitting ? "Saving..." : "Save member"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}