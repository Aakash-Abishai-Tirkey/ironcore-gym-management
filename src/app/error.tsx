"use client";
export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center space-y-3">
        <h1 className="text-2xl font-semibold">Something went wrong</h1>
        <p className="text-muted-foreground text-sm">{error.message}</p>
        <button onClick={reset} className="text-blue-600 hover:underline">Try again</button>
      </div>
    </div>
  );
}