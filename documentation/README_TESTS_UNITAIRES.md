# Tests unitaires de STYMA

Ce document décrit la suite de tests automatisés du projet STYMA, son
organisation, les comportements vérifiés et la manière de l'exécuter.

## Objectif

Les tests unitaires vérifient les règles métier de l'application sans dépendre
d'une connexion réseau ou d'une base Supabase réelle. Ils permettent notamment
de détecter rapidement une régression dans :

- la validation des formulaires ;
- la conversion des données provenant de Supabase ;
- les états de chargement des écrans ;
- la gestion des erreurs ;
- les likes et commentaires ;
- la sélection des contenus affichés sur l'accueil ;
- quelques composants visuels réutilisables.

La suite contient actuellement **84 tests**. Chaque test possède un commentaire
dans son fichier source expliquant précisément le comportement qu'il vérifie.

## Exécuter les tests

Depuis le dossier `styma` :

```powershell
flutter test
```

Pour afficher le détail de chaque scénario :

```powershell
flutter test --reporter expanded
```

Pour générer le rapport de couverture :

```powershell
flutter test --coverage
```

Le rapport brut est créé dans `coverage/lcov.info`. Lors de la dernière
exécution documentée, les tests couvraient **69,6 % des lignes chargées**.

Avant de valider une modification, il est également recommandé d'exécuter :

```powershell
flutter analyze
flutter test
```

## Organisation

```text
test/
├── helpers/
│   └── fakes.dart
├── admin_test.dart
├── models_test.dart
├── validators_test.dart
├── viewmodels_test.dart
└── widgets_and_theme_test.dart
```

### `helpers/fakes.dart`

Ce fichier contient des doublures contrôlables des sources de données :

- `FakeContentDataSource` simule les artistes, morceaux, événements, produits
  et liens sociaux ;
- `FakeAuthDataSource` simule l'inscription, la connexion, la déconnexion et la
  suppression d'un compte ;
- `FakeMusicDataSource` simule les morceaux, likes et commentaires ;
- `FakeAdminDataSource` simule les lectures et écritures de l'espace
  administrateur et mémorise les données envoyées par les formulaires.

Ces objets permettent de provoquer volontairement une réussite ou une erreur
sans effectuer d'appel à Supabase. Ils mémorisent également les paramètres
reçus pour vérifier que les ViewModels transmettent les bonnes informations.

## Validation des formulaires

Fichier concerné : `test/validators_test.dart`.

### Adresse e-mail

Les tests vérifient :

- le refus d'une valeur vide ou `null` ;
- le refus d'une adresse sans arobase ou sans domaine valide ;
- l'acceptation d'une adresse correctement formée ;
- la tolérance des espaces ajoutés avant ou après l'adresse.

### Mot de passe

Les tests vérifient :

- que le mot de passe est obligatoire ;
- la longueur minimale de huit caractères ;
- la présence obligatoire d'au moins une lettre ;
- la présence obligatoire d'au moins un chiffre ;
- l'acceptation d'un mot de passe réunissant toutes les conditions.

### Confirmation du mot de passe

Les tests vérifient :

- que la confirmation est obligatoire ;
- qu'une confirmation différente est refusée ;
- que deux mots de passe identiques sont acceptés.

### Pseudonyme

Les tests vérifient :

- le refus des valeurs vides, nulles ou composées uniquement d'espaces ;
- la longueur minimale de deux caractères ;
- la longueur maximale de vingt caractères ;
- l'acceptation exacte des deux valeurs limites : 2 et 20 caractères.

## Modèles de données

Fichier concerné : `test/models_test.dart`.

### Artiste

Les tests vérifient la conversion du nom, de la biographie et de l'URL de la
photo, ainsi que le cas où aucune photo n'est enregistrée.

### Morceau

Les tests vérifient :

