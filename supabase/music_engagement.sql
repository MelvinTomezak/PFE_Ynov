-- STYMA — ajout des likes et commentaires aux morceaux.
-- À exécuter une fois dans Supabase > SQL Editor sur une base déjà créée.

create table if not exists public.track_likes (
  track_id   uuid not null references public.tracks(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (track_id, user_id)
);

create table if not exists public.track_comments (
  id         uuid primary key default gen_random_uuid(),
  track_id   uuid not null references public.tracks(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  username   text not null check (char_length(username) between 2 and 20),
  content    text not null check (char_length(btrim(content)) between 1 and 500),
  created_at timestamptz not null default now()
);

create index if not exists track_comments_track_created_idx
  on public.track_comments (track_id, created_at desc);

alter table public.track_likes enable row level security;
alter table public.track_comments enable row level security;

drop policy if exists "Lecture likes" on public.track_likes;
drop policy if exists "Ajouter son like" on public.track_likes;
drop policy if exists "Supprimer son like" on public.track_likes;
drop policy if exists "Lecture commentaires" on public.track_comments;
drop policy if exists "Ajouter son commentaire" on public.track_comments;
drop policy if exists "Supprimer son commentaire" on public.track_comments;

create policy "Lecture likes" on public.track_likes
  for select to authenticated using (true);
create policy "Ajouter son like" on public.track_likes
  for insert to authenticated with check (auth.uid() = user_id);
create policy "Supprimer son like" on public.track_likes
  for delete to authenticated using (auth.uid() = user_id);

create policy "Lecture commentaires" on public.track_comments
  for select to authenticated using (true);
create policy "Ajouter son commentaire" on public.track_comments
  for insert to authenticated with check (auth.uid() = user_id);
create policy "Supprimer son commentaire" on public.track_comments
  for delete to authenticated using (auth.uid() = user_id);
