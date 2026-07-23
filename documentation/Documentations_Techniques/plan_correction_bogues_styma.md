# Plan de correction des bogues — STYMA

| | |
|---|---|
| **Projet** | STYMA — Application mobile |
| **Document** | Plan de correction des bogues |
| **Compétence visée** | C2.3.2 |
| **Auteur** | Melvin TOMEZAK |
| **Version** | 1.0 |
| **Date** | 21/07/2026 |

---

## 1. Objet du document

Ce document décrit la démarche adoptée pour **détecter, tracer, prioriser,
corriger et vérifier** les anomalies (bogues) de l'application STYMA. Il présente
le processus, les outils, la classification de gravité, et un journal des
anomalies traitées.

## 2. Objectifs

- Détecter les anomalies au plus tôt, avant qu'elles n'atteignent la production.
- Assurer la **traçabilité** de chaque anomalie, de son signalement à sa clôture.
- Prioriser les corrections selon leur impact.
- Éviter les régressions grâce aux tests automatisés.

## 3. Outils et canaux de détection

| Canal | Rôle |
|---|---|
| **Intégration continue** (GitHub Actions) | Analyse statique (`flutter analyze`) et tests (`flutter test`) à chaque push : détecte erreurs, avertissements et régressions |
| **Tests automatisés** | 84 tests (modèles, ViewModels, widgets) : détectent les régressions de logique |
| **Recette fonctionnelle** | Scénarios du cahier de recettes : détectent les écarts de comportement |
| **Dependabot** | Signale les dépendances présentant une faille de sécurité connue |
| **Retours utilisateurs** | Signalements lors des tests de l'application en ligne |
| **GitHub Issues** | Point d'entrée et de suivi centralisé des anomalies |

## 4. Cycle de vie d'une anomalie

1. **Détection** : l'anomalie est repérée (CI, test, recette, retour utilisateur).
2. **Signalement** : une **Issue** est ouverte sur GitHub (description, étapes de reproduction, gravité).
3. **Qualification** : reproduction, analyse de la cause, estimation de l'impact.
4. **Priorisation** : attribution d'un niveau de gravité et d'une priorité.
5. **Correction** : développement du correctif sur une branche, commit préfixé `fix:` référençant l'Issue.
6. **Vérification** : l'analyse et les tests doivent repasser au vert en CI ; un test est ajouté si pertinent pour prévenir la régression.
7. **Clôture** : l'Issue est fermée, liée au commit de correction.

## 5. Classification de la gravité

| Niveau | Définition | Traitement |
|---|---|---|
| **Bloquant** | Empêche la compilation, le déploiement ou l'usage d'une fonctionnalité majeure | Correction immédiate, prioritaire |
| **Majeur** | Dysfonctionnement important sans contournement simple | Correction planifiée à court terme |
| **Mineur** | Défaut léger, cosmétique ou avec contournement | Correction quand l'occasion se présente |

## 6. Traçabilité via GitHub

- Chaque anomalie fait l'objet d'une **Issue** (titre clair, description, étapes, gravité, éventuelle capture).
- Des **libellés** catégorisent les Issues : `bug`, `bloquant`, `mineur`, `sécurité`, etc.
- Le commit de correction référence l'Issue (ex. `fix: corrige X (#12)`), ce qui **relie automatiquement** la correction à son signalement et ferme l'Issue.
- L'onglet **Actions** conserve l'historique des exécutions de la CI, prouvant le retour au vert après correction.

## 7. Journal des anomalies traitées

Le tableau ci-dessous recense des anomalies réelles rencontrées et corrigées
durant le développement. Il illustre l'efficacité du dispositif : plusieurs ont
été **détectées automatiquement par la CI/CD** avant toute mise en production.

| ID | Description | Gravité | Détection | Correction | Statut |
|---|---|---|---|---|---|
| BUG-01 | Échec de compilation web : la version 10 de `font_awesome_flutter` étend la classe `IconData` devenue *final*, refusée par le compilateur web | Bloquant | Déploiement continu (build web) | Passage à `font_awesome_flutter` v11 et typage des icônes en `FaIconData` | Corrigé |
| BUG-02 | Échec de l'analyse statique en CI : l'asset `.env`, volontairement non versionné, est déclaré dans `pubspec.yaml` et introuvable | Bloquant | Intégration continue (`flutter analyze`) | Ajout de la règle `asset_does_not_exist: ignore` dans `analysis_options.yaml` | Corrigé |
| BUG-03 | Échec des tests en CI : la construction du bundle échoue faute de fichier `.env` | Bloquant | Intégration continue (`flutter test`) | Création d'un `.env` factice pendant le workflow CI | Corrigé |
| BUG-04 | Avertissement : usage d'un paramètre déprécié (`anonKey`) à l'initialisation de Supabase | Mineur | Analyse statique | Remplacement par `publishableKey` | Corrigé |
| BUG-05 | Avertissement : import inutile dans la coquille de navigation | Mineur | Analyse statique | Suppression de l'import | Corrigé |
| BUG-06 | Avertissement : usage de `BuildContext` après un `await` (suppression de compte) | Mineur | Analyse statique | Ajout d'un contrôle `mounted` avant réutilisation du contexte | Corrigé |
| BUG-07 | Effet visuel indésirable au clic (halo d'encre) jugé peu esthétique | Mineur | Retour utilisateur | Désactivation du `splash`/`highlight` dans le thème | Corrigé |

## 8. Prévention des régressions

Chaque correction significative s'accompagne, lorsque c'est pertinent, d'un
**test automatisé** garantissant que l'anomalie ne réapparaîtra pas. L'ensemble
des tests étant rejoué à chaque push, une régression est immédiatement signalée
par la CI (pastille rouge sur le commit concerné).

## 9. Suivi et indicateurs

Le suivi s'appuie sur des indicateurs simples et consultables sur GitHub :

- nombre d'Issues ouvertes / fermées ;
- gravité des anomalies en cours ;
- statut de la dernière exécution de la CI (vert/rouge) ;
- alertes Dependabot actives.

## 10. Conclusion

STYMA dispose d'un dispositif de correction des bogues **outillé et tracé** :
détection automatisée (CI, tests, Dependabot) et manuelle (recette, retours),
suivi centralisé via les Issues GitHub, priorisation par gravité, et prévention
des régressions par les tests. Les anomalies rencontrées durant le développement
ont toutes été corrigées et vérifiées.

---

*Plan établi à la version 1.0 du prototype. Le journal des anomalies est enrichi
au fil de la vie du projet.*
