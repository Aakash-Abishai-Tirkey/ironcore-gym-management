# Security

- Supabase RLS enforces data access; application also validates on server.
- Never commit `.env*`, service role keys, or real member data.
- Use separate Supabase projects/keys for local, preview, and production.
- Audit logs are append-only and restricted to admins.
- Financial records use numeric amounts; avoid floating-point arithmetic.