# DataForge Academy

Application Flutter (Android) pour apprendre le SQL et les bases de données, du niveau débutant jusqu'au niveau « Database Engineer ».

- **38 leçons** réparties en 11 parcours : SQL, SQLite, PostgreSQL, MySQL, MariaDB, SQL Server, Oracle, MongoDB, Redis, conception et SQL + programmation.
- **Playground SQL** avec un vrai moteur SQLite et 5 bases d'entraînement (boutique, bibliothèque, films, employés, école).
- **Défis** corrigés automatiquement en comparant le résultat de la requête avec celui de la solution.
- **Projets guidés**, quiz, glossaire, aide-mémoire, notes et historique des requêtes.
- Progression locale (XP, badges), sans compte ni connexion réseau.

## Prérequis

- Flutter 3.47 ou plus récent (Dart ≥ 3.13)
- Android SDK (pour compiler l'APK)

## Commandes utiles

```bash
flutter pub get          # installer les dépendances
flutter run              # lancer en debug
flutter analyze          # analyse statique (doit afficher « No issues found »)
flutter test             # tests unitaires et tests widgets
flutter build apk --release
```

## Architecture

```
lib/
  main.dart, app.dart        démarrage, thème, écran de chargement
  data/                      contenu pédagogique (leçons, défis, projets, glossaire)
  database/
    practice_data.dart       schéma et données des 5 bases d'entraînement
    playground_database.dart moteur SQL du Playground et des défis
  models/                    modèles (leçons, défis, projets, tables/résultats)
  services/                  progression et réglages (shared_preferences)
  screens/                   écrans
  widgets/, theme/           composants et thème partagés
  utils/sql_util.dart        comparaison des résultats pour les défis
test/                        tests du moteur SQL, des utilitaires et des écrans
```

### Moteur SQL (`playground_database.dart`)

- Chaque base d'entraînement est une base SQLite **en mémoire, indépendante** (`singleInstance: false`). Elle est créée à la première ouverture et revient à son état d'origine via « Réinitialiser la base » ou au redémarrage de l'app.
- `execute()` exécute **une seule instruction** à la fois : les commentaires et le `;` final sont acceptés, plusieurs instructions sont refusées avec un message clair. Le nombre de lignes affectées est calculé avec `total_changes()`.
- `executeReadOnly()` sert aux défis. Seuls `SELECT`/`WITH`/`VALUES` sont acceptés, la requête s'exécute avec `PRAGMA query_only = ON` dans une transaction toujours annulée, et la base ne peut donc pas être modifiée.
- Sur Android, le moteur utilise `sqflite`. Dans les tests et sur desktop, il utilise `sqflite_common_ffi`.

### Correction des défis

La requête de l'utilisateur et la solution sont exécutées en lecture seule, puis leurs lignes sont comparées. Pour les défis qui imposent un tri (`orderByColumn` dans `challenge_data.dart`), l'app vérifie aussi l'ordre sur cette colonne. Les ex æquo peuvent apparaître dans n'importe quel ordre.

### XP

- Leçons, projets et défis ne rapportent de l'XP qu'une seule fois.
- Les quiz ne rapportent de l'XP que si la **première** réponse est juste. Les questions déjà tentées sont enregistrées dans `prog.attemptedQuizzes`.

## Publier une version release

1. Créer une clé d'upload (une seule fois, à conserver précieusement) :

   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias upload
   ```

2. Créer `android/key.properties` :

   ```properties
   storePassword=<mot de passe du keystore>
   keyPassword=<mot de passe de la clé>
   keyAlias=upload
   storeFile=/chemin/absolu/vers/upload-keystore.jks
   ```

   Ce fichier et les `.jks` sont exclus de git (voir `.gitignore`). **Ne jamais les committer.**

3. `flutter build appbundle --release` pour le Play Store, ou `flutter build apk --release` pour un APK.

Sans `key.properties`, le build release est signé avec la clé de debug et un avertissement s'affiche. Cet APK fonctionne en local mais ne peut pas être publié.

L'identifiant de l'application est `com.dataforge.academy`. Il ne doit plus changer après la première publication.
