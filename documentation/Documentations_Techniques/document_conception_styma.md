# Document de conception — STYMA

| | |
|---|---|
| **Projet** | STYMA — Application mobile |
| **Document** | Document de conception (architecture logicielle) |
| **Compétence visée** | C2.2.1 |
| **Auteur** | Melvin TOMEZAK |
| **Version** | 1.0 |
| **Date** | 21/07/2026 |

---

## 1. Objet du document

Ce document décrit l'architecture logicielle de l'application STYMA : les choix
technologiques, l'organisation en couches, le modèle de données, les mesures de
sécurité, la gestion de l'état et la stratégie de tests. Il justifie les
décisions de conception au regard des besoins du projet.

## 2. Contexte et périmètre fonctionnel

STYMA est une application mobile destinée à l'artiste musical du même nom. Elle
permet au public de suivre l'artiste (biographie, musique, événements, réseaux,
boutique), d'interagir avec les morceaux (likes, commentaires) et, à terme, de
participer au concert via un bracelet connecté (vote pour le prochain morceau).
Un espace d'administration permet à l'artiste de gérer son contenu.

**Fonctionnalités principales (user stories) :**

- En tant que visiteur, je peux créer un compte (avec pseudonyme) et me connecter.
- En tant qu'utilisateur, je consulte la biographie, la musique, les événements, les réseaux et la boutique.
- En tant qu'utilisateur, je peux liker et commenter les morceaux.
- En tant qu'utilisateur, je visualise les événements sur une carte.
- En tant qu'utilisateur, je gère mon profil (pseudonyme, suppression de compte).
- En tant qu'administrateur, je crée, modifie et supprime musiques, événements et produits.

## 3. Choix technologiques

| Besoin | Technologie | Justification |
|---|---|---|
| Application multiplateforme | **Flutter (Dart)** | Un seul code pour Android, iOS et web ; interface déclarative et réactive |
| Backend, authentification, base de données | **Supabase** | Solution BaaS complète : PostgreSQL managé, Auth, sécurité par Row Level Security, temps réel |
| Base de données | **PostgreSQL** | Relationnel, robuste, politiques de sécurité au niveau des lignes |
| Gestion d'état | **Provider** (`ChangeNotifier`) | Léger, adapté au pattern MVVM |
| Cartographie | **flutter_map + OpenStreetMap** | Gratuit, sans clé d'API |
| Variables d'environnement | **flutter_dotenv** | Secrets hors du code source |
| Icônes de marque / liens | **font_awesome_flutter**, **url_launcher** | Réseaux sociaux |
| Typographie | **google_fonts** | Identité visuelle (Unbounded, Chakra Petch, Inter) |

## 4. Paradigmes de programmation

L'application repose sur plusieurs paradigmes complémentaires :

- **Programmation orientée objet** : modèles, ViewModels et repositories sont des classes aux responsabilités isolées.
- **Programmation déclarative et réactive** : l'interface Flutter décrit un état ; elle se reconstruit automatiquement lorsque l'état change (`ChangeNotifier` / `notifyListeners`).
- **Architecture en couches (MVVM)** : séparation stricte interface / logique / données.
- **Injection de dépendances** : chaque repository est défini par une interface abstraite et injecté dans le ViewModel, ce qui permet de le remplacer par une implémentation factice en test.
- **Immutabilité** : les modèles exposent des copies modifiées (`copyWith`) plutôt que des mutations en place.

## 5. Architecture logicielle (MVVM)

L'application suit le patron **MVVM** (Model – View – ViewModel), organisé en
trois couches :

```
┌─────────────────────────────────────────────┐
│                    VIEW                       │  Écrans Flutter (Widgets)
│   Affiche l'état, capte les interactions      │
└───────────────┬───────────────────────────────┘
                │ écoute (Provider)      ▲
                ▼                        │ notifyListeners()
┌─────────────────────────────────────────────┐
│                 VIEWMODEL                     │  ChangeNotifier
│   État de l'écran + logique de présentation   │
└───────────────┬───────────────────────────────┘
                │ appelle (interface)    ▲
                ▼                        │ données / erreurs
┌─────────────────────────────────────────────┐
│               REPOSITORY                      │  Accès aux données
│   Seul point qui connaît Supabase             │
└───────────────┬───────────────────────────────┘
                ▼
        ┌───────────────┐
        │   SUPABASE    │  PostgreSQL + Auth + RLS
        └───────────────┘
```

