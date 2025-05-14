-- Enable required extensions
create extension if not exists "uuid-ossp";

-- ========================================
-- 1. Users Table
-- ========================================
create table if not exists users (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text check (role in ('coach', 'student')) not null,
  created_at timestamptz default now()
);

-- ========================================
-- 2. Academies Table
-- ========================================
create table if not exists academies (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  coach_id uuid references users(id) on delete cascade,
  created_at timestamptz default now()
);

-- ========================================
-- 3. Memberships Table (Student <-> Academy)
-- ========================================
create table if not exists memberships (
  id uuid primary key default uuid_generate_v4(),
  academy_id uuid references academies(id) on delete cascade,
  student_id uuid references users(id) on delete cascade,
  created_at timestamptz default now(),
  unique (academy_id, student_id)
);

-- ========================================
-- 4. Training Sessions Table
-- ========================================
create table if not exists training_sessions (
  id uuid primary key default uuid_generate_v4(),
  academy_id uuid references academies(id) on delete cascade,
  title text not null,
  start_time timestamptz not null,
  end_time timestamptz not null,
  created_at timestamptz default now()
);

-- ========================================
-- 5. Session Attendance Table (Students <-> Sessions)
-- ========================================
create table if not exists session_attendance (
  session_id uuid references training_sessions(id) on delete cascade,
  student_id uuid references users(id) on delete cascade,
  primary key (session_id, student_id)
);

-- ========================================
-- 6. Session Coaches Table (Coaches <-> Sessions)
-- ========================================
create table if not exists session_coaches (
  session_id uuid references training_sessions(id) on delete cascade,
  coach_id uuid references users(id) on delete cascade,
  primary key (session_id, coach_id)
);

-- ========================================
-- 7. Enable RLS and Apply Policies
-- ========================================

-- Enable RLS
alter table users enable row level security;
alter table academies enable row level security;
alter table memberships enable row level security;
alter table training_sessions enable row level security;
alter table session_attendance enable row level security;
alter table session_coaches enable row level security;

-- Users Table Policies
create policy "Users can view their own profile"
  on users for select
  using (id = auth.uid());

create policy "Users can insert their own profile"
  on users for insert
  with check (id = auth.uid());

create policy "Users can update their own profile"
  on users for update
  using (id = auth.uid())
  with check (id = auth.uid());

-- Academies Table Policies
create policy "Coaches can manage their academies"
  on academies for all
  using (coach_id = auth.uid());

-- Memberships Table Policies
create policy "Students can view their memberships"
  on memberships for select
  using (student_id = auth.uid());

create policy "Coaches can manage memberships in their academies"
  on memberships for all
  using (
    exists (
      select 1 from academies
      where academies.id = memberships.academy_id
      and academies.coach_id = auth.uid()
    )
  );

-- Training Sessions Table Policies
create policy "Academy members can view sessions"
  on training_sessions for select
  using (
    auth.role() = 'authenticated' and (
      exists (
        select 1 from memberships
        where memberships.academy_id = training_sessions.academy_id
        and memberships.student_id = auth.uid()
      )
      or
      exists (
        select 1 from academies
        where academies.id = training_sessions.academy_id
        and academies.coach_id = auth.uid()
      )
      or
      exists (
        select 1 from session_coaches
        where session_coaches.session_id = training_sessions.id
        and session_coaches.coach_id = auth.uid()
      )
    )
  );

-- Session Attendance Table Policies
create policy "Students manage their own attendance"
  on session_attendance for all
  using (student_id = auth.uid())
  with check (student_id = auth.uid());

-- Session Coaches Table Policies
create policy "Coaches manage their own session links"
  on session_coaches for all
  using (coach_id = auth.uid())
  with check (coach_id = auth.uid());
