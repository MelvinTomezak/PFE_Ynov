# Accessibilité — Audit RGAA — STYMA

| | |
|---|---|
| **Projet** | STYMA — Application mobile |
| **Document** | Démarche d'accessibilité et audit (référentiel RGAA) |
| **Compétence visée** | C2.2.3 |
| **Auteur** | Melvin TOMEZAK |
| **Version** | 1.0 |
| **Date** | 21/07/2026 |

---

## 1. Objet du document

Ce document présente la démarche d'accessibilité mise en œuvre dans l'application
STYMA : le référentiel retenu et sa justification, les mesures appliquées, un
audit d'auto-évaluation et un plan d'amélioration.

## 2. Choix et justification du référentiel

Le référentiel retenu est le **RGAA** (Référentiel Général d'Amélioration de
l'Accessibilité).

**Justification :**

- Il s'agit du **référentiel officiel français** en matière d'accessibilité numérique.
- Il s'appuie techniquement sur les **WCAG 2.1** (Web Content Accessibility Guidelines) du W3C, standard international reconnu.
- Ses critères sont organisés autour de quatre principes fondamentaux : contenu **perceptible**, interface **utilisable**, information **compréhensible** et contenu **robuste**.

**Transposition à une application Flutter.**
Le RGAA cible historiquement le web (DOM HTML). STYMA étant développée avec
Flutter, les critères techniques sont transposés via le mécanisme d'accessibilité
de Flutter : le widget `Semantics` (qui expose rôles, libellés, états aux
lecteurs d'écran), les libellés de formulaires, les info-bulles (`tooltip`) et
les API d'accessibilité natives d'Android, d'iOS et du web. L'évaluation ci-après
s'appuie donc sur les **critères de succès WCAG 2.1 (niveau AA)**, socle du RGAA,
appliqués aux composants Flutter.

## 3. Périmètre et méthode

- **Périmètre** : l'ensemble des écrans de l'application (authentification, accueil, biographie, musique, événements, réseaux, boutique, profil, administration).
- **Méthode** : auto-évaluation menée par le développeur, par revue du code (widgets `Semantics`, contrastes du thème, libellés, tailles de cibles) et essais manuels.
- **Limite** : cette évaluation interne ne remplace pas un audit de conformité mené par un auditeur certifié avec technologies d'assistance ; elle vise à mesurer le niveau d'accessibilité et à identifier les axes de progrès.

## 4. Statuts d'évaluation

| Statut | Signification |
|---|---|
| C | Conforme |
| PC | Partiellement conforme |
| NC | Non conforme |
| NA | Non applicable |

---

## 5. Mesures d'accessibilité mises en œuvre

- **Contraste élevé** : le thème repose sur un texte clair (blanc cassé) sur fond noir ; les couleurs ont été choisies pour respecter les ratios de contraste.
- **Couleurs jamais seules porteuses d'information** : les états (onglet actif, like) sont signalés par plusieurs indices (icône pleine/vide, contour, libellé, compteur), pas uniquement par la couleur.
- **Libellés de formulaires** : chaque champ de saisie possède un libellé explicite ; les erreurs de validation sont affichées sous le champ concerné.
- **Rôles sémantiques** : les titres, boutons et éléments de navigation sont annotés via `Semantics` (rôle en-tête, bouton, état sélectionné) et des info-bulles.
- **Cibles tactiles** : les boutons principaux respectent une hauteur d'au moins 52 px.
- **Retour d'erreur clair** : messages de validation compréhensibles, sans jargon technique.

## 6. Audit par principe (WCAG 2.1 AA, socle du RGAA)

### 6.1 Perceptible

| Critère | Exigence | Mise en œuvre STYMA | Statut |
|---|---|---|---|
| 1.1.1 Contenu non textuel | Alternative textuelle aux éléments non textuels | Icônes interactives dotées d'info-bulles / libellés `Semantics` ; icônes décoratives ignorées | PC |
| 1.3.1 Information et relations | Structure exposée programmatiquement | Titres annotés `header`, champs avec libellés | C |
| 1.4.1 Utilisation de la couleur | La couleur n'est pas le seul vecteur d'information | États signalés par icône + contour + libellé | C |
| 1.4.3 Contraste minimum | Ratio ≥ 4,5:1 (texte normal) | Texte principal blanc sur fond noir (ratio élevé) ; texte secondaire à vérifier | PC |
| 1.4.11 Contraste des éléments non textuels | Ratio ≥ 3:1 pour composants et états | Bordures néon et éléments actifs suffisamment contrastés | C |

### 6.2 Utilisable

| Critère | Exigence | Mise en œuvre STYMA | Statut |
|---|---|---|---|
| 2.1.1 Clavier | Toutes les fonctions accessibles au clavier (web) | Flutter web gère le parcours au clavier ; non audité exhaustivement | PC |
| 2.4.4 Fonction du lien (selon le contexte) | Intitulé de lien explicite | Réseaux et raccourcis explicitement libellés | C |
| 2.4.6 En-têtes et étiquettes | Intitulés descriptifs | Titres de sections et libellés de champs explicites | C |
| 2.5.5 Taille de la cible | Cibles suffisamment grandes | Boutons principaux ≥ 52 px ; certaines cibles (avatar, onglets) à agrandir | PC |
| 2.3.1 Pas plus de trois flashs | Pas de clignotement dangereux | Animations douces (≈ 180 ms), aucun clignotement | C |

### 6.3 Compréhensible

| Critère | Exigence | Mise en œuvre STYMA | Statut |
|---|---|---|---|
| 3.1.1 Langue de la page | Langue déclarée programmatiquement | Interface en français ; langue à déclarer dans `index.html` (web) | PC |
| 3.2.4 Identification cohérente | Composants identiques nommés de façon cohérente | Navigation, boutons et libellés homogènes dans toute l'application | C |
| 3.3.1 Identification des erreurs | Les erreurs de saisie sont signalées | Messages de validation sous chaque champ | C |
| 3.3.2 Étiquettes ou instructions | Champs accompagnés d'étiquettes | Tous les champs disposent d'un libellé | C |

### 6.4 Robuste

| Critère | Exigence | Mise en œuvre STYMA | Statut |
|---|---|---|---|
| 4.1.2 Nom, rôle et valeur | Composants exposant nom, rôle et état | `Semantics` sur les éléments interactifs (bouton, sélectionné, en-tête) | PC |
| 4.1.3 Messages de statut | Messages d'état perceptibles | Retours via `SnackBar` et états de chargement/erreur | PC |

## 7. Synthèse

| Statut | Nombre de critères évalués |
|---|---|
| Conforme (C) | 9 |
| Partiellement conforme (PC) | 7 |
| Non conforme (NC) | 0 |
| Non applicable (NA) | 0 |

L'application présente un **bon niveau d'accessibilité de base** : contrastes
élevés, structure sémantique, formulaires étiquetés et couleur non exclusive.
Les points partiellement conformes concernent surtout l'exhaustivité (libellés de
toutes les icônes, taille de certaines cibles, déclaration de langue, tests
lecteur d'écran).

## 8. Plan d'amélioration

Actions prioritaires identifiées pour progresser vers la conformité :

1. **Déclarer la langue** de l'application web (`<html lang="fr">` dans `index.html`) et corriger la balise `description` par défaut.
2. **Compléter les libellés** `Semantics` de toutes les icônes porteuses de sens (ex. cœur de like, actions d'administration).
3. **Vérifier et ajuster les contrastes** du texte secondaire (couleur atténuée) pour garantir le ratio 4,5:1.
4. **Agrandir certaines cibles tactiles** (avatar, onglets) à au moins 48 px.
5. **Réaliser des tests avec un lecteur d'écran** (TalkBack / VoiceOver) et au clavier sur la version web.
6. **Automatiser une partie des vérifications** (par exemple via l'outil d'accessibilité des tests Flutter).

## 9. Conclusion

L'accessibilité a été prise en compte dès la conception (thème contrasté,
sémantique, formulaires étiquetés). L'auto-évaluation situe l'application à un
niveau satisfaisant, avec des axes d'amélioration clairs et réalisables. Le
référentiel RGAA, adossé aux WCAG 2.1, constitue le cadre de référence retenu et
guidera les prochaines itérations vers une conformité renforcée.

---

*Auto-évaluation réalisée à la version 1.0 du prototype. À réévaluer après mise
en œuvre du plan d'amélioration.*