**Rôle de chaque couche :**

- **View** : les écrans (widgets). Ils affichent l'état exposé par le ViewModel et transmettent les actions de l'utilisateur. Ils ne contiennent aucune logique métier.
- **ViewModel** : une classe `ChangeNotifier` par écran. Elle détient l'état (données, statut de chargement, message d'erreur) et la logique de présentation, et notifie la View à chaque changement. Elle ne dépend ni de Flutter (UI) ni directement de Supabase.
- **Repository** : la seule couche qui connaît Supabase. Chaque repository implémente une **interface abstraite** (ex. `MusicDataSource`, `AdminDataSource`, `AuthDataSource`), ce qui isole l'accès aux données et permet l'injection d'une implémentation factice pour les tests.

Cette séparation rend le code **testable** (les ViewModels se testent sans réseau
ni interface), **maintenable** (un changement de backend n'impacte que la couche
Repository) et **lisible**.

## 6. Structure du projet

```
lib/
├── main.dart                     # Point d'entrée + aiguillage selon la session
├── core/
│   ├── config/                   # Initialisation Supabase (clés via .env)
│   ├── theme/                    # Thème et couleurs (identité néon)
│   └── utils/                    # Validateurs, LoadStatus
├── data/
│   ├── models/                   # Artist, Track, ConcertEvent, Product,
│   │                             #   SocialLink, TrackComment, UserProfile
│   └── repositories/             # Auth, Content, Music, Admin
│                                 #   (interface + implémentation Supabase)
└── ui/
    ├── common/                   # Widgets réutilisables (NeonText, navbar…)
    ├── auth/                     # Connexion / inscription
    ├── home/                     # Accueil (actualités)
    ├── artist/                   # Biographie
    ├── music/                    # Musique (likes, commentaires)
    ├── events/                   # Événements (liste + carte)
    ├── vote/                     # Vote (à venir)
    ├── linktree/                 # Réseaux
    ├── shop/                     # Boutique
    ├── profile/                  # Profil & paramètres
    ├── admin/                    # Espace d'administration
    └── main/                     # Coquille de navigation

supabase/                         # Scripts SQL (schéma, sécurité, rôles)
test/                             # Tests unitaires et tests de widgets
.github/workflows/                # Intégration et déploiement continus
```

## 7. Modèle de données

Les données sont stockées dans PostgreSQL (Supabase). Principales tables :

| Table | Rôle | Points clés |
|---|---|---|
| `artist` | Biographie de l'artiste | Une seule ligne |
| `tracks` | Morceaux | Titre, album, durée, pochette |
| `events` | Concerts | Lieu, ville, date, coordonnées (carte) |
| `products` | Boutique (merch) | Nom, catégorie, prix, image |
| `social_links` | Réseaux (Linktree) | Libellé, URL, icône, couleur, ordre |
| `track_likes` | Likes de morceaux | Clé (track_id, user_id) : un like par utilisateur |
| `track_comments` | Commentaires | Rattachés à un morceau et à un utilisateur |
| `votes` | Vote prochain morceau | Un vote actif par utilisateur |
| `emergencies` | Bouton d'urgence | Journalisation des alertes |
| `user_roles` | Rôle (user / admin) | Attribué automatiquement à l'inscription |

Les tables d'interactions (`track_likes`, `track_comments`, `votes`,
`emergencies`, `user_roles`) référencent `auth.users` avec suppression en
cascade : les données d'un utilisateur supprimé disparaissent automatiquement.

## 8. Sécurité

La sécurité est traitée dès la conception, en cohérence avec les risques du
Top 10 de l'OWASP.

**Contrôle d'accès — Row Level Security (OWASP A01).**
Chaque table est protégée par RLS : par défaut tout accès est refusé, puis
ouvert explicitement au strict nécessaire.

- Contenus publics (`artist`, `tracks`, `events`, `products`, `social_links`) : lecture réservée aux utilisateurs authentifiés.
- Interactions (`track_likes`, `track_comments`) : lecture ouverte pour l'affichage des compteurs, mais un utilisateur ne peut créer ou supprimer que **ses propres** likes et commentaires (`auth.uid() = user_id`).
- Écritures d'administration (`tracks`, `events`, `products`) : autorisées uniquement si l'utilisateur est administrateur, via la fonction `is_admin()`.

