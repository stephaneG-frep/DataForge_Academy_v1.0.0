import '../models/lesson_models.dart';
import 'sgbd_track_lessons.dart';

/// Additional SGBD lessons so that every SGBD track covers at least four
/// levels. Merged with [SgbdTrackLessons] by the ContentRepository.
///
/// Same conventions as [SgbdTrackLessons]: Console-runnable SQL starts with
/// `-- base : <id>`, runnable exercises end with `(base <id>)`.
class SgbdExtraLessons {
  SgbdExtraLessons._();

  static const l = SgbdTrackLessons.l;
  static const code = SgbdTrackLessons.code;
  static const q = SgbdTrackLessons.q;
  static const tf = SgbdTrackLessons.tf;
  static const ex = SgbdTrackLessons.ex;

  // =====================================================================
  // SQLITE — niveau Avancé
  // =====================================================================
  static List<Lesson> sqlite() => [
        l(
          id: 'sqlite_advanced',
          track: 'sqlite',
          level: 3,
          title: 'SQLite avancé : UPSERT, JSON, WAL et performances',
          objective: "Utiliser les fonctions avancées de SQLite et l'optimiser pour une vraie application.",
          content: [
            "UPSERT (depuis SQLite 3.24) insère une ligne, ou la met à jour si elle existe déjà : INSERT … ON CONFLICT(colonne) DO UPDATE SET …. Dans la partie UPDATE, excluded désigne la ligne qu'on essayait d'insérer. C'est idéal pour synchroniser des données.",
            "SQLite sait lire du JSON stocké en texte : json_extract(doc, '\$.champ') lit un champ, json_each() transforme un tableau JSON en lignes. Ces fonctions sont intégrées depuis la version 3.38 (et disponibles avant via l'extension JSON1, presque toujours présente).",
            "Les transactions sont essentielles pour la vitesse : 1 000 INSERT dans une seule transaction vont des centaines de fois plus vite que 1 000 INSERT séparés, car chaque transaction attend l'écriture sur disque. BEGIN IMMEDIATE réserve l'écriture dès le début et évite les conflits.",
            "Le mode WAL (PRAGMA journal_mode = WAL) écrit les modifications dans un journal séparé : les lectures continuent pendant une écriture. C'est le mode recommandé pour une application mobile ou de bureau.",
            "Pour les performances, mêmes règles qu'ailleurs : index sur les colonnes filtrées et jointes, vérification avec EXPLAIN QUERY PLAN, et PRAGMA optimize de temps en temps pour mettre à jour les statistiques.",
            "Attention aux versions : sur Android, SQLite est fourni par le système. Les fonctionnalités récentes (UPSERT, RETURNING, fonctions de fenêtrage) peuvent manquer sur de très vieux appareils. Les bibliothèques comme sqlite3_flutter_libs embarquent une version récente.",
          ],
          codeBlocks: [
            code('sql', "-- base : boutique\nINSERT INTO categories (id, nom) VALUES (2, 'Audio & Hi-Fi')\nON CONFLICT(id) DO UPDATE SET nom = excluded.nom;\nSELECT * FROM categories;",
                e: "La catégorie 2 existe déjà : elle est mise à jour au lieu de provoquer une erreur."),
            code('sql', "-- base : boutique\nSELECT json_extract('{\"nom\": \"Alice\", \"ville\": \"Paris\"}', '\$.ville') AS ville;",
                e: "Lire un champ dans un document JSON stocké en texte."),
            code('sql', "-- base : boutique\nBEGIN IMMEDIATE;\nUPDATE products SET stock = stock - 1 WHERE id = 2;\nINSERT INTO products (name, price, category_id, stock) VALUES ('Câble USB-C', 9.99, 3, 200);\nCOMMIT;\nSELECT name, stock FROM products WHERE id = 2 OR name = 'Câble USB-C';",
                e: "Plusieurs écritures regroupées dans une transaction : plus sûr et beaucoup plus rapide."),
            code('sql', "-- base : boutique\nCREATE INDEX idx_products_cat ON products(category_id);\nEXPLAIN QUERY PLAN SELECT name FROM products WHERE category_id = 2;",
                e: "Le plan indique SEARCH … USING INDEX idx_products_cat."),
          ],
          mistakes: [
            "Faire des milliers d'INSERT sans transaction : chacun attend l'écriture sur disque.",
            "Garder le mode de journal par défaut dans une application avec lectures et écritures simultanées : passe en WAL.",
            "Utiliser une fonction récente (UPSERT, RETURNING) sans vérifier la version de SQLite des appareils visés.",
          ],
          exercises: [
            ex("En une seule requête UPSERT, enregistre l'email farid@example.com pour le client 6 (Farid Haddad, Lille). (base boutique)",
                "INSERT INTO clients (id, nom, email, ville) VALUES (6, 'Farid Haddad', 'farid@example.com', 'Lille') ON CONFLICT(id) DO UPDATE SET email = excluded.email;",
                "Le client 6 existe : seul son email est mis à jour."),
            ex("Extrais le prix du document JSON {\"produit\": \"Clavier\", \"prix\": 79.99}. (base boutique)",
                "SELECT json_extract('{\"produit\": \"Clavier\", \"prix\": 79.99}', '\$.prix') AS prix;",
                "\$ désigne la racine du document, .prix le champ."),
          ],
          quiz: [
            q(QuizType.qcm, "Dans un UPSERT SQLite, que désigne excluded ?",
                ["La ligne qu'on essayait d'insérer", "La ligne supprimée", "La table temporaire du journal", "Les colonnes exclues de l'index"],
                "La ligne qu'on essayait d'insérer",
                "SET email = excluded.email reprend la nouvelle valeur."),
            q(QuizType.qcm, "Quel mode de journal permet de lire pendant une écriture ?",
                ["WAL", "DELETE", "MEMORY", "OFF"], "WAL",
                "Write-Ahead Logging : le mode recommandé pour les applications."),
            tf("Regrouper 1 000 INSERT dans une transaction est beaucoup plus rapide que 1 000 INSERT séparés.", true,
                "Chaque transaction attend la confirmation d'écriture sur disque."),
          ],
          xp: 40,
        ),
      ];

