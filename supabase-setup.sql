-- LM STUDIO website · Supabase setup (run once in Supabase → SQL Editor → New query → Run)
-- 1) Website content (everything you edit in admin.html)
create table if not exists public.site_content (
  id int primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);
alter table public.site_content enable row level security;
drop policy if exists "public read content" on public.site_content;
create policy "public read content" on public.site_content for select using (true);
drop policy if exists "admin write content" on public.site_content;
create policy "admin write content" on public.site_content for all to authenticated using (true) with check (true);

-- 2) Booking requests from the website
create table if not exists public.inquiries (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  name text not null check (char_length(name) between 1 and 120),
  phone text check (char_length(phone) <= 40),
  email text check (char_length(email) <= 120),
  shoot_date date,
  package text check (char_length(package) <= 200),
  place text check (char_length(place) <= 200),
  message text check (char_length(message) <= 2000),
  lang text check (char_length(lang) <= 8),
  status text not null default 'new',
  note text
);
alter table public.inquiries enable row level security;
drop policy if exists "anyone can send inquiry" on public.inquiries;
create policy "anyone can send inquiry" on public.inquiries for insert to anon, authenticated with check (status = 'new' and note is null);
drop policy if exists "admin reads inquiries" on public.inquiries;
create policy "admin reads inquiries" on public.inquiries for select to authenticated using (true);
drop policy if exists "admin updates inquiries" on public.inquiries;
create policy "admin updates inquiries" on public.inquiries for update to authenticated using (true) with check (true);
drop policy if exists "admin deletes inquiries" on public.inquiries;
create policy "admin deletes inquiries" on public.inquiries for delete to authenticated using (true);

-- 3) Photo & video storage (public bucket "media", 50 MB per file)
insert into storage.buckets (id, name, public, file_size_limit)
values ('media', 'media', true, 52428800)
on conflict (id) do update set public = true;
drop policy if exists "public read media" on storage.objects;
create policy "public read media" on storage.objects for select using (bucket_id = 'media');
drop policy if exists "admin upload media" on storage.objects;
create policy "admin upload media" on storage.objects for insert to authenticated with check (bucket_id = 'media');
drop policy if exists "admin update media" on storage.objects;
create policy "admin update media" on storage.objects for update to authenticated using (bucket_id = 'media');
drop policy if exists "admin delete media" on storage.objects;
create policy "admin delete media" on storage.objects for delete to authenticated using (bucket_id = 'media');

-- IMPORTANT: Authentication → Sign In / Providers → turn OFF "Allow new users to sign up",
-- then Authentication → Users → "Add user" to create ONLY your own admin login.
