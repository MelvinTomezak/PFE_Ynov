# STYMA — Application mobile

Application mobile (Flutter + Supabase) — projet du Bloc 2 du titre RNCP 39583.
Architecture **MVVM** : `View` (UI) → `ViewModel` (état/logique) → `Repository` (données).

## Structure

```
lib/
├── core/
│   ├── config/       # Initialisation Supabase
│   ├── theme/        # Thème (contrastes RGAA/WCAG)
│   └── utils/        # Validateurs (fonctions pures, testables)
├── data/
│   ├── models/       # Modèles de données
│   └── repositories/ # Accès aux données (isole Supabase)
└── ui/
    ├── auth/
    │   ├── view/       # Écrans connexion / inscription
    │   └── viewmodel/  # AuthViewModel
    └── home/
        └── view/       # Écran d'accueil
```

## Prérequis

- Flutter SDK ≥ 3.4
- Un projet Supabase (URL + clé anon)

## Démarrage

1. Installer les dépendances :
   ```bash
   flutter pub get
   ```
2. Créer le fichier `.env` à partir du modèle :
   ```bash
   cp .env.example .env
   ```
   puis renseigner `SUPABASE_URL` et `SUPABASE_ANON_KEY`.
   > Le fichier `.env` est ignoré par Git (aucun secret n'est commité).
3. Lancer l'application :
   ```bash
   flutter run
   ```

## Qualité

```bash
flutter analyze   # analyse statique
flutter test      # tests unitaires (à venir — étape 4)
```

## Sécurité (aperçu)

- Secrets hors du code source (`.env` non commité) — OWASP A05.
- Validation systématique des entrées utilisateur — OWASP A03.
- Messages d'erreur génériques côté UI (pas de fuite technique).
- L'autorisation d'accès aux données sera assurée par les politiques RLS Supabase (étape 5).