  // =====================================================================
  // POSTGRESQL — niveau Intermédiaire
  // =====================================================================
  static List<Lesson> postgres() => [
        l(
          id: 'pg_queries',
          track: 'postgres',
          level: 2,
          title: 'Requêtes propres à PostgreSQL',
          objective: "Tirer parti des extensions SQL de PostgreSQL : RETURNING, UPSERT, ILIKE, DISTINCT ON, generate_series.",
          content: [
            "RETURNING renvoie les lignes modifiées par un INSERT, un UPDATE ou un DELETE. Après un INSERT, INSERT … RETURNING id donne directement l'identifiant généré, sans seconde requête.",
            "UPSERT : INSERT … ON CONFLICT (colonne) DO UPDATE SET … met à jour la ligne si la valeur unique existe déjà, et ON CONFLICT DO NOTHING ignore simplement le doublon. EXCLUDED désigne la ligne proposée.",
            "ILIKE est un LIKE insensible à la casse : WHERE nom ILIKE 'mar%' trouve Martin, MARTIN et martine. Pour des motifs plus riches, l'opérateur ~ applique une expression régulière.",
            "DISTINCT ON (colonne) garde la première ligne de chaque groupe selon l'ORDER BY. C'est la façon la plus simple d'obtenir « le dernier achat de chaque client » ou « l'employé le mieux payé de chaque département ».",
            "generate_series(début, fin, pas) génère une série de nombres ou de dates. Combinée avec un LEFT JOIN, elle permet de construire un rapport qui affiche aussi les jours sans ventes.",
            "FILTER s'ajoute à un agrégat pour ne compter que certaines lignes : COUNT(*) FILTER (WHERE statut = 'payée'). C'est plus lisible qu'un SUM(CASE WHEN …).",
          ],
          codeBlocks: [
            code('PostgreSQL', "INSERT INTO clients (nom, email)\nVALUES ('Alice', 'alice@example.com')\nON CONFLICT (email) DO UPDATE SET nom = EXCLUDED.nom\nRETURNING id, nom;",
                e: "UPSERT sur l'email unique, avec récupération de l'id."),
            code('PostgreSQL', "SELECT DISTINCT ON (departement_id)\n       departement_id, nom, salaire\nFROM employes\nORDER BY departement_id, salaire DESC;",
                e: "L'employé le mieux payé de chaque département."),
            code('PostgreSQL', "SELECT jour::date, COUNT(c.id) AS commandes,\n       COUNT(c.id) FILTER (WHERE c.statut = 'payée') AS payees\nFROM generate_series('2026-11-01'::date, '2026-11-07', '1 day') AS jour\nLEFT JOIN commandes c ON c.date_cmd = jour::date\nGROUP BY jour\nORDER BY jour;",
                e: "Un rapport jour par jour, y compris les jours sans commande."),
          ],
          mistakes: [
            "Faire un SELECT après un INSERT pour retrouver l'id généré, au lieu de RETURNING.",
            "Utiliser LOWER(nom) LIKE … partout au lieu de ILIKE (ou d'un index adapté).",
            "Oublier que DISTINCT ON exige un ORDER BY qui commence par les mêmes colonnes.",
          ],
          exercises: [
            ex("Écris l'insertion d'un produit « Webcam » à 39,90 € qui renvoie l'id généré.",
                "INSERT INTO produits (nom, prix) VALUES ('Webcam', 39.90) RETURNING id;",
                "RETURNING évite une seconde requête."),
            ex("Écris la requête qui trouve les clients dont le nom commence par « mar », quelle que soit la casse.",
                "SELECT * FROM clients WHERE nom ILIKE 'mar%';",
                "ILIKE est la version insensible à la casse de LIKE."),
          ],
          quiz: [
            q(QuizType.qcm, "Quel mot-clé renvoie les lignes insérées ou modifiées ?",
                ["RETURNING", "OUTPUT", "RESULT", "FETCH"], "RETURNING",
                "OUTPUT est l'équivalent en SQL Server."),
            q(QuizType.qcm, "Quel opérateur fait un LIKE insensible à la casse ?",
                ["ILIKE", "LIKE CASE", "SIMILAR", "NOCASE"], "ILIKE",
                "ILIKE est une extension de PostgreSQL."),
            q(QuizType.qcm, "À quoi sert generate_series ?",
                ["Générer une suite de nombres ou de dates", "Créer une séquence d'identifiants", "Dupliquer une table", "Générer des index"],
                "Générer une suite de nombres ou de dates",
                "Très utile pour les rapports qui doivent afficher toutes les périodes."),
          ],
          xp: 35,
        ),
      ];

