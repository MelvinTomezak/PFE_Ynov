# Document de spécification — STYMA

| | |
|---|---|
| **Projet** | STYMA — Application mobile |
| **Document** | Document de spécification (fonctionnelle et technique) |
| **Auteur** | Melvin TOMEZAK |
| **Version** | 1.0 |
| **Date** | 21/07/2026 |

---

## 1. Objet du document

Ce document définit les spécifications de l'application STYMA : son contexte, son
périmètre, ses acteurs, ses exigences fonctionnelles et non fonctionnelles, ses
contraintes techniques et ses critères d'acceptation. Il sert de référence
commune tout au long du projet.

## 2. Contexte et objectifs

STYMA est un artiste de musique électronique dont l'univers scénique repose sur
l'interaction avec le public. Le projet consiste à concevoir une **application
mobile** qui prolonge cette expérience :

- **hors concert** : donner accès à la biographie, la musique, les événements, les réseaux et la boutique de l'artiste, et permettre au public d'interagir (likes, commentaires) ;
- **pendant le concert** (perspective) : permettre au public d'influencer le live via un **bracelet connecté** (vote pour le prochain morceau, bouton d'urgence).

**Objectif principal :** renforcer l'engagement de la communauté autour de
l'artiste à travers une application soignée et interactive.

## 3. Périmètre

**Inclus dans le prototype :**

- Authentification et gestion de compte.
- Consultation des contenus (biographie, musique, événements, réseaux, boutique).
- Interactions sociales sur les morceaux (likes, commentaires).
- Visualisation des événements sur une carte.
- Espace d'administration pour la gestion du contenu.

**Perspectives (hors périmètre du prototype actuel) :**

- Vote en temps réel pour le prochain morceau.
- Intégration matérielle du bracelet connecté (BLE).
- Paiement en ligne de la boutique.

## 4. Acteurs et rôles

| Acteur | Description | Droits |
|---|---|---|
| **Visiteur** | Personne non connectée | Peut créer un compte et se connecter |
| **Utilisateur** | Compte standard connecté | Consulte les contenus, like et commente, gère son profil |
| **Administrateur** | Compte disposant du rôle `admin` | Gère le contenu (musiques, événements, produits) en plus des droits utilisateur |

## 5. Exigences fonctionnelles

Priorités selon la méthode **MoSCoW** (Must / Should / Could).

### 5.1 Authentification et compte

- **[Must]** L'utilisateur peut s'inscrire avec un pseudonyme, un e-mail et un mot de passe.
- **[Must]** Les saisies sont validées (format e-mail, robustesse du mot de passe, longueur du pseudonyme).
- **[Must]** L'utilisateur peut se connecter et se déconnecter.
- **[Must]** L'utilisateur peut modifier son pseudonyme et supprimer son compte.

### 5.2 Consultation des contenus

- **[Must]** Consulter la biographie de l'artiste.
- **[Must]** Consulter la liste des morceaux.
- **[Must]** Consulter la liste des événements.
- **[Should]** Visualiser les événements sur une carte interactive.
- **[Must]** Accéder aux réseaux sociaux de l'artiste.
- **[Should]** Consulter la boutique (catalogue et fiches produits).
- **[Must]** Voir un résumé des actualités sur l'accueil (prochain concert, derniers sons).

### 5.3 Interactions sociales

- **[Must]** Liker et « déliker » un morceau.
- **[Must]** Commenter un morceau et consulter les commentaires.

### 5.4 Administration

- **[Must]** L'administrateur peut créer, modifier et supprimer des musiques, des événements et des produits, via des formulaires validés.
- **[Must]** L'espace d'administration n'est accessible qu'aux comptes administrateurs.

### 5.5 Fonctionnalités futures

- **[Could]** Voter pour le prochain morceau pendant un concert.
- **[Could]** Déclencher un bouton d'urgence.
- **[Could]** Interagir via le bracelet connecté.

## 6. Exigences non fonctionnelles

| Domaine | Exigence |
|---|---|
| **Sécurité** | Contrôle d'accès par Row Level Security ; validation des entrées ; secrets hors du code ; rôles gérés en base |
| **Accessibilité** | Prise en compte du référentiel RGAA (contrastes, sémantique, libellés) |
| **Performance** | Interface réactive, chargements asynchrones, build web optimisé |
| **Compatibilité** | Application multiplateforme (Android, iOS, web) grâce à Flutter |
| **Maintenabilité** | Architecture MVVM en couches, code testé et analysé automatiquement |
| **Disponibilité** | Version web déployée en continu et accessible en ligne |
| **Fiabilité** | Gestion des états d'erreur, tests automatisés prévenant les régressions |

## 7. Contraintes techniques

- **Application** : Flutter (Dart).
- **Backend / base de données / authentification** : Supabase (PostgreSQL, Auth, RLS).
- **Gestion de version et automatisation** : Git / GitHub, GitHub Actions (CI/CD), GitHub Pages.
- **Cartographie** : OpenStreetMap via flutter_map.

## 8. Règles de gestion

- Un utilisateur ne peut liker qu'une seule fois un morceau donné.
- Un utilisateur ne peut modifier ou supprimer que ses propres likes et commentaires.
- Le rôle (utilisateur/administrateur) est attribué en base et ne peut pas être modifié par l'utilisateur.
- La suppression d'un compte entraîne la suppression de ses données associées.
- Seul un administrateur peut modifier le contenu de l'application.

## 9. Livrables attendus

- L'application (dépôt de code versionné, version en ligne).
- Le document de conception (architecture).
- Le cahier de recettes.
- La documentation d'accessibilité (RGAA).
- La documentation technique (déploiement, utilisation, mise à jour).
- Le plan de correction des bogues.
- Les protocoles d'intégration et de déploiement continus.

## 10. Critères d'acceptation

- Les fonctionnalités **[Must]** sont opérationnelles et validées par le cahier de recettes.
- L'application se construit, se teste et se déploie automatiquement sans erreur (CI/CD au vert).
- Les mesures de sécurité (RLS, validation, secrets, rôles) sont en place.
- La démarche d'accessibilité est documentée.
- Le code est couvert par des tests automatisés qui passent à 100 %.

---

*Document établi à la version 1.0 du prototype. Il sera actualisé lors de
l'ajout des fonctionnalités de vote et du bracelet connecté.*
