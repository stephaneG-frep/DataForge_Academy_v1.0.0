import '../models/lesson_models.dart';

/// SGBD-specific tracks: SQLite, PostgreSQL, MySQL, MariaDB, SQL Server,
/// Oracle, MongoDB, Redis.
class SgbdTrackLessons {
  SgbdTrackLessons._();

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

  static List<Lesson> sqlite() => [
        l(
          id: 'sqlite_intro',
          track: 'sqlite',
          level: 0,
          title: 'SQLite : la base embarquée',
          objective: 'Comprendre ce qu\'est SQLite et ses cas d\'usage.',
          content: [
            'SQLite est une base de données relationnelle EMBARQUÉE : pas de serveur à installer, tout est stocké dans un simple fichier.',
            'Elle est intégrée par défaut dans Android, iOS, les navigateurs et Python. C\'est la base de données la plus répandue au monde.',
            'Elle supporte une grande partie du SQL standard, y compris ACID, mais gère mal les très fortes concurrences d\'écriture.',
            'Ce Playground utilise SQLite en interne pour exécuter tes requêtes !',
          ],
          codeBlocks: [
            code('sql', '-- SQLite se manipule sans serveur\nSELECT * FROM products;',
                e: 'Même syntaxe, données lues depuis le fichier .sqlite.'),
          ],
          mistakes: [
            'Penser que SQLite a besoin d\'un serveur et d\'un port.',
            'Utiliser SQLite pour de très fortes charges d\'écriture concurrentes.',
          ],
          exercises: [ex('Qu\'est-ce qui distingue SQLite des autres SGBD ?',
              'C\'est une base embarquée stockée dans un fichier, sans serveur.',
              'Elle s\'intègre dans l\'application elle-même.')],
          quiz: [
            q(QuizType.qcm, 'SQLite stocke ses données dans :',
                ['Un fichier unique', 'Plusieurs serveurs', 'Un navigateur', 'Un fichier texte non structuré'],
                'Un fichier unique',
                'Toute la base tient dans un seul fichier portable.'),
          ],
          xp: 20,
        ),
        l(
          id: 'sqlite_types',
          track: 'sqlite',
          level: 1,
          title: 'Types et syntaxe SQLite',
          objective: 'Connaître les types de données et spécificités de SQLite.',
          content: [
            'SQLite utilise des AFFINITÉS de types plus souples que les autres SGBD : INTEGER, REAL, TEXT, BLOB, NULL.',
            'On peut insérer une valeur dont le type ne correspond pas exactement : SQLite convertit automatiquement selon l\'affinité.',
            'SQLite accepte AUTOINCREMENT sur les clés primaires INTEGER.',
            'Fonctions utiles : datetime(), length(), upper(), lower(), coalesce().',
          ],
          codeBlocks: [
            code('sql', "SELECT upper('bonjour') AS maj;",
                e: 'Retourne BONJOUR.'),
            code('sql', 'SELECT datetime(\'now\') AS maintenant;',
                e: 'Date et heure courantes.'),
          ],
          mistakes: [
            'Écrire des types comme VARCHAR(50) avec précision (SQLite les accepte mais les ignore).',
            'Oublier que SQLite est peu typé : le même SGBD ailleurs exigerait des conversions.',
          ],
          exercises: [ex('Quelle fonction SQLite renvoie la date du jour ?',
              'datetime(\'now\').',
              'La fonction datetime avec l\'argument now.')],
          quiz: [
            q(QuizType.trueFalse, 'SQLite est typé de façon très stricte.',
                ['Vrai', 'Faux'], 'Faux',
                'SQLite utilise des affinités souples, pas de typage strict.'),
          ],
          xp: 25,
        ),
        l(
          id: 'sqlite_pragma',
          track: 'sqlite',
          level: 2,
          title: 'PRAGMA et introspection',
          objective: 'Explorer la structure de la base avec PRAGMA.',
          content: [
            'PRAGMA est la commande propre à SQLite pour interroger et régler la base.',
            'PRAGMA table_info(nom) liste les colonnes d\'une table.',
            'sqlite_master est la table interne qui contient toutes les définitions d\'objets.',
            '.tables, .schema sont des raccourcis de l\'outil en ligne de commande.',
          ],
          codeBlocks: [
            code('sql', 'PRAGMA table_info(products);',
                e: 'Affiche colonnes et types de la table.'),
            code('sql', 'SELECT name, sql FROM sqlite_master WHERE type=\'table\';',
                e: 'Lister les tables et leur définition.'),
          ],
          mistakes: [
            'CONFUSION : PRAGMA n\'existe pas dans MySQL/PostgreSQL.',
            'Oublier que sqlite_master est en lecture seule.',
          ],
          exercises: [ex('Comment lister les colonnes d\'une table ?',
              'PRAGMA table_info(nom_table);',
              'C\'est l\'introspection SQLite.')],
          quiz: [
            q(QuizType.qcm, 'Quel PRAGMA liste les colonnes d\'une table ?',
                ['table_info', 'columns', 'show_fields', 'describe'],
                'table_info', 'PRAGMA table_info(nom_table).'),
          ],
          xp: 30,
        ),
      ];

