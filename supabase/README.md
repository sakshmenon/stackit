# Supabase setup for Stackit

## 1. Create a project

1. Go to [supabase.com](https://supabase.com) and create a project.
2. In **Settings → API** note your **Project URL** and **anon (public) key**.

## 2. Run the schema migration

- In the Supabase Dashboard, open **SQL Editor** and run the contents of `migrations/20250225000000_initial_schema.sql`, or
- If you use the Supabase CLI: `supabase db push` (from the repo root with `supabase` linked).

This creates:

- **profiles** – User profile rows (id, auth_provider, email, created_at). A trigger creates a profile when a user signs up in `auth.users`.
- **schedule_items** – Tasks and events (user_id, title, notes, priority, schedule_date, scheduled_start/end, item_type, recurrence, completion, etc.). RLS limits access to the signed-in user.
- **daily_metrics** – Optional daily stats (user_id, date, total_tasks, completed_tasks, streak_length). RLS per user.

## 3. Configure the app

Set your project URL and anon key so the app can talk to Supabase:

- **Option A (recommended for dev):** In Xcode, edit the scheme → **Run → Arguments → Environment Variables** and add:
  - `SUPABASE_URL` = your Project URL (e.g. `https://xxxx.supabase.co`)
  - `SUPABASE_ANON_KEY` = your anon key
- **Option B:** Change the placeholders in `SupabaseConfig.swift` (only for local/testing; do not commit real keys).

Then build and run. Use **Sign up** on the login screen to create an account; **Sign in** to log in. After sign-in, the main schedule screen and Settings (with Sign out) are available.

## 4. Auth providers (optional)

To enable **Sign in with Apple** or **Google**:

- In Supabase Dashboard → **Authentication → Providers**, enable Apple and/or Google and set the required credentials.
- In the app, you can later call `SupabaseClient.shared.auth.signInWithOAuth(provider: .apple)` (or `.google`) and handle the redirect; the same `schedule_items` and RLS apply to any signed-in user.
