# STYMA

Application mobile de l'artiste **STYMA**, pensée pour transformer le concert en
expérience partagée : le public influence le live en temps réel (vote pour le
prochain morceau, bouton d'urgence) via un **bracelet connecté**, et retrouve
hors concert la biographie, la musique, les événements, les réseaux et la
boutique de l'artiste.

> Projet réalisé dans le cadre du **Bloc 2 — Concevoir et développer des
> applications logicielles** (titre RNCP 39583, Expert en développement
> logiciel).

**Application en ligne :** <https://melvintomezak.github.io/PFE_Ynov/>

---

## Sommaire

- [Fonctionnalités](#fonctionnalités)
- [Stack technique](#stack-technique)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation locale](#installation-locale)
- [Structure du projet](#structure-du-projet)
- [Sécurité](#sécurité)
- [Qualité et automatisation](#qualité-et-automatisation)

---

## Fonctionnalités

- **Authentification** : inscription (avec pseudonyme) et connexion via Supabase.
- **Accueil** : résumé des dernières actualités (prochain concert, derniers sons).
- **Biographie** : présentation détaillée de l'artiste.
- **Musique** : liste des morceaux, avec **likes** et **commentaires**.
- **Événements** : concerts à venir, en vue liste ou sur une **carte**.
- **Réseaux** : tous les réseaux sociaux de l'artiste, gérés en base de données.
- **Boutique** : catalogue du merchandising.
- **Profil & paramètres** : édition du pseudonyme, préférences, suppression de compte.
- **Administration** (comptes administrateurs) : gestion des musiques, événements et produits.
- **Vote** : vote pour le prochain morceau en concert *(en cours de développement)*.

---

## Stack technique

| Domaine | Technologie |
|---|---|
| Application | Flutter (Dart) |
| Gestion d'état | Provider (pattern MVVM) |
| Backend / Auth / temps réel | Supabase |
| Base de données | PostgreSQL (+ Row Level Security) |
| Cartographie | flutter_map + OpenStreetMap |
| Polices | google_fonts (Unbounded, Chakra Petch, Inter) |
| Icônes de marque | font_awesome_flutter 11 |
| Ouverture de liens | url_launcher |
| Variables d'environnement | flutter_dotenv |
| Intégration et déploiement continus | GitHub Actions + GitHub Pages |

---

## Architecture

Le projet suit une architecture **MVVM** qui sépare clairement les
responsabilités :

- **View** (`ui/.../view`) : l'interface, sans logique métier.
- **ViewModel** (`ui/.../viewmodel`) : l'état et la logique de présentation
  (classes `ChangeNotifier`), sans dépendance directe à l'interface ni à
  Supabase — ce qui les rend testables unitairement.
- **Repository** (`data/repositories`) : l'accès aux données, seul point qui
  connaît Supabase. Chaque repository est défini par une interface abstraite,
  ce qui permet de l'injecter et de le remplacer par une implémentation
  factice dans les tests.

---

## Prérequis

- **Flutter SDK** ≥ 3.4 ([guide d'installation](https://docs.flutter.dev/install))
- Un **projet Supabase** (offre gratuite suffisante) : URL du projet + clé publique
- Un éditeur (VS Code recommandé, avec l'extension Flutter)
- Pour Android : Android Studio (SDK + émulateur) ou un appareil en débogage USB.
  La compilation iOS nécessite macOS et Xcode.

---

## Installation locale

### 1. Récupérer le projet

```bash
git clone https://github.com/MelvinTomezak/PFE_Ynov.git
cd PFE_Ynov
```

### 2. Générer les plateformes (si les dossiers `android/` ou `web/` sont absents)

```bash
flutter create --project-name styma --platforms=android,web .
```

### 3. Installer les dépendances

```bash
flutter pub get
```

> Toutes les dépendances sont déjà déclarées dans `pubspec.yaml`. En
> particulier, `font_awesome_flutter` est fixé en **11.0.0** : les versions 10.x
> ne compilent pas pour le web avec les versions récentes de Flutter.

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
   **dans l'ordre** :

   | Ordre | Script | Contenu |
   |---|---|---|
   | 1 | `01_schema.sql` | Tables de contenu et d'interactions, RLS, données de démonstration |
   | 2 | `02_music_engagement.sql` | Likes et commentaires (tables et politiques) |
   | 3 | `03_admin_roles.sql` | Rôles utilisateur/administrateur, fonction `is_admin()` |
   | 4 | `04_complements.sql` | Boutique, réseaux, coordonnées des événements, suppression de compte |

5. Pour faciliter les tests, désactiver la confirmation par e-mail :
   Authentication → Providers → Email → décocher « Confirm email ».

### 5. Lancer l'application

```bash
flutter run            # sur l'appareil ou l'émulateur sélectionné
flutter run -d chrome  # dans le navigateur
```

### 6. Devenir administrateur (facultatif)

Après avoir créé un compte via l'application, exécuter dans le SQL Editor :

```sql
update public.user_roles
set role = 'admin'
where user_id = (select id from auth.users where email = 'votre@email.com');
```

Se reconnecter : l'onglet **Admin** apparaît alors dans la barre de navigation.

---

## Structure du projet

```
lib/
├── main.dart                 # Point d'entrée + aiguillage selon la session
├── core/
│   ├── config/               # Initialisation Supabase
│   ├── theme/                # Thème et couleurs (identité néon)
│   └── utils/                # Validateurs, états de chargement
├── data/
│   ├── models/               # Artist, Track, ConcertEvent, Product, ...
│   └── repositories/         # Accès aux données (interface + implémentation)
└── ui/
    ├── common/               # Widgets réutilisables (NeonText, navbar, ...)
    ├── auth/                 # Connexion / inscription
    ├── home/                 # Accueil
    ├── artist/               # Biographie
    ├── music/                # Musique (likes, commentaires)
    ├── events/               # Événements (liste + carte)
    ├── vote/                 # Vote
    ├── linktree/             # Réseaux
    ├── shop/                 # Boutique
    ├── profile/              # Profil & paramètres
    ├── admin/                # Espace d'administration
    └── main/                 # Coquille de navigation

supabase/                     # Scripts SQL numérotés (schéma, sécurité, données)
test/                         # Tests unitaires et tests de widgets
.github/workflows/            # Intégration et déploiement continus
```

---

## Sécurité

La sécurité est prise en compte dès la conception :

- **Contrôle d'accès** : chaque table est protégée par des politiques **Row
  Level Security** (refus par défaut, ouverture explicite au strict nécessaire).
- **Rôles** : le rôle utilisateur/administrateur est stocké en base et ne peut
  pas être modifié depuis le client ; les écritures d'administration sont
  contrôlées côté serveur par la fonction `is_admin()`.
- **Validation des entrées** : les saisies utilisateur sont validées côté
  application par des fonctions pures et testées.
- **Secrets hors du code** : les identifiants Supabase sont chargés depuis un
  fichier `.env` non versionné ; en CI/CD, ils proviennent des secrets GitHub.
- **Suppression de compte** : réalisée par une fonction PostgreSQL
  (`security definer`) qui ne permet de supprimer que son propre compte.

---

## Qualité et automatisation

```bash
flutter analyze          # analyse statique
flutter test             # tests unitaires et de widgets
flutter test --coverage  # avec rapport de couverture
```

À chaque push, le workflow `.github/workflows/ci-cd.yml` enchaîne :

1. **Qualité** — analyse statique, tests et contrôle du seuil de couverture ;
2. **Construction** — build web, uniquement si l'étape précédente réussit ;
3. **Déploiement** — publication automatique sur GitHub Pages.

---

*STYMA — projet de fin d'études.*
