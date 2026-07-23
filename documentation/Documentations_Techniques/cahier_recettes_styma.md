# Cahier de recettes — STYMA

| | |
|---|---|
| **Projet** | STYMA — Application mobile |
| **Document** | Cahier de recettes (tests fonctionnels) |
| **Compétence visée** | C2.3.1 |
| **Auteur** | Melvin TOMEZAK |
| **Version** | 1.1 |
| **Date** | 21/07/2026 |

---

## 1. Objet du document

Ce cahier de recettes décrit les scénarios de tests fonctionnels permettant de
vérifier que l'application STYMA répond aux exigences attendues. Chaque scénario
précise les préconditions, les étapes, le résultat attendu, le résultat obtenu
et un statut. Il constitue la preuve de la conformité fonctionnelle de
l'application.

Ces tests fonctionnels (recette manuelle) sont **complétés par un jeu de tests
automatisés** (tests unitaires et tests de widgets) couvrant les modèles, les
ViewModels et l'espace d'administration ; ces derniers sont exécutés à chaque
push par l'intégration continue.

## 2. Périmètre

Le présent cahier couvre les fonctionnalités livrées : authentification,
navigation, accueil, biographie, musique (avec likes et commentaires),
événements (liste et carte), réseaux, boutique, profil, gestion du compte et
espace d'administration.

La fonctionnalité de **vote** (et l'interaction avec le bracelet connecté) est
en cours de développement : seul l'écran d'information est présent et testé
comme tel.

## 3. Environnement de test

| Élément | Valeur |
|---|---|
| Plateforme | Application web (Flutter) |
| Navigateur | Google Chrome (dernière version) |
| Backend | Supabase (PostgreSQL, Auth) |
| Connexion | Internet requise |
| Environnement | Développement (confirmation e-mail désactivée) |

## 4. Jeu de données

- Un compte **standard** de test (e-mail + mot de passe + pseudonyme).
- Un compte **administrateur** de test.
- Un compte **jetable** pour tester la suppression de compte.
- Les données de démonstration en base (artiste, morceaux, événements, liens
  sociaux, produits).

## 5. Légende des statuts

| Statut | Signification |
|---|---|
| OK | Conforme au résultat attendu |
| KO | Non conforme (anomalie à corriger) |
| N/T | Non testé |
| Info | Fonctionnalité partielle / à venir |

---

## 6. Scénarios de test

### 6.1 Authentification

#### CR-AUTH-01 — Inscription avec des données valides
- **Préconditions** : utilisateur non connecté, sur l'écran d'inscription.
- **Étapes** : 1) Saisir un pseudonyme valide. 2) Un e-mail valide. 3) Un mot de passe valide (≥ 8 caractères, une lettre, un chiffre). 4) Confirmer. 5) Valider.
- **Résultat attendu** : le compte est créé, l'utilisateur accède à l'application.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-AUTH-02 — Inscription avec un e-mail invalide
- **Préconditions** : sur l'écran d'inscription.
- **Étapes** : 1) Saisir un e-mail mal formé. 2) Valider.
- **Résultat attendu** : message d'erreur, compte non créé.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-AUTH-03 — Mot de passe trop faible
- **Préconditions** : sur l'écran d'inscription.
- **Étapes** : 1) Saisir un mot de passe < 8 caractères ou sans chiffre. 2) Valider.
- **Résultat attendu** : message précisant la règle non respectée, compte non créé.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-AUTH-04 — Confirmation différente
- **Préconditions** : sur l'écran d'inscription.
- **Étapes** : 1) Saisir un mot de passe. 2) Une confirmation différente. 3) Valider.
- **Résultat attendu** : message « les mots de passe ne correspondent pas ».
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-AUTH-05 — Pseudonyme manquant ou invalide
- **Préconditions** : sur l'écran d'inscription.
- **Étapes** : 1) Laisser le pseudonyme vide (ou < 2 / > 20 caractères). 2) Valider.
- **Résultat attendu** : message indiquant que le pseudonyme est requis / invalide.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-AUTH-06 — Connexion avec identifiants valides
- **Préconditions** : compte existant, déconnecté.
- **Étapes** : 1) Saisir e-mail et mot de passe. 2) Valider.
- **Résultat attendu** : accès à l'application.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-AUTH-07 — Connexion avec mauvais mot de passe
- **Préconditions** : compte existant.
- **Étapes** : 1) Saisir un mot de passe erroné. 2) Valider.
- **Résultat attendu** : message générique, accès refusé.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-AUTH-08 — Déconnexion
- **Préconditions** : utilisateur connecté.
- **Étapes** : 1) Ouvrir le Profil. 2) « Se déconnecter ».
- **Résultat attendu** : retour à l'écran de connexion.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