- la conversion de toutes les colonnes principales ;
- la transformation de 213 secondes en `3:33` ;
- l'affichage d'une durée vide lorsqu'elle est inconnue ;
- la méthode `copyWith` utilisée pour mettre à jour les likes et commentaires
  sans perdre le titre, l'album ou les autres informations du morceau.

### Événement

Les tests vérifient :

- la conversion des coordonnées entières ou décimales en `double` ;
- la détection d'un événement possédant ses deux coordonnées ;
- le refus d'une localisation incomplète ;
- le format français de la date et de l'heure, avec les zéros nécessaires.

### Produit

Les tests vérifient :

- la conversion des nombres PostgreSQL en `double` ;
- l'affichage d'un prix entier, par exemple `25 €` ;
- l'affichage d'un prix décimal avec une virgule, par exemple `24,90 €`.

### Lien social

Les tests vérifient :

- la conversion d'une couleur hexadécimale valide ;
- l'utilisation automatique du bleu STYMA lorsqu'une couleur est invalide.

### Profil utilisateur

Les tests vérifient :

- la conversion d'une ligne de base de données en objet Dart ;
- la conversion inverse avec `toMap` ;
- l'utilisation d'une chaîne vide lorsqu'un e-mail est absent.

### Commentaire musical

Le test vérifie la conversion de tous les champs d'un commentaire et la
transformation de la date UTC en date locale.

## ViewModels

Fichier concerné : `test/viewmodels_test.dart`.

### Authentification

Les tests vérifient :

- la connexion et la transmission de l'e-mail et du mot de passe ;
- l'inscription avec le pseudonyme ;
- le retour à l'état `idle` après une réussite ;
- le passage par l'état `loading` et les notifications envoyées à l'interface ;
- l'affichage du message précis fourni par une `AuthException` ;
- le remplacement d'une erreur technique inconnue par un message générique ;
- la transmission de la demande de déconnexion au repository.

### Artiste

Les tests vérifient le chargement réussi de la biographie et le message affiché
en cas d'échec.

### Événements

Les tests vérifient la conservation de la liste chargée et le passage à l'état
d'erreur lorsque la source de données échoue.

### Boutique

Les tests vérifient :

- qu'une boutique vide constitue un chargement réussi ;
- la conservation des produits reçus ;
- le message spécifique affiché lors d'une erreur.

### Accueil

Les tests vérifient :

- la sélection des trois morceaux les plus récents ;
- leur ordre, du plus récent au plus ancien ;
- la sélection du premier événement à venir ;
- le cas où aucun événement n'existe ;
- l'état d'erreur si une des sources d'actualités échoue.

### Réseaux sociaux

Les tests vérifient :

- le chargement combiné de la photo de l'artiste et de ses liens ;
- l'utilisation de l'image de repli lorsque l'URL est vide ;
- le message affiché si le chargement échoue.

### Musique, likes et commentaires

Les tests vérifient :

- le chargement réussi et échoué des morceaux ;
- l'ajout optimiste d'un like et l'incrémentation du compteur ;
- le retrait d'un like ;
- l'impossibilité d'obtenir un compteur négatif ;
- l'annulation de la modification visuelle si Supabase refuse le like ;
- le refus propre d'une interaction sur un morceau devenu absent ;
- le chargement des commentaires du morceau demandé uniquement ;
- la transmission du contenu et du pseudonyme lors d'un commentaire ;
- l'incrémentation du nombre de commentaires après une réussite ;
- le retour de `null` et la conservation du compteur après un échec.

## Composants visuels et couleurs

Fichier concerné : `test/widgets_and_theme_test.dart`.

Les tests vérifient :

- les principales couleurs de la palette STYMA ;
- l'ordre et l'orientation du dégradé néon ;
- l'affichage du composant `ErrorState` ;
- la présence de son message et de son icône ;
- l'appel exact de l'action lorsque l'utilisateur touche `Réessayer`.

Les widgets qui utilisent `google_fonts` ne sont pas instanciés dans cette suite
hors ligne, car la bibliothèque tente de télécharger les polices pendant un
test Flutter. Leur rendu complet relève plutôt des tests de widgets avec les
polices intégrées localement au projet.

