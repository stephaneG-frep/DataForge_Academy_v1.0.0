import '../models/lesson_models.dart';

/// Design, conception and programming tracks.
class DesignTrackLessons {
  DesignTrackLessons._();

  static CodeBlock code(String lang, String c, {String? e}) =>
      CodeBlock(lang, c, explanation: e);

  static Lesson l({
    required String id,
    required String track,
    required int level,
    required String title,
    required String objective,
    required List<String> content,
    required List<CodeBlock> codeBlocks,
    List<String> mistakes = const [],
    List<ExerciseItem> exercises = const [],
    List<QuizItem> quiz = const [],
    int xp = 25,
  }) =>
      Lesson(
        id: id,
        trackId: track,
        levelIndex: level,
        title: title,
        objective: objective,
        content: content,
        codeBlocks: codeBlocks,
        commonMistakes: mistakes,
        exercises: exercises,
        quiz: quiz,
        xp: xp,
      );

  static QuizItem q(QuizType t, String q, List<String> o, String c, String e) =>
      QuizItem(type: t, question: q, options: o, correctAnswer: c, explanation: e);

  static ExerciseItem ex(String q, String a, String e) => ExerciseItem(q, a, e);

  static List<Lesson> design() => [
        l(
          id: 'dsg_er',
          track: 'design',
          level: 0,
          title: 'Diagrammes Entité-Relation (ER)',
          objective: 'Modéliser le monde réel avec des entités et relations.',
          content: [
            'Le diagramme ER permet de schématiser une base de données AVANT de la créer.',
            'Une ENTITÉ est un objet du monde réel (Employé, Produit, Client). Elle devient souvent une table.',
            'Un ATTRIBUT est une propriété de l\'entité (nom, prix) qui devient une colonne.',
            'Une RELATION relie deux entités (un Client passe des Commandes).',
          ],
          codeBlocks: [
            code('text', '   [CLIENT] 1----< [COMMANDE] >----1 [PRODUIT]\n\nClient: id, nom            Commande: id, date\nProduit: id, design, prix',
                e: 'Un schéma ER simplifié.'),
          ],
          mistakes: ['Confondre entité et attribut.',
              'Commencer à coder sans schéma d\'abord.'],
          exercises: [ex('Dans un diagramme ER, que devient généralement une entité ?',
              'Une table.',
              'Les entités se transposent en tables.')],
          quiz: [
            q(QuizType.qcm, 'Une entité dans un diagramme ER correspond à :',
                ['Un concept du monde réel', 'Une formule', 'Une requête', 'Un index'], 'Un concept du monde réel',
                'Les entités représentent des objets concrets.'),
          ],
          xp: 20,
        ),
        l(
          id: 'dsg_keys',
          track: 'design',
          level: 0,
          title: 'Clés primaires et étrangères',
          objective: 'Identifier les lignes et relier les tables.',
          content: [
            'La CLÉ PRIMAIRE (PRIMARY KEY) identifie UNE ligne de façon unique : un identifiant, jamais répété, jamais NULL.',
            'La CLÉ ÉTRANGÈRE (FOREIGN KEY) fait référence à la clé primaire d\'UNE AUTRE table : elle crée la relation.',
            'Contrainte d\'intégrité référentielle : on ne peut pas référencer une ligne qui n\'existe pas.',
            'Exemple : employes.departement_id est une clé étrangère vers departements.id.',
          ],
          codeBlocks: [
            code('sql', 'CREATE TABLE departements (\n  id INTEGER PRIMARY KEY,\n  nom TEXT\n);\n\nCREATE TABLE employes (\n  id INTEGER PRIMARY KEY,\n  nom TEXT,\n  departement_id INTEGER,\n  FOREIGN KEY (departement_id)\n    REFERENCES departements(id)\n);',
                e: 'Clé primaire et clé étrangère.'),
          ],
          mistakes: ['Utiliser une colonne mutable (ex: nom) comme clé primaire.',
              'Oublier la contrainte FOREIGN KEY.'],
          exercises: [ex('À quoi sert une clé étrangère ?',
              'À référencer la clé primaire d\'une autre table pour créer une relation.',
              'Elle garantit l\'intégrité référentielle.')],
          quiz: [
            q(QuizType.qcm, 'Une clé primaire doit être :',
                ['Unique et non NULL', 'Toujours un texte', 'Exactement 5 caractères', 'Cachée'], 'Unique et non NULL',
                'La clé primaire identifie chaque ligne de façon unique.'),
          ],
          xp: 25,
        ),
        l(
          id: 'dsg_relations',
          track: 'design',
          level: 1,
          title: 'Relations et cardinalités',
          objective: 'Comprendre 1-1, 1-N et N-N et leurs implémentations.',
          content: [
            'Cardinalité = nombre de relations entre entités : 1-1 (un à un), 1-N (un à plusieurs), N-N (plusieurs à plusieurs).',
            '1-N : un département a plusieurs employés → on met la clé étrangère côté "plusieurs".',
            'N-N : un étudiant suit plusieurs cours ET un cours a plusieurs étudiants → il faut une TABLE DE LIAISON.',
            'La table de liaison (associative) contient les deux clés étrangères.',
          ],
          codeBlocks: [
            code('sql', 'CREATE TABLE inscription (\n  etudiant_id INTEGER,\n  cours_id INTEGER,\n  PRIMARY KEY (etudiant_id, cours_id),\n  FOREIGN KEY (etudiant_id) REFERENCES etudiants(id),\n  FOREIGN KEY (cours_id) REFERENCES cours(id)\n);',
                e: 'Table de liaison pour une relation N-N.'),
          ],
          mistakes: ['Représenter N-N par une simple colonne.',
              'Oublier la table de liaison.'],
          exercises: [ex('Comment implémente-t-on une relation plusieurs-à-plusieurs ?',
              'Avec une table de liaison contenant les deux clés étrangères.',
              'La table associative relie les deux tables.')],
          quiz: [
            q(QuizType.qcm, 'Une relation N-N nécessite :',
                ['Une table de liaison', 'Deux clés primaires identiques', 'Un index plein texte', 'Une vue'],
                'Une table de liaison', 'La table associative gère le N-N.'),
          ],
          xp: 30,
        ),
        l(
          id: 'dsg_normalization',
          track: 'design',
          level: 2,
          title: 'Normalisation : 1NF, 2NF, 3NF',
          objective: 'Éviter les redondances et anomalies avec les formes normales.',
          content: [
            'La normalisation organise les données pour limiter la redondance et les incohérences.',
            '1NF (première forme normale) : chaque cellule contient une valeur atomique, pas de listes.',
            '2NF : pas de dépendance partielle (chaque colonne dépend de TOUTE la clé, pas d\'une partie).',
            '3NF : pas de dépendance transitive (toute colonne dépend directement de la clé primaire).',
            'Objectif : éviter les anomalies d\'insertion, de mise à jour et de suppression.',
          ],
          codeBlocks: [
            code('text', 'NON NORMALISÉ (redondance)\nCommande(id_c, id_p, nom_produit, prix)\n\n3NF : séparer dans une table Produit(pk, nom, prix)\nCommande(id_c) et LigneCommande(id_c, id_p)',
                e: 'Décomposition pour éliminer la redondance.'),
          ],
          mistakes: ['Trop normaliser au détriment des performances (déjà-constaté).',
              'Garder des listes séparées par des virgules dans une colonne (violation 1NF).'],
          exercises: [ex('Que garantit la 3NF ?',
              'Aucune dépendance transitive : chaque colonne dépend de la clé primaire.',
              'Elle élimine les dépendances indirectes.')],
          quiz: [
            q(QuizType.qcm, 'La 1NF impose que chaque cellule soit :',
                ['Atomique (une valeur)', 'Une liste', 'Un tableau', 'Chiffrée'], 'Atomique (une valeur)',
                'Chaque cellule contient une valeur unique et simple.'),
          ],
          xp: 35,
        ),
        l(
          id: 'dsg_backup',
          track: 'design',
          level: 4,
          title: 'Sauvegarde et restauration',
          objective: 'Protéger les données avec des stratégies de sauvegarde.',
          content: [
            'Sauvegarder est essentiel : perte de données = perte d\'activité.',
            'Types : sauvegarde complète, incrémentale (que les changements), différentielle.',
            'Stratégies : sauvegarde complète quotidienne + incrémentales toutes les heures.',
            'Tests de restauration : une sauvegarde non testée n\'existe pas.',
          ],
          codeBlocks: [
            code('bash', '# PostgreSQL\npg_dump mabase > sauvegarde.sql\npsql mabase < sauvegarde.sql\n\n# MySQL\nmysqldump mabase > sauvegarde.sql\nmysql mabase < sauvegarde.sql',
                e: 'Exporter/importer en SQL brut.'),
          ],
          mistakes: ['N\'avoir qu\'une seule copie au même endroit.',
              'Ne jamais tester la restauration.'],
          exercises: [ex('Pourquoi tester la restauration ?',
              'Une sauvegarde non testée est inutile si elle est corrompue.',
              'Le test garantit la récupérabilité.')],
          quiz: [
            q(QuizType.trueFalse, 'Une sauvegarde jamais testée est fiable.',
                ['Vrai', 'Faux'], 'Faux',
                'Il faut vérifier qu\'on peut réellement restaurer.'),
          ],
          xp: 45,
        ),
      ];

