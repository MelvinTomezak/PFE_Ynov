-- ============================================================
--  STYMA — Schéma de base de données, sécurité et données de démo
--  À exécuter dans Supabase : SQL Editor > New query > coller > Run
-- ============================================================

-- ------------------------------------------------------------
--  1. TABLES
-- ------------------------------------------------------------

-- Artiste (une seule ligne : la biographie de STYMA)
create table if not exists public.artist (
  id         smallint primary key default 1,
  name       text not null,
  bio        text not null,
  image_url  text,
  constraint single_row check (id = 1)
);

-- Morceaux
create table if not exists public.tracks (
  id               uuid primary key default gen_random_uuid(),
  title            text not null,
  album            text,
  cover_url        text,
  duration_seconds int,
  created_at       timestamptz not null default now()
);

-- Événements (concerts)
create table if not exists public.events (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  venue      text not null,
  city       text not null,
  starts_at  timestamptz not null,
  created_at timestamptz not null default now()
);

-- Votes (vote pour le prochain morceau) : un vote actif par utilisateur
create table if not exists public.votes (
  user_id    uuid not null references auth.users(id) on delete cascade,
  track_id   uuid not null references public.tracks(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id)
);

-- Urgences (bouton d'urgence)
create table if not exists public.emergencies (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
--  2. SÉCURITÉ — Row Level Security (OWASP A01 : Broken Access Control)
--     Une fois RLS activé, TOUT accès est refusé par défaut ;
--     on ouvre ensuite explicitement, au strict nécessaire.
-- ------------------------------------------------------------

alter table public.artist      enable row level security;
alter table public.tracks      enable row level security;
alter table public.events      enable row level security;
alter table public.votes       enable row level security;
alter table public.emergencies enable row level security;

-- Contenu public : lecture seule pour tout utilisateur authentifié
create policy "Lecture artiste"    on public.artist for select to authenticated using (true);
create policy "Lecture morceaux"   on public.tracks for select to authenticated using (true);
create policy "Lecture evenements" on public.events for select to authenticated using (true);

-- Votes : lecture ouverte (pour le décompte), écriture limitée à SON propre vote
create policy "Lecture votes"    on public.votes for select to authenticated using (true);
create policy "Inserer son vote" on public.votes for insert to authenticated with check (auth.uid() = user_id);
create policy "Modifier son vote" on public.votes for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Supprimer son vote" on public.votes for delete to authenticated using (auth.uid() = user_id);

-- Urgences : chacun ne crée et ne lit QUE ses propres alertes
create policy "Inserer une urgence" on public.emergencies for insert to authenticated with check (auth.uid() = user_id);
create policy "Lire ses urgences"   on public.emergencies for select to authenticated using (auth.uid() = user_id);

-- ------------------------------------------------------------
--  3. DONNÉES DE DÉMONSTRATION
-- ------------------------------------------------------------

insert into public.artist (id, name, bio) values (
  1,
  'STYMA',
  'STYMA est un artiste de musique électronique dont les concerts effacent la frontière entre la scène et le public. Grâce à un bracelet connecté, chaque spectateur influence en direct le déroulé du live : voter pour le prochain morceau, faire réagir la lumière, alerter l''équipe en cas de besoin. Une expérience où le concert se construit ensemble, en temps réel.'
) on conflict (id) do update
  set name = excluded.name, bio = excluded.bio;

insert into public.tracks (title, album, duration_seconds) values
  ('Néon',        'Première Lumière', 213),
  ('Écho',        'Première Lumière', 187),
  ('Pulsar',      'Première Lumière', 241),
  ('Rémanence',   'Signal',           198),
  ('Fréquence',   'Signal',           226),
  ('Aurore',      'Signal',           205)
on conflict do nothing;

insert into public.events (title, venue, city, starts_at) values
  ('STYMA Live — Release Party', 'Le Silo',        'Marseille', now() + interval '20 days'),
  ('STYMA Live — Signal Tour',   'La Cartonnerie', 'Reims',     now() + interval '40 days'),
  ('STYMA Live — Signal Tour',   'Le Transbordeur','Lyon',      now() + interval '55 days')
on conflict do nothing;
