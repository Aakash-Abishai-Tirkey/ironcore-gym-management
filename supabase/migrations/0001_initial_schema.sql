-- IronCore Gym Manager initial schema
create extension if not exists "uuid-ossp";

create sequence if not exists member_code_seq start 1001;
create sequence if not exists payment_code_seq start 100001;

do $$ begin
  create type user_role as enum ('owner','admin','receptionist','trainer','member');
exception when duplicate_object then null;
end $$;
do $$ begin
  create type membership_status as enum ('active','inactive','expired','frozen','cancelled','archived');
exception when duplicate_object then null;
end $$;
do $$ begin
  create type subscription_status as enum ('active','expired','frozen','cancelled');
exception when duplicate_object then null;
end $$;
do $$ begin
  create type payment_status as enum ('pending','completed','failed','refunded','reversed');
exception when duplicate_object then null;
end $$;
do $$ begin
  create type payment_method as enum ('cash','upi','card','bank_transfer','other');
exception when duplicate_object then null;
end $$;

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  gym_id uuid,
  full_name text not null,
  email text,
  phone text,
  role user_role not null default 'member',
  avatar_url text,
  member_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists members (
  id uuid primary key default uuid_generate_v4(),
  member_code text not null unique default ('M-' || lpad(nextval('member_code_seq'::regclass)::text, 6, '0')),
  full_name text not null,
  email text,
  phone text,
  date_of_birth date,
  gender text,
  address text,
  emergency_contact_name text,
  emergency_contact_phone text,
  status membership_status not null default 'active',
  trainer_id uuid,
  fitness_goals text,
  restricted_notes text,
  internal_notes text,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists membership_plans (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  description text,
  duration_days integer not null check (duration_days > 0),
  price numeric(12,2) not null check (price >= 0),
  benefits text,
  session_limit integer,
  freeze_days integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists subscriptions (
  id uuid primary key default uuid_generate_v4(),
  member_id uuid not null references members(id) on delete restrict,
  plan_id uuid not null references membership_plans(id) on delete restrict,
  start_date date not null,
  end_date date not null,
  amount_charged numeric(12,2) not null default 0,
  discount numeric(12,2) not null default 0,
  final_amount numeric(12,2) not null default 0,
  payment_status payment_status not null default 'pending',
  status subscription_status not null default 'active',
  frozen_until date,
  cancelled_at timestamptz,
  cancellation_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_date >= start_date)
);

create table if not exists subscription_freeze_periods (
  id uuid primary key default uuid_generate_v4(),
  subscription_id uuid not null references subscriptions(id) on delete cascade,
  start_date date not null,
  end_date date not null,
  reason text,
  created_at timestamptz not null default now(),
  check (end_date >= start_date)
);

create table if not exists payments (
  id uuid primary key default uuid_generate_v4(),
  transaction_code text not null unique default ('TXN-' || lpad(nextval('payment_code_seq'::regclass)::text, 8, '0')),
  member_id uuid not null references members(id) on delete restrict,
  subscription_id uuid references subscriptions(id) on delete set null,
  amount numeric(12,2) not null check (amount >= 0),
  paid_at timestamptz not null default now(),
  method payment_method not null default 'cash',
  reference text,
  status payment_status not null default 'completed',
  discount numeric(12,2) not null default 0,
  recorded_by uuid references profiles(id),
  notes text,
  reversed_payment_id uuid references payments(id),
  created_at timestamptz not null default now()
);

create table if not exists attendance_records (
  id uuid primary key default uuid_generate_v4(),
  member_id uuid not null references members(id) on delete restrict,
  check_in_at timestamptz not null default now(),
  check_out_at timestamptz,
  recorded_by uuid references profiles(id),
  notes text,
  created_at timestamptz not null default now(),
  check (check_out_at is null or check_out_at >= check_in_at)
);

create table if not exists trainers (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid references profiles(id),
  full_name text not null,
  email text,
  phone text,
  specializations text[] default '{}',
  certifications text,
  employment_status text not null default 'active',
  joining_date date,
  availability text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists trainer_member_assignments (
  id uuid primary key default uuid_generate_v4(),
  trainer_id uuid not null references trainers(id) on delete cascade,
  member_id uuid not null references members(id) on delete cascade,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (trainer_id, member_id)
);

do $$ begin
  alter table members add constraint fk_members_trainer foreign key (trainer_id) references trainers(id) on delete set null;
exception when duplicate_table then null;
end $$;
do $$ begin
  alter table profiles add constraint fk_profiles_member foreign key (member_id) references members(id) on delete set null;
exception when duplicate_table then null;
end $$;

create table if not exists workout_plans (
  id uuid primary key default uuid_generate_v4(),
  member_id uuid not null references members(id) on delete cascade,
  trainer_id uuid references trainers(id) on delete set null,
  name text not null,
  objective text,
  start_date date,
  end_date date,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists workout_exercises (
  id uuid primary key default uuid_generate_v4(),
  plan_id uuid not null references workout_plans(id) on delete cascade,
  order_index integer not null default 0,
  name text not null,
  category text,
  sets integer,
  reps text,
  weight numeric(8,2),
  rest_seconds integer,
  notes text
);

create table if not exists workout_sessions (
  id uuid primary key default uuid_generate_v4(),
  plan_id uuid references workout_plans(id) on delete set null,
  member_id uuid not null references members(id) on delete cascade,
  performed_at timestamptz not null default now(),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists fitness_progress_entries (
  id uuid primary key default uuid_generate_v4(),
  member_id uuid not null references members(id) on delete cascade,
  recorded_by uuid references profiles(id),
  recorded_at date not null default current_date,
  weight numeric(6,2),
  body_fat numeric(5,2),
  measurements jsonb,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists classes (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  description text,
  trainer_id uuid references trainers(id) on delete set null,
  starts_at timestamptz not null,
  duration_minutes integer not null default 60,
  capacity integer not null default 20,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists class_enrollments (
  id uuid primary key default uuid_generate_v4(),
  class_id uuid not null references classes(id) on delete cascade,
  member_id uuid not null references members(id) on delete cascade,
  status text not null default 'enrolled',
  created_at timestamptz not null default now(),
  unique (class_id, member_id)
);

create table if not exists equipment (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  category text,
  purchase_date date,
  purchase_cost numeric(12,2),
  quantity integer not null default 1,
  condition text not null default 'good',
  location text,
  last_maintenance_date date,
  next_maintenance_date date,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists equipment_maintenance_records (
  id uuid primary key default uuid_generate_v4(),
  equipment_id uuid not null references equipment(id) on delete cascade,
  performed_at date not null default current_date,
  notes text,
  cost numeric(12,2),
  created_at timestamptz not null default now()
);

create table if not exists notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade,
  type text not null,
  title text not null,
  message text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists audit_logs (
  id uuid primary key default uuid_generate_v4(),
  actor_id uuid references profiles(id),
  action text not null,
  target_type text,
  target_id uuid,
  metadata jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_members_status on members(status);
create index if not exists idx_members_name on members(full_name);
create index if not exists idx_subscriptions_member on subscriptions(member_id);
create index if not exists idx_subscriptions_status on subscriptions(status);
create index if not exists idx_subscriptions_end on subscriptions(end_date);
create index if not exists idx_payments_member on payments(member_id);
create index if not exists idx_payments_paid on payments(paid_at);
create index if not exists idx_attendance_member on attendance_records(member_id);
create index if not exists idx_attendance_checkin on attendance_records(check_in_at);

-- Helper functions for RLS
create or replace function get_current_app_role() returns user_role
language sql stable security definer as $$
  select role from profiles where id = auth.uid();
$$;

create or replace function is_staff() returns boolean
language sql stable security definer as $$
  select coalesce(get_current_app_role() in ('owner','admin','receptionist','trainer'), false);
$$;

create or replace function is_admin() returns boolean
language sql stable security definer as $$
  select coalesce(get_current_app_role() in ('owner','admin'), false);
$$;

-- Enable RLS
alter table profiles enable row level security;
alter table members enable row level security;
alter table membership_plans enable row level security;
alter table subscriptions enable row level security;
alter table subscription_freeze_periods enable row level security;
alter table payments enable row level security;
alter table attendance_records enable row level security;
alter table trainers enable row level security;
alter table trainer_member_assignments enable row level security;
alter table workout_plans enable row level security;
alter table workout_exercises enable row level security;
alter table workout_sessions enable row level security;
alter table fitness_progress_entries enable row level security;
alter table classes enable row level security;
alter table class_enrollments enable row level security;
alter table equipment enable row level security;
alter table equipment_maintenance_records enable row level security;
alter table notifications enable row level security;
alter table audit_logs enable row level security;

-- profiles policies
drop policy if exists "profiles_select_self_or_staff" on profiles;
create policy "profiles_select_self_or_staff" on profiles for select
  using (id = auth.uid() or is_staff());
drop policy if exists "profiles_update_self_or_admin" on profiles;
create policy "profiles_update_self_or_admin" on profiles for update
  using (id = auth.uid() or is_admin());
drop policy if exists "profiles_insert_admin" on profiles;
create policy "profiles_insert_admin" on profiles for insert
  with check (is_admin() or id = auth.uid());

-- members policies
drop policy if exists "members_select_staff_or_self" on members;
create policy "members_select_staff_or_self" on members for select
  using (is_staff() or exists (select 1 from profiles p where p.id = auth.uid() and p.member_id = members.id));
drop policy if exists "members_insert_staff" on members;
create policy "members_insert_staff" on members for insert
  with check (is_staff());
drop policy if exists "members_update_staff" on members;
create policy "members_update_staff" on members for update
  using (is_staff());
drop policy if exists "members_delete_admin" on members;
create policy "members_delete_admin" on members for delete
  using (is_admin());

-- membership_plans: readable by all authed, writable by admin
drop policy if exists "plans_select_authed" on membership_plans;
create policy "plans_select_authed" on membership_plans for select
  using (auth.uid() is not null);
drop policy if exists "plans_write_admin" on membership_plans;
create policy "plans_write_admin" on membership_plans for all
  using (is_admin()) with check (is_admin());

-- subscriptions
drop policy if exists "subs_select_staff_or_self" on subscriptions;
create policy "subs_select_staff_or_self" on subscriptions for select
  using (is_staff() or exists (select 1 from profiles p where p.id = auth.uid() and p.member_id = subscriptions.member_id));
drop policy if exists "subs_write_staff" on subscriptions;
create policy "subs_write_staff" on subscriptions for all
  using (is_staff()) with check (is_staff());

-- payments
drop policy if exists "payments_select_staff_or_self" on payments;
create policy "payments_select_staff_or_self" on payments for select
  using (is_staff() or exists (select 1 from profiles p where p.id = auth.uid() and p.member_id = payments.member_id));
drop policy if exists "payments_write_staff" on payments;
create policy "payments_write_staff" on payments for all
  using (is_staff()) with check (is_staff());

-- attendance
drop policy if exists "attendance_select_staff_or_self" on attendance_records;
create policy "attendance_select_staff_or_self" on attendance_records for select
  using (is_staff() or exists (select 1 from profiles p where p.id = auth.uid() and p.member_id = attendance_records.member_id));
drop policy if exists "attendance_write_staff" on attendance_records;
create policy "attendance_write_staff" on attendance_records for all
  using (is_staff()) with check (is_staff());

-- trainers
drop policy if exists "trainers_select_authed" on trainers;
create policy "trainers_select_authed" on trainers for select using (auth.uid() is not null);
drop policy if exists "trainers_write_admin" on trainers;
create policy "trainers_write_admin" on trainers for all using (is_admin()) with check (is_admin());

-- assignments
drop policy if exists "assignments_select_authed" on trainer_member_assignments;
create policy "assignments_select_authed" on trainer_member_assignments for select using (auth.uid() is not null);
drop policy if exists "assignments_write_admin" on trainer_member_assignments;
create policy "assignments_write_admin" on trainer_member_assignments for all using (is_admin()) with check (is_admin());

-- workout plans
drop policy if exists "workout_plans_select_staff_or_self" on workout_plans;
create policy "workout_plans_select_staff_or_self" on workout_plans for select
  using (is_staff() or exists (select 1 from profiles p where p.id = auth.uid() and p.member_id = workout_plans.member_id));
drop policy if exists "workout_plans_write_staff" on workout_plans;
create policy "workout_plans_write_staff" on workout_plans for all using (is_staff()) with check (is_staff());

drop policy if exists "workout_exercises_select_authed" on workout_exercises;
create policy "workout_exercises_select_authed" on workout_exercises for select using (auth.uid() is not null);
drop policy if exists "workout_exercises_write_staff" on workout_exercises;
create policy "workout_exercises_write_staff" on workout_exercises for all using (is_staff()) with check (is_staff());

drop policy if exists "workout_sessions_select_staff_or_self" on workout_sessions;
create policy "workout_sessions_select_staff_or_self" on workout_sessions for select
  using (is_staff() or exists (select 1 from profiles p where p.id = auth.uid() and p.member_id = workout_sessions.member_id));
drop policy if exists "workout_sessions_write_staff_or_self" on workout_sessions;
create policy "workout_sessions_write_staff_or_self" on workout_sessions for all using (auth.uid() is not null) with check (auth.uid() is not null);

-- progress
drop policy if exists "progress_select_staff_or_self" on fitness_progress_entries;
create policy "progress_select_staff_or_self" on fitness_progress_entries for select
  using (is_staff() or exists (select 1 from profiles p where p.id = auth.uid() and p.member_id = fitness_progress_entries.member_id));
drop policy if exists "progress_write_staff_or_self" on fitness_progress_entries;
create policy "progress_write_staff_or_self" on fitness_progress_entries for all using (auth.uid() is not null) with check (auth.uid() is not null);

-- classes
drop policy if exists "classes_select_authed" on classes;
create policy "classes_select_authed" on classes for select using (auth.uid() is not null);
drop policy if exists "classes_write_admin" on classes;
create policy "classes_write_admin" on classes for all using (is_admin()) with check (is_admin());

drop policy if exists "enrollments_select_authed" on class_enrollments;
create policy "enrollments_select_authed" on class_enrollments for select using (auth.uid() is not null);
drop policy if exists "enrollments_write_staff" on class_enrollments;
create policy "enrollments_write_staff" on class_enrollments for all using (is_staff()) with check (is_staff());

-- equipment
drop policy if exists "equipment_select_authed" on equipment;
create policy "equipment_select_authed" on equipment for select using (auth.uid() is not null);
drop policy if exists "equipment_write_admin" on equipment;
create policy "equipment_write_admin" on equipment for all using (is_admin()) with check (is_admin());

drop policy if exists "maint_select_authed" on equipment_maintenance_records;
create policy "maint_select_authed" on equipment_maintenance_records for select using (auth.uid() is not null);
drop policy if exists "maint_write_admin" on equipment_maintenance_records;
create policy "maint_write_admin" on equipment_maintenance_records for all using (is_admin()) with check (is_admin());

-- notifications
drop policy if exists "notifications_own" on notifications;
create policy "notifications_own" on notifications for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- audit logs (read admin only; insert via service/admin)
drop policy if exists "audit_select_admin" on audit_logs;
create policy "audit_select_admin" on audit_logs for select using (is_admin());
drop policy if exists "audit_insert_admin" on audit_logs;
create policy "audit_insert_admin" on audit_logs for insert with check (is_admin());

-- handle_new_user trigger
create or replace function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, full_name, email, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.email), new.email, coalesce((new.raw_user_meta_data->>'role')::user_role, 'member'))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- freeze periods, subscriptions update trigger, etc.
create or replace function touch_updated_at() returns trigger
language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists trg_profiles_upd on profiles;
create trigger trg_profiles_upd before update on profiles for each row execute function touch_updated_at();
drop trigger if exists trg_members_upd on members;
create trigger trg_members_upd before update on members for each row execute function touch_updated_at();
drop trigger if exists trg_plans_upd on membership_plans;
create trigger trg_plans_upd before update on membership_plans for each row execute function touch_updated_at();
drop trigger if exists trg_subs_upd on subscriptions;
create trigger trg_subs_upd before update on subscriptions for each row execute function touch_updated_at();
drop trigger if exists trg_trainers_upd on trainers;
create trigger trg_trainers_upd before update on trainers for each row execute function touch_updated_at();
drop trigger if exists trg_plansw_upd on workout_plans;
create trigger trg_plansw_upd before update on workout_plans for each row execute function touch_updated_at();
drop trigger if exists trg_classes_upd on classes;
create trigger trg_classes_upd before update on classes for each row execute function touch_updated_at();
drop trigger if exists trg_equip_upd on equipment;
create trigger trg_equip_upd before update on equipment for each row execute function touch_updated_at();