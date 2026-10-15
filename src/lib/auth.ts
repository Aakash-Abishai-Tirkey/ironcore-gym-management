import { createSupabaseServerClient } from "@/lib/supabase/server";

export type Role = "owner" | "admin" | "receptionist" | "trainer" | "member";

export async function getCurrentProfile() {
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return null;
  const { data: profile } = await supabase
    .from("profiles")
    .select("id, gym_id, role, full_name, email")
    .eq("id", user.id)
    .single();
  return profile;
}

export function isStaffRole(role: string | undefined | null) {
  return role === "owner" || role === "admin" || role === "receptionist" || role === "trainer";
}

export function hasRole(profile: { role?: string | null } | null, allowed: Role[]) {
  if (!profile?.role) return false;
  return allowed.includes(profile.role as Role);
}