## Administration

Fichier concerné : `test/admin_test.dart`.

### Navigation et chargement

Les tests vérifient :

- la présence des menus Musiques, Événements et Merch ;
- l'adaptation du bouton d'ajout à l'onglet sélectionné ;
- l'affichage des contenus existants, des listes vides et des erreurs ;
- la présence des actions de modification et de suppression.

### Musiques

Les tests vérifient :

- la création avec titre, album, durée et URL de pochette ;
- la conversion de la durée en entier ;
- le refus d'un titre vide ou d'une durée non numérique ;
- la modification en conservant l'identifiant ;
- l'affichage d'une erreur lorsque l'écriture distante échoue ;
- le rafraîchissement des écrans publics après une modification.

### Événements

Les tests vérifient :

- la création complète avec les sélecteurs de date et d'heure ;
- l'obligation de choisir une date ;
- le préremplissage et la modification d'un événement existant ;
- la conservation et la conversion des coordonnées géographiques ;
- le refus de coordonnées non numériques ;
- la conservation de l'identifiant pendant une modification.

### Merchandising

Les tests vérifient :

- la création avec nom, catégorie, prix, image et description ;
- l'acceptation d'un prix utilisant une virgule française ;
- la conversion du prix en `double` ;
- le refus d'un prix non numérique ;
- la modification en conservant l'identifiant du produit.

### Suppressions

Les tests vérifient :

- l'ouverture de la confirmation avant suppression ;
- l'annulation sans appel au repository ;
- la suppression confirmée d'une musique, d'un événement et d'un produit ;
- la transmission du bon identifiant pour chaque type de contenu ;
- la notification de changement après une suppression réussie.

Ces tests ont aussi révélé que les onglets invisibles relançaient auparavant
leurs requêtes à chaque reconstruction. Chaque onglet charge désormais ses
données paresseusement et mémorise son `Future`, évitant les appels répétés et
les erreurs asynchrones non interceptées.

## Correction détectée grâce aux tests

La création de la suite a révélé un risque dans `MusicViewModel` : une carte
ancienne pouvait tenter de liker un morceau qui n'était plus dans la liste et
utiliser un index invalide. Les tests ont conduit à ajouter deux protections :

- une interaction sur un morceau absent est maintenant refusée proprement ;
- le compteur de likes ne peut plus devenir négatif.

## Limites des tests unitaires

Les tests unitaires ne prouvent pas le bon fonctionnement de services externes.
Les éléments suivants demandent des tests d'intégration séparés :

- la connexion réelle à Supabase ;
- l'application des politiques RLS utilisateur et administrateur ;
- les triggers SQL de création des rôles ;
- les opérations CRUD réelles de l'espace administrateur ;
- la suppression distante d'un compte ;
- le chargement d'images et de polices par le réseau ;
- l'ouverture des URL externes ;
- l'affichage réel de la carte OpenStreetMap ;
- le comportement complet des formulaires sur Android, iOS et Web.

Une stratégie complète peut donc être organisée en trois niveaux :

1. **Tests unitaires** : règles métier, modèles et ViewModels, déjà présents.
2. **Tests de widgets** : formulaires et navigation dans un environnement Flutter.
3. **Tests d'intégration** : application connectée à une instance Supabase de test.

## Ajouter un nouveau test

Lorsqu'une fonctionnalité est ajoutée :

1. créer ou compléter le fichier correspondant dans `test/` ;
2. tester au minimum le chemin de réussite, le chemin d'erreur et les limites ;
3. utiliser les doublures de `test/helpers/fakes.dart` pour éviter le réseau ;
4. ajouter au-dessus des assertions un commentaire expliquant l'objectif ;
5. exécuter `flutter analyze` puis `flutter test` ;
6. ne jamais utiliser une base Supabase de production dans un test automatisé.
