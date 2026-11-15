-- Supabase > SQL Editor'e yapıştırıp "Run" de. Bir kere çalıştırman yeter.

-- Düşünceler: her satır tek bir kullanıcıya ait.
create table if not exists public.entries (
  id text primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  text text not null,
  topics jsonb not null default '[]'::jsonb,
  status text not null default 'done',
  ts bigint not null
);
create index if not exists entries_user_ts on public.entries (user_id, ts);

alter table public.entries enable row level security;

create policy entries_select on public.entries for select using (auth.uid() = user_id);
create policy entries_insert on public.entries for insert with check (auth.uid() = user_id);
create policy entries_update on public.entries for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy entries_delete on public.entries for delete using (auth.uid() = user_id);

-- Günlük başlık isteği sayacı (maliyeti sınırlamak için).
create table if not exists public.usage (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  day date not null,
  n int not null default 0,
  primary key (user_id, day)
);

alter table public.usage enable row level security;

create policy usage_select on public.usage for select using (auth.uid() = user_id);
create policy usage_insert on public.usage for insert with check (auth.uid() = user_id);
create policy usage_update on public.usage for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