  // =====================================================================
  // MYSQL — niveaux Fondamentaux et Avancé
  // =====================================================================
  static List<Lesson> mysql() => [
        l(
          id: 'mysql_sql',
          track: 'mysql',
          level: 1,
          title: 'Le SQL de MySQL : types, dates et fonctions',
          objective: "Écrire des tables et des requêtes adaptées à MySQL.",
          content: [
            "Types numériques : INT, BIGINT pour les grands identifiants, DECIMAL(10,2) pour les montants (jamais FLOAT, qui fait des erreurs d'arrondi), TINYINT(1) ou BOOLEAN pour les booléens (BOOLEAN est un alias de TINYINT).",
            "Texte : VARCHAR(n) pour les textes courts (la longueur est vérifiée), TEXT pour les textes longs, ENUM('a','b') pour une liste fermée de valeurs. Les comparaisons de texte sont par défaut insensibles à la casse, selon la collation choisie.",
            "Dates : DATE, DATETIME, et TIMESTAMP, converti selon le fuseau horaire. Fonctions : NOW(), CURDATE(), DATE_ADD(d, INTERVAL 7 DAY), DATEDIFF(a, b), DATE_FORMAT(d, '%d/%m/%Y').",
            "Chaînes : CONCAT(a, b) pour concaténer (|| est un OU logique par défaut en MySQL !), IFNULL(x, défaut), SUBSTRING, UPPER, LOWER, LENGTH (en octets) et CHAR_LENGTH (en caractères).",
            "INSERT … ON DUPLICATE KEY UPDATE met à jour la ligne si la clé existe déjà : c'est l'UPSERT de MySQL. INSERT IGNORE ignore silencieusement les doublons.",
            "Le type JSON (MySQL 5.7+) stocke des documents validés, et JSON_EXTRACT(doc, '\$.champ') ou doc->>'\$.champ' en lit un champ.",
          ],
          codeBlocks: [
            code('MySQL', "CREATE TABLE commandes (\n  id BIGINT AUTO_INCREMENT PRIMARY KEY,\n  client_id INT NOT NULL,\n  total DECIMAL(10,2) NOT NULL,\n  statut ENUM('en_attente', 'payee', 'expediee') DEFAULT 'en_attente',\n  cree_le DATETIME DEFAULT CURRENT_TIMESTAMP\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;",
                e: "Montant exact en DECIMAL, statut en ENUM, date de création automatique."),
            code('MySQL', "SELECT CONCAT(prenom, ' ', nom) AS employe,\n       DATE_FORMAT(embauche, '%d/%m/%Y') AS embauche_fr,\n       DATEDIFF(CURDATE(), embauche) AS jours_anciennete\nFROM employes;",
                e: "Concaténation, format de date à la française et calcul d'écart."),
            code('MySQL', "INSERT INTO stocks (produit_id, quantite) VALUES (12, 5)\nON DUPLICATE KEY UPDATE quantite = quantite + VALUES(quantite);",
                e: "Ajoute 5 au stock du produit 12, ou crée la ligne si elle n'existe pas."),
          ],
          mistakes: [
            "Utiliser FLOAT ou DOUBLE pour des montants : préfère DECIMAL.",
            "Concaténer avec || : en MySQL, c'est un OU logique (sauf mode PIPES_AS_CONCAT). Utilise CONCAT().",
            "Oublier que les comparaisons de texte sont souvent insensibles à la casse : 'martin' = 'Martin' est vrai.",
          ],
          exercises: [
            ex("Quel type choisir pour stocker un prix en MySQL ?",
                "DECIMAL(10,2).",
                "DECIMAL stocke la valeur exacte, sans erreur d'arrondi."),
            ex("Écris la requête MySQL qui affiche les commandes des 7 derniers jours.",
                "SELECT * FROM commandes WHERE cree_le >= DATE_SUB(NOW(), INTERVAL 7 DAY);",
                "DATE_SUB (ou DATE_ADD avec un intervalle négatif) calcule la date limite."),
          ],
          quiz: [
            q(QuizType.qcm, "Quelle fonction concatène des chaînes en MySQL ?",
                ["CONCAT()", "||", "+", "JOIN()"], "CONCAT()",
                "|| est un OU logique par défaut en MySQL."),
            q(QuizType.qcm, "Quel type stocke un montant sans erreur d'arrondi ?",
                ["DECIMAL", "FLOAT", "DOUBLE", "REAL"], "DECIMAL",
                "FLOAT et DOUBLE sont des nombres approchés."),
            q(QuizType.qcm, "Quelle syntaxe fait un UPSERT en MySQL ?",
                ["ON DUPLICATE KEY UPDATE", "ON CONFLICT DO UPDATE", "MERGE INTO", "UPSERT INTO"],
                "ON DUPLICATE KEY UPDATE",
                "ON CONFLICT est la syntaxe de PostgreSQL et SQLite."),
          ],
          xp: 25,
        ),
        l(
          id: 'mysql_admin',
          track: 'mysql',
          level: 3,
          title: 'Administrer MySQL : utilisateurs, droits, sauvegarde',
          objective: "Créer des comptes avec les bons droits, sauvegarder et surveiller un serveur MySQL.",
          content: [
            "Un compte MySQL est défini par un nom ET une origine : 'app'@'localhost' et 'app'@'%' (toute machine) sont deux comptes différents. Limite l'origine au strict nécessaire.",
            "GRANT donne des droits précis (SELECT, INSERT, UPDATE, DELETE…) sur une base ou une table, REVOKE les retire. SHOW GRANTS FOR compte affiche les droits. L'application ne doit jamais utiliser le compte root.",
            "mysqldump exporte une base en SQL. L'option --single-transaction fait une copie cohérente des tables InnoDB sans bloquer les utilisateurs. La restauration se fait en rejouant le fichier avec le client mysql.",
            "Le binlog (journal binaire) enregistre toutes les modifications. Il sert à la réplication vers d'autres serveurs, et à la restauration à un instant précis en complément d'une sauvegarde complète.",
            "Pour trouver les requêtes lentes : activer le slow query log (long_query_time = 1 seconde par exemple), puis analyser les requêtes trouvées avec EXPLAIN pour vérifier l'usage des index.",
            "SHOW PROCESSLIST montre les requêtes en cours, et KILL id arrête une requête bloquante. Les réglages se trouvent dans le fichier my.cnf, notamment innodb_buffer_pool_size, la mémoire cache d'InnoDB, à régler selon la RAM disponible.",
          ],
          codeBlocks: [
            code('MySQL', "CREATE USER 'boutique_app'@'10.0.0.%' IDENTIFIED BY 'mot_de_passe_long';\nGRANT SELECT, INSERT, UPDATE ON boutique.* TO 'boutique_app'@'10.0.0.%';\nSHOW GRANTS FOR 'boutique_app'@'10.0.0.%';",
                e: "Un compte limité au réseau interne, sans droit de suppression ni d'administration."),
            code('bash', "mysqldump --single-transaction --routines boutique > boutique.sql\nmysql boutique_test < boutique.sql",
                e: "Sauvegarde cohérente sans blocage, puis restauration dans une base de test."),
            code('MySQL', "EXPLAIN SELECT * FROM commandes WHERE client_id = 42;\nSHOW PROCESSLIST;",
                e: "Vérifier qu'une requête utilise un index, et voir les requêtes en cours."),
          ],
          mistakes: [
            "Connecter l'application avec le compte root.",
            "Créer des comptes 'utilisateur'@'%' accessibles depuis n'importe quelle machine sans nécessité.",
            "Sauvegarder avec mysqldump sans --single-transaction sur une base active : la copie peut être incohérente.",
          ],
          exercises: [
            ex("Écris la commande qui donne au compte 'lecteur'@'localhost' le droit de lire toutes les tables de la base boutique.",
                "GRANT SELECT ON boutique.* TO 'lecteur'@'localhost';",
                "boutique.* désigne toutes les tables de la base."),
            ex("Quelle option de mysqldump permet une sauvegarde cohérente sans bloquer les tables InnoDB ?",
                "--single-transaction",
                "La sauvegarde lit une photo cohérente de la base au début de la transaction."),
          ],
          quiz: [
            q(QuizType.qcm, "Quelle commande retire un droit à un utilisateur ?",
                ["REVOKE", "DENY", "REMOVE", "DROP GRANT"], "REVOKE",
                "DENY existe en SQL Server, pas en MySQL."),
            tf("'app'@'localhost' et 'app'@'%' sont le même compte MySQL.", false,
                "L'origine fait partie de l'identité du compte."),
            q(QuizType.qcm, "À quoi sert le binlog de MySQL ?",
                ["Réplication et restauration à un instant précis", "Stocker les mots de passe", "Accélérer les SELECT", "Lister les utilisateurs"],
                "Réplication et restauration à un instant précis",
                "Il enregistre toutes les modifications de données."),
          ],
          xp: 40,
        ),
      ];

