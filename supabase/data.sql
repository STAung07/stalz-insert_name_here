-- Users Table
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  role TEXT CHECK (role IN ('coach', 'student')),
  full_name TEXT,
  created_at TIMESTAMP DEFAULT now()
);

-- Academies Table
CREATE TABLE academies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  coach_id UUID REFERENCES users(id),
  name TEXT,
  created_at TIMESTAMP DEFAULT now()
);

-- Memberships Table
CREATE TABLE memberships (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  academy_id UUID REFERENCES academies(id),
  student_id UUID REFERENCES users(id)
);

-- Training Sessions Table
CREATE TABLE training_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  academy_id UUID REFERENCES academies(id),
  coach_id UUID REFERENCES users(id),
  session_title TEXT,
  session_time TIMESTAMPTZ,
  student_ids UUID[] DEFAULT '{}'
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE academies ENABLE ROW LEVEL SECURITY;
ALTER TABLE memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_sessions ENABLE ROW LEVEL SECURITY;

-- Users Table Policies
CREATE POLICY "Users can view their own profile"
  ON users FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Users can insert their own profile"
  ON users FOR INSERT
  WITH CHECK (id = auth.uid());

-- Academies Table Policies
CREATE POLICY "Coaches can manage their academies"
  ON academies FOR ALL
  USING (coach_id = auth.uid());

-- Memberships Table Policies
CREATE POLICY "Students can view their memberships"
  ON memberships FOR SELECT
  USING (student_id = auth.uid());

CREATE POLICY "Coaches can manage memberships in their academies"
  ON memberships FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM academies
      WHERE academies.id = memberships.academy_id
      AND academies.coach_id = auth.uid()
    )
  );

-- Training Sessions Table Policies
CREATE POLICY "Coaches can manage their sessions"
  ON training_sessions FOR ALL
  USING (coach_id = auth.uid());

CREATE POLICY "Students can view sessions in their academies"
  ON training_sessions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM memberships
      WHERE memberships.academy_id = training_sessions.academy_id
      AND memberships.student_id = auth.uid()
    )
  );