### 6.2 Navigation

#### CR-NAV-01 — Navigation entre les onglets
- **Préconditions** : utilisateur connecté.
- **Étapes** : 1) Cliquer sur chaque onglet.
- **Résultat attendu** : l'écran correspondant s'affiche, l'onglet actif est mis en évidence.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-NAV-02 — Retour à l'accueil via le logo
- **Préconditions** : être sur un autre onglet.
- **Étapes** : 1) Cliquer sur le logo « STYMA ».
- **Résultat attendu** : l'accueil s'affiche.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-NAV-03 — Accès au profil
- **Préconditions** : connecté.
- **Étapes** : 1) Cliquer sur l'avatar en haut à droite.
- **Résultat attendu** : l'écran Profil s'ouvre.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-NAV-04 — Fermeture d'un écran
- **Préconditions** : être sur Biographie ou Profil.
- **Étapes** : 1) Cliquer sur la croix de fermeture.
- **Résultat attendu** : retour à l'écran précédent.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

### 6.3 Accueil

#### CR-HOME-01 — Salutation personnalisée
- **Préconditions** : connecté avec un pseudonyme.
- **Étapes** : 1) Ouvrir l'Accueil.
- **Résultat attendu** : le pseudonyme s'affiche en titre.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-HOME-02 — Affichage des actualités
- **Préconditions** : données présentes.
- **Étapes** : 1) Ouvrir l'Accueil.
- **Résultat attendu** : prochain concert et derniers sons affichés.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-HOME-03 — Raccourci Biographie
- **Préconditions** : sur l'accueil.
- **Étapes** : 1) Cliquer sur « Biographie ».
- **Résultat attendu** : la Biographie s'ouvre.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

### 6.4 Biographie

#### CR-BIO-01 — Affichage de la biographie
- **Préconditions** : connecté.
- **Étapes** : 1) Ouvrir la Biographie.
- **Résultat attendu** : nom, tags et texte détaillé affichés.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

### 6.5 Musique (liste, likes, commentaires)

#### CR-MUS-01 — Affichage des morceaux
- **Préconditions** : données présentes.
- **Étapes** : 1) Ouvrir l'onglet Musique.
- **Résultat attendu** : la liste s'affiche avec titre, album et durée.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-MUS-02 — Liker un morceau
- **Préconditions** : connecté, sur la Musique.
- **Étapes** : 1) Cliquer sur le cœur d'un morceau.
- **Résultat attendu** : le cœur se remplit, le compteur de likes augmente de 1.
- **Résultat obtenu** : Conforme (mise à jour immédiate).
- **Statut** : OK

#### CR-MUS-03 — Retirer un like
- **Préconditions** : morceau déjà liké.
- **Étapes** : 1) Cliquer de nouveau sur le cœur.
- **Résultat attendu** : le cœur se vide, le compteur diminue (jamais négatif).
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-MUS-04 — Ajouter un commentaire
- **Préconditions** : connecté, sur un morceau.
- **Étapes** : 1) Ouvrir les commentaires. 2) Saisir un texte. 3) Envoyer.
- **Résultat attendu** : le commentaire apparaît avec le pseudonyme, le compteur augmente.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-MUS-05 — Consulter les commentaires
- **Préconditions** : un morceau avec commentaires.
- **Étapes** : 1) Ouvrir les commentaires du morceau.
- **Résultat attendu** : seuls les commentaires de ce morceau s'affichent, du plus récent au plus ancien.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

