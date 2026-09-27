-- ============================================================
-- Daily Trend Express — Supabase schema, seed row, and RLS
-- Run this once in Supabase Dashboard → SQL Editor → New query
-- Replace all 6 occurrences of 'YOUR_ADMIN_EMAIL' below with your real admin email
-- (same email you'll create as a Supabase Auth user in step 3).
-- ============================================================

-- ---------- TABLES ----------

create table if not exists public.articles (
  id          text primary key,
  title       text not null,
  subheadline text,
  category    text not null,
  author      text,
  date        timestamptz not null default now(),
  summary     text,
  content     text,
  image       text,               -- data URI (SVG placeholder or uploaded photo, base64)
  featured    boolean default false,
  breaking    boolean default false,
  trending    boolean default false,
  tags        text[] default '{}',
  views       integer default 0
);

create table if not exists public.settings (
  id        text primary key default 'site',
  ticker    text[] default '{}',
  site_note text default ''
);
insert into public.settings (id) values ('site') on conflict (id) do nothing;

create table if not exists public.comments (
  id         text primary key,
  article_id text references public.articles(id) on delete cascade,
  name       text not null,
  text       text not null,
  date       timestamptz not null default now()
);

create table if not exists public.subscribers (
  id    text primary key,
  email text unique not null,
  date  timestamptz not null default now()
);

-- ---------- ROW LEVEL SECURITY ----------

alter table public.articles    enable row level security;
alter table public.settings    enable row level security;
alter table public.comments    enable row level security;
alter table public.subscribers enable row level security;

-- ARTICLES: anyone can read; only the one admin account can write
drop policy if exists "articles_public_read" on public.articles;
create policy "articles_public_read" on public.articles
  for select using (true);
drop policy if exists "articles_admin_insert" on public.articles;
create policy "articles_admin_insert" on public.articles
  for insert with check (lower(auth.jwt() ->> 'email') = lower('YOUR_ADMIN_EMAIL'));
drop policy if exists "articles_admin_update" on public.articles;
create policy "articles_admin_update" on public.articles
  for update using (lower(auth.jwt() ->> 'email') = lower('YOUR_ADMIN_EMAIL'));
drop policy if exists "articles_admin_delete" on public.articles;
create policy "articles_admin_delete" on public.articles
  for delete using (lower(auth.jwt() ->> 'email') = lower('YOUR_ADMIN_EMAIL'));

-- SETTINGS (breaking-news ticker): anyone can read; only admin can write
drop policy if exists "settings_public_read" on public.settings;
create policy "settings_public_read" on public.settings
  for select using (true);
drop policy if exists "settings_admin_insert" on public.settings;
create policy "settings_admin_insert" on public.settings
  for insert with check (lower(auth.jwt() ->> 'email') = lower('YOUR_ADMIN_EMAIL'));
drop policy if exists "settings_admin_update" on public.settings;
create policy "settings_admin_update" on public.settings
  for update using (lower(auth.jwt() ->> 'email') = lower('YOUR_ADMIN_EMAIL'));

-- COMMENTS: anyone can read and post (public commenting); no public edit/delete
drop policy if exists "comments_public_read" on public.comments;
create policy "comments_public_read" on public.comments
  for select using (true);
drop policy if exists "comments_public_insert" on public.comments;
create policy "comments_public_insert" on public.comments
  for insert with check (true);

-- SUBSCRIBERS: anyone can sign up; only admin can read the list (protects reader emails)
drop policy if exists "subscribers_public_insert" on public.subscribers;
create policy "subscribers_public_insert" on public.subscribers
  for insert with check (true);
drop policy if exists "subscribers_admin_read" on public.subscribers;
create policy "subscribers_admin_read" on public.subscribers
  for select using (lower(auth.jwt() ->> 'email') = lower('YOUR_ADMIN_EMAIL'));

-- ============================================================
-- After running this file:
-- 1. Dashboard → Authentication → Users → Add user → create yourself
--    with the SAME email used above, and a password.
-- 2. Dashboard → Database → Replication → enable Realtime for the
--    "articles" and "settings" tables (so edits sync live to visitors).
-- 3. Dashboard → Project Settings → API → copy the Project URL and the
--    anon/public key (NOT the service_role key) into index.html's
--    SUPABASE_URL / SUPABASE_ANON_KEY / ADMIN_EMAIL constants.
-- ============================================================
