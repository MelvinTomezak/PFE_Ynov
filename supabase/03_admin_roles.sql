-- STYMA — rôles utilisateur/admin et droits de gestion du contenu.
-- À exécuter dans Supabase > SQL Editor sur la base existante.

create table if not exists public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz not null default now()
);

-- Tous les comptes existants deviennent utilisateurs standards.
insert into public.user_roles (user_id, role)
select id, 'user' from auth.users
on conflict (user_id) do nothing;

-- Les futurs comptes reçoivent automatiquement le rôle utilisateur.
create or replace function public.handle_new_user_role()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.user_roles (user_id, role)
  values (new.id, 'user')
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_role on auth.users;
create trigger on_auth_user_created_role
  after insert on auth.users
  for each row execute function public.handle_new_user_role();

-- Fonction utilisée par les politiques sans provoquer de récursion RLS.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer set search_path = ''
as $$
  select exists (
    select 1 from public.user_roles
    where user_id = auth.uid() and role = 'admin'
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

alter table public.user_roles enable row level security;
drop policy if exists "Lire son role" on public.user_roles;
create policy "Lire son role" on public.user_roles
  for select to authenticated using (user_id = auth.uid());

-- Les politiques de lecture existantes restent inchangées.
drop policy if exists "Admin ajouter morceaux" on public.tracks;
drop policy if exists "Admin modifier morceaux" on public.tracks;
drop policy if exists "Admin supprimer morceaux" on public.tracks;
create policy "Admin ajouter morceaux" on public.tracks
  for insert to authenticated with check (public.is_admin());
create policy "Admin modifier morceaux" on public.tracks
  for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admin supprimer morceaux" on public.tracks
  for delete to authenticated using (public.is_admin());

drop policy if exists "Admin ajouter evenements" on public.events;
drop policy if exists "Admin modifier evenements" on public.events;
drop policy if exists "Admin supprimer evenements" on public.events;
create policy "Admin ajouter evenements" on public.events
  for insert to authenticated with check (public.is_admin());
create policy "Admin modifier evenements" on public.events
  for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admin supprimer evenements" on public.events
  for delete to authenticated using (public.is_admin());

-- Remarque : les politiques de la table « products » ne figurent pas ici.
-- Cette table est créée par le script 04, qui définit lui-même ses politiques
-- de lecture et d'écriture. Les déclarer ici créerait une dépendance
-- circulaire entre les scripts 03 et 04.

-- Après exécution, promouvoir manuellement le premier administrateur :
-- update public.user_roles
-- set role = 'admin'
-- where user_id = (select id from auth.users where email = 'admin@example.com');