### 6.6 Événements

#### CR-EVT-01 — Affichage de la liste
- **Préconditions** : données présentes.
- **Étapes** : 1) Ouvrir l'onglet Événement (vue Liste).
- **Résultat attendu** : concerts affichés avec titre, lieu, ville et date.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-EVT-02 — Bascule vers la carte
- **Préconditions** : sur l'onglet Événement.
- **Étapes** : 1) Cliquer sur « Carte ».
- **Résultat attendu** : carte avec un marqueur par événement localisé.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-EVT-03 — Détail d'un événement sur la carte
- **Préconditions** : vue Carte affichée.
- **Étapes** : 1) Cliquer sur un marqueur.
- **Résultat attendu** : fiche avec titre, lieu et date.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

### 6.7 Vote

#### CR-VOTE-01 — Écran de vote
- **Préconditions** : connecté.
- **Étapes** : 1) Ouvrir l'onglet Vote.
- **Résultat attendu** : écran présentant la fonctionnalité à venir.
- **Résultat obtenu** : Écran d'information affiché (fonctionnalité en cours de développement).
- **Statut** : Info

### 6.8 Réseaux

#### CR-RES-01 — Affichage des réseaux
- **Préconditions** : données présentes.
- **Étapes** : 1) Ouvrir l'onglet Réseaux.
- **Résultat attendu** : photo/logo et liste des réseaux affichés.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-RES-02 — Ouverture d'un lien
- **Préconditions** : sur les Réseaux.
- **Étapes** : 1) Cliquer sur un réseau.
- **Résultat attendu** : le lien s'ouvre dans un nouvel onglet / l'app externe.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

### 6.9 Boutique

#### CR-SHOP-01 — Affichage du catalogue
- **Préconditions** : données présentes.
- **Étapes** : 1) Ouvrir l'onglet Boutique.
- **Résultat attendu** : produits en grille avec nom, catégorie et prix.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-SHOP-02 — Fiche produit
- **Préconditions** : sur la Boutique.
- **Étapes** : 1) Cliquer sur un produit.
- **Résultat attendu** : fiche détaillée (image, prix, description).
- **Résultat obtenu** : Conforme.
- **Statut** : OK

### 6.10 Profil et gestion du compte

#### CR-PROF-01 — Modification du pseudonyme
- **Préconditions** : connecté, sur le Profil.
- **Étapes** : 1) Ouvrir « Pseudonyme ». 2) Saisir un nouveau nom. 3) Enregistrer.
- **Résultat attendu** : le pseudonyme est mis à jour (profil et accueil).
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-PROF-02 — Interrupteur de notifications
- **Préconditions** : sur le Profil.
- **Étapes** : 1) Basculer l'interrupteur « Notifications ».
- **Résultat attendu** : l'état de l'interrupteur change.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-PROF-03 — À propos
- **Préconditions** : sur le Profil.
- **Étapes** : 1) Cliquer sur « À propos ».
- **Résultat attendu** : fiche de l'application (nom, version).
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-PROF-04 — Suppression du compte
- **Préconditions** : compte jetable connecté.
- **Étapes** : 1) Profil. 2) « Supprimer mon compte ». 3) Confirmer.
- **Résultat attendu** : compte et données liées supprimés, retour à la connexion, reconnexion impossible.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

### 6.11 Sécurité et robustesse

