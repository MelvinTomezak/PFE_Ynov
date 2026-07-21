# STYMA

Application mobile de l'artiste **STYMA**, pensée pour transformer le concert en
expérience partagée : le public influence le live en temps réel (vote pour le
prochain morceau, bouton d'urgence) via un **bracelet connecté**, et retrouve
hors concert la biographie, la musique, les événements et tous les réseaux de
l'artiste.

> Projet réalisé dans le cadre du **Bloc 2 — Concevoir et développer des
> applications logicielles** (titre RNCP 39583, Expert en développement
> logiciel).

---

## Sommaire

- [Fonctionnalités](#fonctionnalités)
- [Stack technique](#stack-technique)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation locale](#installation-locale)
- [Structure du projet](#structure-du-projet)
- [Sécurité](#sécurité)
- [Lancer et tester](#lancer-et-tester)

---

## Fonctionnalités

- **Authentification** : inscription (avec pseudonyme) et connexion via Supabase.
- **Accueil** : résumé des dernières actualités (prochain concert, derniers sons).
- **Biographie** : présentation détaillée de l'artiste.
- **Musique** : liste des morceaux.
- **Vote** : vote pour le prochain morceau en concert *(en cours de
  développement — le bracelet connecté est simulé dans l'application)*.
- **Événements** : concerts à venir, en vue liste ou sur une **carte**.
- **Linktree** : tous les réseaux sociaux de STYMA, gérés en base de données.
- **Profil & paramètres** : édition du pseudonyme, préférences, suppression de
  compte.

---

## Stack technique

| Domaine | Technologie |
|---|---|
| Application mobile | Flutter (Dart) |
| Gestion d'état | Provider (pattern MVVM) |
| Backend / Auth / temps réel | Supabase |
| Base de données | PostgreSQL (+ Row Level Security) |
| Cartographie | flutter_map + OpenStreetMap |
| Polices | google_fonts (Unbounded, Chakra Petch, Inter) |
| Icônes de marque | font_awesome_flutter |
| Ouverture de liens | url_launcher |
| Variables d'environnement | flutter_dotenv |

---

## Architecture

Le projet suit une architecture **MVVM** qui sépare clairement les
responsabilités :

- **View** (`ui/.../view`) : l'interface, sans logique métier.
- **ViewModel** (`ui/.../viewmodel`) : l'état et la logique de présentation
  (classes `ChangeNotifier`), sans dépendance directe à l'interface ni à
  Supabase — ce qui les rend testables unitairement.
- **Repository** (`data/repositories`) : l'accès aux données, seul point qui
  connaît Supabase. Cela permet de changer de source ou de tester via des mocks.

---

## Prérequis

- **Flutter SDK** ≥ 3.4 ([guide d'installation](https://docs.flutter.dev/install))
- Un **projet Supabase** (gratuit) : URL du projet + clé publique
- Un éditeur (VS Code recommandé, avec l'extension Flutter)
- Pour lancer sur Android : Android Studio (SDK + émulateur) ou un appareil
  Android en débogage USB. La compilation iOS nécessite macOS + Xcode.

---

## Installation locale

### 1. Récupérer le projet

```bash
git clone <URL_DU_DEPOT>
cd styma
```

### 2. Générer les plateformes (si le dossier `android/` est absent)

```bash
flutter create --project-name styma --platforms=android,web .
```

### 3. Installer les dépendances

```bash
flutter pub get
```

> Si nécessaire, ajouter les librairies :
> ```bash
> flutter pub add google_fonts flutter_map latlong2 url_launcher
> flutter pub add font_awesome_flutter:^10.8.0
> ```
> (font_awesome est volontairement fixé en 10.x : la v11 change le type des
> icônes.)

### 4. Configurer Supabase

1. Créer un projet sur [supabase.com](https://supabase.com).
2. Récupérer l'**URL du projet** et la **clé publique** (Settings → API Keys).
3. Copier le modèle d'environnement puis le renseigner :
   ```bash
   cp .env.example .env
   ```
   ```env
   SUPABASE_URL=https://votre-projet.supabase.co
   SUPABASE_ANON_KEY=votre_cle_publique
   ```
   > Le fichier `.env` n'est **jamais** commité (voir `.gitignore`).
4. Dans Supabase → **SQL Editor**, exécuter les scripts du dossier `supabase/`
   pour créer les tables, la sécurité (RLS) et les données de démonstration.
5. Pour faciliter les tests, désactiver la confirmation par e-mail :
   Authentication → Providers → Email → décocher « Confirm email ».

### 5. Lancer l'application

```bash
flutter run
```

Pour un test rapide dans le navigateur :

```bash
flutter run -d chrome
```

---

## Structure du projet

```
lib/
├── main.dart                 # Point d'entrée + aiguillage auth
├── core/
│   ├── config/               # Initialisation Supabase
│   ├── theme/                # Thème et couleurs (DA néon)
│   └── utils/                # Validateurs, utilitaires
├── data/
│   ├── models/               # Modèles (Artist, Track, ConcertEvent, ...)
│   └── repositories/         # Accès aux données (isole Supabase)
└── ui/
    ├── common/               # Widgets réutilisables (NeonText, navbar, ...)
    ├── auth/                 # Connexion / inscription
    ├── home/                 # Accueil
    ├── artist/               # Biographie
    ├── music/                # Musique
    ├── vote/                 # Vote
    ├── events/               # Événements (liste + carte)
    ├── linktree/             # Réseaux sociaux
    ├── profile/              # Profil & paramètres
    └── main/                 # Coquille de navigation

supabase/                     # Scripts SQL (schéma, sécurité, données)
```

---

## Sécurité

La sécurité est prise en compte dès la conception :

- **Contrôle d'accès** : chaque table est protégée par des politiques **Row
  Level Security** (refus par défaut, ouverture explicite au strict
  nécessaire).
- **Validation des entrées** : les saisies utilisateur sont validées côté
  application (fonctions pures et testables).
- **Secrets hors du code** : les identifiants Supabase sont chargés depuis un
  fichier `.env` non versionné.
- **Suppression de compte** : réalisée via une fonction PostgreSQL sécurisée
  (`security definer`) qui ne permet à l'utilisateur de supprimer que son
  propre compte.

---

## Lancer et tester

```bash
flutter analyze   # analyse statique du code
flutter test      # tests unitaires
flutter run       # lancer l'application
```

---

*STYMA — projet de fin d'études.*