  // =====================================================================
  // MARIADB — niveaux Fondamentaux et Avancé
  // =====================================================================
  static List<Lesson> mariadb() => [
        l(
          id: 'mariadb_admin',
          track: 'mariadb',
          level: 1,
          title: 'Administrer MariaDB : comptes, droits et sauvegarde',
          objective: "Sécuriser un serveur MariaDB, créer des comptes et sauvegarder les données.",
          content: [
            "Sur Debian et Ubuntu, le compte root de MariaDB utilise par défaut l'authentification unix_socket : sudo mariadb suffit pour se connecter en root, sans mot de passe, mais seulement depuis le compte root du système.",
            "Pour une application, on crée un compte dédié : CREATE USER 'app'@'localhost' IDENTIFIED BY '…'; puis GRANT avec les seuls droits utiles. Les rôles (CREATE ROLE) regroupent des droits à attribuer à plusieurs comptes.",
            "Les commandes portent désormais le nom mariadb : mariadb (client), mariadb-dump (sauvegarde), mariadb-admin (administration). Les anciens noms mysql et mysqldump restent disponibles.",
            "mariadb-dump --single-transaction produit une sauvegarde logique cohérente. Pour les gros volumes, mariadb-backup fait une copie physique à chaud, beaucoup plus rapide à restaurer.",
            "Le fichier de configuration se trouve dans /etc/mysql/mariadb.conf.d/. Par défaut, le serveur n'écoute que localhost (bind-address = 127.0.0.1) : c'est plus sûr. Ne l'ouvre au réseau que si nécessaire, et derrière un pare-feu.",
            "systemctl status mariadb vérifie que le serveur tourne, et les journaux d'erreurs (journalctl -u mariadb) expliquent un démarrage raté.",
          ],
          codeBlocks: [
            code('MariaDB', "CREATE ROLE lecture;\nGRANT SELECT ON boutique.* TO lecture;\nCREATE USER 'rapport'@'localhost' IDENTIFIED BY 'mot_de_passe_long';\nGRANT lecture TO 'rapport'@'localhost';\nSET DEFAULT ROLE lecture FOR 'rapport'@'localhost';",
                e: "Un rôle en lecture seule attribué à un compte de reporting."),
            code('bash', "mariadb-dump --single-transaction boutique > boutique.sql\nmariadb boutique_test < boutique.sql\n\nmariadb-backup --backup --target-dir=/sauvegardes/complete",
                e: "Sauvegarde logique et restauration, puis sauvegarde physique à chaud."),
            code('bash', "sudo systemctl status mariadb\nsudo journalctl -u mariadb --since today",
                e: "Vérifier l'état du service et lire ses journaux."),
          ],
          mistakes: [
            "Donner un mot de passe au root et l'utiliser dans l'application.",
            "Ouvrir le port 3306 sur Internet en changeant bind-address sans pare-feu.",
            "Ne sauvegarder qu'avec une copie des fichiers pendant que le serveur tourne : utilise mariadb-backup.",
          ],
          exercises: [
            ex("Quelle commande produit une sauvegarde logique cohérente de la base boutique ?",
                "mariadb-dump --single-transaction boutique > boutique.sql",
                "--single-transaction évite de bloquer les tables InnoDB."),
            ex("À quoi sert un rôle (CREATE ROLE) ?",
                "À regrouper des droits pour les attribuer d'un coup à plusieurs comptes.",
                "On gère les droits une fois, sur le rôle."),
          ],
          quiz: [
            q(QuizType.qcm, "Quel outil fait une sauvegarde physique à chaud de MariaDB ?",
                ["mariadb-backup", "mariadb-dump", "mariadb-admin", "mariadb-check"], "mariadb-backup",
                "mariadb-dump fait une sauvegarde logique (fichier SQL)."),
            tf("Par défaut, MariaDB n'écoute que les connexions locales.", true,
                "bind-address = 127.0.0.1 dans la configuration par défaut."),
            q(QuizType.qcm, "Sur Debian, comment le root de MariaDB s'authentifie-t-il par défaut ?",
                ["Par unix_socket (sudo mariadb)", "Avec le mot de passe admin", "Sans aucune vérification", "Avec une clé SSH"],
                "Par unix_socket (sudo mariadb)",
                "Seul le root du système peut se connecter en root MariaDB."),
          ],
          xp: 25,
        ),
        l(
          id: 'mariadb_ha',
          track: 'mariadb',
          level: 3,
          title: 'Tables versionnées et haute disponibilité',
          objective: "Interroger l'historique des données et répartir MariaDB sur plusieurs serveurs.",
          content: [
            "Une table versionnée (WITH SYSTEM VERSIONING) conserve automatiquement toutes les versions passées de chaque ligne. Chaque UPDATE ou DELETE archive l'ancienne version avec sa période de validité.",
            "On interroge le passé avec FOR SYSTEM_TIME : AS OF '2026-01-01' montre la table telle qu'elle était à cette date, ALL montre toutes les versions. C'est idéal pour l'audit, ou pour réparer une erreur sans restaurer une sauvegarde.",
            "La réplication classique copie les modifications d'un serveur principal vers un ou plusieurs réplicas, via le binlog. Les réplicas servent aux lectures et à la reprise en cas de panne.",
            "Galera Cluster, intégré à MariaDB, est un cluster multi-maîtres synchrone : on peut écrire sur n'importe quel nœud, et chaque transaction est validée sur tous les nœuds avant le COMMIT. Il faut au moins 3 nœuds pour éviter les blocages en cas de coupure (quorum).",
            "MaxScale, le proxy de MariaDB, se place devant les serveurs : il envoie les écritures au principal, répartit les lectures et bascule automatiquement en cas de panne.",
            "La haute disponibilité ne remplace pas la sauvegarde : un DELETE malheureux est répliqué instantanément sur tous les nœuds.",
          ],
          codeBlocks: [
            code('MariaDB', "CREATE TABLE prix (\n  produit_id INT PRIMARY KEY,\n  prix DECIMAL(10,2)\n) WITH SYSTEM VERSIONING;\n\nUPDATE prix SET prix = 24.99 WHERE produit_id = 2;",
                e: "Chaque modification de prix est conservée automatiquement."),
            code('MariaDB', "SELECT * FROM prix FOR SYSTEM_TIME AS OF '2026-01-01 00:00:00';\n\nSELECT produit_id, prix, ROW_START, ROW_END\nFROM prix FOR SYSTEM_TIME ALL\nWHERE produit_id = 2;",
                e: "Les prix au 1er janvier, puis tout l'historique du produit 2."),
            code('texte', "        Application\n            │\n         MaxScale\n      ┌─────┼─────┐\n    Nœud1 Nœud2 Nœud3   ← Galera : écritures synchrones partout",
                e: "Un cluster Galera de 3 nœuds derrière le proxy MaxScale."),
          ],
          mistakes: [
            "Croire que la réplication ou Galera remplacent les sauvegardes.",
            "Monter un cluster Galera à 2 nœuds : en cas de coupure entre eux, aucun n'a la majorité.",
            "Versionner une table très modifiée sans prévoir la place : l'historique grossit à chaque UPDATE.",
          ],
          exercises: [
            ex("Écris la requête qui affiche la table prix telle qu'elle était le 1er mars 2026.",
                "SELECT * FROM prix FOR SYSTEM_TIME AS OF '2026-03-01';",
                "AS OF donne l'état de la table à un instant précis."),
            ex("Pourquoi un cluster Galera doit-il compter au moins 3 nœuds ?",
                "Pour qu'une majorité (quorum) reste possible si un nœud ou une liaison tombe.",
                "Avec 2 nœuds séparés, aucun ne sait s'il est du bon côté."),
          ],
          quiz: [
            q(QuizType.qcm, "Quelle clause interroge l'état passé d'une table versionnée ?",
                ["FOR SYSTEM_TIME AS OF", "AS OF TIMESTAMP", "HISTORY OF", "FLASHBACK"], "FOR SYSTEM_TIME AS OF",
                "AS OF TIMESTAMP est la syntaxe d'Oracle Flashback."),
            q(QuizType.qcm, "Galera Cluster est :",
                ["Un cluster multi-maîtres synchrone", "Un moteur de stockage colonnaire", "Un outil de sauvegarde", "Un client graphique"],
                "Un cluster multi-maîtres synchrone",
                "On peut écrire sur n'importe quel nœud."),
            tf("Avec la réplication, un DELETE par erreur est automatiquement annulé sur les réplicas.", false,
                "Il est répliqué comme toute autre modification : seule une sauvegarde ou l'historique permet de revenir en arrière."),
          ],
          xp: 40,
        ),
      ];

