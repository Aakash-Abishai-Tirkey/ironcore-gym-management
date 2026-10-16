-- =============================================================================
-- IronCore Gym Manager — demo seed data
-- Runs AFTER 0001_initial_schema.sql. Idempotent (safe to re-run).
-- Creates demo staff accounts, plans, members, subscriptions, payments,
-- attendance, trainers, workouts, progress, classes, equipment, notifications
-- and audit log entries so every module can be exercised end-to-end.
-- =============================================================================

create extension if not exists pgcrypto with schema extensions;

-- -----------------------------------------------------------------------------
-- 1. Demo staff accounts (Supabase Auth)
--    Password for all demo users: IronCore#2026
-- -----------------------------------------------------------------------------
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, email_change, email_change_token_new, recovery_token
)
values
  ('00000000-0000-0000-0000-000000000000','00000000-0000-4000-8000-000000000001','authenticated','authenticated','owner@ironcore.demo', extensions.crypt('IronCore#2026', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Rohit Malhotra","role":"owner"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000','00000000-0000-4000-8000-000000000002','authenticated','authenticated','admin@ironcore.demo', extensions.crypt('IronCore#2026', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Neha Kulkarni","role":"admin"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000','00000000-0000-4000-8000-000000000003','authenticated','authenticated','frontdesk@ironcore.demo', extensions.crypt('IronCore#2026', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Sandeep Rao","role":"receptionist"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000','00000000-0000-4000-8000-000000000004','authenticated','authenticated','coach@ironcore.demo', extensions.crypt('IronCore#2026', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Vikram Nair","role":"trainer"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000','00000000-0000-4000-8000-000000000005','authenticated','authenticated','member@ironcore.demo', extensions.crypt('IronCore#2026', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Aarav Sharma","role":"member"}', now(), now(), '', '', '', '')
on conflict (id) do nothing;

insert into auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
select extensions.gen_random_uuid(), u.id, u.id,
       jsonb_build_object('sub', u.id, 'email', u.email, 'email_verified', true, 'phone_verified', false),
       'email', now(), now(), now()
from auth.users u
where u.email in ('owner@ironcore.demo','admin@ironcore.demo','frontdesk@ironcore.demo','coach@ironcore.demo','member@ironcore.demo')
on conflict do nothing;

-- Explicit profile roles (the signup trigger also runs, this wins).
insert into profiles (id, full_name, email, phone, role, created_at, updated_at)
values
  ('00000000-0000-4000-8000-000000000001','Rohit Malhotra','owner@ironcore.demo','+91 98000 00001','owner', now(), now()),
  ('00000000-0000-4000-8000-000000000002','Neha Kulkarni','admin@ironcore.demo','+91 98000 00002','admin', now(), now()),
  ('00000000-0000-4000-8000-000000000003','Sandeep Rao','frontdesk@ironcore.demo','+91 98000 00003','receptionist', now(), now()),
  ('00000000-0000-4000-8000-000000000004','Vikram Nair','coach@ironcore.demo','+91 98000 00004','trainer', now(), now()),
  ('00000000-0000-4000-8000-000000000005','Aarav Sharma','member@ironcore.demo','+91 98111 11111','member', now(), now())
on conflict (id) do update set role = excluded.role, full_name = excluded.full_name, updated_at = now();

-- -----------------------------------------------------------------------------
-- 2. Membership plans
-- -----------------------------------------------------------------------------
insert into membership_plans (id, name, description, duration_days, price, benefits, session_limit, freeze_days, active)
values
  ('20000000-0000-4000-8000-000000000001','Monthly','Standard monthly membership',30,1500.00,'Gym floor access, locker',null,7,true),
  ('20000000-0000-4000-8000-000000000002','Quarterly','Three-month membership',90,4200.00,'Gym floor access, locker, 1 guest pass/month',null,10,true),
  ('20000000-0000-4000-8000-000000000003','Half Yearly','Six-month membership',180,7800.00,'Gym floor access, personalised diet plan',null,15,true),
  ('20000000-0000-4000-8000-000000000004','Annual','Twelve-month membership',365,15000.00,'All access, 2 guest passes/month, priority slots',null,21,true),
  ('20000000-0000-4000-8000-000000000005','Student Monthly','Discounted monthly plan for verified students',30,999.00,'Gym floor access during off-peak hours',null,3,true),
  ('20000000-0000-4000-8000-000000000006','Personal Training 10','Ten one-to-one coaching sessions',30,12000.00,'Dedicated trainer, personalised program, progress tracking',10,0,true),
  ('20000000-0000-4000-8000-000000000007','Warrior Pass (60 Days)','Custom 60-day strength pass',60,2500.00,'Strength block access, programme review',null,5,false)
on conflict (id) do update set price = excluded.price, description = excluded.description, updated_at = now();

-- -----------------------------------------------------------------------------
-- 3. Members
-- -----------------------------------------------------------------------------
insert into members (id, member_code, full_name, email, phone, date_of_birth, gender, address, emergency_contact_name, emergency_contact_phone, status, fitness_goals, internal_notes, created_at)
values
  ('10000000-0000-4000-8000-000000000001','M-000001','Aarav Sharma','aarav@example.com','9811111111','1995-04-12','male','12 MG Road, Bengaluru','Meera Sharma','9811111112','active','Fat loss and strength','Prefers morning slots', now() - interval '210 days'),
  ('10000000-0000-4000-8000-000000000002','M-000002','Diya Patel','diya@example.com','9822222222','1998-09-03','female','44 Nehru Nagar, Pune','Ravi Patel','9822222223','active','Hypertrophy',null, now() - interval '180 days'),
  ('10000000-0000-4000-8000-000000000003','M-000003','Kabir Singh','kabir@example.com','9833333333','1992-01-22','male','7 Park Street, Kolkata','Simran Singh','9833333334','active','Endurance','Needs BP monitoring', now() - interval '150 days'),
  ('10000000-0000-4000-8000-000000000004','M-000004','Ishita Rao','ishita@example.com','9844444444','1996-06-18','female','88 Linking Road, Mumbai','Anil Rao','9844444445','active','Postnatal fitness',null, now() - interval '120 days'),
  ('10000000-0000-4000-8000-000000000005','M-000005','Rohan Mehta','rohan@example.com','9855555555','1993-11-05','male','21 CG Road, Ahmedabad','Neel Mehta','9855555556','active','Muscle gain',null, now() - interval '96 days'),
  ('10000000-0000-4000-8000-000000000006','M-000006','Sneha Iyer','sneha@example.com','9866666666','1997-03-27','female','5 Boat Club, Chennai','Latha Iyer','9866666667','active','Weight loss',null, now() - interval '80 days'),
  ('10000000-0000-4000-8000-000000000007','M-000007','Aditya Joshi','aditya@example.com','9877777777','1990-08-14','male','9 Koregaon Park, Pune','Maya Joshi','9877777778','active','Powerlifting',null, now() - interval '70 days'),
  ('10000000-0000-4000-8000-000000000008','M-000008','Priya Menon','priya@example.com','9888888888','1995-12-09','female','34 Sarath Road, Bengaluru','Anil Menon','9888888889','active','General fitness',null, now() - interval '60 days'),
  ('10000000-0000-4000-8000-000000000009','M-000009','Manish Agarwal','manish@example.com','9899999999','1988-02-28','male','17 Civil Lines, Jaipur','Kiran Agarwal','9899000000','active','General fitness','Corporate membership', now() - interval '55 days'),
  ('10000000-0000-4000-8000-000000000010','M-000010','Kavya Nair','kavya@example.com','9810101010','2000-05-19','female','23 Brigade Road, Bengaluru','Mohan Nair','9810101011','active','Tone and flexibility',null, now() - interval '45 days'),
  ('10000000-0000-4000-8000-000000000011','M-000011','Arjun Reddy','arjun@example.com','9811112222','1994-07-08','male','62 Banjara Hills, Hyderabad','Kiran Reddy','9811112223','active','Strength',null, now() - interval '40 days'),
  ('10000000-0000-4000-8000-000000000012','M-000012','Tanvi Desai','tanvi@example.com','9812121212','1999-10-25','female','18 Ellisbridge, Ahmedabad','Jinal Desai','9812121213','active','Fat loss',null, now() - interval '35 days'),
  ('10000000-0000-4000-8000-000000000013','M-000013','Farhan Ali','farhan@example.com','9813131313','1991-01-15','male','77 Nizamuddin, Delhi','Sara Ali','9813131314','active','Boxing conditioning',null, now() - interval '30 days'),
  ('10000000-0000-4000-8000-000000000014','M-000014','Nisha Kulkarni','nisha@example.com','9814141414','1996-09-30','female','3 FC Road, Pune','Omkar Kulkarni','9814141415','active','Strength',null, now() - interval '25 days'),
  ('10000000-0000-4000-8000-000000000015','M-000015','Dev Sharma','dev@example.com','9815151515','1985-03-11','male','55 Connaught Place, Delhi','Kiran Sharma','9815151516','inactive','General fitness','On long leave (work)', now() - interval '22 days'),
  ('10000000-0000-4000-8000-000000000016','M-000016','Ananya Gupta','ananya@example.com','9816161616','2001-06-02','female','14 Salt Lake, Kolkata','Rakesh Gupta','9816161617','active','Student strength',null, now() - interval '18 days'),
  ('10000000-0000-4000-8000-000000000017','M-000017','Suresh Babu','suresh@example.com','9817171717','1989-12-19','male','40 Anna Salai, Chennai','Lakshmi Babu','9817171718','active','Strength',null, now() - interval '14 days'),
  ('10000000-0000-4000-8000-000000000018','M-000018','Ritika Bose','ritika@example.com','9818181818','1994-04-04','female','8 Southern Avenue, Kolkata','Anirban Bose','9818181819','active','Pilates and mobility',null, now() - interval '12 days'),
  ('10000000-0000-4000-8000-000000000019','M-000019','Harsh Vardhan','harsh@example.com','9819191919','1997-08-21','male','71 Banjara Hills, Hyderabad','Sneha Vardhan','9819191920','active','Calisthenics',null, now() - interval '9 days'),
  ('10000000-0000-4000-8000-000000000020','M-000020','Meera Krishnan','meera@example.com','9820202020','1992-11-11','female','2 Indiranagar, Bengaluru','Ravi Krishnan','9820202021','active','Weight loss',null, now() - interval '6 days'),
  ('10000000-0000-4000-8000-000000000021','M-000021','Imran Sheikh','imran@example.com','9821212121','1986-01-07','male','90 Charotar Road, Ahmedabad','Farida Sheikh','9821212122','active','Boxing strength',null, now() - interval '4 days'),
  ('10000000-0000-4000-8000-000000000022','M-000022','Pooja Sinha','pooja@example.com','9822223232','1998-05-16','female','30 Kalyani Nagar, Pune','Manoj Sinha','9822223233','active','General fitness',null, now() - interval '2 days')
on conflict (id) do nothing;

update profiles set member_id = '10000000-0000-4000-8000-000000000001' where id = '00000000-0000-4000-8000-000000000005';

-- -----------------------------------------------------------------------------
-- 4. Subscriptions (statuses cover every state the UI handles)
--    end_date is inclusive: start_date + duration_days - 1
-- -----------------------------------------------------------------------------
insert into subscriptions (id, member_id, plan_id, start_date, end_date, amount_charged, discount, final_amount, payment_status, status, created_at)
values
  -- active, expiring within 7 days (renewal reminders)
  ('30000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000001', current_date - 27, current_date + 3,  1500.00,0.00,1500.00,'completed','active', now() - interval '27 days'),
  ('30000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000002','20000000-0000-4000-8000-000000000002', current_date - 86, current_date + 4,  4200.00,200.00,4000.00,'completed','active', now() - interval '86 days'),
  ('30000000-0000-4000-8000-000000000003','10000000-0000-4000-8000-000000000003','20000000-0000-4000-8000-000000000001', current_date - 25, current_date + 5,  1500.00,0.00,1500.00,'completed','active', now() - interval '25 days'),
  ('30000000-0000-4000-8000-000000000004','10000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000005', current_date - 24, current_date + 6,   999.00,0.00, 999.00,'completed','active', now() - interval '24 days'),
  ('30000000-0000-4000-8000-000000000005','10000000-0000-4000-8000-000000000013','20000000-0000-4000-8000-000000000001', current_date - 26, current_date + 4,  1500.00,0.00,1500.00,'pending','active', now() - interval '26 days'),
  -- active, healthy
  ('30000000-0000-4000-8000-000000000006','10000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000004', current_date - 60, current_date + 305, 15000.00,1500.00,13500.00,'completed','active', now() - interval '60 days'),
  ('30000000-0000-4000-8000-000000000007','10000000-0000-4000-8000-000000000005','20000000-0000-4000-8000-000000000003', current_date - 40, current_date + 140, 7800.00,0.00,7800.00,'completed','active', now() - interval '40 days'),
  ('30000000-0000-4000-8000-000000000008','10000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000006', current_date - 15, current_date + 15, 12000.00,0.00,12000.00,'completed','active', now() - interval '15 days'),
  ('30000000-0000-4000-8000-000000000009','10000000-0000-4000-8000-000000000008','20000000-0000-4000-8000-000000000002', current_date - 50, current_date + 40, 4200.00,0.00,4200.00,'completed','active', now() - interval '50 days'),
  ('30000000-0000-4000-8000-000000000010','10000000-0000-4000-8000-000000000009','20000000-0000-4000-8000-000000000004', current_date - 100, current_date + 265, 15000.00,0.00,15000.00,'completed','active', now() - interval '100 days'),
  ('30000000-0000-4000-8000-000000000011','10000000-0000-4000-8000-000000000010','20000000-0000-4000-8000-000000000001', current_date - 10, current_date + 20, 1500.00,0.00,1500.00,'completed','active', now() - interval '10 days'),
  ('30000000-0000-4000-8000-000000000012','10000000-0000-4000-8000-000000000011','20000000-0000-4000-8000-000000000002', current_date - 20, current_date + 70, 4200.00,500.00,3700.00,'completed','active', now() - interval '20 days'),
  ('30000000-0000-4000-8000-000000000013','10000000-0000-4000-8000-000000000012','20000000-0000-4000-8000-000000000001', current_date - 12, current_date + 18, 1500.00,0.00,1500.00,'completed','active', now() - interval '12 days'),
  ('30000000-0000-4000-8000-000000000014','10000000-0000-4000-8000-000000000014','20000000-0000-4000-8000-000000000002', current_date - 5,  current_date + 85, 4200.00,0.00,4200.00,'completed','active', now() - interval '5 days'),
  ('30000000-0000-4000-8000-000000000015','10000000-0000-4000-8000-000000000016','20000000-0000-4000-8000-000000000005', current_date - 8,  current_date + 22,  999.00,0.00, 999.00,'completed','active', now() - interval '8 days'),
  ('30000000-0000-4000-8000-000000000016','10000000-0000-4000-8000-000000000017','20000000-0000-4000-8000-000000000003', current_date - 90, current_date + 90, 7800.00,0.00,7800.00,'completed','active', now() - interval '90 days'),
  ('30000000-0000-4000-8000-000000000017','10000000-0000-4000-8000-000000000018','20000000-0000-4000-8000-000000000002', current_date - 30, current_date + 60, 4200.00,0.00,4200.00,'completed','active', now() - interval '30 days'),
  ('30000000-0000-4000-8000-000000000018','10000000-0000-4000-8000-000000000019','20000000-0000-4000-8000-000000000001', current_date - 3,  current_date + 27, 1500.00,0.00,1500.00,'completed','active', now() - interval '3 days'),
  ('30000000-0000-4000-8000-000000000019','10000000-0000-4000-8000-000000000020','20000000-0000-4000-8000-000000000002', current_date - 18, current_date + 72, 4200.00,0.00,4200.00,'completed','active', now() - interval '18 days'),
  ('30000000-0000-4000-8000-000000000020','10000000-0000-4000-8000-000000000021','20000000-0000-4000-8000-000000000006', current_date - 2,  current_date + 28, 12000.00,2000.00,10000.00,'completed','active', now() - interval '2 days'),
  ('30000000-0000-4000-8000-000000000021','10000000-0000-4000-8000-000000000022','20000000-0000-4000-8000-000000000001', current_date - 1,  current_date + 29, 1500.00,0.00,1500.00,'completed','active', now() - interval '1 day'),
  -- frozen
  ('30000000-0000-4000-8000-000000000022','10000000-0000-4000-8000-000000000003','20000000-0000-4000-8000-000000000002', current_date - 80, current_date + 95, 4200.00,0.00,4200.00,'completed','frozen', now() - interval '80 days'),
  -- expired
  ('30000000-0000-4000-8000-000000000023','10000000-0000-4000-8000-000000000015','20000000-0000-4000-8000-000000000001', current_date - 60, current_date - 31, 1500.00,0.00,1500.00,'completed','expired', now() - interval '60 days'),
  ('30000000-0000-4000-8000-000000000024','10000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000007', current_date - 90, current_date - 31, 2500.00,0.00,2500.00,'completed','expired', now() - interval '90 days'),
  ('30000000-0000-4000-8000-000000000025','10000000-0000-4000-8000-000000000012','20000000-0000-4000-8000-000000000005', current_date - 70, current_date - 41,  999.00,0.00, 999.00,'completed','expired', now() - interval '70 days'),
  ('30000000-0000-4000-8000-000000000026','10000000-0000-4000-8000-000000000009','20000000-0000-4000-8000-000000000001', current_date - 45, current_date - 16, 1500.00,0.00,1500.00,'completed','expired', now() - interval '45 days'),
  -- cancelled
  ('30000000-0000-4000-8000-000000000027','10000000-0000-4000-8000-000000000010','20000000-0000-4000-8000-000000000001', current_date - 40, current_date - 11, 1500.00,0.00,1500.00,'completed','cancelled', now() - interval '40 days')
on conflict (id) do nothing;

update subscriptions set cancelled_at = now() - interval '5 days', cancellation_reason = 'Relocated out of city'
where id = '30000000-0000-4000-8000-000000000027';

-- Freeze period for the frozen subscription
insert into subscription_freeze_periods (id, subscription_id, start_date, end_date, reason)
values ('31000000-0000-4000-8000-000000000001','30000000-0000-4000-8000-000000000022', current_date - 10, current_date + 20, 'Medical leave — knee injury')
on conflict (id) do nothing;

-- -----------------------------------------------------------------------------
-- 5. Payments (completed / pending / failed / refunded)
-- -----------------------------------------------------------------------------
insert into payments (id, transaction_code, member_id, subscription_id, amount, paid_at, method, reference, status, discount, recorded_by, notes)
values
  ('40000000-0000-4000-8000-000000000001','TXN-000001','10000000-0000-4000-8000-000000000001','30000000-0000-4000-8000-000000000001',1500.00, now() - interval '27 days','upi','UPI-884512',        'completed',0.00,'00000000-0000-4000-8000-000000000003',null),
  ('40000000-0000-4000-8000-000000000002','TXN-000002','10000000-0000-4000-8000-000000000002','30000000-0000-4000-8000-000000000002',4000.00, now() - interval '86 days','card','CARD-771234',      'completed',200.00,'00000000-0000-4000-8000-000000000003','Festival discount applied'),
  ('40000000-0000-4000-8000-000000000003','TXN-000003','10000000-0000-4000-8000-000000000003','30000000-0000-4000-8000-000000000003',1500.00, now() - interval '25 days','cash',null,                'completed',0.00,'00000000-0000-4000-8000-000000000001',null),
  ('40000000-0000-4000-8000-000000000004','TXN-000004','10000000-0000-4000-8000-000000000006','30000000-0000-4000-8000-000000000004', 999.00, now() - interval '24 days','upi','UPI-221099',        'completed',0.00,'00000000-0000-4000-8000-000000000003','Student plan'),
  ('40000000-0000-4000-8000-000000000005','TXN-000005','10000000-0000-4000-8000-000000000013','30000000-0000-4000-8000-000000000005',1500.00, now() - interval '3 days', 'upi','UPI-998877',        'failed',   0.00,'00000000-0000-4000-8000-000000000003','Customer reported debit pending'),
  ('40000000-0000-4000-8000-000000000006','TXN-000006','10000000-0000-4000-8000-000000000004','30000000-0000-4000-8000-000000000006',13500.00,now() - interval '60 days','bank_transfer','NEFT-556677',   'completed',1500.00,'00000000-0000-4000-8000-000000000001','Annual plan with negotiation'),
  ('40000000-0000-4000-8000-000000000007','TXN-000007','10000000-0000-4000-8000-000000000005','30000000-0000-4000-8000-000000000007',7800.00, now() - interval '40 days','card','CARD-112233',      'completed',0.00,'00000000-0000-4000-8000-000000000003',null),
  ('40000000-0000-4000-8000-000000000008','TXN-000008','10000000-0000-4000-8000-000000000007','30000000-0000-4000-8000-000000000008',12000.00,now() - interval '15 days','upi','UPI-445566',        'completed',0.00,'00000000-0000-4000-8000-000000000003','PT package'),
  ('40000000-0000-4000-8000-000000000009','TXN-000009','10000000-0000-4000-8000-000000000008','30000000-0000-4000-8000-000000000009',4200.00, now() - interval '50 days','cash',null,                'completed',0.00,'00000000-0000-4000-8000-000000000001',null),
  ('40000000-0000-4000-8000-000000000010','TXN-000010','10000000-0000-4000-8000-000000000009','30000000-0000-4000-8000-000000000010',15000.00,now() - interval '100 days','bank_transfer','NEFT-889900','completed',0.00,'00000000-0000-4000-8000-000000000001',null),
  ('40000000-0000-4000-8000-000000000011','TXN-000011','10000000-0000-4000-8000-000000000011','30000000-0000-4000-8000-000000000012',3700.00, now() - interval '20 days','upi','UPI-331122',        'completed',500.00,'00000000-0000-4000-8000-000000000003',null),
  ('40000000-0000-4000-8000-000000000012','TXN-000012','10000000-0000-4000-8000-000000000014','30000000-0000-4000-8000-000000000014',4200.00, now() - interval '5 days', 'upi','UPI-667788',        'completed',0.00,'00000000-0000-4000-8000-000000000003',null),
  ('40000000-0000-4000-8000-000000000013','TXN-000013','10000000-0000-4000-8000-000000000016','30000000-0000-4000-8000-000000000015', 999.00, now() - interval '8 days', 'cash',null,                'completed',0.00,'00000000-0000-4000-8000-000000000003','Student verification done'),
  ('40000000-0000-4000-8000-000000000014','TXN-000014','10000000-0000-4000-8000-000000000017','30000000-0000-4000-8000-000000000016',7800.00, now() - interval '90 days','card','CARD-445566',      'completed',0.00,'00000000-0000-4000-8000-000000000003',null),
  ('40000000-0000-4000-8000-000000000015','TXN-000015','10000000-0000-4000-8000-000000000018','30000000-0000-4000-8000-000000000017',4200.00, now() - interval '30 days','upi','UPI-123123',        'completed',0.00,'00000000-0000-4000-8000-000000000003',null),
  ('40000000-0000-4000-8000-000000000016','TXN-000016','10000000-0000-4000-8000-000000000019','30000000-0000-4000-8000-000000000018',1500.00, now() - interval '3 days', 'cash',null,                'completed',0.00,'00000000-0000-4000-8000-000000000001',null),
  ('40000000-0000-4000-8000-000000000017','TXN-000017','10000000-0000-4000-8000-000000000020','30000000-0000-4000-8000-000000000019',4200.00, now() - interval '18 days','upi','UPI-909090',        'completed',0.00,'00000000-0000-4000-8000-000000000003',null),
  ('40000000-0000-4000-8000-000000000018','TXN-000018','10000000-0000-4000-8000-000000000021','30000000-0000-4000-8000-000000000020',10000.00,now() - interval '2 days', 'card','CARD-778899',      'completed',2000.00,'00000000-0000-4000-8000-000000000001',null),
  ('40000000-0000-4000-8000-000000000019','TXN-000019','10000000-0000-4000-8000-000000000022','30000000-0000-4000-8000-000000000021',1500.00, now() - interval '1 day',  'upi','UPI-454545',        'completed',0.00,'00000000-0000-4000-8000-000000000003',null),
  -- refund example (reversal kept, original row preserved)
  ('40000000-0000-4000-8000-000000000020','TXN-000020','10000000-0000-4000-8000-000000000012',null,            1500.00, now() - interval '40 days','upi','UPI-232323',        'refunded',0.00,'00000000-0000-4000-8000-000000000001','Duplicate charge, refunded'),
  ('40000000-0000-4000-8000-000000000021','TXN-000021','10000000-0000-4000-8000-000000000012',null,            1500.00, now() - interval '39 days','upi','UPI-232323-R',      'completed',0.00,'00000000-0000-4000-8000-000000000001','Reversal of duplicate charge')
on conflict (id) do nothing;

update payments set reversed_payment_id = '40000000-0000-4000-8000-000000000020'
where id = '40000000-0000-4000-8000-000000000021';

-- Recent revenue this month (so dashboard/report totals are non-zero)
insert into payments (transaction_code, member_id, subscription_id, amount, paid_at, method, status, recorded_by)
select
  'TXN-M-' || lpad(g::text, 4, '0'),
  m.id, null,
  (500 + (g * 250))::numeric(12,2),
  (current_date - (g % 12)) + interval '18 hours',
  (array['cash','upi','card','bank_transfer']::payment_method[])[1 + (g % 4)],
  'completed',
  '00000000-0000-4000-8000-000000000003'
from generate_series(1, 12) g
join lateral (select id from members order by id offset (g - 1) limit 1) m on true
where not exists (select 1 from payments p where p.transaction_code = 'TXN-M-' || lpad(g::text, 4, '0'));

-- -----------------------------------------------------------------------------
-- 6. Attendance (last 21 days, deterministic offsets)
-- -----------------------------------------------------------------------------
insert into attendance_records (id, member_id, check_in_at, check_out_at, recorded_by)
select
  extensions.gen_random_uuid(),
  m.id,
  (current_date - d)::timestamptz + ((17 + (n % 4)) || ' hours')::interval,
  case when (n % 5) = 0 then null
       else (current_date - d)::timestamptz + ((19 + (n % 3)) || ' hours')::interval end,
  case when (n % 3) = 0
       then '00000000-0000-4000-8000-000000000003'::uuid
       else '00000000-0000-4000-8000-000000000004'::uuid
  end
from generate_series(0, 20) d
cross join lateral (
  select row_number() over (order by id) as n, id from members
) m
where (m.n % 3) = (d % 3);

-- Todays check-ins (one deliberately left open to test duplicate-check-in protection)
insert into attendance_records (member_id, check_in_at, check_out_at, recorded_by)
select '10000000-0000-4000-8000-000000000001', now() - interval '75 minutes', null, '00000000-0000-4000-8000-000000000003'
where not exists (
  select 1 from attendance_records a
  where a.member_id = '10000000-0000-4000-8000-000000000001'
    and a.check_in_at >= (current_date)::timestamptz
);

insert into attendance_records (member_id, check_in_at, check_out_at, recorded_by)
select '10000000-0000-4000-8000-000000000004', now() - interval '40 minutes', null, '00000000-0000-4000-8000-000000000003'
where not exists (
  select 1 from attendance_records a
  where a.member_id = '10000000-0000-4000-8000-000000000004'
    and a.check_in_at >= (current_date)::timestamptz
);

-- -----------------------------------------------------------------------------
-- 7. Trainers + assignments
-- -----------------------------------------------------------------------------
insert into trainers (id, full_name, email, phone, specializations, certifications, employment_status, joining_date, availability, notes)
values
  ('60000000-0000-4000-8000-000000000001','Vikram Nair','coach@ironcore.demo','+91 98000 00004',array['Strength & Conditioning','Powerlifting'],'NSCA-CSCS, ACE Personal Trainer','active','2021-04-01','Mon-Sat 06:00-14:00','Head coach'),
  ('60000000-0000-4000-8000-000000000002','Priya Menon','priya.trainer@ironcore.demo','+91 98000 00011',array['Yoga','Mobility','Pilates'],'RYT-500, FRC Mobility','active','2022-08-15','Mon-Fri 05:30-12:00',null),
  ('60000000-0000-4000-8000-000000000003','Imran Qureshi','imran.trainer@ironcore.demo','+91 98000 00012',array['Boxing','Conditioning'],'AIBA Level 2 Coach','active','2023-01-10','Tue-Sun 16:00-22:00','Boxing ring supervision'),
  ('60000000-0000-4000-8000-000000000004','Ananya Iyer','ananya.trainer@ironcore.demo','+91 98000 00013',array['Rehabilitation','Pre-postnatal'],'Physiotherapy (BPT); ACE-CPT','on_leave','2020-11-02',null,'Parental leave until further notice')
on conflict (id) do update set specializations = excluded.specializations, updated_at = now();

update trainers set profile_id = '00000000-0000-4000-8000-000000000004' where id = '60000000-0000-4000-8000-000000000001';

insert into trainer_member_assignments (id, trainer_id, member_id, active)
select extensions.gen_random_uuid(), t.tid, t.mid, true
from (values
  ('60000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000001'),
  ('60000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000005'),
  ('60000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000007'),
  ('60000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000011'),
  ('60000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000004'),
  ('60000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000006'),
  ('60000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000010'),
  ('60000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000018'),
  ('60000000-0000-4000-8000-000000000003','10000000-0000-4000-8000-000000000013'),
  ('60000000-0000-4000-8000-000000000003','10000000-0000-4000-8000-000000000021'),
  ('60000000-0000-4000-8000-000000000004','10000000-0000-4000-8000-000000000016')
) as t(tid, mid)
where not exists (
  select 1 from trainer_member_assignments a where a.trainer_id = t.tid and a.member_id = t.mid
);

update members m set trainer_id = t.tid
from (values
  ('10000000-0000-4000-8000-000000000001','60000000-0000-4000-8000-000000000001'),
  ('10000000-0000-4000-8000-000000000005','60000000-0000-4000-8000-000000000001'),
  ('10000000-0000-4000-8000-000000000007','60000000-0000-4000-8000-000000000001'),
  ('10000000-0000-4000-8000-000000000011','60000000-0000-4000-8000-000000000001'),
  ('10000000-0000-4000-8000-000000000004','60000000-0000-4000-8000-000000000002'),
  ('10000000-0000-4000-8000-000000000006','60000000-0000-4000-8000-000000000002'),
  ('10000000-0000-4000-8000-000000000010','60000000-0000-4000-8000-000000000002'),
  ('10000000-0000-4000-8000-000000000018','60000000-0000-4000-8000-000000000002'),
  ('10000000-0000-4000-8000-000000000013','60000000-0000-4000-8000-000000000003'),
  ('10000000-0000-4000-8000-000000000021','60000000-0000-4000-8000-000000000003'),
  ('10000000-0000-4000-8000-000000000016','60000000-0000-4000-8000-000000000004')
) as t(mid, tid)
where m.id = t.mid and m.trainer_id is null;

-- -----------------------------------------------------------------------------
-- 8. Workout plans + exercises
-- -----------------------------------------------------------------------------
insert into workout_plans (id, member_id, trainer_id, name, objective, start_date, end_date, status)
values
  ('70000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000001','60000000-0000-4000-8000-000000000001','Aarav — Strength Block A','Build lower-body strength and reduce body fat', current_date - 20, current_date + 40,'active'),
  ('70000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000005','60000000-0000-4000-8000-000000000001','Rohan — Muscle Gain Hypertrophy','Increase lean mass', current_date - 14, current_date + 46,'active'),
  ('70000000-0000-4000-8000-000000000003','10000000-0000-4000-8000-000000000004','60000000-0000-4000-8000-000000000002','Ishita — Postnatal Core & Mobility','Gentle core stability and posture work', current_date - 10, current_date + 50,'active'),
  ('70000000-0000-4000-8000-000000000004','10000000-0000-4000-8000-000000000013','60000000-0000-4000-8000-000000000003','Farhan — Boxing Conditioning','Aerobic base for ring work', current_date - 7, current_date + 53,'active'),
  ('70000000-0000-4000-8000-000000000005','10000000-0000-4000-8000-000000000007','60000000-0000-4000-8000-000000000001','Aditya — Powerlifting Total','Squat/bench/deadlift progression', current_date - 30, current_date + 30,'active'),
  ('70000000-0000-4000-8000-000000000006','10000000-0000-4000-8000-000000000006','60000000-0000-4000-8000-000000000002','Sneha — Fat Loss Circuit','Calorie deficit conditioning', current_date - 60, current_date + 15,'completed')
on conflict (id) do nothing;

insert into workout_exercises (plan_id, order_index, name, category, sets, reps, weight, rest_seconds, notes)
select v.* from (values
  ('70000000-0000-4000-8000-000000000001',1,'Barbell Back Squat','strength',4,'6',70.00,150,'Top set with spotter'),
  ('70000000-0000-4000-8000-000000000001',2,'Romanian Deadlift','strength',3,'8',60.00,120,null),
  ('70000000-0000-4000-8000-000000000001',3,'Walking Lunge','strength',3,'12 per leg',20.00,90,null),
  ('70000000-0000-4000-8000-000000000001',4,'Treadmill Intervals','cardio',6,'2 min fast / 1 min easy',null,60,'HR target 150-165'),
  ('70000000-0000-4000-8000-000000000001',5,'Dead Bug','mobility',3,'12 per side',null,45,'Controlled tempo'),
  ('70000000-0000-4000-8000-000000000002',1,'Bench Press','strength',4,'8',50.00,120,null),
  ('70000000-0000-4000-8000-000000000002',2,'Weighted Pull-up','strength',4,'6',15.00,120,'Belt if needed'),
  ('70000000-0000-4000-8000-000000000002',3,'Incline Dumbbell Press','strength',3,'10',22.00,90,null),
  ('70000000-0000-4000-8000-000000000002',4,'Cable Fly','strength',3,'12',15.00,60,null),
  ('70000000-0000-4000-8000-000000000002',5,'Hanging Leg Raise','core',3,'15',null,60,null),
  ('70000000-0000-4000-8000-000000000003',1,'Cat-Cow','mobility',2,'10',null,30,null),
  ('70000000-0000-4000-8000-000000000003',2,'Bird Dog','mobility',3,'8 per side',null,45,'Focus on bracing'),
  ('70000000-0000-4000-8000-000000000003',3,'Kettlebell Dead Bug','strength',3,'10 per side',8.00,45,null),
  ('70000000-0000-4000-8000-000000000003',4,'Standing March','cardio',3,'2 minutes',null,60,null),
  ('70000000-0000-4000-8000-000000000004',1,'Bag Heavy Work','conditioning',5,'3 minutes',null,60,'Rounds 1-3'),
  ('70000000-0000-4000-8000-000000000004',2,'Assault Bike Sprints','cardio',10,'20 seconds',null,40,'Full recovery between sets'),
  ('70000000-0000-4000-8000-000000000004',3,'Speed Rope','conditioning',5,'3 minutes',null,30,null),
  ('70000000-0000-4000-8000-000000000004',4,'Shadow Boxing','skill',4,'3 minutes',null,60,null),
  ('70000000-0000-4000-8000-000000000005',1,'Competition Squat','strength',5,'3 @ RPE 8',110.00,180,'Weekly load increase'),
  ('70000000-0000-4000-8000-000000000005',2,'Paused Bench Press','strength',5,'3 @ RPE 8',70.00,180,null),
  ('70000000-0000-4000-8000-000000000005',3,'Sumo Deadlift','strength',4,'5',140.00,180,null)
) as v(plan_id, order_index, name, category, sets, reps, weight, rest_seconds, notes)
where not exists (
  select 1 from workout_exercises e
  where e.plan_id = v.plan_id and e.order_index = v.order_index
);

-- -----------------------------------------------------------------------------
-- 9. Workout sessions + fitness progress
-- -----------------------------------------------------------------------------
insert into workout_sessions (plan_id, member_id, performed_at, notes)
select wp.id, wp.member_id, (current_date - g)::timestamptz + interval '7 hours',
       case when g % 3 = 0 then 'Completed with coach, form check pending' else 'Self session' end
from workout_plans wp cross join generate_series(0, 9) g
where not exists (
  select 1 from workout_sessions s where s.plan_id = wp.id and s.performed_at >= (current_date - 10)::timestamptz
);

insert into fitness_progress_entries (member_id, recorded_by, recorded_at, weight, body_fat, measurements, notes)
select v.* from (values
  ('10000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000004', current_date - 60, 88.50, 26.0, '{"chest_cm":102,"waist_cm":92,"arm_cm":36}'::jsonb,'Baseline measurement'),
  ('10000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000004', current_date - 30, 84.20, 23.4, '{"chest_cm":103,"waist_cm":87,"arm_cm":37}'::jsonb,'Mid-program check'),
  ('10000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000004', current_date - 7,  81.90, 21.8, '{"chest_cm":104,"waist_cm":83,"arm_cm":38}'::jsonb,'Good progress, squat +10kg'),
  ('10000000-0000-4000-8000-000000000005','00000000-0000-4000-8000-000000000004', current_date - 30, 68.40, 18.0, '{"chest_cm":98,"waist_cm":78,"arm_cm":34}'::jsonb,null),
  ('10000000-0000-4000-8000-000000000005','00000000-0000-4000-8000-000000000004', current_date - 7,  69.60, 17.6, '{"chest_cm":99,"waist_cm":79,"arm_cm":35}'::jsonb,'Gaining as planned'),
  ('10000000-0000-4000-8000-000000000002','00000000-0000-4000-8000-000000000004', current_date - 21, 57.20, 24.0, '{"waist_cm":70,"arm_cm":28}'::jsonb,null),
  ('10000000-0000-4000-8000-000000000002','00000000-0000-4000-8000-000000000004', current_date - 7,  55.80, 22.5, '{"waist_cm":68,"arm_cm":28.5}'::jsonb,'Progressing well'),
  ('10000000-0000-4000-8000-000000000006','00000000-0000-4000-8000-000000000004', current_date - 14, 63.00, 27.0, '{"waist_cm":74,"arm_cm":29}'::jsonb,null),
  ('10000000-0000-4000-8000-000000000007','00000000-0000-4000-8000-000000000004', current_date - 7,  82.30, 15.2, '{"chest_cm":106,"waist_cm":85}',null),
  ('10000000-0000-4000-8000-000000000013','00000000-0000-4000-8000-000000000004', current_date - 6,  74.10, 14.0, '{"waist_cm":80,"arm_cm":35}'::jsonb,null),
  ('10000000-0000-4000-8000-000000000010','00000000-0000-4000-8000-000000000004', current_date - 5,  54.60, 25.5, '{"waist_cm":66,"arm_cm":26}'::jsonb,null)
) as v(member_id, recorded_by, recorded_at, weight, body_fat, measurements, notes)
where not exists (
  select 1 from fitness_progress_entries f
  where f.member_id = v.member_id and f.recorded_at = v.recorded_at
);

-- -----------------------------------------------------------------------------
-- 10. Classes + enrollments
-- -----------------------------------------------------------------------------
insert into classes (id, name, description, trainer_id, starts_at, duration_minutes, capacity)
values
  ('80000000-0000-4000-8000-000000000001','Sunrise Strength Club','60-min coached full-body strength session','60000000-0000-4000-8000-000000000001', (date_trunc('day', now()) + interval '1 day 06:00'), 60, 20),
  ('80000000-0000-4000-8000-000000000002','Yoga & Mobility Flow','Vinyasa and deep mobility work','60000000-0000-4000-8000-000000000002',      (date_trunc('day', now()) + interval '1 day 07:30'), 60, 25),
  ('80000000-0000-4000-8000-000000000003','Boxing Conditioning','Pad work, bag rounds and footwork','60000000-0000-4000-8000-000000000003',  (date_trunc('day', now()) + interval '2 days 18:00'), 75, 16),
  ('80000000-0000-4000-8000-000000000004','Core & Stability','Core-focused conditioning for all levels','60000000-0000-4000-8000-000000000001',       (date_trunc('day', now()) + interval '2 days 19:30'), 45, 18),
  ('80000000-0000-4000-8000-000000000005','HIIT Express','Short high-intensity intervals','60000000-0000-4000-8000-000000000001',              (date_trunc('day', now()) + interval '3 days 07:00'), 30, 20),
  ('80000000-0000-4000-8000-000000000006','Powerlifting Clinic','Technique clinic for squat/bench/deadlift','60000000-0000-4000-8000-000000000001',  (date_trunc('day', now()) + interval '4 days 17:00'), 90, 10),
  ('80000000-0000-4000-8000-000000000007','Pilates Reformer','Mat and reformer basics','60000000-0000-4000-8000-000000000002',                       (date_trunc('day', now()) + interval '5 days 08:00'), 60, 12)
on conflict (id) do nothing;

insert into class_enrollments (class_id, member_id, status)
select c.id, m.id, 'enrolled'
from (values
  ('80000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000001'),
  ('80000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000005'),
  ('80000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000007'),
  ('80000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000004'),
  ('80000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000006'),
  ('80000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000010'),
  ('80000000-0000-4000-8000-000000000003','10000000-0000-4000-8000-000000000013'),
  ('80000000-0000-4000-8000-000000000003','10000000-0000-4000-8000-000000000021'),
  ('80000000-0000-4000-8000-000000000004','10000000-0000-4000-8000-000000000008'),
  ('80000000-0000-4000-8000-000000000004','10000000-0000-4000-8000-000000000012'),
  ('80000000-0000-4000-8000-000000000005','10000000-0000-4000-8000-000000000001'),
  ('80000000-0000-4000-8000-000000000005','10000000-0000-4000-8000-000000000020'),
  ('80000000-0000-4000-8000-000000000006','10000000-0000-4000-8000-000000000007'),
  ('80000000-0000-4000-8000-000000000006','10000000-0000-4000-8000-000000000011'),
  ('80000000-0000-4000-8000-000000000007','10000000-0000-4000-8000-000000000018')
) as e(cid, mid)
join classes c on c.id = e.cid
join members m on m.id = e.mid
where not exists (
  select 1 from class_enrollments ce where ce.class_id = e.cid and ce.member_id = e.mid
);

-- -----------------------------------------------------------------------------
-- 11. Equipment + maintenance
-- -----------------------------------------------------------------------------
insert into equipment (id, name, category, purchase_date, purchase_cost, quantity, condition, location, last_maintenance_date, next_maintenance_date, notes)
values
  ('90000000-0000-4000-8000-000000000001','Treadmill - Technogym Run 505','Cardio', current_date - 420, 220000.00, 4,'good','Cardio Zone', current_date - 40, current_date + 50,'Belt replaced last quarter'),
  ('90000000-0000-4000-8000-000000000002','Rowing Machine - Concept2','Cardio', current_date - 380, 120000.00, 3,'good','Cardio Zone', current_date - 30, current_date + 60,null),
  ('90000000-0000-4000-8000-000000000003','Assault Bike','Cardio', current_date - 300, 95000.00, 2,'good','Cardio Zone', current_date - 25, current_date + 65,'Chain lubrication due'),
  ('90000000-0000-4000-8000-000000000004','Olympic Barbell Set','Strength', current_date - 500, 85000.00, 8,'good','Strength Floor', current_date - 60, current_date + 30,'Two bars pending re-sleeve'),
  ('90000000-0000-4000-8000-000000000005','Adjustable Bench Press','Strength', current_date - 450, 60000.00, 3,'good','Strength Floor', current_date - 45, current_date + 45,null),
  ('90000000-0000-4000-8000-000000000006','Squat Rack','Strength', current_date - 450, 48000.00, 2,'fair','Strength Floor', current_date - 90, current_date + 15,'J-hook wear, inspection needed'),
  ('90000000-0000-4000-8000-000000000007','Dumbbell Set 2-40kg','Strength', current_date - 350, 150000.00, 40,'good','Free Weights', current_date - 20, current_date + 70,null),
  ('90000000-0000-4000-8000-000000000008','Cable Crossover Machine','Strength', current_date - 280, 175000.00, 1,'good','Strength Floor', current_date - 35, current_date + 55,null),
  ('90000000-0000-4000-8000-000000000009','Yoga Mat','Accessories', current_date - 200, 25000.00, 30,'good','Studio', current_date - 60, current_date + 120,'12 mats need replacement'),
  ('90000000-0000-4000-8000-000000000010','Battle Ropes','Conditioning', current_date - 150, 30000.00, 2,'damaged','Functional Zone', current_date - 100, current_date - 30,'Rope fraying — awaiting replacement quote')
on conflict (id) do nothing;

insert into equipment_maintenance_records (equipment_id, performed_at, notes, cost)
select v.* from (values
  ('90000000-0000-4000-8000-000000000001', current_date - 40, 'Belt tension adjusted and lubrication done', 3500.00),
  ('90000000-0000-4000-8000-000000000003', current_date - 25, 'Chain replaced', 1800.00),
  ('90000000-0000-4000-8000-000000000006', current_date - 90, 'Safety pins inspected, J-hook replacement ordered', 5200.00),
  ('90000000-0000-4000-8000-000000000010', current_date - 100,'Rope condition audit — flagged for replacement', 0.00)
) as v(equipment_id, performed_at, notes, cost)
where not exists (
  select 1 from equipment_maintenance_records m
  where m.equipment_id = v.equipment_id and m.performed_at = v.performed_at
);

-- -----------------------------------------------------------------------------
-- 12. Notifications (for owner + front desk)
-- -----------------------------------------------------------------------------
insert into notifications (user_id, type, title, message, read_at)
select '00000000-0000-4000-8000-000000000001','membership_expiring','Membership expiring in 3 days','Aarav Sharma (M-000001) Monthly plan expires soon.','00000000-0000-0000-0000-000000000000'::uuid
where not exists (select 1 from notifications where user_id='00000000-0000-4000-8000-000000000001' and title like 'Membership expiring in 3 days%');

insert into notifications (user_id, type, title, message)
select '00000000-0000-4000-8000-000000000001','payment_received','Payment received','₹12,000 PT package collected from Aditya Joshi via card'
where not exists (select 1 from notifications where user_id='00000000-0000-4000-8000-000000000001' and title='Payment received');

insert into notifications (user_id, type, title, message)
select '00000000-0000-4000-8000-000000000001','payment_failed','Payment failed','₹1,500 UPI payment for Farhan Ali was reported as failed'
where not exists (select 1 from notifications where user_id='00000000-0000-4000-8000-000000000001' and title='Payment failed');

insert into notifications (user_id, type, title, message)
select '00000000-0000-4000-8000-000000000003','membership_expired','Membership expired','Kabir Singh membership is frozen, Rohan Mehta membership has expired'
where not exists (select 1 from notifications where user_id='00000000-0000-4000-8000-000000000003' and title='Membership expired');

insert into notifications (user_id, type, title, message)
select '00000000-0000-4000-8000-000000000003','maintenance_due','Maintenance due','Squat Rack inspection due in 15 days'
where not exists (select 1 from notifications where user_id='00000000-0000-4000-8000-000000000003' and title='Maintenance due');

-- -----------------------------------------------------------------------------
-- 13. Audit log
-- -----------------------------------------------------------------------------
insert into audit_logs (actor_id, action, target_type, target_id, metadata, created_at)
select v.actor, v.action, v.ttype, v.tid, v.meta, v.at
from (values
  ('00000000-0000-4000-8000-000000000003'::uuid,'member.create','member','10000000-0000-4000-8000-000000000022'::uuid,'{"source":"front desk"}'::jsonb, now() - interval '2 days'),
  ('00000000-0000-4000-8000-000000000001'::uuid,'subscription.create','subscription','30000000-0000-4000-8000-000000000021'::uuid,'{"plan":"Monthly","final_amount":1500}'::jsonb, now() - interval '1 day'),
  ('00000000-0000-4000-8000-000000000003'::uuid,'payment.record','payment','40000000-0000-4000-8000-000000000019'::uuid,'{"amount":1500,"method":"upi"}'::jsonb, now() - interval '1 day'),
  ('00000000-0000-4000-8000-000000000001'::uuid,'payment.refund','payment','40000000-0000-4000-8000-000000000020'::uuid,'{"amount":1500,"reason":"duplicate charge"}'::jsonb, now() - interval '39 days'),
  ('00000000-0000-4000-8000-000000000004'::uuid,'attendance.override','attendance',null,'{"note":"staff check-in for rehab member"}'::jsonb, now() - interval '4 days'),
  ('00000000-0000-4000-8000-000000000001'::uuid,'settings.update','gym','00000000-0000-4000-8000-000000000001'::uuid,'{"reminder_days":[7,3,1]}'::jsonb, now() - interval '12 days'),
  ('00000000-0000-4000-8000-000000000001'::uuid,'role.assign','profile','00000000-0000-4000-8000-000000000003'::uuid,'{"role":"receptionist"}'::jsonb, now() - interval '20 days')
) as v(actor, action, ttype, tid, meta, at)
where not exists (
  select 1 from audit_logs a
  where a.action = v.action
    and coalesce(a.target_id::text, '') = coalesce(v.tid::text, '')
);

-- -----------------------------------------------------------------------------
-- Summary (verification output)
-- -----------------------------------------------------------------------------
select 'members' as entity, count(*) from members
union all select 'membership_plans', count(*) from membership_plans
union all select 'subscriptions', count(*) from subscriptions
union all select 'payments', count(*) from payments
union all select 'attendance_records', count(*) from attendance_records
union all select 'trainers', count(*) from trainers
union all select 'workout_plans', count(*) from workout_plans
union all select 'workout_exercises', count(*) from workout_exercises
union all select 'classes', count(*) from classes
union all select 'equipment', count(*) from equipment
union all select 'notifications', count(*) from notifications
union all select 'audit_logs', count(*) from audit_logs
order by 1;