#### CR-SEC-01 — Message d'erreur sans fuite d'information
- **Préconditions** : sur la connexion.
- **Étapes** : 1) Connexion avec identifiants incorrects.
- **Résultat attendu** : message générique, sans détail technique.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-SEC-02 — Cloisonnement des données (RLS)
- **Préconditions** : deux comptes distincts.
- **Étapes** : 1) Créer une donnée personnelle avec le compte A. 2) Se connecter avec le compte B.
- **Résultat attendu** : le compte B ne peut ni voir ni modifier les données privées de A.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-SEC-03 — Accès administrateur restreint
- **Préconditions** : un compte standard et un compte administrateur.
- **Étapes** : 1) Se connecter en standard : vérifier l'absence de l'onglet Administration. 2) Se connecter en administrateur : vérifier sa présence.
- **Résultat attendu** : l'espace d'administration n'est visible que pour un compte administrateur.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

### 6.12 Administration (compte administrateur)

#### CR-ADM-01 — Affichage des trois catégories
- **Préconditions** : connecté en administrateur, onglet Administration.
- **Étapes** : 1) Observer les onglets de gestion.
- **Résultat attendu** : Musiques, Événements et Merch sont disponibles.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-ADM-02 — Ajouter une musique
- **Préconditions** : onglet Musiques de l'admin.
- **Étapes** : 1) « Ajouter une musique ». 2) Renseigner titre, album, durée, image. 3) Enregistrer.
- **Résultat attendu** : la musique est créée et apparaît dans la liste.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-ADM-03 — Validation du formulaire musique
- **Préconditions** : formulaire d'ajout de musique ouvert.
- **Étapes** : 1) Laisser le titre vide, ou saisir une durée non numérique. 2) Enregistrer.
- **Résultat attendu** : un message de validation bloque l'enregistrement.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-ADM-04 — Modifier une musique
- **Préconditions** : au moins une musique existante.
- **Étapes** : 1) Icône « modifier ». 2) Changer le titre. 3) Enregistrer.
- **Résultat attendu** : la musique est mise à jour (identifiant conservé).
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-ADM-05 — Supprimer une musique (et annulation)
- **Préconditions** : au moins une musique existante.
- **Étapes** : 1) Icône « supprimer ». 2) Tester « Annuler » (rien ne change). 3) Recommencer et « Supprimer ».
- **Résultat attendu** : « Annuler » ne modifie rien ; « Supprimer » retire la musique après confirmation.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-ADM-06 — Gérer un événement
- **Préconditions** : onglet Événements de l'admin.
- **Étapes** : 1) « Ajouter un événement ». 2) Renseigner titre, lieu, ville. 3) Tenter d'enregistrer sans date. 4) Choisir la date/heure. 5) Enregistrer. 6) Éditer puis supprimer.
- **Résultat attendu** : la date est obligatoire ; les coordonnées, si saisies, doivent être numériques ; création, édition et suppression fonctionnent.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

#### CR-ADM-07 — Gérer un produit
- **Préconditions** : onglet Merch de l'admin.
- **Étapes** : 1) « Ajouter un produit ». 2) Renseigner nom, catégorie, prix (accepter la virgule), image, description. 3) Enregistrer. 4) Éditer puis supprimer.
- **Résultat attendu** : un prix non numérique est refusé ; la virgule décimale est acceptée ; création, édition et suppression fonctionnent.
- **Résultat obtenu** : Conforme.
- **Statut** : OK

---

## 7. Synthèse des résultats

| Statut | Nombre |
|---|---|
| OK | 39 |
| KO | 0 |
| Non testé | 0 |
| Info (à venir) | 1 |
| **Total scénarios** | **40** |

Taux de conformité des fonctionnalités livrées : **100 %** (39/39 des scénarios
applicables). Le scénario CR-VOTE-01 reflète une fonctionnalité en cours de
développement.

## 8. Anomalies relevées

Aucune anomalie bloquante relevée lors de cette campagne de recette. Les
anomalies futures seront tracées et traitées selon le *Plan de correction des
bogues* (via les tickets/Issues du dépôt).

---

*Ce cahier de recettes a été exécuté sur l'environnement décrit en section 3. Il
est destiné à être rejoué avant toute livraison majeure. Les tests fonctionnels
sont complétés par les tests automatisés du dépôt (exécutés en intégration
continue).*