  // =====================================================================
  // SQL SERVER — niveaux Fondamentaux et Intermédiaire
  // =====================================================================
  static List<Lesson> sqlserver() => [
        l(
          id: 'mssql_sql',
          track: 'sqlserver',
          level: 1,
          title: 'Types et fonctions T-SQL',
          objective: "Choisir les bons types et utiliser les fonctions courantes de SQL Server.",
          content: [
            "Types courants : INT et BIGINT, DECIMAL(10,2) pour les montants, BIT pour les booléens (0/1), NVARCHAR(n) pour le texte Unicode, NVARCHAR(MAX) pour les textes longs, DATE, DATETIME2 (plus précis que l'ancien DATETIME) et UNIQUEIDENTIFIER pour les GUID.",
            "Dates : GETDATE() ou SYSDATETIME() pour maintenant, DATEADD(day, 7, d) pour ajouter, DATEDIFF(day, a, b) pour un écart, FORMAT(d, 'dd/MM/yyyy') pour l'affichage, EOMONTH(d) pour le dernier jour du mois.",
            "Texte : + ou CONCAT() pour concaténer (CONCAT ignore les NULL, + renvoie NULL), LEN, UPPER, LOWER, SUBSTRING, REPLACE, TRIM, STRING_AGG(colonne, ', ') pour regrouper des valeurs en une chaîne.",
            "NULL : ISNULL(x, défaut) ou le standard COALESCE. Conditions : CASE WHEN, ou IIF(condition, si_vrai, si_faux).",
            "TOP n WITH TIES renvoie aussi les ex æquo du dernier rang. La clause OUTPUT renvoie les lignes modifiées par un INSERT, un UPDATE ou un DELETE (inserted.*, deleted.*).",
            "Les chaînes Unicode littérales se préfixent par N : N'Élodie'. Sans le N, les caractères hors de la page de code du serveur peuvent être perdus.",
          ],
          codeBlocks: [
            code('T-SQL', "SELECT CONCAT(prenom, ' ', nom) AS employe,\n       FORMAT(embauche, 'dd/MM/yyyy') AS embauche_fr,\n       DATEDIFF(year, embauche, GETDATE()) AS annees\nFROM employes;",
                e: "Concaténation, format de date et écart en années."),
            code('T-SQL', "SELECT d.nom, STRING_AGG(e.nom, ', ') AS equipe\nFROM departements d\nJOIN employes e ON e.departement_id = d.id\nGROUP BY d.nom;",
                e: "La liste des employés de chaque département en une seule chaîne."),
            code('T-SQL', "INSERT INTO clients (nom, email)\nOUTPUT inserted.id, inserted.nom\nVALUES (N'Élodie', N'elodie@example.com');",
                e: "OUTPUT renvoie l'id généré ; le préfixe N garde les accents."),
          ],
          mistakes: [
            "Oublier le préfixe N devant les chaînes Unicode : N'Élodie'.",
            "Concaténer avec + une valeur NULL : tout le résultat devient NULL (CONCAT les ignore).",
            "Utiliser l'ancien type DATETIME au lieu de DATETIME2, plus précis et plus large.",
          ],
          exercises: [
            ex("Quelle fonction T-SQL ajoute 30 jours à une date ?",
                "DATEADD(day, 30, la_date)",
                "Le premier argument est l'unité : day, month, year…"),
            ex("Écris la requête T-SQL qui affiche les 3 salaires les plus élevés, ex æquo compris.",
                "SELECT TOP 3 WITH TIES nom, salaire FROM employes ORDER BY salaire DESC;",
                "WITH TIES ajoute les lignes à égalité avec la dernière."),
          ],
          quiz: [
            q(QuizType.qcm, "Quel type stocke un booléen en SQL Server ?",
                ["BIT", "BOOLEAN", "BOOL", "TINYBOOL"], "BIT",
                "BIT vaut 0, 1 ou NULL."),
            q(QuizType.qcm, "Quelle clause renvoie les lignes insérées ou modifiées en T-SQL ?",
                ["OUTPUT", "RETURNING", "RESULT", "SELECT INSERTED"], "OUTPUT",
                "RETURNING est l'équivalent en PostgreSQL."),
            q(QuizType.predictResult, "Que renvoie 'Bonjour ' + NULL en T-SQL ?",
                ["NULL", "'Bonjour '", "Une erreur", "'Bonjour NULL'"], "NULL",
                "CONCAT('Bonjour ', NULL) renverrait 'Bonjour '."),
          ],
          xp: 25,
        ),
        l(
          id: 'mssql_index',
          track: 'sqlserver',
          level: 2,
          title: "Index, vues et plans d'exécution",
          objective: "Comprendre les index cluster et non cluster, et lire un plan d'exécution.",
          content: [
            "SQL Server distingue deux sortes d'index. L'index CLUSTER détermine l'ordre physique des lignes : il y en a un seul par table, et c'est par défaut la clé primaire. Les index NON CLUSTER sont des structures séparées qui pointent vers les lignes.",
            "Un index non cluster peut INCLURE des colonnes supplémentaires (INCLUDE) : la requête trouve alors toutes ses colonnes dans l'index, sans lire la table. On parle d'index couvrant.",
            "Le plan d'exécution (Ctrl+M dans SSMS, « plan réel ») montre comment la requête est exécutée. Index Seek est une recherche ciblée, Index Scan ou Table Scan un parcours complet, et Key Lookup un aller-retour vers la table, souvent évitable avec INCLUDE.",
            "SET STATISTICS IO ON affiche le nombre de pages lues par chaque requête : c'est la mesure la plus fiable pour comparer deux versions d'une requête.",
            "Une vue (CREATE VIEW) simplifie les requêtes répétées. Une vue indexée (avec WITH SCHEMABINDING et un index cluster unique) stocke son résultat, comme une vue matérialisée, et est maintenue automatiquement.",
            "Les index se fragmentent avec le temps : ALTER INDEX … REORGANIZE ou REBUILD les remet en ordre. Les statistiques, qui guident l'optimiseur, se mettent à jour avec UPDATE STATISTICS.",
          ],
          codeBlocks: [
            code('T-SQL', "CREATE NONCLUSTERED INDEX ix_commandes_client\nON dbo.commandes (client_id)\nINCLUDE (date_cmd, total);",
                e: "Un index couvrant : la requête ci-dessous n'a plus besoin de lire la table."),
            code('T-SQL', "SET STATISTICS IO ON;\nSELECT date_cmd, total\nFROM dbo.commandes\nWHERE client_id = 42;",
                e: "Affiche les pages lues : à comparer avant et après la création de l'index."),
            code('T-SQL', "CREATE VIEW dbo.v_ca_client WITH SCHEMABINDING AS\nSELECT client_id, SUM(total) AS ca, COUNT_BIG(*) AS nb\nFROM dbo.commandes\nGROUP BY client_id;\nGO\nCREATE UNIQUE CLUSTERED INDEX ix_v_ca ON dbo.v_ca_client (client_id);",
                e: "Une vue indexée : le chiffre d'affaires par client est stocké et tenu à jour."),
          ],
          mistakes: [
            "Créer un index non cluster par colonne au lieu d'index adaptés aux requêtes réelles.",
            "Ignorer les Key Lookup dans le plan : un INCLUDE les supprime souvent.",
            "Juger une optimisation au temps d'exécution seul, sans regarder les lectures (STATISTICS IO).",
          ],
          exercises: [
            ex("Combien d'index cluster une table peut-elle avoir ?",
                "Un seul.",
                "Il définit l'ordre physique des lignes, qui ne peut être qu'unique."),
            ex("Écris un index non cluster sur produits(categorie_id) qui couvre aussi les colonnes nom et prix.",
                "CREATE NONCLUSTERED INDEX ix_produits_cat ON dbo.produits (categorie_id) INCLUDE (nom, prix);",
                "INCLUDE ajoute les colonnes au niveau feuille de l'index."),
          ],
          quiz: [
            q(QuizType.qcm, "Dans un plan d'exécution, quelle opération est une recherche ciblée ?",
                ["Index Seek", "Table Scan", "Index Scan", "Key Lookup"], "Index Seek",
                "Les Scan parcourent tout, le Key Lookup est un aller-retour vers la table."),
            q(QuizType.qcm, "À quoi sert INCLUDE dans un index non cluster ?",
                ["Ajouter des colonnes pour couvrir la requête", "Inclure les lignes supprimées", "Lier deux tables", "Chiffrer l'index"],
                "Ajouter des colonnes pour couvrir la requête",
                "La requête lit tout dans l'index, sans accéder à la table."),
            tf("Par défaut, la clé primaire d'une table SQL Server est son index cluster.", true,
                "Sauf si on précise PRIMARY KEY NONCLUSTERED."),
          ],
          xp: 35,
        ),
      ];