  static List<Lesson> postgres() => [
        l(
          id: 'pg_intro',
          track: 'postgres',
          level: 0,
          title: 'PostgreSQL : le SGBD open source avancé',
          objective: 'Découvrir PostgreSQL et ses forces.',
          content: [
            'PostgreSQL ("Postgres") est un SGBD objet-relationnel open source, réputé pour sa fiabilité, ses types avancés et sa conformité au standard SQL.',
            'Il supporte JSON, les types géométriques, les index hybrides, les fonctions procédurales (PL/pgSQL).',
            'C\'est le choix privilégié pour les applications modernes exigeantes (comme ici pour ce projet).',
            'Il fonctionne en client-serveur : un serveur (port 5432 par défaut) reçoit les connexions.',
          ],
          codeBlocks: [
            code('sql', '-- Connexion\npsql -U utilisateur -d mabase\n\nSELECT version();',
                e: 'Le client psql et la version du serveur.'),
          ],
          mistakes: ['Confondre le port de Postgres (5432) avec MySQL (3306).',
              'Oublier que c\'est un modèle client-serveur.'],
          exercises: [ex('PostgreSQL est-il un modèle client-serveur ou embarqué ?',
              'Client-serveur.',
              'Un serveur reçoit les connexions sur le réseau.')],
          quiz: [
            q(QuizType.qcm, 'Quel est le port par défaut de PostgreSQL ?',
                ['5432', '3306', '27017', '6379'], '5432',
                '5432 pour Postgres, 3306 pour MySQL.'),
          ],
          xp: 20,
        ),
        l(
          id: 'pg_types',
          track: 'postgres',
          level: 1,
          title: 'Types avancés et SERIAL',
          objective: 'Types PostgreSQL : SERIAL, JSON, réseaux, ranges.',
          content: [
            'PostgreSQL offre des types riches : SERIAL (auto-incrément), JSON/JSONB, UUID, points géométriques, adresses réseau (inet), intervalles de dates (range).',
            'SERIAL crée une séquence automatique pour la clé primaire : id SERIAL PRIMARY KEY.',
            'JSONB stocke le JSON de façon binaire et permet de l\'indexer pour de vraies recherches.',
            'Le typage est strict : pas de conversion implicite hasardeuse.',
          ],
          codeBlocks: [
            code('sql', 'CREATE TABLE clients (\n  id SERIAL PRIMARY KEY,\n  nom TEXT NOT NULL,\n  metadatas JSONB\n);',
                e: 'id auto-incrémenté, colonne JSON binaire.'),
          ],
          mistakes: ['Confondre JSON et JSONB (le B est binaire et indexable).',
              'Utiliser AUTO_INCREMENT (MySQL) à la place de SERIAL.'],
          exercises: [ex('Que fait SERIAL dans PostgreSQL ?',
              'Il crée un auto-incrément pour la colonne.',
              'SERIAL repose sur une séquence.')],
          quiz: [
            q(QuizType.qcm, 'Quel type stocke du JSON indexable ?',
                ['JSONB', 'VARCHAR', 'BLOB', 'TEXTARRAY'], 'JSONB',
                'JSONB est la version binaire indexable.'),
          ],
          xp: 25,
        ),
        l(
          id: 'pg_plsql',
          track: 'postgres',
          level: 3,
          title: 'PL/pgSQL : fonctions et procédures',
          objective: 'Écrire des fonctions et blocs procéduraux.',
          content: [
            'PL/pgSQL est le langage procédural de PostgreSQL pour les fonctions, procédures et triggers.',
            'Une fonction peut retourner une valeur ou une table. Elle supporte les variables, boucles et conditions.',
            'Cette puissance permet de centraliser la logique métier dans la base.',
          ],
          codeBlocks: [
            code('sql', 'CREATE FUNCTION prix_total(p_qte INT, p_prix REAL)\nRETURNS REAL AS \$\$\nBEGIN\n  RETURN p_qte * p_prix;\nEND;\n\$\$ LANGUAGE plpgsql;',
                e: 'Une fonction SQL simple en PL/pgSQL.'),
          ],
          mistakes: ['Oublier LANGUAGE plpgsql à la fin.',
              'Faire un RETURN dans une procédure (qui ne retourne rien).'],
          exercises: [ex('À quoi sert CSO plpgsql ?',
              'À donner un langage procédural à PostgreSQL.',
              'Il active PL/pgSQL pour la fonction.')],
          quiz: [
            q(QuizType.qcm, 'Le langage procédural natif de PostgreSQL s\'appelle :',
                ['PL/pgSQL', 'T-SQL', 'PL/SQL', 'MySQLi'], 'PL/pgSQL',
                'PL/pgSQL est propre à PostgreSQL.'),
          ],
          xp: 40,
        ),
      ];

