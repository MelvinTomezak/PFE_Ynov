# Documentation technique — STYMA

| | |
|---|---|
| **Projet** | STYMA — Application mobile |
| **Document** | Documentation technique (déploiement, utilisation, mise à jour) |
| **Compétence visée** | C2.4.1 |
| **Auteur** | Melvin TOMEZAK |
| **Version** | 1.0 |
| **Date** | 21/07/2026 |

---

## 1. Introduction

Cette documentation technique regroupe trois manuels :

- le **manuel de déploiement** : installer et mettre en ligne l'application ;
- le **manuel d'utilisation** : se servir de l'application ;
- le **manuel de mise à jour** : faire évoluer l'application et son contenu.

**Pile technique :** application Flutter (Dart), backend Supabase (PostgreSQL,
Auth, Row Level Security), déploiement web via GitHub Actions et GitHub Pages.

---

# Partie A — Manuel de déploiement

## A.1 Prérequis

- **Flutter SDK** ≥ 3.4
- **Git**
- Un compte **Supabase** (gratuit)
- Un compte **GitHub** (pour le déploiement continu)
- Pour Android : Android Studio (SDK + émulateur). La compilation iOS nécessite macOS + Xcode.

## A.2 Récupération du code

```bash
git clone https://github.com/MelvinTomezak/PFE_Ynov.git
cd PFE_Ynov
```

## A.3 Génération des plateformes (si absentes)

```bash
flutter create --project-name styma --platforms=android,web .
```

## A.4 Installation des dépendances

```bash
flutter pub get
```

En cas de besoin, les dépendances principales peuvent être réinstallées :

```bash
flutter pub add google_fonts flutter_map latlong2 url_launcher
flutter pub add font_awesome_flutter:^11.0.0
```

## A.5 Configuration de Supabase

