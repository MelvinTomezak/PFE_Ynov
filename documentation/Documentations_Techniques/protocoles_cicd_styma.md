# Protocoles d'intégration et de déploiement continus — STYMA

| | |
|---|---|
| **Projet** | STYMA — Application mobile |
| **Document** | Protocoles CI/CD et critères de qualité et de performance |
| **Compétences visées** | C2.1.1, C2.1.2 |
| **Auteur** | Melvin TOMEZAK |
| **Version** | 1.0 |
| **Date** | 21/07/2026 |

---

## 1. Objet du document

Ce document décrit la chaîne d'**intégration continue** (CI) et de **déploiement
continu** (CD) mise en place pour STYMA, ainsi que les **critères de qualité et
de performance** retenus. Ces automatisations reposent sur **GitHub Actions** et
**GitHub Pages**.

## 2. Vue d'ensemble de la chaîne

À chaque modification poussée sur le dépôt, deux automatisations se déclenchent :

```
  Développeur
      │  git push
      ▼
┌──────────────────────────────┐     ┌──────────────────────────────┐
│   INTÉGRATION CONTINUE (CI)   │     │   DÉPLOIEMENT CONTINU (CD)    │
│  analyse statique + tests     │     │  build web + publication      │
│  (ci.yml)                     │     │  GitHub Pages (cd.yml)        │
└──────────────┬───────────────┘     └──────────────┬───────────────┘
               ▼                                     ▼
        Rapport vert/rouge                    Application en ligne
        (qualité du code)                     mise à jour
```

Les deux workflows sont versionnés dans le dépôt, sous
`.github/workflows/ci.yml` et `.github/workflows/cd.yml`.

---

## 3. Protocole d'intégration continue (C2.1.2)

### 3.1 Déclencheurs

La CI s'exécute à chaque `push` et à chaque *pull request* sur les branches
`master` et `main`.

### 3.2 Étapes du pipeline

1. **Récupération du code** (`actions/checkout`).
2. **Installation de Flutter** (canal stable).
3. **Installation des dépendances** (`flutter pub get`).
4. **Création d'un fichier `.env` factice** — le fichier réel n'étant pas versionné, un `.env` à valeurs neutres permet la construction du bundle sans exposer de secret.
5. **Analyse statique** (`flutter analyze`) — vérifie la qualité et la conformité du code aux règles de lint.
6. **Tests** (`flutter test`) — exécute l'ensemble des tests unitaires et de widgets.

### 3.3 Règle de blocage

Le pipeline échoue (statut rouge) si l'analyse relève une erreur/avertissement
ou si un test échoue. Un code non conforme est ainsi **signalé immédiatement**,
avant toute mise en production.

---

## 4. Protocole de déploiement continu (C2.1.1)

### 4.1 Déclencheur

Le CD s'exécute à chaque `push` sur la branche `master`.

### 4.2 Étapes du pipeline

1. **Récupération du code** et **installation de Flutter**.
2. **Installation des dépendances**.
3. **Injection des secrets** : le fichier `.env` est reconstruit à partir des secrets GitHub `SUPABASE_URL` et `SUPABASE_ANON_KEY` (les clés ne figurent jamais dans le dépôt).
4. **Construction de la version web** : `flutter build web --release` avec le `base-href` correspondant au dépôt.
5. **Publication** sur **GitHub Pages** (`upload-pages-artifact` puis `deploy-pages`).

### 4.3 Résultat

L'application est publiée et mise à jour automatiquement à l'adresse :
`https://melvintomezak.github.io/PFE_Ynov/`

### 4.4 Prérequis de configuration

- Secrets `SUPABASE_URL` et `SUPABASE_ANON_KEY` définis dans le dépôt.
- Source des Pages réglée sur **GitHub Actions**.
- Droits du workflow : `pages: write`, `id-token: write`.

---

## 5. Critères de qualité

| Critère | Exigence | Vérification |
|---|---|---|
| Conformité du code | Aucune erreur ni avertissement | `flutter analyze` en CI |
| Respect des conventions | Règles `flutter_lints` appliquées | `analysis_options.yaml` + CI |
| Couverture fonctionnelle par les tests | Tests au vert à 100 % | `flutter test` en CI (84 tests) |
| Non-régression | Les tests existants continuent de passer | CI à chaque push |
| Sécurité des dépendances | Pas de faille connue non traitée | Alertes Dependabot |
| Traçabilité | Commits explicites (convention `feat`/`fix`/…) et versions taguées | Historique Git |
| Protection des secrets | Aucun secret dans le dépôt | `.gitignore` + secrets GitHub |

## 6. Critères de performance

| Critère | Exigence | Moyen |
|---|---|---|
| Build optimisé | Version web minifiée et optimisée | `flutter build web --release` (compilation dart2js optimisée) |
| Rapidité de la chaîne | Pipeline court (quelques minutes) | Actions légères, cache de l'environnement Flutter |
| Réactivité de l'interface | Pas de blocage pendant les chargements | Chargements asynchrones avec états dédiés (`LoadStatus`) |
| Fluidité des interactions | Retour immédiat sur les actions sociales | Mise à jour optimiste (likes) avec annulation en cas d'erreur |
| Robustesse d'affichage | Pas d'écran figé en cas d'erreur réseau | États d'erreur avec bouton de réessai, images avec repli |

## 7. Sécurité de la chaîne

- Les **secrets** (identifiants Supabase) sont stockés chiffrés dans GitHub et injectés uniquement à l'exécution ; ils n'apparaissent jamais dans le code ni dans les journaux.
- La **protection des secrets** de GitHub bloque tout push contenant accidentellement une clé.
- **Dependabot** surveille les dépendances et signale les vulnérabilités.

## 8. Environnements

| Environnement | Usage | Particularité |
|---|---|---|
| **Local** | Développement | `.env` local, `flutter run` |
| **CI** | Vérification | `.env` factice, aucune donnée réelle |
| **Production (web)** | Application en ligne | `.env` reconstruit depuis les secrets, publié sur GitHub Pages |

## 9. Conclusion

STYMA dispose d'une chaîne CI/CD **complète et automatisée** : chaque
modification est analysée et testée (intégration continue), puis, si elle est
sur `master`, construite et publiée en ligne (déploiement continu). Les critères
de qualité (analyse, tests, sécurité, traçabilité) et de performance (build
optimisé, interface réactive) sont vérifiés en continu, garantissant un code
fiable et une application toujours à jour.

---

*Protocoles établis à la version 1.0 du prototype. Ils évolueront avec le projet
(par exemple ajout d'un build APK automatisé sur les tags de version).*