  static List<Lesson> mysql() => [
        l(
          id: 'mysql_intro',
          track: 'mysql',
          level: 0,
          title: 'MySQL : le SGBD le plus populaire du web',
          objective: 'Découvrir MySQL et son modèle client-serveur.',
          content: [
            'MySQL est un SGBD relationnel open source, très répandu sur le web (associé à PHP/Apache dans la pile LAMP).',
            'Il est performant en lecture, facile à administrer, et utilisé par d\'immenses plateformes.',
            'Port par défaut : 3306. Un serveur reçoit des connexions TCP des clients.',
            'Il a été racheté par Oracle, ce qui a conduit à la création de MariaDB (voir plus loin).',
          ],
          codeBlocks: [
            code('sql', '-- Connexion\nmysql -u root -p\n\nSHOW DATABASES;',
                e: 'Le client mysql et la liste des bases.'),
          ],
          mistakes: ['Utiliser SHOW DATABASES alors que PostgreSQL utilise \\dt.',
              'Oublier le mot de passe du client.'],
          exercises: [ex('Quel est le port par défaut de MySQL ?',
              '3306.', 'C\'est le port MySQL standard.')],
          quiz: [
            q(QuizType.qcm, 'MySQL est souvent associé à quel langage côté serveur web ?',
                ['PHP', 'FORTRAN', 'COBOL', 'Assembly'], 'PHP',
                'MySQL et PHP forment le duo classique de la pile LAMP.'),
          ],
          xp: 20,
        ),
        l(
          id: 'mysql_engine',
          track: 'mysql',
          level: 2,
          title: 'Moteurs de stockage : InnoDB',
          objective: 'Comprendre les moteurs de stockage MySQL.',
          content: [
            'MySQL permet de choisir le MOTEUR de stockage de chaque table. Le plus utilisé est InnoDB.',
            'InnoDB supporte les transactions ACID, les clés étrangères et la récupération après panne.',
            'MyISAM (ancien moteur) est plus rapide en lecture pure mais ne supporte PAS les transactions ni les clés étrangères.',
            'ENGINE=InnoDB s\'écrit à la création de la table.',
          ],
          codeBlocks: [
            code('sql', 'CREATE TABLE produits (\n  id INT AUTO_INCREMENT PRIMARY KEY,\n  name VARCHAR(100)\n) ENGINE=InnoDB;',
                e: 'AUTO_INCREMENT (MySQL) + moteur InnoDB.'),
          ],
          mistakes: ['Utiliser AUTO_INCREMENT (MySQL) au lieu de SERIAL (Postgres).',
              'Choisir MyISAM quand on a besoin de transactions.'],
          exercises: [ex('Quel moteur supporte les transactions ?',
              'InnoDB.', 'MyISAM lui ne les supporte pas.')],
          quiz: [
            q(QuizType.qcm, 'AUTO_INCREMENT est spécifique à :',
                ['MySQL/MariaDB', 'PostgreSQL', 'Oracle', 'SQL Server'], 'MySQL/MariaDB',
                'MySQL utilise AUTO_INCREMENT pour l\'auto-incrément.'),
          ],
          xp: 30,
        ),
      ];

