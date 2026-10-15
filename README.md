# IronCore Gym Manager

Production-oriented full-stack gym management system built with Next.js (App Router), TypeScript, Tailwind CSS, shadcn/ui, and Supabase (PostgreSQL + Auth).

## Features
- Auth with Supabase (email/password, password reset)
- Role-based access: owner/admin, receptionist, trainer, member
- Member management, plans, subscriptions, attendance, payments
- Dashboard, reports, trainers, workouts, classes, equipment, notifications, audit logs
- RLS policies and SQL migrations
- Unit tests and production build

## Local setup
1. Install Node.js 20+ and npm.
2. `npm install`
3. Copy `.env.example` to `.env.local` and set Supabase values.
4. Apply `supabase/migrations/0001_initial_schema.sql` to your Supabase project.
   Optionally run `supabase/seed.sql` in a non-production database.
5. `npm run dev`

## Scripts
- `npm run dev` - development server
- `npm run build` - production build
- `npm run lint` - lint
- `npm run typecheck` - TypeScript
- `npm test` - unit tests

## Environment variables
See `.env.example`. Only `NEXT_PUBLIC_*` are browser-safe. `SUPABASE_SERVICE_ROLE_KEY` is server-only and must never use `NEXT_PUBLIC_`.

## Deployment
1. Push repository to GitHub.
2. Import into Vercel.
3. Configure environment variables in Vercel.
4. Set Supabase Auth redirect URLs to include your Vercel production domain and `/auth/callback`.
5. Apply migrations to production database.