-- Demo seed data. Run only in a non-production database.
-- Assumes an owner user exists. Replace :owner_id with a real profile id.

insert into membership_plans (name, description, duration_days, price, benefits, active) values
  ('Monthly', 'Standard monthly membership', 30, 1500.00, 'Gym floor access', true),
  ('Quarterly', '3-month plan', 90, 4200.00, 'Gym floor + locker', true),
  ('Annual', '12-month plan', 365, 15000.00, 'All access + guest pass', true),
  ('Student Monthly', 'Discounted monthly for students', 30, 999.00, 'Gym floor access', true);

-- sample members
insert into members (full_name, phone, email, status) values
  ('Aarav Sharma', '9000000001', 'aarav@example.com', 'active'),
  ('Diya Patel', '9000000002', 'diya@example.com', 'active'),
  ('Kabir Singh', '9000000003', 'kabir@example.com', 'active');