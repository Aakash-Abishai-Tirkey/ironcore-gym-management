import { Card, CardContent } from "@/components/ui/card";
import type { LucideIcon } from "lucide-react";

export function KpiCard({ title, value, icon: Icon }: { title: string; value: string | number; icon: LucideIcon }) {
  return (
    <Card>
      <CardContent className="pt-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-muted-foreground">{title}</p>
            <p className="text-2xl font-semibold mt-1">{value}</p>
          </div>
          <Icon className="size-8 text-muted-foreground/60" />
        </div>
      </CardContent>
    </Card>
  );
}