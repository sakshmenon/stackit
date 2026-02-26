-- Stackit initial schema: profiles (user info), schedule_items (tasks/events), daily_metrics.
-- Run in Supabase SQL Editor or via Supabase CLI (supabase db push).

-- =============================================================================
-- PROFILES (extends Supabase auth.users with app-specific fields)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  auth_provider TEXT,
  email TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.profiles IS 'User profile and login metadata; id matches auth.users(id).';

-- RLS: users can read/update only their own profile
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Trigger: create profile on signup (call from auth.users trigger or app)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, auth_provider, email, created_at, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_app_meta_data->>'provider', 'email'),
    NEW.email,
    now(),
    now()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users (requires superuser or migration run as postgres)
-- If you cannot add trigger on auth.users, call handle_new_user from your app after signUp.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- SCHEDULE_ITEMS (tasks and events)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.schedule_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  notes TEXT NOT NULL DEFAULT '',
  priority INT NOT NULL DEFAULT 1,
  schedule_date DATE NOT NULL,
  scheduled_start TIMESTAMPTZ,
  scheduled_end TIMESTAMPTZ,
  estimated_duration_minutes INT,
  item_type TEXT NOT NULL DEFAULT 'task' CHECK (item_type IN ('task', 'event')),
  recurrence_kind TEXT NOT NULL DEFAULT 'none' CHECK (recurrence_kind IN ('none', 'daily', 'weekdays', 'weekly')),
  recurrence_weekdays INT[],
  is_completed BOOLEAN NOT NULL DEFAULT false,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.schedule_items IS 'Tasks and events; item_type: task | event; recurrence stored as kind + optional weekdays.';

CREATE INDEX IF NOT EXISTS idx_schedule_items_user_date ON public.schedule_items (user_id, schedule_date);
CREATE INDEX IF NOT EXISTS idx_schedule_items_user_id ON public.schedule_items (user_id);

ALTER TABLE public.schedule_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own schedule items"
  ON public.schedule_items
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- =============================================================================
-- DAILY_METRICS (optional; for streaks and daily stats)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.daily_metrics (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  total_tasks INT NOT NULL DEFAULT 0,
  completed_tasks INT NOT NULL DEFAULT 0,
  streak_length INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, date)
);

ALTER TABLE public.daily_metrics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own daily metrics"
  ON public.daily_metrics
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
