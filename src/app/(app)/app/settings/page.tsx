export default function SettingsPage() {
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Settings</h1>
      <div className="rounded border bg-white p-4 space-y-2">
        <p className="text-sm">Configure gym name, logo, contact details, timezone and receipt numbering via environment/config. See README for details.</p>
        <ul className="text-sm list-disc pl-5">
          <li>Timezone: Asia/Kolkata (configurable)</li>
          <li>Currency: INR</li>
          <li>Date format: DD MMM YYYY</li>
        </ul>
      </div>
    </div>
  );
}