  // =====================================================================
  // ORACLE — niveaux Fondamentaux et Intermédiaire
  // =====================================================================
  static List<Lesson> oracle() => [
        l(
          id: 'oracle_sql',
          track: 'oracle',
          level: 1,
          title: "Le SQL d'Oracle : types, séquences et fonctions",
          objective: "Écrire des tables et des requêtes dans le dialecte d'Oracle.",
          content: [
            "Types principaux : NUMBER(p, s) pour tous les nombres (NUMBER(10,2) pour un montant), VARCHAR2(n) pour le texte (VARCHAR est déconseillé), CLOB pour les textes longs, DATE (qui contient aussi l'heure !) et TIMESTAMP. Il n'y a pas de type BOOLEAN en SQL avant la version 23ai.",
            "Auto-incrément : depuis la 12c, GENERATED AS IDENTITY. Avant, on utilisait une séquence (CREATE SEQUENCE) et nom_seq.NEXTVAL dans l'INSERT. Les séquences restent utiles pour numéroter des factures.",
            "NULL : NVL(x, défaut) est l'équivalent de COALESCE, et NVL2(x, si_non_null, si_null) choisit selon la présence d'une valeur. DECODE(x, v1, r1, v2, r2, défaut) est l'ancien équivalent de CASE.",
            "Dates : SYSDATE (date et heure du serveur), TO_DATE('19/11/2026', 'DD/MM/YYYY') pour convertir un texte, TO_CHAR(d, 'DD/MM/YYYY') pour l'afficher, ADD_MONTHS(d, 1), TRUNC(d) pour retirer l'heure. On peut ajouter des jours directement : SYSDATE + 7.",
            "Texte : || pour concaténer, UPPER, LOWER, INITCAP (première lettre en majuscule), SUBSTR, INSTR, LENGTH, TRIM, LISTAGG(colonne, ', ') pour regrouper des valeurs.",
            "Comme DATE contient l'heure, WHERE date_cmd = DATE '2026-11-19' ne trouve que les commandes passées à minuit pile. Utilise TRUNC(date_cmd) ou un intervalle.",
          ],
          codeBlocks: [
            code('Oracle', "CREATE SEQUENCE seq_facture START WITH 1000 INCREMENT BY 1;\n\nINSERT INTO factures (numero, client_id, emise_le)\nVALUES (seq_facture.NEXTVAL, 42, SYSDATE);",
                e: "Une séquence pour numéroter les factures."),
            code('Oracle', "SELECT INITCAP(nom) AS nom,\n       NVL(TO_CHAR(manager_id), 'aucun') AS manager,\n       TO_CHAR(embauche, 'DD/MM/YYYY') AS embauche_fr,\n       ADD_MONTHS(embauche, 6) AS fin_periode_essai\nFROM employes;",
                e: "Fonctions de texte, de NULL et de dates."),
            code('Oracle', "SELECT d.nom,\n       LISTAGG(e.nom, ', ') WITHIN GROUP (ORDER BY e.nom) AS equipe\nFROM departements d\nJOIN employes e ON e.departement_id = d.id\nGROUP BY d.nom;",
                e: "La liste triée des employés de chaque département."),
          ],
          mistakes: [
            "Oublier que DATE contient l'heure : une égalité sur une date seule rate presque tout.",
            "Utiliser VARCHAR au lieu de VARCHAR2.",
            "Comparer une date à un texte sans TO_DATE : la conversion dépend des réglages de la session.",
          ],
          exercises: [
            ex("Quelle fonction Oracle remplace une valeur NULL par une valeur par défaut ?",
                "NVL(x, défaut) (ou COALESCE).",
                "NVL est la fonction historique d'Oracle."),
            ex("Écris la requête Oracle qui affiche les commandes passées aujourd'hui, quelle que soit l'heure.",
                "SELECT * FROM commandes WHERE TRUNC(date_cmd) = TRUNC(SYSDATE);",
                "TRUNC retire l'heure des deux côtés."),
          ],
          quiz: [
            q(QuizType.qcm, "Quel type de texte faut-il utiliser dans Oracle ?",
                ["VARCHAR2", "VARCHAR", "NVARCHAR(MAX)", "STRING"], "VARCHAR2",
                "VARCHAR est réservé par Oracle pour un usage futur."),
            q(QuizType.qcm, "Comment obtient-on la valeur suivante d'une séquence ?",
                ["seq.NEXTVAL", "NEXT VALUE seq", "seq++", "AUTO(seq)"], "seq.NEXTVAL",
                "NEXT VALUE FOR seq est la syntaxe de SQL Server."),
            tf("Dans Oracle, le type DATE contient aussi l'heure.", true,
                "D'où l'usage fréquent de TRUNC pour comparer des jours."),
          ],
          xp: 25,
        ),
        l(
          id: 'oracle_tx',
          track: 'oracle',
          level: 2,
          title: 'Transactions et concurrence dans Oracle',
          objective: "Comprendre le COMMIT explicite, la lecture cohérente et les verrous d'Oracle.",
          content: [
            "Dans Oracle, il n'y a pas d'autocommit par défaut dans SQL*Plus ou SQL Developer : une transaction commence automatiquement au premier INSERT, UPDATE ou DELETE, et dure jusqu'au COMMIT ou au ROLLBACK. Fermer SQL Developer sans COMMIT peut faire perdre son travail.",
            "En revanche, chaque instruction DDL (CREATE, ALTER, DROP) fait un COMMIT implicite avant et après elle : elle valide aussi les modifications en cours.",
            "Lecture cohérente : une requête voit les données telles qu'elles étaient à son démarrage, grâce aux informations d'annulation (UNDO). Les lecteurs ne bloquent jamais les écrivains, et les écrivains ne bloquent jamais les lecteurs.",
            "Deux sessions qui modifient la même ligne se bloquent : la seconde attend le COMMIT ou le ROLLBACK de la première. SELECT … FOR UPDATE verrouille à l'avance les lignes qu'on va modifier, et NOWAIT renvoie une erreur au lieu d'attendre.",
            "Flashback : SELECT … AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '10' MINUTE) lit une table telle qu'elle était il y a 10 minutes, tant que l'UNDO est disponible. FLASHBACK TABLE … TO BEFORE DROP récupère une table supprimée depuis la corbeille.",
            "SAVEPOINT nom puis ROLLBACK TO nom annulent une partie seulement de la transaction, comme en SQL standard.",
          ],
          codeBlocks: [
            code('Oracle', "UPDATE comptes SET solde = solde - 100 WHERE id = 1;\nUPDATE comptes SET solde = solde + 100 WHERE id = 2;\nCOMMIT;",
                e: "Sans le COMMIT final, les autres sessions ne voient rien, et tout est perdu si la session se ferme."),
            code('Oracle', "SELECT solde FROM comptes WHERE id = 1 FOR UPDATE NOWAIT;\nUPDATE comptes SET solde = solde - 100 WHERE id = 1;\nCOMMIT;",
                e: "Verrouille la ligne avant de la modifier, et échoue immédiatement si quelqu'un d'autre l'a déjà verrouillée."),
            code('Oracle', "-- Les produits tels qu'ils étaient il y a 15 minutes\nSELECT * FROM produits\nAS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '15' MINUTE);\n\n-- Récupérer une table supprimée par erreur\nFLASHBACK TABLE produits TO BEFORE DROP;",
                e: "Flashback : revenir en arrière sans restaurer de sauvegarde."),
          ],
          mistakes: [
            "Oublier le COMMIT dans SQL Developer : les modifications ne sont ni visibles ni définitives.",
            "Ignorer que CREATE, ALTER ou DROP valident implicitement la transaction en cours.",
            "Garder une transaction ouverte longtemps : les lignes modifiées restent verrouillées pour les autres.",
          ],
          exercises: [
            ex("Que se passe-t-il si on exécute un CREATE TABLE au milieu d'une transaction Oracle ?",
                "Un COMMIT implicite valide les modifications en cours avant le CREATE.",
                "Toute instruction DDL valide la transaction."),
            ex("Écris la requête qui affiche la table commandes telle qu'elle était il y a une heure.",
                "SELECT * FROM commandes AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '1' HOUR);",
                "C'est une requête Flashback, qui s'appuie sur l'UNDO."),
          ],
          quiz: [
            tf("SQL*Plus valide automatiquement chaque UPDATE (autocommit).", false,
                "Par défaut, il faut un COMMIT explicite."),
            q(QuizType.qcm, "Que fait SELECT … FOR UPDATE ?",
                ["Verrouille les lignes lues en vue de les modifier", "Met à jour toutes les lignes", "Crée un index", "Valide la transaction"],
                "Verrouille les lignes lues en vue de les modifier",
                "Les autres sessions ne peuvent plus modifier ces lignes jusqu'au COMMIT."),
            q(QuizType.qcm, "Grâce à quoi une requête Oracle voit-elle des données cohérentes pendant que d'autres écrivent ?",
                ["Les informations d'annulation (UNDO)", "Des verrous sur toute la table", "Une copie complète de la base", "L'autocommit"],
                "Les informations d'annulation (UNDO)",
                "Les lecteurs ne bloquent pas les écrivains, et inversement."),
          ],
          xp: 35,
        ),
      ];

