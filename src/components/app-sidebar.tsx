"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Home, Users, CreditCard, ClipboardList, Wallet, Dumbbell, Calendar, BarChart3, Bell, Wrench, Shield, FileText, Settings, LogOut } from "lucide-react";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { createSupabaseBrowserClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

const groups = [
  {
    label: "Overview",
    items: [{ href: "/app", label: "Dashboard", icon: Home }],
  },
  {
    label: "Members",
    items: [
      { href: "/app/members", label: "Members", icon: Users },
      { href: "/app/plans", label: "Membership Plans", icon: CreditCard },
      { href: "/app/subscriptions", label: "Subscriptions", icon: ClipboardList },
      { href: "/app/attendance", label: "Attendance", icon: ClipboardList },
      { href: "/app/payments", label: "Payments", icon: Wallet },
    ],
  },
  {
    label: "Coaching",
    items: [
      { href: "/app/trainers", label: "Trainers", icon: Dumbbell },
      { href: "/app/workouts", label: "Workout Plans", icon: Dumbbell },
      { href: "/app/classes", label: "Classes & Schedule", icon: Calendar },
    ],
  },
  {
    label: "Ops",
    items: [
      { href: "/app/reports", label: "Reports", icon: BarChart3 },
      { href: "/app/notifications", label: "Notifications", icon: Bell },
      { href: "/app/equipment", label: "Equipment", icon: Wrench },
      { href: "/app/staff", label: "Staff", icon: Shield },
      { href: "/app/audit", label: "Audit Logs", icon: FileText },
      { href: "/app/settings", label: "Settings", icon: Settings },
    ],
  },
];

export function AppSidebar() {
  const pathname = usePathname();
  const router = useRouter();
  async function signOut() {
    const supabase = createSupabaseBrowserClient();
    await supabase.auth.signOut();
    router.push("/login");
    router.refresh();
  }
  return (
    <Sidebar>
      <SidebarHeader>
        <div className="px-2 py-2">
          <div className="text-lg font-semibold tracking-tight">IronCore</div>
          <div className="text-xs text-muted-foreground">Gym Manager</div>
        </div>
      </SidebarHeader>
      <SidebarContent>
        {groups.map((g) => (
          <SidebarGroup key={g.label}>
            <SidebarGroupLabel>{g.label}</SidebarGroupLabel>
            <SidebarMenu>
              {g.items.map((item) => {
                const active = pathname === item.href || pathname.startsWith(item.href + "/");
                return (
                  <SidebarMenuItem key={item.href}>
                    <SidebarMenuButton render={<Link href={item.href} />} isActive={active}>
                      <item.icon className="size-4" />
                      <span>{item.label}</span>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                );
              })}
            </SidebarMenu>
          </SidebarGroup>
        ))}
      </SidebarContent>
      <SidebarFooter>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton onClick={signOut}>
              <LogOut className="size-4" />
              <span>Sign out</span>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
    </Sidebar>
  );
}