**Gestion des rôles.**
Le rôle est stocké en base dans `user_roles` et **ne peut pas être modifié par
l'utilisateur**. Un déclencheur attribue le rôle « user » à chaque inscription.
La fonction `is_admin()` (SQL, `security definer`) est utilisée par les
politiques RLS pour autoriser les écritures d'administration sans exposer de
route privilégiée côté client. L'onglet d'administration n'apparaît dans
l'interface que si `isAdmin()` renvoie vrai — mais c'est bien la **base** qui
fait autorité, pas l'interface.

**Suppression de compte.**
Réalisée par une fonction `delete_account()` (`security definer`) qui ne permet à
l'utilisateur de supprimer que son propre compte.

**Validation des entrées (OWASP A03).**
Les saisies utilisateur (e-mail, mot de passe, pseudonyme, formulaires
d'administration) sont validées par des fonctions dédiées avant tout envoi.

**Gestion des secrets (OWASP A05).**
Les identifiants Supabase sont chargés depuis un fichier `.env` non versionné.
En intégration/déploiement continus, ils sont fournis via les secrets GitHub.

**Messages d'erreur.**
Les erreurs techniques ne sont pas exposées : l'interface affiche un message
générique, évitant toute fuite d'information.

## 9. Gestion de l'état

L'état est géré avec **Provider** et le patron `ChangeNotifier`. Un enum
`LoadStatus` (idle, loading, success, error) permet à chaque écran d'afficher un
indicateur de chargement, le contenu ou un état d'erreur avec réessai.

Pour les interactions sociales (likes, commentaires), l'application applique une
**mise à jour optimiste** : l'interface est mise à jour immédiatement pour un
ressenti fluide, puis, en cas d'échec de l'écriture distante, l'état précédent
est restauré (annulation). Le compteur de likes est protégé pour ne jamais
devenir négatif.

## 10. Conception de quelques fonctionnalités clés

**Authentification.** L'écran d'entrée aiguille l'utilisateur vers l'application
ou l'écran de connexion selon l'état de la session Supabase, écouté en temps
réel. Le pseudonyme est enregistré dans les métadonnées du compte.

**Musique (likes / commentaires).** Le `MusicRepository` agrège les morceaux avec
leurs compteurs de likes et de commentaires. Le `MusicViewModel` gère les
interactions avec mise à jour optimiste et annulation en cas d'erreur.

**Événements.** Affichage en liste ou sur une carte OpenStreetMap ; les
événements disposant de coordonnées sont matérialisés par des marqueurs
cliquables.

**Administration.** Tableau de bord à trois catégories (musiques, événements,
merch). Chaque catégorie propose la création, la modification et la suppression
via des formulaires validés, avec confirmation de suppression. Les écritures ne
sont possibles que pour un compte administrateur (contrôle côté base par RLS).

## 11. Stratégie de tests

L'application est testée à **deux niveaux complémentaires** :

- **Tests automatisés** (dossier `test/`) : tests unitaires des modèles et des ViewModels, et tests de widgets de l'espace d'administration. Grâce aux interfaces de repository, les ViewModels sont testés avec des implémentations **factices** (fakes), sans réseau ni base réelle. Ils couvrent notamment le mapping des données, la logique de chargement, la mise à jour optimiste des likes et la validation des formulaires d'administration. Ces tests sont exécutés automatiquement à chaque push par l'intégration continue.
- **Recette fonctionnelle** (voir *Cahier de recettes*) : scénarios exécutés manuellement pour valider les parcours utilisateur de bout en bout.

Cette double approche assure à la fois la justesse du code unité par unité et la
conformité de l'application dans son ensemble.

## 12. Intégration et déploiement continus

Un pipeline **GitHub Actions** assure la qualité à chaque `push` :

- **Intégration continue** : analyse statique (`flutter analyze`) puis exécution des tests (`flutter test`).
- **Déploiement continu** : construction de la version web et publication automatique sur GitHub Pages, permettant de disposer en permanence d'une version en ligne à jour.

## 13. Perspectives

La fonctionnalité de **vote** pour le prochain morceau et l'intégration du
**bracelet connecté** (BLE) constituent la prochaine évolution. L'architecture en
couches et les tables déjà prévues (`votes`, `emergencies`) permettront de les
intégrer sans remettre en cause la conception existante.

---

*Document établi à la version 1.0 du prototype. Il évoluera avec le projet,
notamment lors de l'ajout du vote et du bracelet connecté.*