  // =====================================================================
  // MONGODB — niveau Avancé
  // =====================================================================
  static List<Lesson> mongodb() => [
        l(
          id: 'mongo_model',
          track: 'mongodb',
          level: 3,
          title: 'Modélisation et index MongoDB',
          objective: "Choisir entre imbriquer et référencer, et indexer correctement une collection.",
          content: [
            "En MongoDB, on modélise selon la façon dont les données sont LUES : ce qui est lu ensemble doit être stocké ensemble. C'est l'inverse du relationnel, où l'on modélise d'abord les entités.",
            "IMBRIQUER (un sous-document ou un tableau dans le document) convient aux relations « contient » de taille limitée : les lignes d'une commande, l'adresse d'un client. Une seule lecture suffit, et la mise à jour est atomique.",
            "RÉFÉRENCER (stocker l'_id d'un autre document) convient aux relations nombreuses ou partagées : les commandes d'un client (qui grossissent sans limite), un produit présent dans des milliers de commandes. On joint au besoin avec \$lookup.",
            "Sans index, find() parcourt toute la collection (COLLSCAN). createIndex({ champ: 1 }) crée un index croissant. Un index composé { client_id: 1, date: -1 } sert aux recherches par client triées par date. Les index uniques ({ unique: true }) empêchent les doublons, et les index TTL suppriment automatiquement les documents expirés.",
            "explain('executionStats') montre si un index est utilisé (IXSCAN) ou non (COLLSCAN), et combien de documents ont été examinés pour en renvoyer combien.",
            "Pour garder un minimum de structure, on peut ajouter une validation de schéma (\$jsonSchema) à une collection : champs obligatoires, types attendus.",
          ],
          codeBlocks: [
            code('mongosh', r'''// Imbriquer : la commande contient ses lignes
db.commandes.insertOne({
  client_id: ObjectId("665f1c2a9b1e8a3d4c2b1a00"),   // référence
  date: new Date(),
  lignes: [ { produit: "Clavier", qte: 1, prix: 79.99 } ]  // imbriqué
});''',
                e: "Les lignes sont imbriquées (lues avec la commande), le client est référencé (partagé)."),
            code('mongosh', r'''db.commandes.createIndex({ client_id: 1, date: -1 });
db.clients.createIndex({ email: 1 }, { unique: true });
db.sessions.createIndex({ cree_le: 1 }, { expireAfterSeconds: 3600 });''',
                e: "Un index composé, un index unique, et un index TTL qui supprime les sessions après une heure."),
            code('mongosh', r'''db.commandes.find({ client_id: ObjectId("665f1c2a9b1e8a3d4c2b1a00") })
  .sort({ date: -1 })
  .explain("executionStats");''',
                e: "Vérifier que le plan utilise l'index (IXSCAN) et non un parcours complet (COLLSCAN)."),
          ],
          mistakes: [
            "Imbriquer des tableaux qui grossissent sans limite (tous les avis d'un produit très populaire).",
            "Reproduire un schéma relationnel avec des références partout, puis des \$lookup à chaque lecture.",
            "Oublier les index : chaque recherche parcourt alors toute la collection.",
          ],
          exercises: [
            ex("Un blog : faut-il imbriquer les commentaires dans l'article ou les référencer ?",
                "Les référencer (ou ne garder que les derniers dans l'article) : les commentaires peuvent être très nombreux.",
                "Un document est limité à 16 Mo et doit rester de taille raisonnable."),
            ex("Crée un index unique sur le champ email de la collection utilisateurs.",
                "db.utilisateurs.createIndex({ email: 1 }, { unique: true });",
                "L'index accélère les recherches et empêche les doublons."),
          ],
          quiz: [
            q(QuizType.qcm, "Dans un plan MongoDB, que signifie COLLSCAN ?",
                ["Un parcours complet de la collection", "Une recherche par index", "Une jointure", "Une compression"],
                "Un parcours complet de la collection",
                "IXSCAN indique l'utilisation d'un index."),
            q(QuizType.qcm, "Quand faut-il plutôt imbriquer des données ?",
                ["Quand elles sont lues ensemble et de taille limitée", "Quand elles sont partagées par des milliers de documents", "Quand elles grossissent sans limite", "Jamais"],
                "Quand elles sont lues ensemble et de taille limitée",
                "Ce qui est lu ensemble est stocké ensemble."),
            tf("Un index TTL supprime automatiquement les documents expirés.", true,
                "Pratique pour les sessions, les jetons ou les journaux temporaires."),
          ],
          xp: 40,
        ),
      ];