  static List<Lesson> programming() => [
        l(
          id: 'prog_connect',
          track: 'programming',
          level: 2,
          title: 'Connecter une base depuis un langage',
          objective: 'Comprendre comment un programme communique avec une base.',
          content: [
            'Un programme client se connecte au SGBD via un DRIVER/connexion, puis envoie des requêtes et récupère des résultats.',
            'Chaque langage a ses bibliothèques : Flutter/Dart (sqflite/drift), Python (psycopg2, pymysql), Node.js (pg, mysql2), Java (JDBC), C# (ADO.NET/EF Core), PHP (PDO, mysqli).',
            'Le principe est identique : ouvrir une connexion, exécuter des requêtes préparées, fermer proprement.',
          ],
          codeBlocks: [
            code('python', 'import psycopg2\n\nconn = psycopg2.connect(dbname="mabase", user="u", password="p")\ncur = conn.cursor()\ncur.execute("SELECT * FROM products WHERE price < %s", (50,))\nrows = cur.fetchall()\nconn.close()',
                e: 'Connexion PostgreSQL depuis Python.'),
            code('php', '\$pdo = new PDO("mysql:host=localhost;dbname=mabase", "u", "p");\n\$req = \$pdo->prepare("SELECT * FROM products WHERE price < ?");\n\$req->execute([50]);\n\$rows = \$req->fetchAll();',
                e: 'Connexion MySQL avec PDO depuis PHP.'),
          ],
          mistakes: ['Ne pas fermer la connexion (fuite de ressources).',
              'Concaténer du SQL au lieu d\'utiliser des requêtes préparées.'],
          exercises: [ex('Quel est le grand avantage des requêtes préparées ?',
              'La protection contre les injections SQL et la réutilisation.',
              'Les paramètres sont liés, jamais interprétés comme du code.')],
          quiz: [
            q(QuizType.qcm, 'Une requête préparée protège principalement contre :',
                ['Les injections SQL', 'Les pannes', 'La lenteur', 'La perte de données'], 'Les injections SQL',
                'Les paramètres liés neutralisent les injections.'),
          ],
          xp: 35,
        ),
        l(
          id: 'prog_orm',
          track: 'programming',
          level: 3,
          title: 'ORM et requêtes préparées',
          objective: 'Découvrir les ORM et les bonnes pratiques d\'accès aux données.',
          content: [
            'Un ORM (Object-Relational Mapping) mappe des objets du code vers les tables : on manipule des objets au lieu de SQL.',
            'Exemples : Prisma/Drizzle (Node), SQLAlchemy (Python), Hibernate (Java), EF Core (C#), Drift (Flutter/Dart).',
            'Voici le compromis : les ORM accélèrent le développement mais peuvent produire des requêtes inefficaces.',
            'Toujours utiliser des requêtes préparées ET un ORM qui le fait par défaut.',
          ],
          codeBlocks: [
            code('js', '// Node.js + Prisma (ORM)\nconst low = await prisma.product.findMany({\n  where: { price: { lt: 50 } },\n  orderBy: { price: "desc" }\n});',
                e: 'Un ORM évite d\'écrire le SQL à la main.'),
          ],
          mistakes: ['Faire confiance à l\'ORM pour toutes les requêtes complexes.',
              'Négliger les requêtes préparées quand on écrit du SQL brut.'],
          exercises: [ex('Que fait un ORM ?',
              'Il mappe les tables vers des objets du langage.',
              'On manipule des objets, l\'ORM génère le SQL.')],
          quiz: [
            q(QuizType.qcm, 'Un ORM transforme les tables en :',
                ['Objets du langage', 'Fichiers CSV', 'API REST', 'Procédures'], 'Objets du langage',
                'L\'ORM lie les tables aux objets.'),
          ],
          xp: 40,
        ),
        l(
          id: 'prog_api',
          track: 'programming',
          level: 4,
          title: 'API REST et backend',
          objective: 'Exposer une base de données via une API REST.',
          content: [
            'Une API REST expose les données d\'une base via HTTP : GET (lire), POST (créer), PUT/PATCH (mettre à jour), DELETE (supprimer).',
            'Le backend est le serveur qui traite les requêtes HTTP et interroge la base.',
            'La séparation app front (Flutter) ↔ backend ↔ base est l\'architecture classique des applications.',
            'Bonnes pratiques : authentification, validation, pagination, gestion des erreurs, jamais de mdp en clair.',
          ],
          codeBlocks: [
            code('js', '// Express (Node.js)\napp.get("/products", async (req, res) => {\n  const rows = await db.query(\n    "SELECT * FROM products WHERE price < \$1", [req.query.price]\n  );\n  res.json(rows.rows);\n});',
                e: 'Un endpoint REST qui lit la base.'),
          ],
          mistakes: ['Renvoyer la structure interne de la base telle quelle.',
              'Créer une API sans authentification ni validation.'],
          exercises: [ex('Quelle méthode HTTP sert à créer une ressource ?',
              'POST.',
              'POST crée, GET lit, PATCH modifie, DELETE supprime.')],
          quiz: [
            q(QuizType.qcm, 'GET /products correspond à une opération :',
                ['Lecture', 'Suppression', 'Création', 'Fermeture'], 'Lecture',
                'GET lit des ressources.'),
          ],
          xp: 45,
        ),
      ];
}
