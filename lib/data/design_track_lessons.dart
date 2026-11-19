import '../models/lesson_models.dart';

/// Design, conception and programming tracks.
///
/// Conventions (checked by test/lesson_content_test.dart):
/// - SQL examples that run in the app's Console start with `-- base : <id>`;
/// - runnable exercises end with `(base <id>)`.
///
/// Quiz progress is stored per question index (`<lessonId>#q<i>`): never
/// reorder or remove existing quiz items, only append new ones.
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

  static QuizItem tf(String question, bool correct, String explanation) =>
      q(QuizType.trueFalse, question, const ['Vrai', 'Faux'],
          correct ? 'Vrai' : 'Faux', explanation);

  static ExerciseItem ex(String q, String a, String e) => ExerciseItem(q, a, e);

  // =====================================================================
  // CONCEPTION & MODÉLISATION
  // =====================================================================
  static List<Lesson> design() => [
        l(
          id: 'dsg_er',
          track: 'design',
          level: 0,
          title: 'Diagrammes Entité-Relation (ER)',
          objective: "Modéliser un besoin réel avec des entités, des attributs et des relations.",
          content: [
            "Avant d'écrire le moindre CREATE TABLE, on dessine le modèle de données. Le diagramme Entité-Relation (ER), appelé MCD dans la méthode Merise, sert à discuter du besoin avec tout le monde, y compris les non-techniciens.",
            "Une ENTITÉ est un objet du monde réel que l'on veut mémoriser : Client, Produit, Commande. Elle deviendra une table. Repère-les dans le cahier des charges : ce sont souvent les noms communs importants.",
            "Un ATTRIBUT est une propriété d'une entité (nom, prix, date) : il deviendra une colonne. Chaque entité a un IDENTIFIANT, l'attribut qui distingue chaque occurrence, et qui deviendra la clé primaire.",
            "Une RELATION relie des entités (un Client PASSE des Commandes). Elle porte des CARDINALITÉS : combien de commandes un client peut-il passer (0 à plusieurs) ? À combien de clients appartient une commande (exactement 1) ?",
            "Une relation plusieurs-à-plusieurs, comme une commande qui contient plusieurs produits, chaque produit pouvant être dans plusieurs commandes, devient une table intermédiaire : la ligne de commande, avec ses propres attributs (quantité, prix unitaire).",
            "Démarche : lire le besoin, lister les entités, leurs attributs et identifiants, tracer les relations et leurs cardinalités, puis traduire en tables. Les exemples ci-dessous font cette traduction dans la base Boutique.",
          ],
          codeBlocks: [
            code('texte', "[CLIENT] 1 ──passe──< [COMMANDE] >──contient──< [PRODUIT]\n                              (quantité)\n\nClient   : id, nom, email\nCommande : id, date\nProduit  : id, nom, prix",
                e: "Un client passe 0..n commandes ; une commande contient 1..n produits."),
            code('sql', "-- base : boutique\nCREATE TABLE commandes (\n  id INTEGER PRIMARY KEY,\n  client_id INTEGER NOT NULL REFERENCES clients(id),\n  date_cmd TEXT NOT NULL\n);\nCREATE TABLE lignes_commande (\n  commande_id INTEGER REFERENCES commandes(id),\n  product_id INTEGER REFERENCES products(id),\n  quantite INTEGER NOT NULL CHECK (quantite > 0),\n  PRIMARY KEY (commande_id, product_id)\n);",
                e: "Le schéma traduit en tables : la relation N-N devient la table lignes_commande."),
            code('sql', "-- base : boutique\nINSERT INTO commandes (client_id, date_cmd) VALUES (1, '2026-11-19');\nINSERT INTO lignes_commande VALUES (1, 2, 3);\nSELECT c.nom, p.name, l.quantite\nFROM lignes_commande l\nJOIN commandes o ON o.id = l.commande_id\nJOIN clients c ON c.id = o.client_id\nJOIN products p ON p.id = l.product_id;",
                e: "Alice commande 3 souris : le modèle permet de retrouver qui a commandé quoi (instructions à exécuter une par une)."),
          ],
          mistakes: [
            "Confondre entité et attribut (la ville d'un client est-elle un simple attribut ou une entité ?).",
            "Commencer à coder sans schéma préalable.",
            "Oublier l'entité intermédiaire d'une relation plusieurs-à-plusieurs (ici la ligne de commande).",
          ],
          exercises: [
            ex("Dans un diagramme ER, que devient généralement une entité ?",
                "Une table.",
                "Les entités se transposent en tables."),
            ex("Une bibliothèque prête des livres à des adhérents. Quelles entités identifies-tu ?",
                "Livre, Auteur, Adhérent et Emprunt (avec la date d'emprunt et la date de retour).",
                "L'emprunt relie un adhérent et un livre, et porte ses propres dates."),
            ex("Crée la table adherents avec un id, un nom obligatoire et un email unique. (base bibliotheque)",
                "CREATE TABLE adherents (id INTEGER PRIMARY KEY, nom TEXT NOT NULL, email TEXT UNIQUE);",
                "L'identifiant de l'entité devient la clé primaire."),
          ],
          quiz: [
            q(QuizType.qcm, 'Une entité dans un diagramme ER correspond à :',
                ['Un concept du monde réel', 'Une formule', 'Une requête', 'Un index'], 'Un concept du monde réel',
                'Les entités représentent des objets concrets.'),
            q(QuizType.qcm, "Dans un schéma ER, un attribut devient généralement :",
                ["Une colonne", "Une table", "Une base", "Un index"], "Une colonne",
                "L'entité devient une table, ses attributs des colonnes."),
            tf("Il vaut mieux concevoir le schéma avant d'écrire les CREATE TABLE.", true,
                "Corriger un schéma sur papier coûte bien moins cher que de migrer une base en production."),
          ],
          xp: 20,
        ),
        l(
          id: 'dsg_keys',
          track: 'design',
          level: 0,
          title: 'Clés primaires et étrangères',
          objective: "Identifier chaque ligne et relier les tables en garantissant l'intégrité.",
          content: [
            "La CLÉ PRIMAIRE (PRIMARY KEY) identifie chaque ligne de façon unique : jamais répétée, jamais NULL. Elle peut porter sur une colonne, ou sur plusieurs (clé composite).",
            "Clé naturelle ou clé de substitution ? Une clé naturelle a un sens métier (numéro ISBN, email), mais elle peut changer ou contenir des erreurs. Une clé de substitution (surrogate) est un identifiant technique sans signification, comme un id auto-incrémenté : c'est le choix le plus courant.",
            "La CLÉ ÉTRANGÈRE (FOREIGN KEY ou REFERENCES) est une colonne qui contient la clé primaire d'une autre table : employes.departement_id pointe vers departements.id. C'est elle qui crée la relation.",
            "L'intégrité référentielle interdit de référencer une ligne qui n'existe pas : impossible d'affecter un employé au département 99 s'il n'existe pas. La base refuse l'opération.",
            "Que faire quand on supprime la ligne référencée ? ON DELETE RESTRICT (par défaut) refuse la suppression, ON DELETE CASCADE supprime aussi les lignes qui la référencent, ON DELETE SET NULL vide la clé étrangère.",
            "Dans SQLite, la vérification n'est active qu'avec PRAGMA foreign_keys = ON. La Console l'active pour toi, tu peux donc tester tout cela.",
          ],
          codeBlocks: [
            code('sql', "-- base : boutique\nCREATE TABLE marques (\n  id INTEGER PRIMARY KEY,\n  nom TEXT NOT NULL UNIQUE\n);\nCREATE TABLE modeles (\n  id INTEGER PRIMARY KEY,\n  nom TEXT NOT NULL,\n  marque_id INTEGER NOT NULL REFERENCES marques(id) ON DELETE CASCADE\n);",
                e: "Une clé primaire dans chaque table, une clé étrangère avec suppression en cascade."),
            code('sql', "-- base : boutique\nINSERT INTO marques (nom) VALUES ('Logitech');\nINSERT INTO modeles (nom, marque_id) VALUES ('MX Master', 1);\nSELECT m.nom, ma.nom AS marque FROM modeles m JOIN marques ma ON ma.id = m.marque_id;",
                e: "Essaie ensuite INSERT INTO modeles (nom, marque_id) VALUES ('X', 99); : la base refuse, la marque 99 n'existe pas."),
            code('sql', "-- base : boutique\nDELETE FROM marques WHERE id = 1;\nSELECT COUNT(*) AS modeles_restants FROM modeles;",
                e: "ON DELETE CASCADE : supprimer la marque a supprimé ses modèles (0 restant)."),
          ],
          mistakes: [
            "Utiliser une colonne qui peut changer (un nom, un email) comme clé primaire.",
            "Oublier la contrainte FOREIGN KEY : rien n'empêche alors des références vers des lignes inexistantes.",
            "Mettre ON DELETE CASCADE partout : une suppression peut effacer en chaîne des données importantes.",
          ],
          exercises: [
            ex("À quoi sert une clé étrangère ?",
                "À référencer la clé primaire d'une autre table pour créer une relation.",
                "Elle garantit l'intégrité référentielle."),
            ex("Affiche chaque employé avec le nom de son département, grâce à la clé étrangère departement_id. (base employes)",
                "SELECT e.nom, d.nom AS departement FROM employes e JOIN departements d ON d.id = e.departement_id;",
                "La jointure suit la clé étrangère vers la clé primaire."),
          ],
          quiz: [
            q(QuizType.qcm, 'Une clé primaire doit être :',
                ['Unique et non NULL', 'Toujours un texte', 'Exactement 5 caractères', 'Cachée'], 'Unique et non NULL',
                'La clé primaire identifie chaque ligne de façon unique.'),
            q(QuizType.qcm, "Que fait ON DELETE CASCADE ?",
                ["Supprime aussi les lignes qui référencent la ligne supprimée", "Empêche toute suppression", "Met la clé étrangère à 0", "Supprime la table"],
                "Supprime aussi les lignes qui référencent la ligne supprimée",
                "C'est pratique, mais à utiliser avec prudence."),
            q(QuizType.qcm, "Une clé de substitution (surrogate) est :",
                ["Un identifiant technique sans signification métier", "Le numéro de sécurité sociale", "Une clé étrangère", "Une colonne toujours NULL"],
                "Un identifiant technique sans signification métier",
                "Par exemple un id auto-incrémenté."),
          ],
          xp: 25,
        ),
        l(
          id: 'dsg_relations',
          track: 'design',
          level: 1,
          title: 'Relations et cardinalités',
          objective: "Traduire les relations 1-1, 1-N et N-N en tables.",
          content: [
            "La cardinalité indique combien d'occurrences d'une entité peuvent être liées à une occurrence de l'autre : 1-1 (un à un), 1-N (un à plusieurs), N-N (plusieurs à plusieurs).",
            "Relation 1-N, la plus fréquente : un département a plusieurs employés, un employé a un seul département. La clé étrangère se place du côté « plusieurs » : departement_id dans la table employes.",
            "Relation 1-1 : un employé a au plus un badge, et un badge appartient à un seul employé. On met une clé étrangère UNIQUE, ou on utilise la même clé primaire dans les deux tables. Elle sert souvent à séparer des données rarement lues ou sensibles.",
            "Relation N-N : un étudiant suit plusieurs cours et un cours a plusieurs étudiants. Aucune des deux tables ne peut porter la clé : il faut une TABLE DE LIAISON contenant les deux clés étrangères, qui forment ensemble sa clé primaire.",
            "La table de liaison peut porter ses propres attributs. Dans la base École, la table notes relie etudiants et cours, et contient la note obtenue.",
            "Pour trouver les cardinalités, pose la question dans les deux sens : « un X peut avoir combien de Y ? » puis « un Y peut avoir combien de X ? ».",
          ],
          codeBlocks: [
            code('sql', "-- base : ecole\nCREATE TABLE inscription (\n  etudiant_id INTEGER,\n  cours_id INTEGER,\n  PRIMARY KEY (etudiant_id, cours_id),\n  FOREIGN KEY (etudiant_id) REFERENCES etudiants(id),\n  FOREIGN KEY (cours_id) REFERENCES cours(id)\n);",
                e: "Table de liaison pour une relation N-N : sa clé primaire est le couple des deux clés étrangères."),
            code('sql', "-- base : ecole\nSELECT e.nom, c.titre, n.note\nFROM notes n\nJOIN etudiants e ON e.id = n.etudiant_id\nJOIN cours c ON c.id = n.cours_id\nORDER BY e.nom;",
                e: "notes est une table de liaison N-N qui porte un attribut : la note."),
            code('sql', "-- base : employes\nCREATE TABLE badges (\n  employe_id INTEGER PRIMARY KEY REFERENCES employes(id),\n  code TEXT NOT NULL UNIQUE\n);\nINSERT INTO badges VALUES (1, 'B-0001');\nSELECT e.nom, b.code FROM employes e JOIN badges b ON b.employe_id = e.id;",
                e: "Relation 1-1 : la clé primaire du badge est aussi la clé étrangère vers l'employé."),
          ],
          mistakes: [
            "Représenter une relation N-N par une simple colonne contenant une liste.",
            "Oublier la table de liaison.",
            "Placer la clé étrangère du côté « un » dans une relation 1-N.",
          ],
          exercises: [
            ex("Comment implémente-t-on une relation plusieurs-à-plusieurs ?",
                "Avec une table de liaison contenant les deux clés étrangères.",
                "La table associative relie les deux tables."),
            ex("Affiche le nombre de cours suivis par chaque étudiant, grâce à la table de liaison notes. (base ecole)",
                "SELECT e.nom, COUNT(n.cours_id) AS nb_cours FROM etudiants e JOIN notes n ON n.etudiant_id = e.id GROUP BY e.id, e.nom;",
                "On passe par la table de liaison pour compter."),
          ],
          quiz: [
            q(QuizType.qcm, 'Une relation N-N nécessite :',
                ['Une table de liaison', 'Deux clés primaires identiques', 'Un index plein texte', 'Une vue'],
                'Une table de liaison', 'La table associative gère le N-N.'),
            q(QuizType.qcm, "Dans une relation 1-N, la clé étrangère se place :",
                ["Du côté « plusieurs »", "Du côté « un »", "Dans les deux tables", "Dans une vue"],
                "Du côté « plusieurs »",
                "Chaque employé porte l'id de son unique département."),
            tf("Une table de liaison peut contenir ses propres attributs (date, note…).", true,
                "Par exemple la note dans la table notes, ou la quantité dans une ligne de commande."),
          ],
          xp: 30,
        ),
        l(
          id: 'dsg_normalization',
          track: 'design',
          level: 2,
          title: 'Normalisation : 1NF, 2NF, 3NF',
          objective: "Éviter les redondances et les anomalies grâce aux formes normales.",
          content: [
            "La normalisation organise les tables pour que chaque information ne soit stockée qu'à un seul endroit. Elle évite trois anomalies : de mise à jour (modifier une donnée à plusieurs endroits et en oublier un), d'insertion (impossible d'ajouter une donnée sans en inventer une autre) et de suppression (perdre une information en supprimant une ligne).",
            "1NF (première forme normale) : chaque cellule contient une seule valeur atomique. Pas de liste « Clavier, Souris » dans une colonne, pas de colonnes répétées produit1, produit2, produit3.",
            "2NF : la table est en 1NF et chaque colonne dépend de TOUTE la clé primaire, pas d'une partie seulement. Cela ne concerne que les clés composites : dans LigneCommande(commande_id, produit_id, quantite, nom_produit), nom_produit ne dépend que de produit_id, il faut le déplacer dans Produit.",
            "3NF : la table est en 2NF et aucune colonne ne dépend d'une autre colonne non-clé (pas de dépendance transitive). Dans Commande(id, client_id, ville_client), ville_client dépend de client_id, pas de la commande : elle va dans Client.",
            "Moyen mnémotechnique : chaque colonne dépend de la clé, de toute la clé, et de rien d'autre que la clé.",
            "La dénormalisation volontaire existe : on duplique une donnée pour accélérer la lecture (un total de commande stocké, un compteur). C'est un choix conscient, qu'il faut maintenir à jour, par exemple avec un trigger.",
          ],
          codeBlocks: [
            code('texte', "NON NORMALISÉ (redondance)\nCommande(id_c, client, ville_client, produits, prix)\n\n3NF\nClient(id, nom, ville)\nProduit(id, nom, prix)\nCommande(id, client_id, date)\nLigneCommande(commande_id, produit_id, quantite)",
                e: "Décomposition pour éliminer la redondance."),
            code('sql', "-- base : boutique\nCREATE TABLE commandes_brutes (id INTEGER, client TEXT, ville_client TEXT, produits TEXT);\nINSERT INTO commandes_brutes VALUES\n  (1, 'Alice', 'Paris', 'Clavier, Souris'),\n  (2, 'Alice', 'Paris', 'Écran');\nSELECT * FROM commandes_brutes;",
                e: "Viole la 1NF (liste de produits) et répète la ville d'Alice : si elle déménage, il faut modifier chaque ligne."),
            code('sql', "-- base : boutique\nSELECT p.name, c.nom AS categorie\nFROM products p\nJOIN categories c ON c.id = p.category_id;",
                e: "Une base normalisée : le nom de chaque catégorie n'est stocké qu'une fois, dans categories."),
          ],
          mistakes: [
            "Trop normaliser au détriment des performances : des dizaines de jointures pour un simple affichage.",
            "Garder des listes séparées par des virgules dans une colonne (violation de la 1NF).",
            "Stocker une donnée calculable (le total d'une commande) sans la maintenir à jour.",
          ],
          exercises: [
            ex("Que garantit la 3NF ?",
                "Aucune dépendance transitive : chaque colonne dépend directement de la clé primaire.",
                "Elle élimine les dépendances indirectes."),
            ex("La table Commande(id, client_id, client_nom, client_ville) est-elle en 3NF ? Pourquoi ?",
                "Non : client_nom et client_ville dépendent de client_id, pas de la clé id. Il faut les déplacer dans une table clients.",
                "C'est une dépendance transitive : id → client_id → client_ville."),
            ex("La table products ne stocke que category_id, pas le nom de la catégorie. Affiche le nom de chaque produit avec le nom de sa catégorie. (base boutique)",
                "SELECT p.name, c.nom AS categorie FROM products p JOIN categories c ON c.id = p.category_id;",
                "En base normalisée, on retrouve l'information par une jointure au lieu de la dupliquer."),
          ],
          quiz: [
            q(QuizType.qcm, 'La 1NF impose que chaque cellule soit :',
                ['Atomique (une valeur)', 'Une liste', 'Un tableau', 'Chiffrée'], 'Atomique (une valeur)',
                'Chaque cellule contient une valeur unique et simple.'),
            q(QuizType.qcm, "Une dépendance transitive viole :",
                ["La 3NF", "La 1NF", "Aucune forme normale", "La clé primaire"], "La 3NF",
                "Une colonne non-clé ne doit pas dépendre d'une autre colonne non-clé."),
            q(QuizType.qcm, "Quelle anomalie apparaît quand on doit modifier la même information à plusieurs endroits ?",
                ["L'anomalie de mise à jour", "L'anomalie de jointure", "L'anomalie d'index", "L'anomalie de type"],
                "L'anomalie de mise à jour",
                "Si on oublie un endroit, la base devient incohérente."),
          ],
          xp: 35,
        ),
        l(
          id: 'dsg_backup',
          track: 'design',
          level: 4,
          title: 'Sauvegarde et restauration',
          objective: "Mettre en place une stratégie de sauvegarde fiable et testée.",
          content: [
            "Une base sans sauvegarde est une catastrophe en attente : erreur humaine (un DELETE sans WHERE), panne de disque, rançongiciel, bug applicatif. La question n'est pas « si », mais « quand ».",
            "Types de sauvegarde : complète (toute la base), incrémentale (seulement ce qui a changé depuis la dernière sauvegarde, quelle qu'elle soit), différentielle (ce qui a changé depuis la dernière complète). Exemple de stratégie : une complète chaque nuit, des incrémentales toutes les heures.",
            "Sauvegarde logique ou physique : un export SQL (pg_dump, mysqldump) est portable et lisible, mais lent à restaurer sur de gros volumes. Une copie physique des fichiers du serveur est rapide, mais liée à la version du SGBD.",
            "La restauration à un instant précis (Point-In-Time Recovery) combine une sauvegarde complète et le journal des transactions (WAL pour PostgreSQL, binlog pour MySQL) : on peut revenir à 14 h 31, juste avant l'erreur.",
            "Règle 3-2-1 : 3 copies des données, sur 2 supports différents, dont 1 hors site (un autre bâtiment ou un autre cloud). Chiffre les sauvegardes : volées, elles exposeraient toutes les données.",
            "Une sauvegarde jamais testée n'existe pas. Restaure régulièrement sur un serveur de test, et mesure le temps nécessaire (RTO) et la quantité de données qu'on accepte de perdre (RPO).",
          ],
          codeBlocks: [
            code('bash', "# PostgreSQL\npg_dump mabase > sauvegarde.sql\npsql mabase < sauvegarde.sql\n\n# MySQL\nmysqldump mabase > sauvegarde.sql\nmysql mabase < sauvegarde.sql",
                e: "Exporter puis réimporter en SQL brut."),
            code('bash', "# SQLite : copie cohérente même pendant l'utilisation\nsqlite3 app.db \".backup 'app-2026-11-19.db'\"\n\n# PostgreSQL : format compressé, restauration sélective\npg_dump -Fc mabase > mabase.dump\npg_restore -d mabase_test mabase.dump",
                e: "Sauvegarde SQLite à chaud, et format personnalisé de PostgreSQL."),
            code('bash', "# crontab : sauvegarde chaque nuit à 2 h, conservée 14 jours\n0 2 * * * pg_dump -Fc mabase > /sauvegardes/mabase-\$(date +\\%F).dump\n30 2 * * * find /sauvegardes -name '*.dump' -mtime +14 -delete",
                e: "Automatiser et faire le ménage : une sauvegarde manuelle finit toujours par être oubliée."),
            code('sql', "-- base : boutique\nSELECT 'INSERT INTO categories VALUES (' || id || ', ''' || nom || ''');' AS sauvegarde\nFROM categories;",
                e: "Ce que contient une sauvegarde logique : des instructions SQL qui recréent les données."),
            code('sql', "-- base : boutique\nPRAGMA integrity_check;",
                e: "Avant de sauvegarder une base SQLite, vérifie qu'elle n'est pas corrompue : la réponse doit être ok."),
          ],
          mistakes: [
            "N'avoir qu'une seule copie, au même endroit que la base.",
            "Ne jamais tester la restauration.",
            "Sauvegarder sans chiffrer : une sauvegarde volée expose toutes les données.",
          ],
          exercises: [
            ex("Pourquoi tester la restauration ?",
                "Une sauvegarde non testée peut être incomplète ou corrompue, et donc inutile le jour où on en a besoin.",
                "Le test garantit qu'on peut réellement récupérer les données."),
            ex("Que signifie la règle 3-2-1 ?",
                "3 copies des données, sur 2 supports différents, dont 1 hors site.",
                "Elle protège contre la panne d'un support comme contre un sinistre sur le site."),
            ex("Génère les instructions INSERT qui permettraient de recréer la table genres. (base films)",
                "SELECT 'INSERT INTO genres VALUES (' || id || ', ''' || nom || ''');' FROM genres;",
                "C'est le principe d'un export logique comme pg_dump ou mysqldump."),
          ],
          quiz: [
            q(QuizType.trueFalse, 'Une sauvegarde jamais testée est fiable.',
                ['Vrai', 'Faux'], 'Faux',
                "Il faut vérifier qu'on peut réellement restaurer."),
            q(QuizType.qcm, "La règle 3-2-1 recommande :",
                ["3 copies, 2 supports, 1 hors site", "3 serveurs, 2 bases, 1 utilisateur", "3 sauvegardes par jour pendant 2 semaines", "3 index, 2 vues, 1 table"],
                "3 copies, 2 supports, 1 hors site",
                "C'est la règle de base de toute stratégie de sauvegarde."),
            q(QuizType.qcm, "Une sauvegarde incrémentale contient :",
                ["Les changements depuis la dernière sauvegarde", "Toute la base", "Uniquement le schéma", "Les changements depuis la création de la base"],
                "Les changements depuis la dernière sauvegarde",
                "La différentielle, elle, repart toujours de la dernière complète."),
          ],
          xp: 45,
        ),
      ];

  // =====================================================================
  // SQL + PROGRAMMATION
  // =====================================================================
  static List<Lesson> programming() => [
        l(
          id: 'prog_connect',
          track: 'programming',
          level: 2,
          title: 'Connecter une base depuis un langage',
          objective: "Comprendre comment un programme se connecte à une base et l'interroge proprement.",
          content: [
            "Un programme communique avec le SGBD grâce à un DRIVER, une bibliothèque propre au langage et au SGBD. Le principe est toujours le même : ouvrir une connexion, envoyer des requêtes, lire les résultats, libérer la connexion.",
            "Chaque langage a ses bibliothèques : Dart/Flutter (sqflite, drift, postgres), Python (sqlite3, psycopg, pymysql), Node.js (pg, mysql2), Java (JDBC), C# (ADO.NET, Dapper), PHP (PDO).",
            "La connexion se décrit par une chaîne de connexion ou des paramètres : hôte, port, base, utilisateur, mot de passe. Ces secrets ne s'écrivent jamais dans le code : on les lit dans des variables d'environnement ou un gestionnaire de secrets.",
            "On utilise toujours des requêtes préparées : la requête contient des marqueurs (?, %s, \$1 selon le driver) et les valeurs sont passées à part. C'est la protection contre les injections SQL, et le SGBD peut réutiliser le plan d'exécution.",
            "Ouvrir une connexion coûte cher. Un serveur utilise donc un POOL de connexions : quelques connexions restent ouvertes et sont prêtées à chaque requête, puis rendues au pool.",
            "Plusieurs écritures liées se font dans une transaction côté code : commit si tout réussit, rollback en cas d'exception. Et on libère toujours la connexion, même en cas d'erreur (with en Python, try/finally ailleurs).",
          ],
          codeBlocks: [
            code('python', "import os, psycopg\n\nwith psycopg.connect(os.environ[\"DATABASE_URL\"]) as conn:\n    rows = conn.execute(\n        \"SELECT name, price FROM products WHERE price < %s\", (50,)\n    ).fetchall()\n# la connexion est fermée automatiquement à la fin du with",
                e: "PostgreSQL depuis Python : secret lu dans l'environnement, requête préparée, fermeture automatique."),
            code('php', r'''$pdo = new PDO("mysql:host=localhost;dbname=mabase", "u", "p");
$req = $pdo->prepare("SELECT * FROM products WHERE price < ?");
$req->execute([50]);
$rows = $req->fetchAll();''',
                e: "MySQL avec PDO depuis PHP."),
            code('dart', "final db = await openDatabase('app.db');\nfinal rows = await db.rawQuery(\n  'SELECT name, price FROM products WHERE price < ?',\n  [50],\n);\nawait db.transaction((txn) async {\n  await txn.rawUpdate('UPDATE products SET stock = stock - 1 WHERE id = ?', [3]);\n  await txn.rawInsert('INSERT INTO ventes (product_id) VALUES (?)', [3]);\n});",
                e: "SQLite depuis Flutter avec sqflite : requête préparée et transaction (c'est ce qu'utilise cette application)."),
          ],
          mistakes: [
            "Ne pas fermer la connexion (fuite de ressources).",
            "Concaténer du SQL au lieu d'utiliser des requêtes préparées.",
            "Écrire le mot de passe de la base en dur dans le code source.",
          ],
          exercises: [
            ex("Quel est le grand avantage des requêtes préparées ?",
                "La protection contre les injections SQL, et la réutilisation du plan d'exécution.",
                "Les paramètres sont liés, jamais interprétés comme du code."),
            ex("Où ranger le mot de passe de connexion à la base ?",
                "Dans une variable d'environnement ou un gestionnaire de secrets, jamais dans le code.",
                "Le code finit souvent dans un dépôt partagé."),
          ],
          quiz: [
            q(QuizType.qcm, 'Une requête préparée protège principalement contre :',
                ['Les injections SQL', 'Les pannes', 'La lenteur', 'La perte de données'], 'Les injections SQL',
                'Les paramètres liés neutralisent les injections.'),
            q(QuizType.qcm, "Un pool de connexions sert à :",
                ["Réutiliser des connexions déjà ouvertes", "Chiffrer les données", "Créer des index", "Sauvegarder la base"],
                "Réutiliser des connexions déjà ouvertes",
                "Ouvrir une connexion à chaque requête serait trop lent."),
            tf("Il faut toujours fermer (ou rendre au pool) une connexion après usage.", true,
                "Sinon les connexions s'accumulent jusqu'à saturer le serveur."),
          ],
          xp: 35,
        ),
        l(
          id: 'prog_orm',
          track: 'programming',
          level: 3,
          title: 'ORM et requêtes préparées',
          objective: "Utiliser un ORM efficacement et éviter ses pièges.",
          content: [
            "Un ORM (Object-Relational Mapping) fait le lien entre les tables et les objets du langage : on manipule des objets Produit, l'ORM génère le SQL, l'exécute et convertit les résultats.",
            "Exemples : Prisma et Drizzle (Node.js), SQLAlchemy et Django ORM (Python), Hibernate (Java), Entity Framework Core (C#), Drift (Dart/Flutter), Eloquent (PHP).",
            "Avantages : moins de code répétitif, requêtes préparées par défaut, typage, portabilité entre SGBD, et migrations pour faire évoluer le schéma de façon versionnée, comme le code.",
            "Piège n°1, le problème N+1 : on charge une liste de 100 commandes (1 requête), puis le client de chacune (100 requêtes). La solution : demander le chargement groupé (include, join, prefetch), qui fait tout en une ou deux requêtes.",
            "Autres pièges : récupérer toutes les colonnes alors qu'on en affiche deux, charger des milliers d'objets en mémoire sans pagination, ou ne jamais regarder le SQL généré. Active les logs SQL de l'ORM pendant le développement.",
            "Un ORM ne remplace pas la connaissance du SQL. Pour un rapport complexe (fonctions de fenêtrage, CTE), écrire le SQL à la main, toujours avec des paramètres, est souvent plus clair et plus rapide.",
          ],
          codeBlocks: [
            code('js', "// Node.js + Prisma (ORM)\nconst produits = await prisma.product.findMany({\n  where: { price: { lt: 50 } },\n  orderBy: { price: \"desc\" },\n  select: { name: true, price: true },\n});",
                e: "Un ORM évite d'écrire le SQL à la main ; select ne récupère que deux colonnes."),
            code('js', "// ❌ N+1 : 1 requête + 1 requête par commande\nconst commandes = await prisma.commande.findMany();\nfor (const c of commandes) {\n  c.client = await prisma.client.findUnique({ where: { id: c.clientId } });\n}\n\n// ✅ Chargement groupé\nconst commandes2 = await prisma.commande.findMany({ include: { client: true } });",
                e: "Le même résultat en 2 requêtes au lieu de 101."),
            code('python', "# SQLAlchemy : SQL écrit à la main, mais paramétré\nfrom sqlalchemy import text\n\nrows = session.execute(\n    text(\"SELECT nom, RANK() OVER (ORDER BY salaire DESC) AS rang \"\n         \"FROM employes WHERE departement_id = :dep\"),\n    {\"dep\": 2},\n).all()",
                e: "Pour une requête avancée, du SQL brut avec un paramètre nommé."),
          ],
          mistakes: [
            "Faire confiance à l'ORM pour toutes les requêtes complexes, sans regarder le SQL généré.",
            "Négliger les requêtes préparées quand on écrit du SQL brut.",
            "Le problème N+1 : charger une liste, puis faire une requête par élément.",
          ],
          exercises: [
            ex("Que fait un ORM ?",
                "Il fait correspondre les tables et les objets du langage, et génère le SQL.",
                "On manipule des objets, l'ORM génère le SQL."),
            ex("Qu'est-ce que le problème N+1, et comment l'éviter ?",
                "Une requête pour la liste, puis une requête par élément pour ses données liées. On l'évite avec un chargement groupé (include, join, prefetch).",
                "On passe de N+1 requêtes à une ou deux."),
          ],
          quiz: [
            q(QuizType.qcm, 'Un ORM transforme les tables en :',
                ['Objets du langage', 'Fichiers CSV', 'API REST', 'Procédures'], 'Objets du langage',
                "L'ORM lie les tables aux objets."),
            q(QuizType.qcm, "Le problème N+1 se résout le plus souvent par :",
                ["Un chargement groupé (include, join)", "Plus de serveurs", "La suppression des index", "La désactivation de l'ORM"],
                "Un chargement groupé (include, join)",
                "On récupère les données liées en une seule fois."),
            q(QuizType.qcm, "Une migration sert à :",
                ["Faire évoluer le schéma de façon versionnée", "Copier la base vers un autre serveur", "Chiffrer les colonnes", "Vider les tables"],
                "Faire évoluer le schéma de façon versionnée",
                "Chaque modification du schéma devient un fichier rejouable, versionné avec le code."),
          ],
          xp: 40,
        ),
        l(
          id: 'prog_api',
          track: 'programming',
          level: 4,
          title: 'API REST et backend',
          objective: "Exposer une base de données de façon sûre à travers une API REST.",
          content: [
            "Une application mobile ou web ne se connecte jamais directement à la base de production : elle passe par un BACKEND, un serveur qui reçoit des requêtes HTTP, vérifie les droits, interroge la base et renvoie du JSON.",
            "Une API REST organise les données en ressources (/products, /products/12) et utilise les méthodes HTTP : GET pour lire, POST pour créer, PUT ou PATCH pour modifier, DELETE pour supprimer.",
            "Les codes de statut HTTP indiquent le résultat : 200 OK, 201 Created (ressource créée), 400 Bad Request (données invalides), 401 et 403 (non authentifié, non autorisé), 404 Not Found, 500 (erreur serveur).",
            "Sécurité : authentifier chaque requête (session ou jeton JWT), vérifier les droits (cet utilisateur peut-il modifier CETTE commande ?), valider toutes les entrées, utiliser des requêtes préparées, et ne jamais renvoyer les messages d'erreur SQL au client.",
            "Bonnes pratiques : paginer les listes (?page=2&limit=20), ne renvoyer que les champs utiles (jamais le hash du mot de passe), versionner l'API (/v1/…), journaliser les erreurs côté serveur.",
            "L'architecture classique : application Flutter → API (Node.js, Python, Dart…) → base de données. Chaque couche a son rôle : l'interface, les règles métier et la sécurité, le stockage.",
          ],
          codeBlocks: [
            code('js', r'''// Express (Node.js) : lire avec pagination
app.get("/products", async (req, res) => {
  const limit = Math.min(Number(req.query.limit) || 20, 100);
  const offset = (Math.max(Number(req.query.page) || 1, 1) - 1) * limit;
  const result = await db.query(
    "SELECT id, name, price FROM products ORDER BY id LIMIT $1 OFFSET $2",
    [limit, offset]
  );
  res.json(result.rows);
});''',
                e: "Un endpoint REST paginé : les valeurs sont bornées et passées en paramètres."),
            code('js', r'''// Créer une ressource : validation, 201 ou 400
app.post("/products", async (req, res) => {
  const { name, price } = req.body;
  if (typeof name !== "string" || !(price > 0)) {
    return res.status(400).json({ error: "Nom ou prix invalide" });
  }
  const r = await db.query(
    "INSERT INTO products (name, price) VALUES ($1, $2) RETURNING id",
    [name, price]
  );
  res.status(201).json({ id: r.rows[0].id });
});''',
                e: "On valide avant d'écrire, et on renvoie le bon code HTTP."),
            code('dart', "// Côté Flutter : appeler l'API\nfinal resp = await http.get(Uri.parse('https://api.exemple.fr/v1/products?page=1'));\nif (resp.statusCode == 200) {\n  final produits = jsonDecode(resp.body) as List;\n}",
                e: "L'application ne connaît que l'API, jamais la base elle-même."),
          ],
          mistakes: [
            "Renvoyer la structure interne de la base telle quelle (colonnes sensibles comprises).",
            "Créer une API sans authentification ni validation.",
            "Renvoyer 200 pour toutes les réponses, même les erreurs : utilise 201, 400, 404, 500…",
          ],
          exercises: [
            ex("Quelle méthode HTTP sert à créer une ressource ?",
                "POST.",
                "POST crée, GET lit, PATCH modifie, DELETE supprime."),
            ex("Quel code HTTP renvoyer quand la ressource demandée n'existe pas ?",
                "404 Not Found.",
                "Les codes 4xx signalent une erreur du côté de la requête."),
          ],
          quiz: [
            q(QuizType.qcm, 'GET /products correspond à une opération :',
                ['Lecture', 'Suppression', 'Création', 'Fermeture'], 'Lecture',
                'GET lit des ressources.'),
            q(QuizType.qcm, "Quel code HTTP indique qu'une ressource a été créée ?",
                ["201", "200", "404", "500"], "201",
                "201 Created, souvent accompagné de l'identifiant de la ressource."),
            tf("Une application mobile devrait se connecter directement à la base de production.", false,
                "Elle passe par une API qui contrôle l'accès ; les identifiants de la base ne doivent jamais être dans l'application."),
          ],
          xp: 45,
        ),
      ];
}