  static List<Lesson> mariadb() => [
        l(
          id: 'mariadb_intro',
          track: 'mariadb',
          level: 0,
          title: 'MariaDB : le fork communautaire de MySQL',
          objective: 'Comprendre l\'origine de MariaDB et ses différences.',
          content: [
            'MariaDB est un fork open source de MySQL, créé par les développeurs originaux après le rachat de MySQL par Oracle.',
            'Il reste 100% compatible avec MySQL pour la majorité des usages, avec des moteurs de stockage et optimisations supplémentaires.',
            'C\'est le serveur par défaut sur de nombreuses distributions Linux (Debian/Ubuntu).',
            'Port : 3306, comme MySQL.',
          ],
          codeBlocks: [
            code('sql', 'SELECT VERSION();',
                e: 'Affiche la version (ex : 10.11.x MariaDB).'),
          ],
          mistakes: ['Croire que MariaDB n\'est pas compatible avec MySQL.',
              'Confondre les ports.'],
          exercises: [ex('De quoi MariaDB est-il issu ?',
              'D\'un fork de MySQL.',
              'Les développeurs initiaux de MySQL l\'ont créé.')],
          quiz: [
            q(QuizType.trueFalse, 'MariaDB est un fork open source de MySQL.',
                ['Vrai', 'Faux'], 'Vrai',
                'MariaDB est le fork communautaire de MySQL.'),
          ],
          xp: 20,
        ),
        l(
          id: 'mariadb_storage',
          track: 'mariadb',
          level: 2,
          title: 'Moteurs de stockage supplémentaires',
          objective: 'Les moteurs propres à MariaDB.',
          content: [
            'MariaDB ajoute des moteurs comme Aria, ColumnStore (analytique colonnaire) et MyRocks.',
            'ColumnStore est optimisé pour l\'analyse massivement parallèle sur de gros volumes.',
            'Ces moteurs complètent InnoDB pour des besoins spécifiques.',
          ],
          codeBlocks: [
            code('sql', 'CREATE TABLE analyse (\n  date DATE,\n  ventes INT\n) ENGINE=ColumnStore;',
                e: 'Moteur colonnaire pour l\'analyse.'),
          ],
          mistakes: ['Oublier que le moteur s\'écrit à la création.',
              'Utiliser ColumnStore pour des transactions simples.'],
          exercises: [ex('Quel moteur de MariaDB est optimisé pour l\'analytique ?',
              'ColumnStore.',
              'Il stocke les données en colonnes pour l\'analyse rapide.')],
          quiz: [
            q(QuizType.qcm, 'ColumnStore est optimisé pour :',
                ['Le calcul analytique massif', 'Les transactions bancaires en temps réel', 'Le stockage de fichiers', 'La messagerie'],
                'Le calcul analytique massif',
                'C\'est un stockage colonnaire dédié à l\'analyse.'),
          ],
          xp: 30,
        ),
      ];