  // =====================================================================
  // REDIS — niveaux Intermédiaire et Avancé
  // =====================================================================
  static List<Lesson> redis() => [
        l(
          id: 'redis_patterns',
          track: 'redis',
          level: 2,
          title: 'Motifs courants : cache, sessions, limitation, verrous',
          objective: "Mettre en œuvre les usages classiques de Redis dans une application.",
          content: [
            "Cache : on lit d'abord Redis, sinon la base, puis on met le résultat en cache avec une durée de vie (cache-aside). À chaque modification de la donnée en base, on supprime la clé (DEL) pour éviter de servir une valeur périmée.",
            "Sessions : la session d'un utilisateur est stockée dans un hash (session:<jeton>) avec un EXPIRE. Tous les serveurs web partagent ainsi les mêmes sessions, et elles expirent toutes seules.",
            "Limitation de débit (rate limiting) : INCR sur une clé par utilisateur et par minute (rate:user42:202611191430), avec EXPIRE 60. Au-delà de la limite, on refuse la requête. C'est simple, atomique et très rapide.",
            "Verrou distribué : SET verrou:facture:12 <identifiant> NX EX 30 ne réussit que si la clé n'existe pas encore (NX), et expire seul après 30 secondes, même si le programme plante. On libère le verrou en vérifiant d'abord qu'on en est bien le propriétaire.",
            "Classements : un ZSET avec ZINCRBY pour ajouter des points et ZREVRANGE pour afficher le top. Files de tâches : LPUSH pour ajouter, BRPOP pour attendre et retirer (bloquant), ou les Streams pour des files fiables avec accusé de réception.",
            "MULTI … EXEC exécute plusieurs commandes d'un bloc, sans qu'un autre client ne s'intercale. Pour une logique plus complexe, un script Lua (EVAL) s'exécute de façon atomique sur le serveur.",
          ],
          codeBlocks: [
            code('redis-cli', "INCR rate:user42:202611191430\nEXPIRE rate:user42:202611191430 60\n# si la valeur renvoyée par INCR dépasse 100 → refuser la requête",
                e: "Limiter un utilisateur à 100 requêtes par minute."),
            code('redis-cli', "SET verrou:facture:12 \"worker-7\" NX EX 30\n# → OK : verrou obtenu ; (nil) : quelqu'un d'autre le détient\nGET verrou:facture:12\nDEL verrou:facture:12",
                e: "Un verrou qui expire seul après 30 secondes si le programme plante."),
            code('redis-cli', "MULTI\nDECRBY stock:produit:3 1\nLPUSH commandes:a_traiter \"cmd-981\"\nEXEC",
                e: "Deux commandes exécutées d'un bloc, sans interruption."),
          ],
          mistakes: [
            "Mettre en cache sans expiration ni invalidation : les utilisateurs voient des données périmées.",
            "Prendre un verrou sans durée d'expiration : il reste bloqué pour toujours si le programme plante.",
            "Utiliser Redis comme seule copie de données importantes sans persistance.",
          ],
          exercises: [
            ex("Quelle commande crée un verrou seulement s'il n'existe pas, avec une expiration de 10 secondes ?",
                "SET verrou:ressource mon_id NX EX 10",
                "NX : seulement si la clé n'existe pas ; EX : durée en secondes."),
            ex("Que faut-il faire dans le cache quand une donnée est modifiée en base ?",
                "Supprimer (DEL) ou mettre à jour la clé correspondante, pour ne pas servir une valeur périmée.",
                "C'est l'invalidation du cache."),
          ],
          quiz: [
            q(QuizType.qcm, "Que signifie l'option NX de SET ?",
                ["Seulement si la clé n'existe pas", "Ne jamais expirer", "Écraser la clé", "Lire puis écrire"],
                "Seulement si la clé n'existe pas",
                "XX fait l'inverse : seulement si la clé existe déjà."),
            q(QuizType.qcm, "Quelle commande permet d'attendre un élément dans une file ?",
                ["BRPOP", "RPOP", "GET", "WAIT"], "BRPOP",
                "Le B signifie bloquant : la commande attend qu'un élément arrive."),
            tf("Les commandes entre MULTI et EXEC sont exécutées d'un bloc, sans qu'un autre client ne s'intercale.", true,
                "C'est la transaction Redis."),
          ],
          xp: 30,
        ),
        l(
          id: 'redis_persistence',
          track: 'redis',
          level: 3,
          title: 'Persistance, réplication et haute disponibilité',
          objective: "Protéger les données Redis et faire tenir Redis en production.",
          content: [
            "RDB : Redis écrit périodiquement un instantané complet de la mémoire sur disque (par exemple toutes les 5 minutes s'il y a eu des modifications). C'est compact et rapide à recharger, mais on peut perdre les dernières minutes en cas de panne.",
            "AOF (Append Only File) : chaque écriture est ajoutée à un journal, synchronisé sur disque chaque seconde avec appendfsync everysec. On perd au plus une seconde de données. On peut combiner RDB et AOF.",
            "maxmemory fixe la mémoire maximale, et maxmemory-policy décide quoi faire quand elle est atteinte : allkeys-lru supprime les clés les moins récemment utilisées (idéal pour un cache), noeviction refuse les nouvelles écritures (pour des données à ne pas perdre).",
            "Réplication : des réplicas (REPLICAOF) reçoivent une copie de toutes les écritures du principal. Ils servent aux lectures et à la reprise en cas de panne.",
            "Redis Sentinel surveille le principal et promeut automatiquement un réplica s'il tombe, puis indique aux clients la nouvelle adresse. Redis Cluster va plus loin : il répartit les clés sur plusieurs principaux (16 384 emplacements de hachage), chacun avec ses réplicas.",
            "Sécurité : Redis ne doit jamais être exposé sur Internet. Active un mot de passe et des ACL (requirepass, ACL SETUSER), écoute sur une interface privée, et utilise TLS si le trafic traverse un réseau non sûr.",
          ],
          codeBlocks: [
            code('redis.conf', "# Persistance\nsave 300 10            # instantané RDB si 10 modifs en 5 min\nappendonly yes\nappendfsync everysec   # AOF : au plus 1 s de perte\n\n# Mémoire\nmaxmemory 2gb\nmaxmemory-policy allkeys-lru",
                e: "Une configuration courante : RDB + AOF, et éviction LRU pour un cache."),
            code('redis-cli', "INFO persistence\nINFO replication\nREPLICAOF 10.0.0.5 6379",
                e: "Voir l'état de la persistance et de la réplication, et faire de ce serveur un réplica."),
            code('redis-cli', "ACL SETUSER app on >mot_de_passe_long ~cache:* +get +set +del +expire\nACL LIST",
                e: "Un utilisateur limité aux clés cache:* et à quelques commandes."),
          ],
          mistakes: [
            "Exposer Redis sur Internet sans mot de passe : des robots le trouvent en quelques minutes.",
            "Utiliser noeviction pour un cache : quand la mémoire est pleine, toutes les écritures échouent.",
            "Croire qu'un réplica protège contre un FLUSHALL accidentel : il est répliqué aussitôt.",
          ],
          exercises: [
            ex("Quelle politique d'éviction choisir pour un Redis utilisé comme cache ?",
                "allkeys-lru (supprimer les clés les moins récemment utilisées).",
                "Un cache peut toujours être reconstruit depuis la base."),
            ex("Quelle option AOF limite la perte de données à environ une seconde ?",
                "appendfsync everysec",
                "Le journal est synchronisé sur disque chaque seconde."),
          ],
          quiz: [
            q(QuizType.qcm, "Quel mode de persistance enregistre chaque écriture dans un journal ?",
                ["AOF", "RDB", "LRU", "TTL"], "AOF",
                "RDB fait des instantanés périodiques."),
            q(QuizType.qcm, "Quel outil promeut automatiquement un réplica quand le principal tombe ?",
                ["Redis Sentinel", "redis-cli", "RDB", "MULTI"], "Redis Sentinel",
                "Redis Cluster gère aussi la bascule, en plus de répartir les clés."),
            tf("On peut exposer Redis sur Internet sans risque s'il ne contient qu'un cache.", false,
                "Un Redis ouvert peut être détourné pour écrire des fichiers ou exécuter des commandes sur le serveur."),
          ],
          xp: 40,
        ),
      ];
}