1. Créer un projet sur [supabase.com](https://supabase.com).
2. Récupérer l'**URL du projet** et la **clé publique** (Settings → API Keys).
3. Copier le modèle d'environnement et le renseigner :
   ```bash
   cp .env.example .env
   ```
   ```env
   SUPABASE_URL=https://votre-projet.supabase.co
   SUPABASE_ANON_KEY=votre_cle_publique
   ```
   > Le fichier `.env` n'est jamais versionné (protégé par `.gitignore`).

## A.6 Initialisation de la base de données

Dans Supabase → **SQL Editor**, exécuter les scripts du dossier `supabase/`
**dans l'ordre** :

1. `schema.sql` — tables de contenu et d'interactions, sécurité RLS, données de démonstration.
2. Les scripts de création des tables **produits** (Boutique) et **liens sociaux** (Réseaux), si elles ne sont pas déjà présentes.
3. `music_engagement.sql` — tables et politiques des likes et commentaires.
4. `admin_roles.sql` — rôles utilisateur/admin, fonction `is_admin()` et politiques d'écriture d'administration.

> Recommandation : regrouper l'ensemble des scripts SQL dans le dossier
> `supabase/`, numérotés dans l'ordre d'exécution (ex. `01_schema.sql`,
> `02_boutique.sql`, …) pour un déploiement reproductible.

## A.7 Réglages de l'authentification

Pour faciliter les tests et la démonstration : Authentication → Providers →
Email → décocher **« Confirm email »**.

## A.8 Promotion d'un administrateur

Le premier administrateur se promeut manuellement en base, après avoir créé son
compte via l'application :

```sql
update public.user_roles
set role = 'admin'
where user_id = (select id from auth.users where email = 'admin@example.com');
```

## A.9 Lancement en local

```bash
flutter run            # sur l'appareil/émulateur sélectionné
flutter run -d chrome  # dans le navigateur
```

## A.10 Génération des exécutables

```bash
flutter build web --release            # version web (dossier build/web)
flutter build apk --release            # APK Android (build/app/outputs/…)
```

## A.11 Déploiement continu (GitHub Pages)

Le dépôt contient un workflow `.github/workflows/cd.yml` qui construit et publie
la version web à chaque push sur `master`.

**Réglages (une seule fois) :**

1. Settings → Secrets and variables → Actions : créer les secrets `SUPABASE_URL` et `SUPABASE_ANON_KEY`.
2. Settings → Pages → Source : **GitHub Actions**.

À chaque push, l'application est publiée sur :
`https://melvintomezak.github.io/PFE_Ynov/`

---

# Partie B — Manuel d'utilisation

## B.1 Création de compte et connexion

- **Inscription** : renseigner un pseudonyme, un e-mail et un mot de passe (au moins 8 caractères, une lettre et un chiffre). Valider pour créer le compte.
- **Connexion** : saisir l'e-mail et le mot de passe.

## B.2 Navigation générale

- La barre inférieure permet d'accéder aux sections : **Accueil, Musique, Vote, Événement, Réseaux, Boutique** (et **Administration** pour les comptes administrateurs).
- Le logo **STYMA** en haut à gauche ramène à l'accueil.
- L'**avatar** en haut à droite ouvre le profil et les paramètres.

## B.3 Sections principales

- **Accueil** : salutation personnalisée, prochain concert, derniers sons et accès rapides.
- **Biographie** : présentation de l'artiste.
- **Musique** : liste des morceaux. Chaque morceau peut être **liké** (icône cœur) et **commenté**.
- **Événement** : liste des concerts, avec une bascule vers une **carte** où chaque concert localisé est cliquable.
- **Réseaux** : liens vers les réseaux sociaux de l'artiste (ouverture externe).
- **Boutique** : catalogue du merchandising ; chaque produit ouvre une fiche détaillée.

## B.4 Profil et gestion du compte

Depuis l'avatar :

- **Modifier le pseudonyme**.
- Activer/désactiver les **notifications**.
- Consulter la fiche **À propos**.
- **Se déconnecter**.
- **Supprimer son compte** (action définitive, avec confirmation).

## B.5 Espace d'administration (comptes administrateurs)

L'onglet **Administration** propose trois catégories : **Musiques**,
**Événements**, **Merch**. Pour chacune, il est possible de :

- **Ajouter** un élément via un formulaire (avec validation des champs) ;
- **Modifier** un élément existant ;
- **Supprimer** un élément (avec confirmation).

Les modifications sont immédiatement répercutées dans l'application pour tous les
utilisateurs.

---

# Partie C — Manuel de mise à jour

## C.1 Faire évoluer le code

Le projet suit une convention de commits explicite :

- `feat:` nouvelle fonctionnalité
- `fix:` correction de bug
- `style:` mise en forme / interface
- `refactor:` réorganisation du code
- `docs:` documentation
- `test:` tests
- `chore:` configuration, dépendances

Cycle de travail :

```bash
git add .
git commit -m "feat: description du changement"
git push
```

À chaque push, l'**intégration continue** relance automatiquement l'analyse
statique et les tests ; le **déploiement continu** met à jour la version en
ligne.

## C.2 Publier une version

Les versions sont matérialisées par des **tags** :

```bash
git tag -a v0.2.0 -m "Version 0.2.0 — description"
git push origin v0.2.0
```

Un tag peut être transformé en **Release** sur GitHub (page Releases) pour
documenter les nouveautés.

## C.3 Mettre à jour le contenu

- **Via l'application** : un administrateur ajoute, modifie ou supprime musiques, événements et produits depuis l'espace d'administration.
- **Via Supabase** : les données peuvent aussi être gérées dans Table Editor (par exemple les réseaux sociaux ou la photo de l'artiste).

## C.4 Faire évoluer la base de données

Toute modification de structure se fait par un **nouveau script SQL** exécuté
dans le SQL Editor de Supabase, puis ajouté au dossier `supabase/` du dépôt pour
conserver l'historique et la reproductibilité.

## C.5 Mettre à jour les dépendances

```bash
flutter pub outdated   # liste les mises à jour disponibles
flutter pub upgrade    # met à jour selon les contraintes du pubspec
flutter test           # vérifier que tout passe après mise à jour
```

> L'outil **Dependabot** (activé sur le dépôt) signale automatiquement les
> dépendances présentant une faille de sécurité connue.

---

## Annexe — Scripts SQL du projet

| Script | Rôle |
|---|---|
| `schema.sql` | Tables de contenu et d'interactions, RLS, données de démonstration |
| `music_engagement.sql` | Likes et commentaires (tables + politiques) |
| `admin_roles.sql` | Rôles utilisateur/admin, fonction `is_admin()`, droits d'administration |
| *(à consolider)* | Tables produits (Boutique) et liens sociaux (Réseaux) |

---

*Documentation établie à la version 1.0 du prototype. À maintenir à jour au fil
des évolutions de l'application.*