  static List<Lesson> sqlserver() => [
        l(
          id: 'mssql_intro',
          track: 'sqlserver',
          level: 0,
          title: 'SQL Server / T-SQL',
          objective: 'Découvrir SQL Server et le langage T-SQL.',
          content: [
            'Microsoft SQL Server est le SGBD de Microsoft, très utilisé dans le monde de l\'entreprise.',
            'Il utilise T-SQL (Transact-SQL), une extension de SQL avec des procédures stockées, triggers et syntaxe TOP.',
            'Port par défaut : 1433. Outil d\'administration : SQL Server Management Studio (SSMS).',
            'Points forts : intégration avec l\'écosystème .NET/C#, outils de reporting, sécurité avancée.',
          ],
          codeBlocks: [
            code('sql', '-- Limiter les résultats avec TOP (SQL Server)\nSELECT TOP 5 * FROM produits;',
                e: 'TOP est spécifique à T-SQL.'),
          ],
          mistakes: ['Utiliser LIMIT (MySQL/SQLite) au lieu de TOP en T-SQL.',
              'Utiliser [[]] pour les identifiants (c\'est [] en T-SQL).'],
          exercises: [ex('Quel langage SQL utilise SQL Server ?',
              'T-SQL (Transact-SQL).',
              'L\'extension propriétaire de Microsoft.')],
          quiz: [
            q(QuizType.qcm, 'SQL Server utilise quel mot-clé pour limiter les résultats ?',
                ['TOP', 'LIMIT', 'FIRST', 'FETCH ONLY'], 'TOP',
                'T-SQL utilise TOP n.'),
          ],
          xp: 20,
        ),
        l(
          id: 'mssql_tsql',
          track: 'sqlserver',
          level: 3,
          title: 'Procédures stockées T-SQL',
          objective: 'Écrire des procédures stockées et variables.',
          content: [
            'T-SQL permet de créer des procédures stockées avec CREATE PROCEDURE.',
            'Il utilise @ devant les variables : @prix INT.',
            'EXEC exécute une procédure.',
            'Les procédures centralisent le code réutilisable et améliorent la sécurité et les performances.',
          ],
          codeBlocks: [
            code('sql', 'CREATE PROCEDURE PrixParCategorie\n  @cat INT\nAS\nBEGIN\n  SELECT name, price FROM products\n  WHERE category_id = @cat;\nEND;\n\nEXEC PrixParCategorie 1;',
                e: 'Une procédure stockée paramétrée T-SQL.'),
          ],
          mistakes: ['Oublier @ devant les variables.',
              'Utiliser BEGIN/END en style PL/SQL incompatible.'],
          exercises: [ex('Comment déclare-t-on une variable en T-SQL ?',
              'Avec @ devant le nom, ex : @prix INT.',
              '@ est le préfixe de variable T-SQL.')],
          quiz: [
            q(QuizType.trueFalse, 'T-SQL préfixe ses variables avec @.',
                ['Vrai', 'Faux'], 'Vrai',
                '@variable est la syntaxe T-SQL.'),
          ],
          xp: 40,
        ),
      ];

  static List<Lesson> oracle() => [
        l(
          id: 'oracle_intro',
          track: 'oracle',
          level: 0,
          title: 'Oracle / PL-SQL',
          objective: 'Découvrir Oracle et PL/SQL.',
          content: [
            'Oracle Database est un SGBD commercial historique, très robuste, utilisé dans les grandes entreprises et la finance.',
            'Il utilise PL/SQL (Procedural Language/SQL) pour les procédures stockées, avec des blocs BEGIN...END.',
            'Il respecte strictement le SQL standard avec quelques spécificités',
            'SQL*Plus et SQL Developer sont les outils courants.',
          ],
          codeBlocks: [
            code('sql', '-- Oracle utilise DUAL pour une requête sans table\nSELECT 2 + 3 AS total FROM DUAL;',
                e: 'DUAL est une table factice d\'Oracle.'),
          ],
          mistakes: ['Utiliser LIMIT (Oracle utilise FETCH FIRST ou ROWNUM).',
              'Oublier SELECT ... FROM DUAL.'],
          exercises: [ex('À quoi sert la table DUAL dans Oracle ?',
              'C\'est une table factice pour les SELECT sans table.',
              'DUAL permet d\'évaluer des expressions.')],
          quiz: [
            q(QuizType.qcm, 'Quel langage procédural utilise Oracle ?',
                ['PL/SQL', 'T-SQL', 'PL/pgSQL', 'VBScript'], 'PL/SQL',
                'Oracle utilise PL/SQL.'),
          ],
          xp: 20,
        ),
        l(
          id: 'oracle_plsql',
          track: 'oracle',
          level: 3,
          title: 'Blocs PL/SQL',
          objective: 'Écrire des blocs anonymes et fonctions PL/SQL.',
          content: [
            'Un bloc PL/SQL a la structure : DECLARE (variables) / BEGIN (code) / EXCEPTION (gestion d\'erreurs) / END;',
            'Les variables se déclarent sans @ ni \$ : v_prix NUMBER(10,2);',
            'Il utilise la dualité de parcours : FOR, IF/THEN/ELSE, LOOP.',
            'Des fonctions et procédures se créent avec CREATE FUNCTION / CREATE PROCEDURE.',
          ],
          codeBlocks: [
            code('sql', 'DECLARE\n  v_total NUMBER := 10;\nBEGIN\n  v_total := v_total * 2;\n  DBMS_OUTPUT.PUT_LINE(\'Total: \' || v_total);\nEND;',
                e: 'Un bloc anonyme PL/SQL.'),
          ],
          mistakes: ['Oublier le point-virgule à la fin du bloc.',
              'Utiliser PRINT au lieu de DBMS_OUTPUT.PUT_LINE.'],
          exercises: [ex('Quelle instruction affiche du texte en PL/SQL ?',
              'DBMS_OUTPUT.PUT_LINE(\'...\').',
              'C\'est la sortie console PL/SQL.')],
          quiz: [
            q(QuizType.qcm, 'La section EXCEPTION d\'un bloc PL/SQL sert à :',
                ['Gérer les erreurs', 'Déclarer des variables', 'Créer des tables', 'Faire des jointures'],
                'Gérer les erreurs',
                'EXCEPTION gère les exceptions levées.'),
          ],
          xp: 40,
        ),
      ];

