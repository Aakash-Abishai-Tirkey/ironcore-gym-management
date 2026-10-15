export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-3xl font-semibold">404</h1>
        <p className="text-muted-foreground">Page not found.</p>
        <a href="/app" className="text-blue-600 hover:underline">Go to dashboard</a>
      </div>
    </div>
  );
}