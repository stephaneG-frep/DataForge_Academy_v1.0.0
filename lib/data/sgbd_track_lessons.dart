import '../models/lesson_models.dart';

/// SGBD-specific tracks: SQLite, PostgreSQL, MySQL, MariaDB, SQL Server,
/// Oracle, MongoDB, Redis.
///
/// Conventions (checked by test/lesson_content_test.dart):
/// - SQL examples that run in the app's Console start with `-- base : <id>`;
///   examples for other SGBD are illustrative and carry no tag;
/// - runnable exercises end with `(base <id>)`.
///
/// Quiz progress is stored per question index (`<lessonId>#q<i>`): never
/// reorder or remove existing quiz items, only append new ones.
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

  static QuizItem tf(String question, bool correct, String explanation) =>
      q(QuizType.trueFalse, question, const ['Vrai', 'Faux'],
          correct ? 'Vrai' : 'Faux', explanation);

  static ExerciseItem ex(String q, String a, String e) => ExerciseItem(q, a, e);

  // =====================================================================
  // SQLITE
  // =====================================================================
  static List<Lesson> sqlite() => [
        l(
          id: 'sqlite_intro',
          track: 'sqlite',
          level: 0,
          title: 'SQLite : la base embarquée',
          objective: "Comprendre ce qu'est SQLite, ses forces et ses limites.",
          content: [
            "SQLite est une base de données relationnelle EMBARQUÉE : pas de serveur à installer ni de port à ouvrir. Toute la base (tables, index, données) tient dans un seul fichier, que l'application ouvre directement.",
            "C'est la base de données la plus déployée au monde : elle est intégrée à Android, iOS, macOS, aux navigateurs (Chrome, Firefox), à Python, et à d'innombrables applications. Ton téléphone en contient des dizaines.",
            "Elle respecte une grande partie du SQL standard : jointures, sous-requêtes, vues, triggers, CTE, fonctions de fenêtrage. Ses transactions sont ACID, même en cas de coupure de courant.",
            "Sa limite principale : une seule écriture à la fois. Elle convient parfaitement à une application mobile, un logiciel de bureau, un petit site ou des tests, mais pas à un serveur qui reçoit des milliers d'écritures simultanées : là, on choisit PostgreSQL ou MySQL.",
            "Le fichier est portable : on peut le copier, l'envoyer, l'ouvrir sur un autre système. L'outil en ligne de commande sqlite3 permet de l'explorer.",
            "La Console de cette application utilise SQLite : tout ce que tu y tapes est exécuté par un vrai moteur SQLite.",
          ],
          codeBlocks: [
            code('sql', "-- base : boutique\nSELECT sqlite_version() AS version;",
                e: "Affiche la version du moteur SQLite utilisé par la Console."),
            code('sql', "-- base : boutique\nSELECT * FROM products LIMIT 5;",
                e: "Même syntaxe SQL qu'ailleurs, mais les données sont lues dans un simple fichier (ici en mémoire)."),
            code('bash', "sqlite3 boutique.db\nsqlite> .tables\nsqlite> SELECT COUNT(*) FROM products;\nsqlite> .quit",
                e: "L'outil sqlite3 en ligne de commande : .tables et .quit sont des commandes de l'outil, pas du SQL."),
          ],
          mistakes: [
            "Penser que SQLite a besoin d'un serveur et d'un port.",
            "Utiliser SQLite pour de très fortes charges d'écriture concurrentes.",
            "Croire que SQLite est une « fausse » base : elle est ACID et très fiable.",
          ],
          exercises: [
            ex("Qu'est-ce qui distingue SQLite des autres SGBD ?",
                "C'est une base embarquée stockée dans un fichier, sans serveur.",
                "Elle s'intègre dans l'application elle-même."),
            ex("Affiche la version de SQLite utilisée par la Console. (base boutique)",
                "SELECT sqlite_version();",
                "sqlite_version() est une fonction propre à SQLite."),
          ],
          quiz: [
            q(QuizType.qcm, 'SQLite stocke ses données dans :',
                ['Un fichier unique', 'Plusieurs serveurs', 'Un navigateur', 'Un fichier texte non structuré'],
                'Un fichier unique',
                'Toute la base tient dans un seul fichier portable.'),
            q(QuizType.qcm, "Dans quel cas SQLite est-il le meilleur choix ?",
                ["Une application mobile qui stocke ses données localement", "Un site avec des milliers d'écritures simultanées", "Un entrepôt de données partagé par 100 serveurs", "Un cluster distribué mondial"],
                "Une application mobile qui stocke ses données localement",
                "SQLite excelle pour le stockage local d'une application."),
            tf("SQLite nécessite d'installer un serveur et d'ouvrir un port.", false,
                "SQLite est embarquée : l'application ouvre directement le fichier."),
          ],
          xp: 20,
        ),
        l(
          id: 'sqlite_types',
          track: 'sqlite',
          level: 1,
          title: 'Types et syntaxe SQLite',
          objective: "Connaître le typage souple de SQLite et ses fonctions utiles.",
          content: [
            "SQLite stocke chaque valeur dans l'une de 5 classes : INTEGER (entier), REAL (décimal), TEXT (texte), BLOB (binaire brut) et NULL.",
            "Le type déclaré d'une colonne ne fixe qu'une AFFINITÉ, une préférence. Une colonne INTEGER convertit '123' en nombre 123, mais accepte 'abc' tel quel, sous forme de texte. C'est très différent de PostgreSQL, qui refuserait.",
            "La fonction typeof(valeur) révèle la classe réellement stockée. Depuis SQLite 3.37, on peut aussi créer une table STRICT (CREATE TABLE … STRICT), dont les types sont vérifiés comme dans les autres SGBD.",
            "Il n'y a pas de type DATE ni BOOLEAN dédié. Les dates se stockent en TEXT au format AAAA-MM-JJ (ou en nombre), et les booléens en INTEGER 0 ou 1. Les fonctions date(), time(), datetime() et strftime() manipulent ces dates.",
            "Une colonne INTEGER PRIMARY KEY devient l'identifiant interne de la ligne (rowid) et se remplit automatiquement. AUTOINCREMENT ajoute seulement la garantie qu'un id supprimé ne sera jamais réutilisé.",
            "Fonctions utiles : upper(), lower(), length(), substr(), replace(), trim(), round(), coalesce(), ifnull(), et || pour concaténer.",
          ],
          codeBlocks: [
            code('sql', "-- base : boutique\nSELECT typeof(42), typeof(4.2), typeof('42'), typeof(NULL);",
                e: "integer, real, text, null : la classe réellement stockée."),
            code('sql', "-- base : boutique\nCREATE TABLE test_affinite (n INTEGER);\nINSERT INTO test_affinite VALUES ('123'), ('abc');\nSELECT n, typeof(n) FROM test_affinite;",
                e: "'123' est converti en entier, 'abc' reste du texte : c'est l'affinité."),
            code('sql', "-- base : boutique\nSELECT upper('bonjour') AS maj,\n       datetime('now') AS maintenant,\n       date('now', '+7 days') AS dans_une_semaine;",
                e: "Fonctions de texte et de date."),
          ],
          mistakes: [
            "Écrire des types comme VARCHAR(50) en croyant que la longueur est contrôlée : SQLite l'accepte mais l'ignore.",
            "Oublier que SQLite est peu typé : le même code peut échouer sur un SGBD plus strict.",
            "Stocker des dates dans un format libre (19/11/2026) au lieu de AAAA-MM-JJ : tri et comparaisons deviennent faux.",
          ],
          exercises: [
            ex("Quelle fonction SQLite renvoie la date et l'heure actuelles ? (base boutique)",
                "SELECT datetime('now');",
                "La fonction datetime avec l'argument 'now'."),
            ex("Affiche la classe de stockage de chaque colonne de la première ligne de products. (base boutique)",
                "SELECT typeof(id), typeof(name), typeof(price), typeof(stock) FROM products LIMIT 1;",
                "typeof() s'applique à n'importe quelle colonne."),
          ],
          quiz: [
            q(QuizType.trueFalse, 'SQLite est typé de façon très stricte.',
                ['Vrai', 'Faux'], 'Faux',
                'SQLite utilise des affinités souples, pas de typage strict.'),
            q(QuizType.predictResult, "Que renvoie typeof(3.5) ?",
                ["real", "integer", "text", "numeric"], "real",
                "3.5 est un nombre à virgule : classe REAL."),
            q(QuizType.qcm, "Comment SQLite stocke-t-il un booléen ?",
                ["0 ou 1 (INTEGER)", "Un type BOOLEAN natif", "Obligatoirement le texte TRUE ou FALSE", "Il ne peut pas"],
                "0 ou 1 (INTEGER)",
                "SQLite n'a pas de type booléen : TRUE vaut 1 et FALSE vaut 0."),
          ],
          xp: 25,
        ),
        l(
          id: 'sqlite_pragma',
          track: 'sqlite',
          level: 2,
          title: 'PRAGMA et introspection',
          objective: "Explorer et régler une base SQLite avec PRAGMA et sqlite_master.",
          content: [
            "PRAGMA est une commande propre à SQLite pour interroger ou modifier le fonctionnement de la base. Elle n'existe pas dans MySQL ni PostgreSQL.",
            "PRAGMA table_info(table) liste les colonnes d'une table : nom, type, NOT NULL, valeur par défaut, clé primaire. PRAGMA foreign_key_list(table) et PRAGMA index_list(table) montrent les clés étrangères et les index.",
            "La table interne sqlite_master (aussi appelée sqlite_schema) contient la définition de tous les objets : tables, index, vues, triggers, avec leur CREATE d'origine. On l'interroge avec un SELECT normal.",
            "Piège important : dans SQLite, les clés étrangères ne sont PAS vérifiées par défaut. Il faut exécuter PRAGMA foreign_keys = ON à chaque ouverture de connexion. La Console de l'application le fait pour toi.",
            "D'autres réglages : PRAGMA journal_mode = WAL (lectures et écriture simultanées, recommandé pour une application), PRAGMA integrity_check (vérifie que le fichier n'est pas corrompu).",
            "Dans l'outil sqlite3, .tables et .schema sont des raccourcis pratiques, mais ce ne sont pas des commandes SQL : ils ne marchent ni dans la Console ni dans un programme.",
          ],
          codeBlocks: [
            code('sql', "-- base : boutique\nPRAGMA table_info(products);",
                e: "Colonnes, types et clé primaire de la table products."),
            code('sql', "-- base : boutique\nSELECT name, sql FROM sqlite_master WHERE type = 'table';",
                e: "Toutes les tables et leur CREATE TABLE d'origine."),
            code('sql', "-- base : employes\nPRAGMA foreign_keys;",
                e: "Renvoie 1 : la Console a activé la vérification des clés étrangères."),
            code('sql', "-- base : boutique\nPRAGMA integrity_check;",
                e: "Renvoie ok si le fichier de la base est sain."),
          ],
          mistakes: [
            "Chercher PRAGMA dans MySQL ou PostgreSQL : c'est propre à SQLite.",
            "Essayer de modifier sqlite_master à la main : elle est gérée par SQLite.",
            "Oublier PRAGMA foreign_keys = ON : les clés étrangères ne sont alors pas vérifiées.",
          ],
          exercises: [
            ex("Liste les colonnes de la table employes. (base employes)",
                "PRAGMA table_info(employes);",
                "C'est l'introspection SQLite."),
            ex("Liste le nom de toutes les tables de la base. (base ecole)",
                "SELECT name FROM sqlite_master WHERE type = 'table';",
                "sqlite_master s'interroge comme une table normale."),
          ],
          quiz: [
            q(QuizType.qcm, "Quel PRAGMA liste les colonnes d'une table ?",
                ['table_info', 'columns', 'show_fields', 'describe'],
                'table_info', 'PRAGMA table_info(nom_table).'),
            tf("Dans SQLite, les clés étrangères sont vérifiées par défaut, sans réglage.", false,
                "Il faut PRAGMA foreign_keys = ON à chaque connexion."),
            q(QuizType.qcm, "Quelle table interne contient la définition de toutes les tables ?",
                ["sqlite_master", "information_schema.tables", "sys.tables", "pg_catalog"],
                "sqlite_master",
                "Les autres sont les équivalents de MySQL/PostgreSQL et de SQL Server."),
          ],
          xp: 30,
        ),
      ];

  // =====================================================================
  // POSTGRESQL
  // =====================================================================
  static List<Lesson> postgres() => [
        l(
          id: 'pg_intro',
          track: 'postgres',
          level: 0,
          title: 'PostgreSQL : le SGBD open source avancé',
          objective: "Découvrir PostgreSQL, son fonctionnement client-serveur et ses outils.",
          content: [
            "PostgreSQL (« Postgres ») est un SGBD relationnel open source, développé depuis plus de 30 ans. Il est réputé pour sa fiabilité, sa conformité au standard SQL et sa richesse fonctionnelle.",
            "Il fonctionne en client-serveur : un serveur tourne en permanence (port 5432 par défaut) et des clients s'y connectent par le réseau avec un utilisateur et un mot de passe. Plusieurs utilisateurs peuvent lire et écrire en même temps.",
            "Ses points forts : types avancés (JSONB, tableaux, UUID, intervalles), extensions (PostGIS pour la géographie, pgvector pour l'IA), contrôle de concurrence MVCC (les lectures ne bloquent pas les écritures), et un optimiseur de requêtes performant.",
            "Le client officiel est psql, en ligne de commande. Il a ses propres méta-commandes qui commencent par un antislash : \\l (bases), \\c (connexion), \\dt (tables), \\d table (structure), \\q (quitter). Des outils graphiques existent aussi : pgAdmin, DBeaver.",
            "Attention aux guillemets : en PostgreSQL, 'texte' est une chaîne et \"nom\" désigne un identifiant (colonne, table). Les noms non entourés de guillemets sont convertis en minuscules.",
            "Le SQL que tu apprends dans la Console (SQLite) fonctionne presque tel quel dans PostgreSQL. Les différences portent surtout sur les types, plus stricts, et sur quelques fonctions.",
          ],
          codeBlocks: [
            code('bash', "psql -U utilisateur -d mabase -h localhost",
                e: "Connexion au serveur avec le client psql."),
            code('psql', "\\l              -- liste les bases\n\\c mabase       -- se connecte à une base\n\\dt             -- liste les tables\n\\d clients      -- structure de la table clients\n\\q              -- quitte psql",
                e: "Les méta-commandes de psql (ce n'est pas du SQL)."),
            code('PostgreSQL', "SELECT version();\nSELECT current_database(), current_user;",
                e: "La version du serveur, la base et l'utilisateur courants."),
          ],
          mistakes: [
            "Confondre le port de PostgreSQL (5432) avec celui de MySQL (3306).",
            "Oublier que c'est un modèle client-serveur : le serveur doit être démarré.",
            "Utiliser des guillemets doubles pour les textes : \"Paris\" désigne une colonne, 'Paris' un texte.",
          ],
          exercises: [
            ex("PostgreSQL est-il un modèle client-serveur ou embarqué ?",
                "Client-serveur.",
                "Un serveur reçoit les connexions sur le réseau."),
            ex("Quelle méta-commande psql liste les tables de la base courante ?",
                "\\dt",
                "\\l liste les bases, \\dt les tables, \\d table décrit une table."),
          ],
          quiz: [
            q(QuizType.qcm, 'Quel est le port par défaut de PostgreSQL ?',
                ['5432', '3306', '27017', '6379'], '5432',
                '5432 pour Postgres, 3306 pour MySQL.'),
            q(QuizType.qcm, "Quelle commande psql liste les tables ?",
                ["\\dt", "SHOW TABLES;", ".tables", "sp_tables"], "\\dt",
                "SHOW TABLES est MySQL, .tables est l'outil sqlite3."),
            tf("PostgreSQL est un SGBD embarqué sans serveur, comme SQLite.", false,
                "PostgreSQL fonctionne avec un serveur auquel les clients se connectent."),
          ],
          xp: 20,
        ),
        l(
          id: 'pg_types',
          track: 'postgres',
          level: 1,
          title: 'Types avancés et SERIAL',
          objective: "Utiliser les types PostgreSQL : identités, JSONB, tableaux, dates avec fuseau.",
          content: [
            "PostgreSQL est strictement typé : insérer 'abc' dans une colonne INTEGER provoque une erreur. Les conversions se font explicitement avec CAST(x AS type) ou la notation courte x::type.",
            "Auto-incrément : l'ancienne écriture id SERIAL PRIMARY KEY crée une séquence. La syntaxe standard moderne est id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY.",
            "JSON et JSONB stockent des documents JSON. JSONB est stocké sous forme binaire : il est plus rapide à interroger et peut être indexé (index GIN). Opérateurs : -> renvoie un élément JSON, ->> le renvoie en texte, @> teste si un document en contient un autre.",
            "Autres types utiles : UUID (identifiants uniques), TEXT[] (tableaux), NUMERIC(10,2) (montants exacts), INET (adresses IP), TSTZRANGE (périodes), et les types géographiques avec PostGIS.",
            "Pour les dates, préfère TIMESTAMPTZ (avec fuseau horaire) à TIMESTAMP : PostgreSQL stocke l'instant exact et l'affiche dans le fuseau de la session. NOW() donne l'instant courant.",
            "Ces types riches évitent souvent une table supplémentaire, mais garde le relationnel pour les données structurées : JSONB est fait pour les données vraiment variables.",
          ],
          codeBlocks: [
            code('PostgreSQL', "CREATE TABLE clients (\n  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,\n  nom TEXT NOT NULL,\n  tags TEXT[],\n  metadatas JSONB,\n  cree_le TIMESTAMPTZ DEFAULT NOW()\n);",
                e: "Identité, tableau de textes, JSON binaire et date avec fuseau."),
            code('PostgreSQL', "SELECT nom, metadatas->>'ville' AS ville\nFROM clients\nWHERE metadatas @> '{\"vip\": true}';",
                e: "Lire un champ JSON en texte et filtrer les clients VIP."),
            code('PostgreSQL', "SELECT '42'::INTEGER + 1 AS resultat,\n       NOW()::DATE AS aujourd_hui;",
                e: "Conversions explicites avec ::."),
          ],
          mistakes: [
            "Confondre JSON et JSONB (le B est binaire et indexable).",
            "Utiliser AUTO_INCREMENT (MySQL) à la place de SERIAL ou IDENTITY.",
            "Utiliser TIMESTAMP sans fuseau pour des événements : préfère TIMESTAMPTZ.",
          ],
          exercises: [
            ex("Que fait SERIAL dans PostgreSQL ?",
                "Il crée un auto-incrément pour la colonne.",
                "SERIAL repose sur une séquence."),
            ex("Écris la requête qui lit le champ « ville », en texte, de la colonne JSONB metadatas de la table clients.",
                "SELECT metadatas->>'ville' FROM clients;",
                "->> renvoie du texte, -> renverrait du JSON."),
          ],
          quiz: [
            q(QuizType.qcm, 'Quel type stocke du JSON indexable ?',
                ['JSONB', 'VARCHAR', 'BLOB', 'TEXTARRAY'], 'JSONB',
                'JSONB est la version binaire indexable.'),
            q(QuizType.qcm, "Quel opérateur extrait un champ JSONB sous forme de texte ?",
                ["->>", "->", "@>", "::"], "->>",
                "-> renvoie du JSON, ->> du texte."),
            q(QuizType.qcm, "Quelle syntaxe standard moderne crée un auto-incrément ?",
                ["GENERATED ALWAYS AS IDENTITY", "AUTO_INCREMENT", "IDENTITY(1,1)", "ROWNUM"],
                "GENERATED ALWAYS AS IDENTITY",
                "AUTO_INCREMENT est MySQL, IDENTITY(1,1) est SQL Server."),
          ],
          xp: 25,
        ),
        l(
          id: 'pg_plsql',
          track: 'postgres',
          level: 3,
          title: 'PL/pgSQL : fonctions et procédures',
          objective: "Écrire des fonctions, des procédures et des triggers en PL/pgSQL.",
          content: [
            "PL/pgSQL est le langage procédural de PostgreSQL. Il ajoute au SQL des variables, des conditions (IF), des boucles (LOOP, FOR, WHILE) et la gestion d'erreurs, pour écrire des fonctions, des procédures et des triggers.",
            r"Le corps d'une fonction s'écrit entre deux délimiteurs $$ (dollar quoting), ce qui évite d'avoir à doubler les apostrophes à l'intérieur. La fonction se termine par LANGUAGE plpgsql.",
            "Une fonction (CREATE FUNCTION) renvoie une valeur ou une table (RETURNS TABLE) et s'appelle dans un SELECT. Une procédure (CREATE PROCEDURE, depuis PostgreSQL 11) ne renvoie rien, s'appelle avec CALL et peut faire COMMIT ou ROLLBACK.",
            "Les variables se déclarent dans une section DECLARE, avant BEGIN. On peut leur donner le type d'une colonne avec nom_table.colonne%TYPE.",
            "Un trigger exécute automatiquement une fonction avant ou après un INSERT, un UPDATE ou un DELETE. La fonction de trigger renvoie le type TRIGGER et accède à la ligne via NEW et OLD. Exemple classique : mettre à jour une date de modification.",
            "Mettre de la logique dans la base garantit qu'elle s'applique à toutes les applications. Mais trop de logique en base devient difficile à tester et à versionner : réserve-la aux règles d'intégrité et aux traitements de données lourds.",
          ],
          codeBlocks: [
            code('PostgreSQL', r'''CREATE FUNCTION prix_total(p_qte INT, p_prix NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
  RETURN p_qte * p_prix;
END;
$$ LANGUAGE plpgsql;

SELECT prix_total(3, 9.90);''',
                e: "Une fonction simple, appelée dans un SELECT."),
            code('PostgreSQL', r'''CREATE FUNCTION maj_date() RETURNS TRIGGER AS $$
BEGIN
  NEW.modifie_le := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_maj_date
BEFORE UPDATE ON produits
FOR EACH ROW EXECUTE FUNCTION maj_date();''',
                e: "Un trigger qui met à jour la date de modification à chaque UPDATE."),
            code('PostgreSQL', r'''CREATE PROCEDURE archiver_commandes(p_avant DATE)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO commandes_archive SELECT * FROM commandes WHERE date_cmd < p_avant;
  DELETE FROM commandes WHERE date_cmd < p_avant;
  COMMIT;
END;
$$;

CALL archiver_commandes('2025-01-01');''',
                e: "Une procédure, appelée avec CALL, qui valide elle-même son travail."),
          ],
          mistakes: [
            "Oublier LANGUAGE plpgsql à la fin.",
            "Faire un RETURN de valeur dans une procédure (qui ne retourne rien).",
            "Mettre toute la logique métier dans la base : elle devient difficile à tester et à versionner.",
          ],
          exercises: [
            ex(r"Quel délimiteur entoure le corps d'une fonction PL/pgSQL ?",
                r"$$ (le dollar quoting).",
                "Il évite de doubler les apostrophes à l'intérieur du code."),
            ex("Écris l'appel de la fonction prix_total pour 3 articles à 9,90 €.",
                "SELECT prix_total(3, 9.90);",
                "Une fonction s'appelle dans un SELECT."),
          ],
          quiz: [
            q(QuizType.qcm, "Le langage procédural natif de PostgreSQL s'appelle :",
                ['PL/pgSQL', 'T-SQL', 'PL/SQL', 'MySQLi'], 'PL/pgSQL',
                'PL/pgSQL est propre à PostgreSQL.'),
            q(QuizType.qcm, "Comment appelle-t-on une procédure (PostgreSQL 11+) ?",
                ["CALL ma_procedure();", "EXEC ma_procedure;", "RUN ma_procedure;", "PERFORM PROCEDURE;"],
                "CALL ma_procedure();",
                "EXEC est la syntaxe de SQL Server."),
            tf("Une fonction de trigger PL/pgSQL renvoie le type TRIGGER.", true,
                "Elle renvoie NEW (ou OLD) pour indiquer la ligne à utiliser."),
          ],
          xp: 40,
        ),
      ];

  // =====================================================================
  // MYSQL
  // =====================================================================
  static List<Lesson> mysql() => [
        l(
          id: 'mysql_intro',
          track: 'mysql',
          level: 0,
          title: 'MySQL : le SGBD le plus populaire du web',
          objective: "Découvrir MySQL, ses outils et les particularités de son SQL.",
          content: [
            "MySQL est un SGBD relationnel open source, l'un des plus utilisés au monde. Il est historiquement associé à PHP dans la pile LAMP (Linux, Apache, MySQL, PHP) et fait tourner WordPress, Drupal et d'innombrables sites.",
            "Il fonctionne en client-serveur, sur le port 3306 par défaut. On s'y connecte avec le client en ligne de commande mysql, ou avec des outils graphiques : MySQL Workbench, phpMyAdmin, DBeaver.",
            "MySQL appartient à Oracle depuis 2010. Ce rachat a conduit les créateurs d'origine à lancer MariaDB, un fork resté entièrement communautaire.",
            "Quelques particularités de son SQL : les identifiants peuvent s'écrire entre accents graves (`nom`), l'auto-incrément s'écrit AUTO_INCREMENT, et la concaténation se fait avec CONCAT() plutôt qu'avec ||. LIMIT existe comme dans SQLite.",
            "Depuis la version 8, MySQL gère les CTE (WITH), les fonctions de fenêtrage et un vrai type JSON : la plupart des notions vues dans le parcours SQL s'appliquent directement.",
            "Pour l'encodage, utilise toujours utf8mb4 : le jeu « utf8 » historique de MySQL est incomplet et ne stocke pas les émojis.",
          ],
          codeBlocks: [
            code('bash', "mysql -u root -p -h localhost",
                e: "Connexion avec le client mysql (le mot de passe est demandé)."),
            code('MySQL', "SHOW DATABASES;\nUSE boutique;\nSHOW TABLES;\nDESCRIBE products;",
                e: "Lister les bases, en choisir une, lister ses tables et décrire une table."),
            code('MySQL', "SELECT `name`, price\nFROM products\nORDER BY price DESC\nLIMIT 5;",
                e: "Les accents graves autour des identifiants sont propres à MySQL (facultatifs ici)."),
          ],
          mistakes: [
            "Confondre les commandes : SHOW TABLES (MySQL), \\dt (PostgreSQL), .tables (outil sqlite3).",
            "Se connecter en root depuis l'application : crée un utilisateur dédié avec les seuls droits utiles.",
            "Choisir l'encodage utf8 au lieu de utf8mb4 : les émojis ne passent pas.",
          ],
          exercises: [
            ex("Quel est le port par défaut de MySQL ?",
                "3306.", "C'est le port MySQL standard."),
            ex("Quelle commande affiche la structure de la table products ?",
                "DESCRIBE products; (ou SHOW COLUMNS FROM products;)",
                "DESCRIBE liste les colonnes, leurs types et les clés."),
          ],
          quiz: [
            q(QuizType.qcm, 'MySQL est souvent associé à quel langage côté serveur web ?',
                ['PHP', 'FORTRAN', 'COBOL', 'Assembly'], 'PHP',
                'MySQL et PHP forment le duo classique de la pile LAMP.'),
            q(QuizType.qcm, "Quel est le port par défaut de MySQL ?",
                ["3306", "5432", "1433", "6379"], "3306",
                "5432 est PostgreSQL, 1433 SQL Server, 6379 Redis."),
            q(QuizType.qcm, "Quel jeu de caractères stocke tout l'Unicode, émojis compris ?",
                ["utf8mb4", "utf8", "latin1", "ascii"], "utf8mb4",
                "Le « utf8 » de MySQL est limité à 3 octets par caractère."),
          ],
          xp: 20,
        ),
        l(
          id: 'mysql_engine',
          track: 'mysql',
          level: 2,
          title: 'Moteurs de stockage : InnoDB',
          objective: "Comprendre les moteurs de stockage MySQL et choisir le bon.",
          content: [
            "MySQL sépare la partie SQL du stockage physique : chaque table utilise un MOTEUR de stockage, choisi à sa création. C'est une particularité de MySQL et de MariaDB.",
            "InnoDB est le moteur par défaut depuis MySQL 5.5, et celui qu'il faut presque toujours utiliser. Il gère les transactions ACID, les clés étrangères, le verrouillage ligne par ligne (deux utilisateurs peuvent modifier deux lignes différentes en même temps) et la récupération automatique après une panne.",
            "MyISAM, l'ancien moteur par défaut, ne gère ni les transactions ni les clés étrangères, et verrouille toute la table à chaque écriture. On ne le rencontre plus que dans de vieilles bases.",
            "MEMORY garde la table en mémoire vive : très rapide, mais son contenu disparaît au redémarrage du serveur. Il convient seulement à des données temporaires.",
            "On choisit le moteur avec ENGINE=… dans le CREATE TABLE, on le vérifie avec SHOW TABLE STATUS ou dans information_schema.tables, et on convertit une table avec ALTER TABLE … ENGINE = InnoDB.",
            "En MySQL, une transaction s'ouvre avec START TRANSACTION (ou BEGIN) et se termine par COMMIT ou ROLLBACK. Seules les tables InnoDB sont concernées par le ROLLBACK.",
          ],
          codeBlocks: [
            code('MySQL', "CREATE TABLE produits (\n  id INT AUTO_INCREMENT PRIMARY KEY,\n  name VARCHAR(100) NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;",
                e: "AUTO_INCREMENT, moteur InnoDB et encodage utf8mb4."),
            code('MySQL', "SELECT table_name, engine\nFROM information_schema.tables\nWHERE table_schema = 'boutique';",
                e: "Le moteur de chaque table de la base boutique."),
            code('MySQL', "ALTER TABLE vieille_table ENGINE = InnoDB;\n\nSTART TRANSACTION;\nUPDATE comptes SET solde = solde - 100 WHERE id = 1;\nUPDATE comptes SET solde = solde + 100 WHERE id = 2;\nCOMMIT;",
                e: "Convertir une table MyISAM, puis une transaction en MySQL."),
          ],
          mistakes: [
            "Choisir MyISAM quand on a besoin de transactions ou de clés étrangères.",
            "Stocker des données importantes dans une table MEMORY : elles disparaissent au redémarrage.",
            "Mélanger InnoDB et MyISAM dans une transaction : les tables MyISAM ne sont pas annulées par ROLLBACK.",
          ],
          exercises: [
            ex("Quel moteur supporte les transactions ?",
                "InnoDB.", "MyISAM, lui, ne les supporte pas."),
            ex("Écris la commande qui convertit la table logs au moteur InnoDB.",
                "ALTER TABLE logs ENGINE = InnoDB;",
                "ALTER TABLE … ENGINE change le moteur d'une table existante."),
          ],
          quiz: [
            q(QuizType.qcm, 'AUTO_INCREMENT est spécifique à :',
                ['MySQL/MariaDB', 'PostgreSQL', 'Oracle', 'SQL Server'], 'MySQL/MariaDB',
                "MySQL utilise AUTO_INCREMENT pour l'auto-incrément."),
            q(QuizType.qcm, "Quel est le moteur par défaut de MySQL moderne ?",
                ["InnoDB", "MyISAM", "MEMORY", "CSV"], "InnoDB",
                "InnoDB est le moteur par défaut depuis MySQL 5.5."),
            tf("MyISAM gère les clés étrangères et les transactions.", false,
                "C'est justement ce qui manque à MyISAM."),
          ],
          xp: 30,
        ),
      ];

  // =====================================================================
  // MARIADB
  // =====================================================================
  static List<Lesson> mariadb() => [
        l(
          id: 'mariadb_intro',
          track: 'mariadb',
          level: 0,
          title: 'MariaDB : le fork communautaire de MySQL',
          objective: "Comprendre l'origine de MariaDB et ses différences avec MySQL.",
          content: [
            "MariaDB est un fork de MySQL, lancé en 2009 par Michael « Monty » Widenius, le créateur de MySQL, après le rachat de MySQL par Oracle. Il est développé par une fondation et reste entièrement open source.",
            "Il est compatible avec MySQL pour l'essentiel : même protocole, même port (3306), mêmes clients, mêmes commandes (SHOW TABLES, DESCRIBE…). Une application MySQL classique fonctionne en général sans modification.",
            "Les deux projets ont cependant divergé depuis MySQL 8 : le type JSON, certaines fonctions ou le système d'authentification diffèrent. Pour une application récente, teste sur le SGBD que tu utiliseras réellement.",
            "MariaDB est le serveur MySQL par défaut de nombreuses distributions Linux (Debian, Ubuntu, Fedora) et de beaucoup d'hébergeurs.",
            "Il apporte des fonctionnalités propres : séquences (CREATE SEQUENCE), tables versionnées dans le temps (on peut interroger l'état d'une table à une date passée), clustering Galera multi-maîtres, et des moteurs de stockage supplémentaires.",
            "Après l'installation, lance mariadb-secure-installation : il supprime les comptes anonymes et la base de test, et sécurise le compte root.",
          ],
          codeBlocks: [
            code('MariaDB', "SELECT VERSION();",
                e: "Affiche la version, par exemple 11.4.x-MariaDB."),
            code('bash', "sudo apt install mariadb-server\nsudo mariadb-secure-installation\nsudo mariadb -u root -p",
                e: "Installation sur Debian/Ubuntu, sécurisation, puis connexion."),
            code('MariaDB', "CREATE SEQUENCE seq_facture START WITH 1000;\nSELECT NEXTVAL(seq_facture);",
                e: "Une séquence : un compteur indépendant de toute table, ici pour numéroter des factures."),
          ],
          mistakes: [
            "Croire que MariaDB n'est pas compatible avec MySQL.",
            "Croire à l'inverse qu'ils sont identiques à 100 % : depuis MySQL 8, certaines fonctions divergent.",
            "Oublier de lancer mariadb-secure-installation après l'installation.",
          ],
          exercises: [
            ex("De quoi MariaDB est-il issu ?",
                "D'un fork de MySQL.",
                "Les développeurs initiaux de MySQL l'ont créé."),
            ex("Quelle requête affiche la version du serveur MariaDB ?",
                "SELECT VERSION();",
                "La même requête fonctionne dans MySQL."),
          ],
          quiz: [
            q(QuizType.trueFalse, 'MariaDB est un fork open source de MySQL.',
                ['Vrai', 'Faux'], 'Vrai',
                'MariaDB est le fork communautaire de MySQL.'),
            q(QuizType.qcm, "Pourquoi MariaDB a-t-il été créé ?",
                ["Après le rachat de MySQL par Oracle", "Pour remplacer PostgreSQL", "Pour faire du NoSQL", "Pour fonctionner uniquement sous Windows"],
                "Après le rachat de MySQL par Oracle",
                "Ses créateurs voulaient garantir un MySQL entièrement libre."),
            q(QuizType.qcm, "Quel est le port par défaut de MariaDB ?",
                ["3306", "5432", "27017", "1521"], "3306",
                "Le même que MySQL, puisque le protocole est compatible."),
          ],
          xp: 20,
        ),
        l(
          id: 'mariadb_storage',
          track: 'mariadb',
          level: 2,
          title: 'Moteurs de stockage supplémentaires',
          objective: "Connaître les moteurs propres à MariaDB et savoir quand les utiliser.",
          content: [
            "Comme MySQL, MariaDB choisit un moteur de stockage par table. InnoDB reste le moteur par défaut et le bon choix pour la grande majorité des tables. MariaDB en propose d'autres pour des besoins précis.",
            "Aria remplace MyISAM avec une meilleure résistance aux pannes. MariaDB l'utilise pour ses tables système et ses tables temporaires internes.",
            "ColumnStore stocke les données par colonne plutôt que par ligne. Il est idéal pour l'analytique : additionner une colonne sur des millions de lignes est très rapide, mais modifier des lignes une à une est lent.",
            "MyRocks (moteur RocksDB) compresse fortement les données et supporte très bien les écritures massives : journaux, événements, historiques.",
            "Spider répartit une table sur plusieurs serveurs (sharding), et CONNECT permet de lire des sources externes (fichiers CSV, autres bases) comme des tables.",
            "SHOW ENGINES liste les moteurs disponibles sur le serveur : certains doivent être installés comme plugins avant usage.",
          ],
          codeBlocks: [
            code('MariaDB', "CREATE TABLE analyse (\n  date_vente DATE,\n  produit_id INT,\n  ventes INT\n) ENGINE=ColumnStore;",
                e: "Moteur colonnaire pour l'analyse de gros volumes."),
            code('MariaDB', "SHOW ENGINES;",
                e: "Les moteurs installés et celui utilisé par défaut."),
            code('MariaDB', "CREATE TABLE journal (\n  id BIGINT AUTO_INCREMENT PRIMARY KEY,\n  evenement VARCHAR(200),\n  cree_le DATETIME DEFAULT CURRENT_TIMESTAMP\n) ENGINE=RocksDB;",
                e: "MyRocks pour une table qui reçoit énormément d'écritures."),
          ],
          mistakes: [
            "Oublier que le moteur se choisit à la création (ou avec ALTER TABLE … ENGINE).",
            "Utiliser ColumnStore pour des transactions simples, ligne par ligne.",
            "Utiliser un moteur sans vérifier qu'il est installé (SHOW ENGINES).",
          ],
          exercises: [
            ex("Quel moteur de MariaDB est optimisé pour l'analytique ?",
                "ColumnStore.",
                "Il stocke les données en colonnes pour l'analyse rapide."),
            ex("Quelle commande liste les moteurs disponibles sur le serveur ?",
                "SHOW ENGINES;",
                "Elle indique aussi le moteur par défaut."),
          ],
          quiz: [
            q(QuizType.qcm, 'ColumnStore est optimisé pour :',
                ['Le calcul analytique massif', 'Les transactions bancaires en temps réel', 'Le stockage de fichiers', 'La messagerie'],
                'Le calcul analytique massif',
                "C'est un stockage colonnaire dédié à l'analyse."),
            q(QuizType.qcm, "Quel moteur remplace MyISAM avec une meilleure résistance aux pannes ?",
                ["Aria", "ColumnStore", "Spider", "CONNECT"], "Aria",
                "Aria est utilisé pour les tables système de MariaDB."),
            tf("On peut choisir un moteur de stockage différent pour chaque table.", true,
                "Le moteur est une propriété de la table, pas de la base."),
          ],
          xp: 30,
        ),
      ];

  // =====================================================================
  // SQL SERVER
  // =====================================================================
  static List<Lesson> sqlserver() => [
        l(
          id: 'mssql_intro',
          track: 'sqlserver',
          level: 0,
          title: 'SQL Server / T-SQL',
          objective: "Découvrir SQL Server, ses outils et les particularités de T-SQL.",
          content: [
            "Microsoft SQL Server est le SGBD relationnel de Microsoft, très présent en entreprise, notamment avec les applications .NET/C#. Il existe en édition gratuite (Express, Developer) et payante, et tourne sous Windows, Linux et dans Docker depuis 2017.",
            "Il utilise T-SQL (Transact-SQL), une extension du SQL standard avec ses propres mots-clés et fonctions.",
            "Particularités de T-SQL : TOP n pour limiter les résultats (ou OFFSET … FETCH NEXT pour paginer), crochets [nom] pour les identifiants, + pour concaténer, GETDATE() pour la date du jour, IDENTITY(1,1) pour l'auto-incrément.",
            "Les tables sont rangées dans des schémas, dbo par défaut : on écrit dbo.clients. Pour le texte multilingue, on utilise NVARCHAR (Unicode) plutôt que VARCHAR.",
            "Outils : SQL Server Management Studio (SSMS), Azure Data Studio, et sqlcmd en ligne de commande. Port par défaut : 1433.",
            "Points forts : intégration avec l'écosystème Microsoft (.NET, Power BI, Azure), outils de reporting et d'intégration de données, sécurité et haute disponibilité avancées.",
          ],
          codeBlocks: [
            code('T-SQL', "-- Limiter les résultats avec TOP\nSELECT TOP 5 * FROM products;",
                e: "TOP est spécifique à T-SQL."),
            code('T-SQL', "CREATE TABLE dbo.clients (\n  id INT IDENTITY(1,1) PRIMARY KEY,\n  nom NVARCHAR(100) NOT NULL,\n  cree_le DATETIME2 DEFAULT GETDATE()\n);",
                e: "Auto-incrément IDENTITY, texte Unicode et date par défaut."),
            code('T-SQL', "SELECT name, price\nFROM products\nORDER BY price DESC\nOFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;",
                e: "Pagination : la page 2 de 10 produits."),
          ],
          mistakes: [
            "Utiliser LIMIT (MySQL, SQLite) au lieu de TOP ou OFFSET … FETCH en T-SQL.",
            "Utiliser VARCHAR pour du texte multilingue : NVARCHAR stocke l'Unicode.",
            "Oublier le schéma (dbo.) : selon les droits de l'utilisateur, la table peut ne pas être trouvée.",
          ],
          exercises: [
            ex("Quel langage SQL utilise SQL Server ?",
                "T-SQL (Transact-SQL).",
                "L'extension propriétaire de Microsoft."),
            ex("Écris en T-SQL la requête qui affiche les 3 produits les plus chers.",
                "SELECT TOP 3 name, price FROM products ORDER BY price DESC;",
                "TOP s'utilise avec ORDER BY pour avoir les « premiers »."),
          ],
          quiz: [
            q(QuizType.qcm, 'SQL Server utilise quel mot-clé pour limiter les résultats ?',
                ['TOP', 'LIMIT', 'FIRST', 'FETCH ONLY'], 'TOP',
                'T-SQL utilise TOP n.'),
            q(QuizType.qcm, "Quel est le port par défaut de SQL Server ?",
                ["1433", "3306", "5432", "1521"], "1433",
                "1521 est le port d'Oracle."),
            q(QuizType.qcm, "Quel type stocke du texte Unicode en SQL Server ?",
                ["NVARCHAR", "VARCHAR", "CHAR", "TEXT ASCII"], "NVARCHAR",
                "Le N signifie « national » : texte Unicode."),
          ],
          xp: 20,
        ),
        l(
          id: 'mssql_tsql',
          track: 'sqlserver',
          level: 3,
          title: 'Procédures stockées T-SQL',
          objective: "Écrire des procédures stockées avec variables, conditions et gestion d'erreurs.",
          content: [
            "Une procédure stockée est un bloc de T-SQL enregistré dans la base sous un nom. On la crée avec CREATE PROCEDURE et on l'exécute avec EXEC. Elle peut recevoir des paramètres et renvoyer des résultats.",
            "Les variables et les paramètres commencent par @ : DECLARE @stock INT = 0;. On leur affecte une valeur avec SET @x = … ou SELECT @x = colonne FROM ….",
            "Le contrôle de flux utilise IF … ELSE et WHILE, avec BEGIN … END pour regrouper plusieurs instructions. PRINT affiche un message dans l'onglet Messages de SSMS.",
            "La gestion d'erreurs passe par BEGIN TRY … END TRY BEGIN CATCH … END CATCH. Dans le CATCH, on annule la transaction (ROLLBACK) et on relance l'erreur avec THROW.",
            "Les transactions s'écrivent BEGIN TRANSACTION … COMMIT (ou ROLLBACK). Combinées avec TRY…CATCH, elles garantissent qu'une procédure fait tout ou rien.",
            "Dans SSMS, GO sépare les lots d'instructions. CREATE PROCEDURE doit être la première instruction de son lot. Les procédures centralisent le code réutilisable, limitent les droits nécessaires et peuvent améliorer les performances.",
          ],
          codeBlocks: [
            code('T-SQL', "CREATE PROCEDURE PrixParCategorie\n  @cat INT\nAS\nBEGIN\n  SELECT name, price FROM products\n  WHERE category_id = @cat;\nEND;\nGO\n\nEXEC PrixParCategorie @cat = 1;",
                e: "Une procédure stockée paramétrée, puis son exécution."),
            code('T-SQL', "DECLARE @stock INT;\nSELECT @stock = stock FROM products WHERE id = 1;\n\nIF @stock < 10\n  PRINT 'Stock faible';\nELSE\n  PRINT 'Stock suffisant';",
                e: "Une variable remplie par un SELECT, puis une condition."),
            code('T-SQL', "BEGIN TRY\n  BEGIN TRANSACTION;\n  UPDATE comptes SET solde = solde - 100 WHERE id = 1;\n  UPDATE comptes SET solde = solde + 100 WHERE id = 2;\n  COMMIT;\nEND TRY\nBEGIN CATCH\n  ROLLBACK;\n  THROW;\nEND CATCH;",
                e: "Tout ou rien : en cas d'erreur, la transaction est annulée et l'erreur relancée."),
          ],
          mistakes: [
            "Oublier @ devant les variables.",
            "Oublier GO avant CREATE PROCEDURE dans SSMS : elle doit être la première instruction du lot.",
            "Ne pas gérer les erreurs : sans TRY…CATCH, une transaction peut rester ouverte.",
          ],
          exercises: [
            ex("Comment déclare-t-on une variable en T-SQL ?",
                "Avec DECLARE et @ devant le nom, par exemple : DECLARE @prix INT;",
                "@ est le préfixe des variables T-SQL."),
            ex("Écris l'appel de la procédure PrixParCategorie pour la catégorie 2.",
                "EXEC PrixParCategorie @cat = 2;",
                "On peut nommer le paramètre ou le passer par position : EXEC PrixParCategorie 2;"),
          ],
          quiz: [
            q(QuizType.trueFalse, 'T-SQL préfixe ses variables avec @.',
                ['Vrai', 'Faux'], 'Vrai',
                '@variable est la syntaxe T-SQL.'),
            q(QuizType.qcm, "Quel bloc gère les erreurs en T-SQL ?",
                ["BEGIN TRY … BEGIN CATCH", "EXCEPTION WHEN OTHERS", "ON ERROR RESUME NEXT", "TRAP … END TRAP"],
                "BEGIN TRY … BEGIN CATCH",
                "EXCEPTION WHEN OTHERS est la syntaxe d'Oracle PL/SQL."),
            q(QuizType.qcm, "Quelle instruction exécute une procédure stockée en T-SQL ?",
                ["EXEC", "CALL", "RUN", "DO"], "EXEC",
                "CALL est utilisé par PostgreSQL et MySQL."),
          ],
          xp: 40,
        ),
      ];

  // =====================================================================
  // ORACLE
  // =====================================================================
  static List<Lesson> oracle() => [
        l(
          id: 'oracle_intro',
          track: 'oracle',
          level: 0,
          title: 'Oracle / PL-SQL',
          objective: "Découvrir Oracle Database et les particularités de son SQL.",
          content: [
            "Oracle Database est un SGBD commercial historique, réputé pour sa robustesse et ses performances sur de très gros volumes. On le trouve dans les grandes entreprises, la banque, l'assurance et les administrations. Une édition gratuite (Oracle Database Free) permet de se former.",
            "Son langage procédural est PL/SQL (Procedural Language/SQL), organisé en blocs DECLARE … BEGIN … EXCEPTION … END.",
            "Particularités de son SQL : la table factice DUAL pour les SELECT sans table, les types VARCHAR2 et NUMBER, SYSDATE pour la date du jour. Pour limiter les résultats : FETCH FIRST n ROWS ONLY (depuis la version 12c) ou l'ancienne pseudo-colonne ROWNUM.",
            "Piège classique : Oracle traite la chaîne vide '' comme NULL. WHERE nom = '' ne trouve donc jamais rien.",
            "Dans Oracle, un utilisateur et son schéma sont quasiment la même chose : les tables créées par l'utilisateur RH sont dans le schéma RH (RH.employes).",
            "Outils : SQL*Plus et SQLcl en ligne de commande, SQL Developer en graphique. Port par défaut : 1521.",
          ],
          codeBlocks: [
            code('Oracle', "-- Oracle utilise DUAL pour une requête sans table\nSELECT 2 + 3 AS total FROM DUAL;\nSELECT SYSDATE, USER FROM DUAL;",
                e: "DUAL est une table factice d'une seule ligne."),
            code('Oracle', "CREATE TABLE clients (\n  id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,\n  nom VARCHAR2(100) NOT NULL,\n  cree_le DATE DEFAULT SYSDATE\n);",
                e: "Types Oracle et auto-incrément (12c et plus)."),
            code('Oracle', "SELECT nom, salaire\nFROM employes\nORDER BY salaire DESC\nFETCH FIRST 5 ROWS ONLY;",
                e: "Les 5 plus hauts salaires (12c et plus)."),
          ],
          mistakes: [
            "Utiliser LIMIT : Oracle utilise FETCH FIRST ou ROWNUM.",
            "Oublier FROM DUAL dans un SELECT sans table.",
            "Oublier qu'Oracle traite la chaîne vide '' comme NULL.",
          ],
          exercises: [
            ex("À quoi sert la table DUAL dans Oracle ?",
                "C'est une table factice pour les SELECT sans table.",
                "DUAL permet d'évaluer des expressions."),
            ex("Écris en Oracle (12c et plus) la requête qui affiche les 3 salaires les plus élevés de la table employes.",
                "SELECT nom, salaire FROM employes ORDER BY salaire DESC FETCH FIRST 3 ROWS ONLY;",
                "FETCH FIRST remplace LIMIT."),
          ],
          quiz: [
            q(QuizType.qcm, 'Quel langage procédural utilise Oracle ?',
                ['PL/SQL', 'T-SQL', 'PL/pgSQL', 'VBScript'], 'PL/SQL',
                'Oracle utilise PL/SQL.'),
            q(QuizType.qcm, "Quel est le port par défaut d'Oracle Database ?",
                ["1521", "1433", "3306", "5432"], "1521",
                "1433 est SQL Server, 3306 MySQL, 5432 PostgreSQL."),
            tf("Dans Oracle, une chaîne vide '' est traitée comme NULL.", true,
                "C'est un comportement propre à Oracle."),
          ],
          xp: 20,
        ),
        l(
          id: 'oracle_plsql',
          track: 'oracle',
          level: 3,
          title: 'Blocs PL/SQL',
          objective: "Écrire des blocs, des procédures et gérer les erreurs en PL/SQL.",
          content: [
            "Un bloc PL/SQL a la structure : DECLARE (variables, facultatif) / BEGIN (instructions) / EXCEPTION (gestion d'erreurs, facultatif) / END;. Un bloc sans nom est dit anonyme.",
            "Les variables se déclarent sans préfixe : v_prix NUMBER(10,2);. L'affectation s'écrit :=. Avec %TYPE, une variable reprend le type d'une colonne (v_salaire employes.salaire%TYPE), ce qui évite les incohérences.",
            "SELECT … INTO … charge le résultat d'une requête dans des variables. Elle doit renvoyer exactement une ligne, sinon une exception est levée : NO_DATA_FOUND (aucune ligne) ou TOO_MANY_ROWS (plusieurs).",
            "Contrôle de flux : IF … THEN … ELSIF … ELSE … END IF, boucles LOOP, WHILE et FOR i IN 1..10 LOOP. La boucle FOR r IN (SELECT …) LOOP parcourt directement les lignes d'une requête.",
            "Les blocs peuvent devenir des procédures (CREATE PROCEDURE), des fonctions (CREATE FUNCTION), et être regroupés dans des packages. RAISE_APPLICATION_ERROR lève une erreur métier personnalisée.",
            "Dans SQL*Plus, SET SERVEROUTPUT ON est nécessaire pour voir les messages de DBMS_OUTPUT.PUT_LINE, et une barre oblique / seule sur une ligne exécute le bloc.",
          ],
          codeBlocks: [
            code('PL/SQL', "SET SERVEROUTPUT ON\nDECLARE\n  v_total NUMBER := 10;\nBEGIN\n  v_total := v_total * 2;\n  DBMS_OUTPUT.PUT_LINE('Total : ' || v_total);\nEND;\n/",
                e: "Un bloc anonyme, exécuté dans SQL*Plus avec /."),
            code('PL/SQL', "DECLARE\n  v_salaire employes.salaire%TYPE;\nBEGIN\n  SELECT salaire INTO v_salaire FROM employes WHERE id = 999;\n  DBMS_OUTPUT.PUT_LINE(v_salaire);\nEXCEPTION\n  WHEN NO_DATA_FOUND THEN\n    DBMS_OUTPUT.PUT_LINE('Employé introuvable');\nEND;\n/",
                e: "%TYPE, SELECT INTO et gestion de l'exception NO_DATA_FOUND."),
            code('PL/SQL', "BEGIN\n  FOR r IN (SELECT nom, salaire FROM employes WHERE salaire > 45000) LOOP\n    DBMS_OUTPUT.PUT_LINE(r.nom || ' : ' || r.salaire);\n  END LOOP;\nEND;\n/",
                e: "Une boucle qui parcourt directement le résultat d'une requête."),
          ],
          mistakes: [
            "Oublier le point-virgule après END, ou la barre oblique / dans SQL*Plus.",
            "Utiliser PRINT au lieu de DBMS_OUTPUT.PUT_LINE.",
            "Oublier SET SERVEROUTPUT ON : DBMS_OUTPUT n'affiche alors rien.",
          ],
          exercises: [
            ex("Quelle instruction affiche du texte en PL/SQL ?",
                "DBMS_OUTPUT.PUT_LINE('...').",
                "C'est la sortie console de PL/SQL."),
            ex("Comment déclarer une variable du même type que la colonne salaire de la table employes ?",
                "v_salaire employes.salaire%TYPE;",
                "%TYPE reprend automatiquement le type de la colonne."),
          ],
          quiz: [
            q(QuizType.qcm, "La section EXCEPTION d'un bloc PL/SQL sert à :",
                ['Gérer les erreurs', 'Déclarer des variables', 'Créer des tables', 'Faire des jointures'],
                'Gérer les erreurs',
                'EXCEPTION gère les exceptions levées.'),
            q(QuizType.qcm, "Quelle exception est levée quand SELECT INTO ne trouve aucune ligne ?",
                ["NO_DATA_FOUND", "TOO_MANY_ROWS", "ZERO_DIVIDE", "VALUE_ERROR"], "NO_DATA_FOUND",
                "TOO_MANY_ROWS est levée quand il y a plusieurs lignes."),
            q(QuizType.qcm, "À quoi sert %TYPE ?",
                ["Reprendre le type d'une colonne", "Convertir en texte", "Créer une table", "Déclarer une exception"],
                "Reprendre le type d'une colonne",
                "Si le type de la colonne change, la variable suit automatiquement."),
          ],
          xp: 40,
        ),
      ];

  // =====================================================================
  // MONGODB
  // =====================================================================
  static List<Lesson> mongodb() => [
        l(
          id: 'mongo_intro',
          track: 'mongodb',
          level: 0,
          title: 'MongoDB : les bases NoSQL document',
          objective: "Comprendre le modèle document de MongoDB et le comparer au relationnel.",
          content: [
            "MongoDB est une base NoSQL orientée DOCUMENTS. Au lieu de lignes dans des tables, elle stocke des documents de type JSON (en interne du BSON, un JSON binaire) rangés dans des COLLECTIONS.",
            "Correspondance avec le SQL : une base reste une base, une collection correspond à une table, un document à une ligne, un champ à une colonne. Chaque document a un identifiant unique _id, généré automatiquement (un ObjectId) si on ne le fournit pas.",
            "Le schéma est flexible : deux documents d'une même collection peuvent avoir des champs différents. On peut aussi imbriquer des objets et des tableaux, par exemple une commande qui contient directement la liste de ses lignes.",
            "On n'utilise pas SQL : on interroge MongoDB avec des méthodes (insertOne, find, updateOne…) et des filtres écrits en JSON, depuis le shell mongosh ou un driver (Node.js, Python, Java…).",
            "MongoDB convient aux données de structure variable, aux catalogues, aux contenus, aux journaux, et se répartit facilement sur plusieurs serveurs. Pour des données très reliées avec des transactions complexes (comptabilité, stocks), le relationnel reste souvent plus adapté.",
            "Un document est limité à 16 Mo : on n'y imbrique pas des listes qui grossissent sans fin (par exemple tous les commentaires d'un article très populaire).",
          ],
          codeBlocks: [
            code('mongosh', "// Insérer un document\nuse boutique\ndb.products.insertOne({\n  name: \"Souris\",\n  price: 29.99,\n  stock: 60\n});",
                e: "Un document JSON dans la collection products (créée automatiquement)."),
            code('mongosh', "db.commandes.insertOne({\n  client: { nom: \"Alice\", ville: \"Paris\" },\n  lignes: [\n    { produit: \"Clavier\", qte: 1, prix: 79.99 },\n    { produit: \"Souris\", qte: 2, prix: 29.99 }\n  ],\n  date: new Date()\n});",
                e: "Objet et tableau imbriqués : toute la commande dans un seul document."),
            code('texte', "SQL            MongoDB\n-----------    -----------\nbase           base\ntable          collection\nligne          document\ncolonne        champ\nclé primaire   _id\nJOIN           \$lookup (ou imbrication)",
                e: "Le vocabulaire relationnel et son équivalent MongoDB."),
          ],
          mistakes: [
            "Chercher une structure de table stricte : il n'y en a pas (sauf si on ajoute une validation de schéma).",
            r"Reproduire des jointures SQL partout : on imbrique les données lues ensemble, ou on utilise $lookup.",
            "Imbriquer des tableaux qui grossissent sans limite : un document est limité à 16 Mo.",
          ],
          exercises: [
            ex("Comment s'appelle le regroupement de documents, l'équivalent d'une table ?",
                "Une collection.",
                "Les documents sont rangés dans des collections."),
            ex("Insère dans la collection livres un document avec le titre « 1984 » et l'année 1949.",
                "db.livres.insertOne({ titre: \"1984\", annee: 1949 });",
                "La collection est créée automatiquement au premier insert."),
          ],
          quiz: [
            q(QuizType.qcm, 'MongoDB stocke les données en :',
                ['Documents BSON', 'Tableaux Excel', 'Fichiers plats', 'Feuilles de calcul'],
                'Documents BSON', 'MongoDB est orienté document.'),
            q(QuizType.qcm, "Quel champ identifie chaque document de façon unique ?",
                ["_id", "id", "pk", "rowid"], "_id",
                "MongoDB le génère automatiquement si on ne le fournit pas."),
            q(QuizType.qcm, "En MongoDB, l'équivalent d'une ligne SQL est :",
                ["Un document", "Une collection", "Une base", "Un index"], "Un document",
                "La collection, elle, correspond à la table."),
          ],
          xp: 20,
        ),
        l(
          id: 'mongo_query',
          track: 'mongodb',
          level: 1,
          title: 'Interroger avec find()',
          objective: "Chercher, trier, modifier et supprimer des documents.",
          content: [
            "db.collection.find(filtre) renvoie les documents qui correspondent au filtre, findOne(filtre) le premier seulement. Sans filtre, find() renvoie toute la collection.",
            "Le filtre est un objet JSON. Pour l'égalité, on écrit simplement { ville: \"Paris\" }. Plusieurs conditions dans le même objet sont combinées avec ET : { ville: \"Paris\", vip: true }.",
            r"Les opérateurs commencent par $ : $lt (moins que), $lte, $gt (plus que), $gte, $ne (différent), $in (dans une liste), $regex (motif de texte), et $or pour combiner avec OU. Exemple : { price: { $lt: 50 } }.",
            "Le deuxième paramètre de find() est une projection : il choisit les champs renvoyés ({ name: 1, price: 1, _id: 0 }). On enchaîne ensuite .sort({ price: -1 }) (1 croissant, -1 décroissant), .limit(n) et .skip(n). countDocuments(filtre) compte les résultats.",
            r"Pour modifier : updateOne(filtre, { $set: { champ: valeur } }) ou updateMany. $inc incrémente un nombre. replaceOne remplace tout le document.",
            "Pour supprimer : deleteOne(filtre) ou deleteMany(filtre). Comme en SQL, un filtre vide {} vise TOUS les documents.",
          ],
          codeBlocks: [
            code('mongosh', r'''// Produits à moins de 50 €
db.products.find({ price: { $lt: 50 } });''',
                e: r"$lt = moins de."),
            code('mongosh', "// Trier par prix décroissant\ndb.products.find().sort({ price: -1 });",
                e: "-1 = décroissant, 1 = croissant."),
            code('mongosh', r'''db.products.find(
  { category: { $in: ["Audio", "Jeux"] }, stock: { $gt: 0 } },
  { name: 1, price: 1, _id: 0 }
).limit(5);''',
                e: r"Filtre avec $in et $gt, projection sur deux champs, 5 résultats maximum."),
            code('mongosh', r'''db.products.updateOne({ name: "Souris" }, { $set: { price: 24.99 } });
db.products.updateMany({}, { $inc: { stock: 10 } });
db.products.deleteMany({ stock: 0 });''',
                e: "Modifier un champ, incrémenter tous les stocks, supprimer les produits en rupture."),
          ],
          mistakes: [
            r"Utiliser < au lieu de { $lt: … }.",
            "Oublier la syntaxe des opérateurs { champ: { op: valeur } }.",
            r"Confondre updateOne avec $set (modifie des champs) et replaceOne (remplace tout le document).",
          ],
          exercises: [
            ex("Quel opérateur MongoDB signifie « moins de » ?",
                r"$lt.",
                r"$lt (less than)."),
            ex("Trouve les produits dont le prix est compris entre 20 et 50 €.",
                r"db.products.find({ price: { $gte: 20, $lte: 50 } });",
                "Deux opérateurs sur le même champ sont combinés avec ET."),
          ],
          quiz: [
            q(QuizType.qcm, 'Pour trier décroissant en MongoDB on utilise sort({prix: ?})',
                ['-1', '1', '0', 'DESC'], '-1',
                '-1 signifie décroissant, 1 croissant.'),
            q(QuizType.qcm, "Quel opérateur met à jour un champ sans toucher au reste du document ?",
                [r"$set", r"$put", r"$update", r"$replace"], r"$set",
                r"$set ne modifie que les champs indiqués."),
            q(QuizType.qcm, "Dans find({ a: 1, b: 2 }), les deux conditions sont combinées avec :",
                ["ET (AND)", "OU (OR)", "Aucune combinaison", "OU exclusif"], "ET (AND)",
                r"Pour un OU, il faut l'opérateur $or."),
          ],
          xp: 25,
        ),
        l(
          id: 'mongo_agg',
          track: 'mongodb',
          level: 2,
          title: "Pipeline d'agrégation",
          objective: "Grouper, calculer et joindre des collections avec le pipeline d'agrégation.",
          content: [
            "L'agrégation traite les documents à travers un PIPELINE : un tableau d'étapes, chacune recevant le résultat de la précédente. C'est l'équivalent de GROUP BY, des agrégats et des jointures en SQL.",
            r"$match filtre les documents (comme WHERE). Place-le le plus tôt possible : les étapes suivantes traitent alors moins de documents et les index peuvent servir.",
            r'$group regroupe par la clé indiquée dans _id et calcule des accumulateurs : $sum, $avg, $min, $max, $push (liste des valeurs). Pour désigner un champ, on le préfixe de $ : "$category".',
            r"$sort trie, $limit limite, $project choisit ou calcule les champs de sortie. $unwind « déplie » un tableau : un document avec 3 lignes devient 3 documents.",
            r"$lookup joint une autre collection, comme un LEFT JOIN : il ajoute à chaque document un tableau des documents correspondants.",
            r"Équivalence : SELECT category, AVG(price) FROM products WHERE stock > 0 GROUP BY category ORDER BY 2 DESC devient [$match, $group, $sort].",
          ],
          codeBlocks: [
            code('mongosh', r'''// Nombre de produits par catégorie
db.products.aggregate([
  { $group: { _id: "$category", total: { $sum: 1 } } }
]);''',
                e: "Groupement et comptage."),
            code('mongosh', r'''db.products.aggregate([
  { $match: { stock: { $gt: 0 } } },
  { $group: { _id: "$category", prixMoyen: { $avg: "$price" } } },
  { $sort: { prixMoyen: -1 } },
  { $limit: 3 }
]);''',
                e: "Les 3 catégories au prix moyen le plus élevé, parmi les produits en stock."),
            code('mongosh', r'''db.commandes.aggregate([
  { $lookup: {
      from: "clients",
      localField: "client_id",
      foreignField: "_id",
      as: "client"
  } },
  { $unwind: "$client" },
  { $project: { date: 1, "client.nom": 1, total: 1 } }
]);''',
                e: "Une jointure : chaque commande avec le nom de son client."),
          ],
          mistakes: [
            r"Ne pas comprendre que _id dans $group est la clé de regroupement.",
            r'Oublier le $ devant le nom de champ dans $group ("$category").',
            r"Placer $match après $group alors qu'il pourrait filtrer avant : tout le pipeline est plus lent.",
          ],
          exercises: [
            ex("Quelle étape filtre dans le pipeline d'agrégation ?",
                r"$match.",
                r"$match filtre les documents en amont du groupement."),
            ex("Calcule le prix moyen des produits par catégorie.",
                r'''db.products.aggregate([{ $group: { _id: "$category", prixMoyen: { $avg: "$price" } } }]);''',
                r"$avg est l'équivalent de AVG en SQL."),
          ],
          quiz: [
            q(QuizType.qcm, r'$sum est un :',
                ['Accumulateur', 'Filtre', 'Tri', 'Index'], 'Accumulateur',
                r'Les accumulateurs ($sum, $avg) calculent dans $group.'),
            q(QuizType.qcm, "Quelle étape simule une jointure entre collections ?",
                [r"$lookup", r"$join", r"$merge", r"$unwind"], r"$lookup",
                r"$lookup ajoute les documents correspondants d'une autre collection."),
            tf(r"Il vaut mieux placer $match le plus tôt possible dans le pipeline.", true,
                "Moins de documents à traiter ensuite, et les index peuvent servir."),
          ],
          xp: 30,
        ),
      ];

  // =====================================================================
  // REDIS
  // =====================================================================
  static List<Lesson> redis() => [
        l(
          id: 'redis_intro',
          track: 'redis',
          level: 0,
          title: 'Redis : le cache clé-valeur en mémoire',
          objective: "Comprendre le modèle clé-valeur, la rapidité de Redis et ses usages.",
          content: [
            "Redis est une base NoSQL de type CLÉ-VALEUR : chaque donnée est rangée sous une clé unique, et on la retrouve directement par cette clé. Il n'y a ni tables ni requêtes SQL.",
            "Les données sont gardées EN MÉMOIRE vive, d'où une rapidité extrême : des centaines de milliers d'opérations par seconde, avec des temps de réponse inférieurs à la milliseconde. Chaque commande s'exécute de façon atomique.",
            "La persistance est possible mais optionnelle : instantanés périodiques (RDB) ou journal de toutes les écritures (AOF). Sans persistance, un redémarrage efface tout.",
            "Usages typiques : cache devant une base SQL, sessions des utilisateurs, compteurs, limitation du nombre de requêtes, files de tâches, classements en temps réel.",
            "Convention de nommage des clés : objet:id:champ, par exemple user:42:nom ou produit:7. Les deux-points n'ont pas de sens technique, ils organisent les clés.",
            "Port par défaut : 6379. On l'explore avec redis-cli. Évite la commande KEYS * sur une grosse base en production : elle bloque le serveur pendant qu'elle parcourt toutes les clés. Utilise SCAN à la place.",
          ],
          codeBlocks: [
            code('redis-cli', "SET produit:1 \"Souris\"\nGET produit:1\nDEL produit:1",
                e: "Écrire, lire et supprimer une clé."),
            code('redis-cli', "SET visites 0\nINCR visites\nINCR visites\nGET visites",
                e: "Un compteur atomique : GET renvoie 2, même si mille clients incrémentent en même temps."),
            code('python', "def produit(id):\n    cle = f\"produit:{id}\"\n    cache = redis.get(cle)\n    if cache:\n        return json.loads(cache)        # trouvé dans le cache\n    row = db.query(\"SELECT * FROM products WHERE id = %s\", id)\n    redis.set(cle, json.dumps(row), ex=300)  # gardé 5 minutes\n    return row",
                e: "Le motif « cache-aside » : on lit d'abord Redis, sinon la base, puis on met en cache."),
          ],
          mistakes: [
            "Oublier que Redis est en mémoire : sans persistance, les données disparaissent au redémarrage.",
            "Utiliser du SQL avec Redis : ce n'est pas une base relationnelle.",
            "Lancer KEYS * en production : la commande bloque le serveur (préfère SCAN).",
          ],
          exercises: [
            ex("Quel type de base est Redis ?",
                "NoSQL clé-valeur en mémoire.",
                "Stockage clé-valeur ultra rapide."),
            ex("Écris les commandes qui stockent le nom « Alice » sous la clé user:1:nom, puis le relisent.",
                "SET user:1:nom \"Alice\"\nGET user:1:nom",
                "SET écrit, GET lit."),
          ],
          quiz: [
            q(QuizType.qcm, 'Redis stocke les données principalement :',
                ['En mémoire', 'Sur un disque dur lent', 'Dans le cache navigateur', 'Dans des fichiers texte'],
                'En mémoire', "C'est un stockage en mémoire pour la vitesse."),
            q(QuizType.qcm, "Quel est le port par défaut de Redis ?",
                ["6379", "5432", "27017", "3306"], "6379",
                "27017 est le port de MongoDB."),
            q(QuizType.qcm, "Quelle commande incrémente un compteur de façon atomique ?",
                ["INCR", "ADD", "PLUS", "SUM"], "INCR",
                "INCR fonctionne même avec de nombreux clients simultanés."),
          ],
          xp: 20,
        ),
        l(
          id: 'redis_types',
          track: 'redis',
          level: 1,
          title: 'Les types de données Redis',
          objective: "Choisir la bonne structure Redis : chaîne, hash, liste, set, sorted set.",
          content: [
            "La valeur associée à une clé n'est pas forcément une simple chaîne : Redis propose plusieurs structures, chacune avec ses commandes optimisées.",
            "STRING : texte, nombre ou données binaires (SET, GET, INCR). HASH : un objet avec plusieurs champs (HSET user:1 nom Alice age 30, HGET, HGETALL). On peut modifier un seul champ sans réécrire tout l'objet.",
            "LIST : une liste ordonnée, idéale pour une file d'attente. LPUSH ajoute au début, RPOP retire à la fin, LRANGE lit une portion.",
            "SET : un ensemble sans doublon (SADD, SISMEMBER, SMEMBERS), pratique pour des tags ou les visiteurs uniques. SORTED SET (ZSET) : chaque élément a un score, et les éléments sont triés par score (ZADD, ZREVRANGE). C'est la structure des classements.",
            "Toute clé peut expirer : EXPIRE cle secondes, ou directement SET cle valeur EX 3600. TTL cle donne le temps restant. C'est indispensable pour un cache ou des sessions.",
            "Redis propose aussi les Streams (journal d'événements), le Pub/Sub (messagerie) et des structures spécialisées (HyperLogLog, géospatial).",
          ],
          codeBlocks: [
            code('redis-cli', "HSET user:1 name Alice age 30\nHGETALL user:1\nSET session:42 \"abc\"\nEXPIRE session:42 3600",
                e: "Un objet (hash) et une clé avec expiration."),
            code('redis-cli', "LPUSH taches \"envoyer-mail-1\"\nLPUSH taches \"envoyer-mail-2\"\nRPOP taches",
                e: "Une file : RPOP renvoie la tâche la plus ancienne (envoyer-mail-1)."),
            code('redis-cli', "ZADD classement 120 alice 95 bob 150 chloe\nZREVRANGE classement 0 2 WITHSCORES",
                e: "Un classement : chloe, alice, bob avec leurs scores."),
            code('redis-cli', "SADD visiteurs:2026-11-19 ip1 ip2 ip1\nSCARD visiteurs:2026-11-19",
                e: "Un set ignore les doublons : SCARD renvoie 2 visiteurs uniques."),
          ],
          mistakes: [
            "Utiliser une seule structure pour tout.",
            "Oublier de faire expirer les clés de cache : la mémoire se remplit.",
            "Stocker un gros JSON dans une chaîne et le réécrire entièrement pour changer un champ : un hash est fait pour ça.",
          ],
          exercises: [
            ex("Quelle commande fait expirer une clé ?",
                "EXPIRE clé secondes.",
                "EXPIRE fixe une durée de vie."),
            ex("Ajoute Alice (120 points) et Bob (95 points) à un classement, puis affiche-le du meilleur au moins bon.",
                "ZADD classement 120 alice 95 bob\nZREVRANGE classement 0 -1 WITHSCORES",
                "ZREVRANGE trie par score décroissant, 0 -1 signifie « tout »."),
          ],
          quiz: [
            q(QuizType.qcm, 'HSET crée une structure de type :',
                ['Hash (objet)', 'Liste', 'Float', 'Table'], 'Hash (objet)',
                'Un hash représente un objet avec plusieurs champs.'),
            q(QuizType.qcm, "Quelle structure est idéale pour un classement ?",
                ["Sorted set (ZSET)", "List", "String", "Hash"], "Sorted set (ZSET)",
                "Les éléments sont automatiquement triés par score."),
            q(QuizType.qcm, "Quelle commande donne le temps de vie restant d'une clé ?",
                ["TTL", "EXPIRE", "LIFE", "TIME"], "TTL",
                "EXPIRE fixe la durée, TTL la lit."),
          ],
          xp: 25,
        ),
      ];
}