  static List<Lesson> mongodb() => [
        l(
          id: 'mongo_intro',
          track: 'mongodb',
          level: 0,
          title: 'MongoDB : les bases NoSQL document',
          objective: 'Comprendre MongoDB et le modèle document.',
          content: [
            'MongoDB est une base NoSQL orientée DOCUMENTS. Les données sont stockées en BSON (JSON binaire) dans des COLLECTIONS.',
            'Pas de tables ni de schéma fixe : chaque document peut avoir sa propre structure (schéma flexible).',
            'Une collection = un groupe de documents (comparable à une table). Un document = un enregistrement (comparable à une ligne).',
            'On l\'interroge avec un langage de requêtes JSON, pas du SQL.',
          ],
          codeBlocks: [
            code('js', '// Insérer un document\nuse boutique\ndb.products.insertOne({\n  name: "Souris",\n  price: 29.99,\n  stock: 60\n});',
                e: 'Un document JSON dans la collection products.'),
          ],
          mistakes: ['Chercher une structure de table stricte (il n\'y en a pas).',
              'Utiliser des jointures SQL (aucune ; on utilise l\'agrégation \$lookup).'],
          exercises: [ex('Comment s\'appelle l\'unité de stockage d\'un document ?',
              'La collection.',
              'Les documents sont rangés dans des collections.')],
          quiz: [
            q(QuizType.qcm, 'MongoDB stocke les données en :',
                ['Documents BSON', 'Tableaux Excel', 'Fichiers plats', 'Feuilles de calcul'],
                'Documents BSON', 'MongoDB est orienté document.'),
          ],
          xp: 20,
        ),
        l(
          id: 'mongo_query',
          track: 'mongodb',
          level: 1,
          title: 'Interroger avec find()',
          objective: 'Chercher des documents avec find et filtrer avec des opérateurs.',
          content: [
            'db.collection.find() retourne les documents d\'une collection.',
            'On filtre avec un objet de condition : {price: {\$lt: 50}}.',
            'Opérateurs : \$lt (moins), \$gt (plus), \$gte/\$lte, \$in, \$regex.',
            'Projection : deuxième paramètre pour choisir les champs à retourner.',
          ],
          codeBlocks: [
            code('js', '// Produits à moins de 50 €\ndb.products.find({ price: { \$lt: 50 } });',
                e: '\$lt = moins de.'),
            code('js', '// Trier par prix décroissant\ndb.products.find().sort({ price: -1 });',
                e: '-1 = décroissant.'),
          ],
          mistakes: ['Utiliser < au lieu de {\$lt: ...}.',
              'Oublier la syntaxe des opérateurs { champ: { op: valeur } }.'],
          exercises: [ex('Quel opérateur MongoDB signifie "moins de" ?',
              '\$lt.',
              '\$lt (less than).')],
          quiz: [
            q(QuizType.qcm, 'Pour trier décroissant en MongoDB on utilise sort({prix: ?})',
                ['-1', '1', '0', 'DESC'], '-1',
                '-1 signifie décroissant, 1 croissant.'),
          ],
          xp: 25,
        ),
        l(
          id: 'mongo_agg',
          track: 'mongodb',
          level: 2,
          title: 'Pipeline d\'agrégation',
          objective: 'Grouper et calculer avec l\'agrégation.',
          content: [
            'L\'agrégation MongoDB traite les documents via un PIPELINE d\'étapes.',
            '\$match filtre, \$group regroupe avec des accumulateurs (\$sum, \$avg, \$count).',
            '\$lookup permet de simuler une jointure entre collections.',
            'C\'est l\'équivalent de GROUP BY + agrégats du SQL.',
          ],
          codeBlocks: [
            code('js', '// Nombre de produits par catégorie\ndb.products.aggregate([\n  { \$group: { _id: "\$category", total: { \$sum: 1 } } }\n]);',
                e: 'Groupement + comptage.'),
          ],
          mistakes: ['Ne pas comprendre que _id du \$group est la clé de regroupement.',
              'Oublier \$ devant le nom de champ dans \$group (\$category).'],
          exercises: [ex('Quelle étape filtre dans le pipeline d\'agrégation ?',
              '\$match.',
              '\$match filtre les documents en amont du groupement.')],
          quiz: [
            q(QuizType.qcm, '\$sum est un :',
                ['Accumulateur', 'Filtre', 'Tri', 'Index'], 'Accumulateur',
                'Les accumulateurs (\$sum, \$avg) calculent dans \$group.'),
          ],
          xp: 30,
        ),
      ];

