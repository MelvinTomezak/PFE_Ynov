-- ============================================================
--  STYMA — Compléments du schéma
--  À exécuter APRÈS : schema.sql, music_engagement.sql, admin_roles.sql
--
--  Ce script ajoute les éléments nécessaires au fonctionnement
--  complet de l'application :
--    1. Coordonnées géographiques des événements (vue carte)
--    2. Table des produits (Boutique)
--    3. Table des liens sociaux (Réseaux)
--    4. Fonction de suppression de compte
-- ============================================================


-- ------------------------------------------------------------
--  1. COORDONNÉES DES ÉVÉNEMENTS (vue carte)
-- ------------------------------------------------------------

alter table public.events add column if not exists latitude  double precision;
alter table public.events add column if not exists longitude double precision;

-- Coordonnées des salles de démonstration
update public.events set latitude = 43.3125, longitude = 5.3653 where city = 'Marseille';
update public.events set latitude = 49.2447, longitude = 4.0669 where city = 'Reims';
update public.events set latitude = 45.7861, longitude = 4.8646 where city = 'Lyon';


-- ------------------------------------------------------------
--  2. BOUTIQUE (produits)
-- ------------------------------------------------------------

create table if not exists public.products (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  category    text,
  price       numeric(10,2) not null default 0,
  image_url   text,
  description text,
  sort_order  int not null default 0,
  created_at  timestamptz not null default now()
);

alter table public.products enable row level security;

-- Lecture : tout utilisateur authentifié
drop policy if exists "Lecture produits" on public.products;
create policy "Lecture produits" on public.products
  for select to authenticated using (true);

-- Écriture : administrateurs uniquement
drop policy if exists "Admin ajouter produits" on public.products;
create policy "Admin ajouter produits" on public.products
  for insert to authenticated with check (public.is_admin());

drop policy if exists "Admin modifier produits" on public.products;
create policy "Admin modifier produits" on public.products
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Admin supprimer produits" on public.products;
create policy "Admin supprimer produits" on public.products
  for delete to authenticated using (public.is_admin());

-- Données de démonstration
insert into public.products (name, category, price, description, sort_order) values
  ('T-shirt STYMA Noir',       'Vêtements',   25.00, 'T-shirt noir en coton bio, logo STYMA néon sérigraphié au dos.', 1),
  ('Hoodie Néon',              'Vêtements',   55.00, 'Sweat à capuche épais, broderie bleu néon sur la poitrine.',     2),
  ('T-shirt Première Lumière', 'Vêtements',   25.00, 'T-shirt collector de la tournée « Première Lumière ».',           3),
  ('Casquette Logo',           'Accessoires', 20.00, 'Casquette noire réglable, logo brodé.',                           4),
  ('Tote bag STYMA',           'Accessoires', 15.00, 'Sac en toile écologique, motif néon.',                            5),
  ('Vinyle « Signal »',        'Musique',     30.00, 'Édition vinyle de l''album « Signal », pochette exclusive.',      6)
on conflict do nothing;


-- ------------------------------------------------------------
--  3. RÉSEAUX SOCIAUX (Linktree)
-- ------------------------------------------------------------

create table if not exists public.social_links (
  id         uuid primary key default gen_random_uuid(),
  label      text not null,
  handle     text,
  url        text not null,
  icon_key   text not null,           -- clé mappée vers une icône côté application
  color      text not null default '#38BDF8',
  sort_order int  not null default 0,
  created_at timestamptz not null default now()
);

alter table public.social_links enable row level security;

-- Lecture : tout utilisateur authentifié
drop policy if exists "Lecture liens sociaux" on public.social_links;
create policy "Lecture liens sociaux" on public.social_links
  for select to authenticated using (true);

-- Écriture : administrateurs uniquement
drop policy if exists "Admin ajouter liens" on public.social_links;
create policy "Admin ajouter liens" on public.social_links
  for insert to authenticated with check (public.is_admin());

drop policy if exists "Admin modifier liens" on public.social_links;
create policy "Admin modifier liens" on public.social_links
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Admin supprimer liens" on public.social_links;
create policy "Admin supprimer liens" on public.social_links
  for delete to authenticated using (public.is_admin());

-- Données de démonstration
insert into public.social_links (label, handle, url, icon_key, color, sort_order) values
  ('Spotify',     'STYMA',  'https://open.spotify.com', 'spotify',    '#1DB954', 1),
  ('Instagram',   '@styma', 'https://instagram.com',    'instagram',  '#E1306C', 2),
  ('YouTube',     'STYMA',  'https://youtube.com',      'youtube',    '#FF0000', 3),
  ('TikTok',      '@styma', 'https://tiktok.com',       'tiktok',     '#EDEFF5', 4),
  ('Apple Music', 'STYMA',  'https://music.apple.com',  'apple',      '#FA57C1', 5),
  ('SoundCloud',  'STYMA',  'https://soundcloud.com',   'soundcloud', '#FF5500', 6),
  ('Deezer',      'STYMA',  'https://deezer.com',       'deezer',     '#A238FF', 7)
on conflict do nothing;


-- ------------------------------------------------------------
--  4. SUPPRESSION DE COMPTE
--     Fonction "security definer" : l'utilisateur ne peut supprimer
--     QUE son propre compte (auth.uid()). Les données liées (likes,
--     commentaires, votes, rôle) sont supprimées en cascade.
-- ------------------------------------------------------------

create or replace function public.delete_account()
returns void
language sql
security definer set search_path = ''
as $$
  delete from auth.users where id = auth.uid();
$$;

revoke all on function public.delete_account() from public, anon;
grant execute on function public.delete_account() to authenticated;


-- ============================================================
--  FIN DU SCRIPT
-- ============================================================