  static List<Lesson> redis() => [
        l(
          id: 'redis_intro',
          track: 'redis',
          level: 0,
          title: 'Redis : le cache clé-valeur en mémoire',
          objective: 'Comprendre les bases de données clé-valeur et Redis.',
          content: [
            'Redis est une base NoSQL de type CLÉ-VALEUR, stockée EN MÉMOIRE (très rapide).',
            'Chaque donnée est associée à une clé unique. On lit et écrit avec GET/SET.',
            'Il sert surtout de cache, de file de messages, de gestionnaire de sessions.',
            'Port par défaut : 6379.',
          ],
          codeBlocks: [
            code('bash', 'SET produit:1 "Souris"\nGET produit:1\nDEL produit:1',
                e: 'Commandes Redis de base.'),
          ],
          mistakes: ['Oublier que Redis est en mémoire (les données peuvent être volatiles).',
              'Utiliser du SQL avec Redis (ce n\'est pas relationnel).'],
          exercises: [ex('Quel type de base est Redis ?',
              'NoSQL clé-valeur en mémoire.',
              'Stockage clé-valeur ultra rapide.')],
          quiz: [
            q(QuizType.qcm, 'Redis stocke les données principalement :',
                ['En mémoire', 'Sur un disque dur lent', 'Dans le cache navigateur', 'Dans des fichiers texte'],
                'En mémoire', 'C\'est un stockage en mémoire pour la vitesse.'),
          ],
          xp: 20,
        ),
        l(
          id: 'redis_types',
          track: 'redis',
          level: 1,
          title: 'Les types de données Redis',
          objective: 'Découvrir les structures Redis : chaînes, hash, listes, sets.',
          content: [
            'Au-delà des chaînes, Redis offre des structures riches : HASH (objet), LIST, SET (ensemble sans doublon), ZSET (set trié), Streams.',
            'HSET pour un objet : HSET user:1 name Alice age 30.',
            'Les TTL (expiration) permettent de faire expirer des clés : EXPIRE clé secondes.',
            'Ces structures sont optimisées pour des cas concrets (files, classements).',
          ],
          codeBlocks: [
            code('bash', 'HSET user:1 name Alice age 30\nHGETALL user:1\nSET session:42 "abc"\nEXPIRE session:42 3600',
                e: 'Un objet (hash) et une clé avec expiration.'),
          ],
          mistakes: ['Utiliser une seule structure pour tout.',
              'Oublier d\'expirer les caches pour éviter la surcharge mémoire.'],
          exercises: [ex('Quelle commande expire une clé ?',
              'EXPIRE clé secondes.',
              'EXPIRE fixe une durée de vie.')],
          quiz: [
            q(QuizType.qcm, 'HSET crée une structure de type :',
                ['Hash (objet)', 'Liste', 'Float', 'Table'], 'Hash (objet)',
                'Un hash représente un objet avec plusieurs champs.'),
          ],
          xp: 25,
        ),
      ];
}
