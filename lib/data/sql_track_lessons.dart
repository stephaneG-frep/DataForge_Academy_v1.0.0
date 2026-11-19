import '../models/lesson_models.dart';
import 'sql_core_lessons.dart';

/// Core "SQL" track lessons — the deepest pedagogical content.
/// Levels: Débutant(0) → Database Engineer(5).
class SqlTrackLessons {
  SqlTrackLessons._();

  static CodeBlock code(String lang, String c, {String? e}) => CodeBlock(lang, c, explanation: e);

  /// Display order inside each level (lessons are grouped by level in the UI).
  static const _order = [
    'sql_intro', 'sql_select', 'sql_write', // 0
    'sql_where', 'sql_filters', 'sql_null', 'sql_order_group', 'sql_ddl', // 1
    'sql_join', 'sql_join_types', 'sql_group_having', 'sql_union_case', 'sql_functions', // 2
    'sql_subqueries', 'sql_cte', 'sql_views', 'sql_transactions', // 3
    'sql_indexes', 'sql_window', 'sql_security', // 4
    'sql_scalability', // 5
  ];

  static List<Lesson> all() {
    final lessons = [..._base(), ...SqlCoreLessons.all()];
    int rank(Lesson l) {
      final i = _order.indexOf(l.id);
      return i < 0 ? _order.length : i;
    }
    // Stable: lessons missing from _order keep their relative order at the end.
    final indexed = lessons.asMap().entries.toList()
      ..sort((a, b) {
        final r = rank(a.value).compareTo(rank(b.value));
        return r != 0 ? r : a.key.compareTo(b.key);
      });
    return [for (final e in indexed) e.value];
  }

  // Helpers (same conventions as SqlCoreLessons: runnable examples start with
  // `-- base : <id>`, runnable exercises end with `(base <id>)`).
  static ExerciseItem ex(String q, String a, String e) => ExerciseItem(q, a, e);
  static QuizItem q(QuizType t, String question, List<String> options,
          String correct, String explanation) =>
      QuizItem(
          type: t,
          question: question,
          options: options,
          correctAnswer: correct,
          explanation: explanation);
  static QuizItem tf(String question, bool correct, String explanation) =>
      q(QuizType.trueFalse, question, const ['Vrai', 'Faux'],
          correct ? 'Vrai' : 'Faux', explanation);

  // NOTE: quiz progress is stored per question index (`<lessonId>#q<i>`).
  // Never reorder or remove existing quiz items: only append new ones.
  static List<Lesson> _base() => [
        // ================= LEVEL 0 : DÉBUTANT =================
        Lesson(
          id: 'sql_intro',
          trackId: 'sql',
          levelIndex: 0,
          title: "Qu'est-ce qu'une base de données ?",
          objective:
              "Comprendre le rôle d'une base de données et le vocabulaire de base (table, colonne, ligne, clé).",
          content: [
            "Une base de données (BDD) est un ensemble organisé de données stockées de manière structurée et persistante. Pense à elle comme à un très grand classeur où chaque fiche est rangée proprement et retrouvable en une fraction de seconde.",
            "Dans une base de données relationnelle, les données sont rangées dans des TABLES. Une table ressemble à un tableau de tableur : des lignes (les enregistrements) et des colonnes (les attributs). Chaque colonne a un type : nombre entier, décimal, texte, date…",
            "Exemple : la table employes de la Console a les colonnes id, nom, prenom, departement_id, salaire… Chaque ligne est un employé, chaque colonne une information le concernant.",
            "Chaque ligne possède une clé primaire (souvent la colonne id) : une valeur unique qui l'identifie sans ambiguïté. Une clé étrangère est une colonne qui pointe vers la clé primaire d'une autre table : departement_id relie chaque employé à une ligne de la table departements. C'est ce lien qui fait le « relationnel ».",
            "Le logiciel qui gère la base s'appelle un SGBD (Système de Gestion de Base de Données) : SQLite, PostgreSQL, MySQL, SQL Server, Oracle… La Console de l'application utilise SQLite.",
            "SQL (Structured Query Language) est le langage universel pour créer, lire, modifier et supprimer des données dans une base relationnelle. Chaque SGBD a quelques particularités, mais les bases du SQL sont les mêmes partout.",
          ],
          codeBlocks: [
            code('texte',
                "Table employes\n"
                "id | nom     | prenom | departement_id | salaire\n"
                "---|---------|--------|----------------|--------\n"
                "1  | Martin  | Sophie | 2              | 42000\n"
                "2  | Bernard | Paul   | 1              | 35000",
                e: "Chaque colonne est un attribut, chaque ligne un enregistrement. departement_id est une clé étrangère."),
            code('sql', "-- base : employes\nSELECT * FROM employes;",
                e: "Ta première requête : affiche toute la table employes. Choisis la base Employés dans la Console."),
            code('sql', "-- base : employes\nSELECT * FROM departements;",
                e: "La table liée : l'employé avec departement_id = 2 travaille dans le département id 2 (Informatique)."),
          ],
          commonMistakes: [
            "Confondre la base de données (le contenu) et le SGBD (le logiciel qui la gère, par exemple PostgreSQL).",
            "Penser que les tables sont indépendantes : elles sont reliées par des clés étrangères.",
            "Répéter la même information dans plusieurs tables au lieu de la relier par une clé.",
          ],
          exercises: [
            ex("Dans une table, qu'appelle-t-on une « ligne » ?",
                "Un enregistrement complet correspondant à un élément réel (un employé, un produit...).",
                "Chaque ligne regroupe toutes les valeurs d'un même enregistrement."),
            ex("Comment s'appelle le langage des bases de données relationnelles ?",
                "SQL (Structured Query Language).",
                "SQL sert à interroger et manipuler les données."),
            ex("Affiche tout le contenu de la table auteurs. (base bibliotheque)",
                "SELECT * FROM auteurs;",
                "L'étoile * affiche toutes les colonnes."),
          ],
          quiz: [
            q(QuizType.qcm, "Une table est :",
                ["Un ensemble de colonnes et de lignes", "Un fichier texte", "Une formule", "Un programme"],
                "Un ensemble de colonnes et de lignes",
                "Une table est une structure en lignes (enregistrements) et colonnes (attributs)."),
            q(QuizType.qcm, "Comment s'appelle le logiciel qui gère une base de données ?",
                ["Un SGBD", "Un tableur", "Un compilateur", "Un navigateur"], "Un SGBD",
                "SQLite, PostgreSQL ou MySQL sont des SGBD."),
            tf("Deux lignes d'une table peuvent avoir la même clé primaire.", false,
                "La clé primaire identifie chaque ligne de façon unique."),
          ],
          xp: 20,
        ),
        Lesson(
          id: 'sql_select',
          trackId: 'sql',
          levelIndex: 0,
          title: 'SELECT : lire des données',
          objective:
              "Écrire ses premières requêtes SELECT pour afficher, renommer et calculer des colonnes.",
          content: [
            "SELECT est l'instruction la plus utilisée. Elle sert à LIRE des données : tu choisis les colonnes à afficher et la table d'où elles viennent. Elle ne modifie jamais rien.",
            "La syntaxe minimale : SELECT colonne FROM table;. Pour plusieurs colonnes, sépare-les par des virgules : SELECT nom, prenom FROM employes;. L'ordre des colonnes dans le résultat suit l'ordre que tu écris.",
            "L'étoile * sélectionne toutes les colonnes : SELECT * FROM table;. Pratique pour découvrir une table, mais dans une vraie application on liste les colonnes utiles : c'est plus clair et plus rapide.",
            "AS donne un alias (un nom) à une colonne du résultat : SELECT nom AS nom_employe. Le nom réel de la colonne dans la table ne change pas.",
            "SELECT peut aussi calculer : SELECT name, price * 1.2 AS prix_ttc FROM products; affiche une colonne calculée pour chaque ligne. On peut utiliser + - * / et des fonctions.",
            "Les mots-clés SQL ne sont pas sensibles à la casse (select = SELECT), mais l'usage est de les écrire en majuscules. Une requête peut tenir sur plusieurs lignes, ce qui la rend plus lisible. Le point-virgule termine l'instruction.",
          ],
          codeBlocks: [
            code('sql', "-- base : employes\nSELECT nom, prenom FROM employes;",
                e: "Affiche les colonnes nom et prenom de toutes les lignes."),
            code('sql', "-- base : boutique\nSELECT * FROM products;",
                e: "Affiche toutes les colonnes de la table products."),
            code('sql', "-- base : employes\nSELECT nom AS nom_employe FROM employes;",
                e: "Renomme la colonne nom en nom_employe dans le résultat."),
            code('sql', "-- base : boutique\nSELECT name, price, price * 1.2 AS prix_ttc\nFROM products;",
                e: "Une colonne calculée : le prix TTC avec 20 % de TVA."),
          ],
          commonMistakes: [
            "Oublier le FROM : SELECT nom; ne sait pas dans quelle table chercher.",
            "Mettre une virgule en trop après la dernière colonne : SELECT nom, prenom, FROM employes;",
            "Utiliser SELECT * partout dans une application : on récupère des colonnes inutiles.",
          ],
          exercises: [
            ex("Affiche uniquement les colonnes name et price de la table products. (base boutique)",
                "SELECT name, price FROM products;",
                "On liste les colonnes séparées par des virgules après SELECT."),
            ex("Affiche le titre et l'année de tous les films. (base films)",
                "SELECT titre, annee FROM films;",
                "Deux colonnes, séparées par une virgule."),
            ex("Affiche le nom de chaque produit et son prix avec 10 % de remise, dans une colonne nommée prix_remise. (base boutique)",
                "SELECT name, price * 0.9 AS prix_remise FROM products;",
                "price * 0.9 applique la remise, AS nomme la colonne."),
          ],
          quiz: [
            q(QuizType.completeQuery, "Complète : afficher toutes les colonnes de la table films",
                ["SELECT * FROM films;", "SELECT all films;", "FROM films SELECT;", "SHOW films;"],
                "SELECT * FROM films;",
                "L'astérisque * sélectionne toutes les colonnes, FROM précise la table."),
            tf("SELECT affiche les lignes d'une table mais ne les modifie jamais.", true,
                "SELECT est une requête de lecture : elle ne change pas les données."),
            q(QuizType.qcm, "Que fait AS dans SELECT nom AS employe ?",
                ["Renomme la colonne dans le résultat", "Renomme la colonne dans la table", "Filtre les lignes", "Trie le résultat"],
                "Renomme la colonne dans le résultat",
                "L'alias n'existe que dans le résultat de la requête."),
          ],
          xp: 25,
        ),

        // ================= LEVEL 1 : FONDAMENTAUX =================
        Lesson(
          id: 'sql_where',
          trackId: 'sql',
          levelIndex: 1,
          title: 'WHERE : filtrer les lignes',
          objective:
              "Filtrer les résultats avec WHERE, les opérateurs de comparaison et AND / OR / NOT.",
          content: [
            "WHERE ne garde que les lignes qui respectent une condition. Il se place après FROM : SELECT colonnes FROM table WHERE condition;.",
            "Opérateurs de comparaison : = (égal), != ou <> (différent), >, <, >=, <=. En SQL, l'égalité s'écrit avec un seul =.",
            "Les textes s'écrivent entre apostrophes : WHERE nom = 'Martin'. Les nombres s'écrivent sans : WHERE salaire > 40000. En SQLite, = est sensible à la casse : 'martin' n'est pas égal à 'Martin'.",
            "AND exige que les deux conditions soient vraies, OR qu'au moins une le soit, NOT inverse une condition.",
            "Attention à la priorité : AND est évalué avant OR. a OR b AND c se lit a OR (b AND c). Mets des parenthèses dès que tu mélanges AND et OR, c'est plus sûr et plus lisible.",
            "D'autres opérateurs rendent les filtres plus pratiques : IN, BETWEEN, LIKE et IS NULL. Ils sont détaillés dans les leçons « Filtres pratiques » et « Le cas NULL ».",
          ],
          codeBlocks: [
            code('sql', "-- base : boutique\nSELECT name, price FROM products\nWHERE price < 50;",
                e: "Affiche les produits à moins de 50 €."),
            code('sql', "-- base : boutique\nSELECT name FROM products\nWHERE category_id = 1 AND price > 20;",
                e: "Les deux conditions doivent être vraies."),
            code('sql', "-- base : boutique\nSELECT name FROM products\nWHERE name LIKE '%souris%';",
                e: "Le % remplace n'importe quelle suite de caractères."),
            code('sql', "-- base : boutique\nSELECT name, price, category_id FROM products\nWHERE (category_id = 1 OR category_id = 2)\n  AND price < 60;",
                e: "Les parenthèses forcent le OR à être évalué avant le AND."),
          ],
          commonMistakes: [
            "Oublier les apostrophes autour des textes : WHERE nom = Martin au lieu de WHERE nom = 'Martin'.",
            "Mélanger AND et OR sans parenthèses : AND est évalué avant OR, le résultat surprend.",
            "Écrire == au lieu de = : en SQL, l'égalité s'écrit avec un seul =.",
          ],
          exercises: [
            ex("Affiche les produits dont le prix est compris entre 30 et 60. (base boutique)",
                "SELECT name, price FROM products WHERE price BETWEEN 30 AND 60;",
                "BETWEEN inclut les bornes. On peut aussi écrire price >= 30 AND price <= 60."),
            ex("Affiche les employés du département 2 qui gagnent plus de 44 000 €. (base employes)",
                "SELECT nom, prenom, salaire FROM employes WHERE departement_id = 2 AND salaire > 44000;",
                "AND : les deux conditions doivent être vraies."),
            ex("Affiche les livres qui ne sont pas disponibles. (base bibliotheque)",
                "SELECT titre FROM livres WHERE disponible = 0;",
                "disponible vaut 1 (oui) ou 0 (non)."),
          ],
          quiz: [
            q(QuizType.qcm, "Quel opérateur signifie « différent de » ?",
                ["!=", "==", "&&", "!"], "!=",
                "!= (ou <>) teste l'inégalité en SQL."),
            q(QuizType.findError, "Trouve l'erreur : SELECT name WHERE price < 50",
                ["Il manque FROM", "price est inconnu", "Il manque ;", "name est mal écrit"],
                "Il manque FROM",
                "WHERE s'utilise avec FROM : SELECT name FROM products WHERE price < 50."),
            q(QuizType.predictResult, "Dans WHERE a = 1 OR a = 2 AND b = 3, quelle partie est évaluée en premier ?",
                ["a = 2 AND b = 3", "a = 1 OR a = 2", "Tout en même temps", "De gauche à droite"],
                "a = 2 AND b = 3",
                "AND est prioritaire sur OR, comme la multiplication sur l'addition."),
          ],
          xp: 30,
        ),
        Lesson(
          id: 'sql_order_group',
          trackId: 'sql',
          levelIndex: 1,
          title: "ORDER BY et fonctions d'agrégation",
          objective:
              "Trier les résultats et calculer des statistiques (COUNT, SUM, AVG, MIN, MAX).",
          content: [
            "ORDER BY trie les résultats : ASC (croissant, par défaut) ou DESC (décroissant). Sans ORDER BY, l'ordre des lignes n'est jamais garanti.",
            "On peut trier sur plusieurs colonnes : ORDER BY departement_id ASC, salaire DESC trie par département, puis du plus haut au plus bas salaire dans chaque département.",
            "Les fonctions d'agrégation calculent UNE valeur à partir de plusieurs lignes : COUNT compte, SUM additionne, AVG fait la moyenne, MIN et MAX trouvent les extrêmes.",
            "Sans GROUP BY, une requête avec agrégat renvoie une seule ligne qui résume toute la table (ou les lignes gardées par WHERE). COUNT(*) compte les lignes, COUNT(colonne) compte les valeurs non NULL.",
            "On ne peut pas mélanger une colonne normale et un agrégat sans GROUP BY : SELECT name, AVG(price) n'a pas de sens, car quel name afficher à côté de la moyenne ? Ce sera l'objet de la leçon GROUP BY.",
            "Ordre des clauses : SELECT … FROM … WHERE … ORDER BY … ; ORDER BY vient toujours à la fin, et on peut y utiliser un alias défini dans le SELECT.",
          ],
          codeBlocks: [
            code('sql', "-- base : boutique\nSELECT name, price FROM products\nORDER BY price DESC;",
                e: "Trie du plus cher au moins cher."),
            code('sql', "-- base : boutique\nSELECT COUNT(*) AS nb FROM products;",
                e: "Compte le nombre total de lignes."),
            code('sql', "-- base : boutique\nSELECT AVG(price) AS prix_moyen FROM products;",
                e: "Calcule le prix moyen de tous les produits."),
            code('sql', "-- base : employes\nSELECT nom, departement_id, salaire FROM employes\nORDER BY departement_id ASC, salaire DESC;",
                e: "Tri sur deux colonnes."),
            code('sql', "-- base : boutique\nSELECT MIN(price) AS moins_cher, MAX(price) AS plus_cher,\n       SUM(stock) AS stock_total\nFROM products;",
                e: "Plusieurs agrégats dans la même requête."),
          ],
          commonMistakes: [
            "Oublier DESC : par défaut, ORDER BY trie du plus petit au plus grand.",
            "Mélanger une colonne normale et un agrégat sans GROUP BY.",
            "Placer ORDER BY avant WHERE : l'ordre est SELECT, FROM, WHERE, ORDER BY.",
          ],
          exercises: [
            ex("Compte le nombre de produits dont le prix est inférieur à 50. (base boutique)",
                "SELECT COUNT(*) FROM products WHERE price < 50;",
                "On filtre d'abord avec WHERE, puis COUNT compte les lignes restantes."),
            ex("Affiche le salaire le plus élevé et le plus bas de l'entreprise. (base employes)",
                "SELECT MAX(salaire) AS max_salaire, MIN(salaire) AS min_salaire FROM employes;",
                "MAX et MIN dans la même requête."),
            ex("Affiche les films du plus récent au plus ancien, puis par titre pour une même année. (base films)",
                "SELECT titre, annee FROM films ORDER BY annee DESC, titre ASC;",
                "Le deuxième critère départage les films de la même année."),
          ],
          quiz: [
            q(QuizType.qcm, "Que retourne AVG(price) ?",
                ["Le prix le plus bas", "La moyenne des prix", "Le nombre de prix", "La somme des prix"],
                "La moyenne des prix",
                "AVG calcule la moyenne arithmétique."),
            q(QuizType.predictResult, "SELECT COUNT(*) FROM products WHERE price < 0;",
                ["0", "1", "Toutes les lignes", "Une erreur"], "0",
                "Aucun produit n'a un prix négatif, donc COUNT renvoie 0."),
            q(QuizType.qcm, "Par défaut, ORDER BY trie :",
                ["Par ordre croissant (ASC)", "Par ordre décroissant (DESC)", "Au hasard", "Par date d'insertion"],
                "Par ordre croissant (ASC)",
                "Il faut écrire DESC pour l'ordre décroissant."),
          ],
          xp: 30,
        ),

        // ================= LEVEL 2 : INTERMÉDIAIRE =================
        Lesson(
          id: 'sql_join',
          trackId: 'sql',
          levelIndex: 2,
          title: 'JOIN : lier les tables',
          objective:
              "Associer des lignes de plusieurs tables avec INNER JOIN.",
          content: [
            "Dans une base bien conçue, on évite de répéter les informations : le nom d'un département n'est écrit qu'une fois, dans la table departements, et chaque employé y fait référence par departement_id. Pour afficher les deux ensemble, il faut une jointure.",
            "INNER JOIN (ou simplement JOIN) associe chaque ligne d'une table aux lignes de l'autre table qui correspondent, et ne garde que les lignes qui ont une correspondance des DEUX côtés.",
            "La syntaxe : SELECT colonnes FROM table1 JOIN table2 ON table1.cle = table2.cle;. ON précise la condition de correspondance, presque toujours « clé étrangère = clé primaire ».",
            "On donne des alias courts aux tables (FROM employes e) et on préfixe les colonnes (e.nom, d.nom). C'est indispensable quand deux tables ont une colonne du même nom.",
            "On peut enchaîner plusieurs jointures : notes → etudiants → cours. Chaque JOIN ajoute une table avec sa propre condition ON. On peut ensuite filtrer avec WHERE et trier avec ORDER BY comme d'habitude.",
            "Il existe d'autres jointures (LEFT, RIGHT, FULL, CROSS, auto-jointure) pour garder aussi les lignes sans correspondance : voir la leçon « Tous les types de jointures ».",
          ],
          codeBlocks: [
            code('sql', "-- base : employes\nSELECT e.nom, d.nom AS departement\nFROM employes e\nJOIN departements d ON e.departement_id = d.id;",
                e: "Affiche chaque employé avec son département."),
            code('sql', "-- base : boutique\nSELECT p.name, c.nom AS categorie\nFROM products p\nLEFT JOIN categories c ON p.category_id = c.id;",
                e: "LEFT JOIN garde tous les produits, même sans catégorie."),
            code('sql', "-- base : ecole\nSELECT e.nom, c.titre, n.note\nFROM notes n\nJOIN etudiants e ON n.etudiant_id = e.id\nJOIN cours c ON n.cours_id = c.id\nORDER BY e.nom;",
                e: "Trois tables : chaque note avec le nom de l'étudiant et le titre du cours."),
            code('sql', "-- base : films\nSELECT f.titre, g.nom AS genre\nFROM films f\nJOIN genres g ON f.genre_id = g.id\nWHERE g.nom = 'Animation';",
                e: "Une jointure suivie d'un filtre."),
          ],
          commonMistakes: [
            "Oublier la condition ON : un JOIN sans ON est un produit cartésien.",
            "Ne pas préfixer les colonnes qui existent dans les deux tables (colonne ambiguë).",
            "Choisir le mauvais type de JOIN (LEFT plutôt qu'INNER).",
          ],
          exercises: [
            ex("Affiche le titre de chaque livre avec le nom de son auteur. (base bibliotheque)",
                "SELECT l.titre, a.nom FROM livres l JOIN auteurs a ON l.auteur_id = a.id;",
                "On joint livres et auteurs sur la clé auteur_id."),
            ex("Affiche les produits de la catégorie « Audio » avec le nom de la catégorie. (base boutique)",
                "SELECT p.name, c.nom FROM products p JOIN categories c ON p.category_id = c.id WHERE c.nom = 'Audio';",
                "La jointure apporte le nom de la catégorie, WHERE filtre dessus."),
            ex("Affiche le nom des étudiants qui ont une note dans le cours « Bases de données ». (base ecole)",
                "SELECT e.nom, n.note FROM notes n JOIN etudiants e ON n.etudiant_id = e.id JOIN cours c ON n.cours_id = c.id WHERE c.titre = 'Bases de données';",
                "Deux jointures, puis un filtre sur le titre du cours."),
          ],
          quiz: [
            q(QuizType.qcm, "Que retourne INNER JOIN ?",
                ["Seulement les lignes qui correspondent dans les deux tables", "Toutes les lignes de la table de gauche", "Toutes les lignes des deux tables", "Aucune ligne"],
                "Seulement les lignes qui correspondent dans les deux tables",
                "INNER JOIN exclut les lignes sans correspondance dans l'autre table."),
            q(QuizType.completeQuery, "Complète : SELECT l.titre, a.nom FROM livres l JOIN auteurs a …",
                ["ON l.auteur_id = a.id", "WHERE l.id = a.id", "USING auteurs", "ON l.titre = a.nom"],
                "ON l.auteur_id = a.id",
                "La clé étrangère auteur_id correspond à la clé primaire id des auteurs."),
            tf("Une requête peut enchaîner plusieurs JOIN.", true,
                "Chaque JOIN ajoute une table, avec sa propre condition ON."),
          ],
          xp: 35,
        ),
        Lesson(
          id: 'sql_group_having',
          trackId: 'sql',
          levelIndex: 2,
          title: 'GROUP BY et HAVING',
          objective:
              "Grouper des lignes pour calculer des agrégats par groupe, puis filtrer ces groupes.",
          content: [
            "GROUP BY regroupe les lignes qui ont la même valeur dans une ou plusieurs colonnes. Les fonctions d'agrégation (COUNT, SUM, AVG…) sont alors calculées pour chaque groupe, au lieu de toute la table.",
            "Exemple : compter les produits par catégorie, c'est GROUP BY category_id + COUNT(*). Le résultat contient une ligne par catégorie.",
            "Règle d'or : chaque colonne du SELECT doit soit apparaître dans le GROUP BY, soit être dans une fonction d'agrégation. SELECT departement_id, nom, COUNT(*) … GROUP BY departement_id est incorrect : quel nom afficher pour tout un département ? (SQLite l'accepte et choisit au hasard, PostgreSQL le refuse.)",
            "HAVING filtre les GROUPES, après le calcul des agrégats, alors que WHERE filtre les lignes AVANT le regroupement. Pour « les départements de plus de 2 employés », c'est HAVING COUNT(*) > 2.",
            "Ordre logique d'exécution : FROM → WHERE (filtre les lignes) → GROUP BY → HAVING (filtre les groupes) → SELECT → ORDER BY.",
            "On peut grouper sur plusieurs colonnes, et combiner GROUP BY avec une jointure pour afficher un libellé lisible (le nom du département plutôt que son id).",
          ],
          codeBlocks: [
            code('sql', "-- base : boutique\nSELECT category_id, COUNT(*) AS nb\nFROM products\nGROUP BY category_id;",
                e: "Combien de produits par catégorie."),
            code('sql', "-- base : boutique\nSELECT category_id, COUNT(*) AS nb\nFROM products\nGROUP BY category_id\nHAVING COUNT(*) >= 3;",
                e: "Ne garde que les catégories d'au moins 3 produits."),
            code('sql', "-- base : employes\nSELECT departement_id, COUNT(*) AS nb, ROUND(AVG(salaire)) AS salaire_moyen\nFROM employes\nWHERE embauche >= '2016-01-01'\nGROUP BY departement_id\nHAVING COUNT(*) >= 2\nORDER BY salaire_moyen DESC;",
                e: "Toutes les clauses ensemble, dans l'ordre."),
            code('sql', "-- base : employes\nSELECT d.nom, COUNT(e.id) AS nb_employes\nFROM departements d\nJOIN employes e ON e.departement_id = d.id\nGROUP BY d.id, d.nom;",
                e: "Avec une jointure, on affiche le nom du département."),
          ],
          commonMistakes: [
            "Utiliser WHERE pour filtrer des agrégats : WHERE COUNT(*) > 2 est interdit, il faut HAVING.",
            "Sélectionner une colonne qui n'est ni dans GROUP BY ni dans un agrégat.",
            "Mettre dans HAVING un filtre sur une colonne normale : il marche, mais WHERE est plus rapide car il filtre avant de grouper.",
          ],
          exercises: [
            ex("Affiche le nombre d'employés par département. (base employes)",
                "SELECT departement_id, COUNT(*) AS nb FROM employes GROUP BY departement_id;",
                "GROUP BY département puis COUNT."),
            ex("Affiche le nombre de livres par auteur, seulement pour les auteurs qui en ont au moins 2. (base bibliotheque)",
                "SELECT auteur_id, COUNT(*) AS nb FROM livres GROUP BY auteur_id HAVING COUNT(*) >= 2;",
                "HAVING filtre les groupes après le comptage."),
            ex("Affiche la moyenne de chaque étudiant, de la meilleure à la moins bonne. (base ecole)",
                "SELECT etudiant_id, AVG(note) AS moyenne FROM notes GROUP BY etudiant_id ORDER BY moyenne DESC;",
                "On groupe par étudiant puis on trie sur l'alias."),
          ],
          quiz: [
            tf("HAVING s'applique aux groupes, WHERE aux lignes.", true,
                "WHERE filtre avant le regroupement, HAVING filtre après."),
            q(QuizType.qcm, "Dans quel ordre logique s'appliquent ces clauses ?",
                ["WHERE → GROUP BY → HAVING → ORDER BY", "GROUP BY → WHERE → ORDER BY → HAVING", "HAVING → WHERE → GROUP BY → ORDER BY", "ORDER BY → HAVING → GROUP BY → WHERE"],
                "WHERE → GROUP BY → HAVING → ORDER BY",
                "On filtre les lignes, on groupe, on filtre les groupes, puis on trie."),
            q(QuizType.findError, "Trouve l'erreur : SELECT departement_id, nom, COUNT(*) FROM employes GROUP BY departement_id;",
                ["nom n'est ni dans GROUP BY ni agrégé", "COUNT(*) est interdit avec GROUP BY", "Il manque HAVING", "departement_id doit être agrégé"],
                "nom n'est ni dans GROUP BY ni agrégé",
                "Un département contient plusieurs noms : lequel afficher ?"),
          ],
          xp: 35,
        ),

        // ================= LEVEL 3 : AVANCÉ =================
        Lesson(
          id: 'sql_subqueries',
          trackId: 'sql',
          levelIndex: 3,
          title: 'Sous-requêtes',
          objective:
              "Utiliser des requêtes imbriquées pour répondre à des questions en plusieurs étapes.",
          content: [
            "Une sous-requête est un SELECT placé entre parenthèses à l'intérieur d'une autre requête. Elle permet de répondre à une question en deux temps : « quel est le prix maximum ? », puis « quels produits ont ce prix ? ».",
            "Sous-requête scalaire : elle renvoie UNE seule valeur et s'utilise avec =, <, > : WHERE price = (SELECT MAX(price) FROM products). Si elle renvoie plusieurs lignes, c'est une erreur.",
            "Sous-requête de liste : elle renvoie une colonne de plusieurs valeurs et s'utilise avec IN ou NOT IN : WHERE departement_id IN (SELECT id FROM departements WHERE ville = 'Paris').",
            "EXISTS teste si une sous-requête renvoie au moins une ligne. Il est souvent combiné avec une sous-requête corrélée, c'est-à-dire qui utilise une colonne de la requête principale et qui est donc recalculée pour chaque ligne.",
            "Dans FROM, une sous-requête devient une table temporaire (table dérivée), qui doit avoir un alias : SELECT … FROM (SELECT …) AS t.",
            "Beaucoup de sous-requêtes peuvent s'écrire aussi avec une jointure ou une CTE (WITH). Choisis la forme la plus lisible : les SGBD modernes optimisent souvent les deux de la même façon.",
          ],
          codeBlocks: [
            code('sql', "-- base : boutique\nSELECT name, price FROM products\nWHERE price = (SELECT MAX(price) FROM products);",
                e: "Le produit le plus cher."),
            code('sql', "-- base : employes\nSELECT nom, prenom FROM employes\nWHERE departement_id IN (\n  SELECT id FROM departements WHERE ville = 'Paris'\n);",
                e: "Les employés des départements situés à Paris."),
            code('sql', "-- base : employes\nSELECT nom, salaire, departement_id FROM employes e\nWHERE salaire > (\n  SELECT AVG(salaire) FROM employes\n  WHERE departement_id = e.departement_id\n);",
                e: "Sous-requête corrélée : payés plus que la moyenne de LEUR département."),
            code('sql', "-- base : bibliotheque\nSELECT a.nom FROM auteurs a\nWHERE EXISTS (\n  SELECT 1 FROM livres l\n  WHERE l.auteur_id = a.id AND l.disponible = 0\n);",
                e: "Les auteurs dont au moins un livre est emprunté."),
            code('sql', "-- base : bibliotheque\nSELECT ROUND(AVG(nb), 1) AS livres_par_auteur\nFROM (SELECT auteur_id, COUNT(*) AS nb FROM livres GROUP BY auteur_id) AS t;",
                e: "Une sous-requête dans FROM : la moyenne de livres par auteur."),
          ],
          commonMistakes: [
            "Sous-requête qui retourne plusieurs lignes là où on attend une seule valeur.",
            "Oublier l'alias pour une sous-requête dans FROM.",
            "Utiliser NOT IN avec une sous-requête qui peut renvoyer NULL : le résultat devient vide. Préfère NOT EXISTS.",
          ],
          exercises: [
            ex("Trouve le produit le plus cher. (base boutique)",
                "SELECT name, price FROM products WHERE price = (SELECT MAX(price) FROM products);",
                "La sous-requête calcule le prix maximum."),
            ex("Affiche les employés qui gagnent plus que la moyenne de l'entreprise. (base employes)",
                "SELECT nom, salaire FROM employes WHERE salaire > (SELECT AVG(salaire) FROM employes);",
                "Sous-requête scalaire : une seule valeur, la moyenne globale."),
            ex("Affiche les cours dans lesquels au moins un étudiant a eu plus de 18. (base ecole)",
                "SELECT titre FROM cours WHERE id IN (SELECT cours_id FROM notes WHERE note > 18);",
                "Sous-requête de liste avec IN."),
          ],
          quiz: [
            q(QuizType.qcm, "Où peut se placer une sous-requête dans une requête ?",
                ["Dans WHERE, FROM ou SELECT", "Seulement dans SELECT", "Après le point-virgule", "Jamais"],
                "Dans WHERE, FROM ou SELECT",
                "Les sous-requêtes peuvent apparaître dans plusieurs clauses selon le besoin."),
            q(QuizType.qcm, "Qu'est-ce qu'une sous-requête corrélée ?",
                ["Une sous-requête qui utilise une colonne de la requête principale", "Une sous-requête placée dans FROM", "Une sous-requête qui renvoie une seule valeur", "Une sous-requête sans WHERE"],
                "Une sous-requête qui utilise une colonne de la requête principale",
                "Elle est recalculée pour chaque ligne de la requête principale."),
            q(QuizType.findError, "Trouve l'erreur : WHERE price = (SELECT price FROM products WHERE category_id = 1)",
                ["La sous-requête renvoie plusieurs lignes", "Il manque un alias", "price n'existe pas", "= est interdit avec une sous-requête"],
                "La sous-requête renvoie plusieurs lignes",
                "Avec =, la sous-requête doit renvoyer une seule valeur. Ici, il faudrait IN."),
          ],
          xp: 40,
        ),
        Lesson(
          id: 'sql_transactions',
          trackId: 'sql',
          levelIndex: 3,
          title: 'Transactions et ACID',
          objective:
              "Regrouper plusieurs opérations en un bloc indivisible pour garantir l'intégrité des données.",
          content: [
            "Une transaction est un ensemble d'opérations qui doivent réussir TOUTES ensemble, ou échouer TOUTES ensemble. Exemple type : un virement retire 100 € d'un compte et les ajoute à un autre. Si la panne survient entre les deux, l'argent ne doit pas disparaître.",
            "BEGIN démarre une transaction, COMMIT valide définitivement toutes ses modifications, ROLLBACK les annule toutes. Tant que le COMMIT n'est pas fait, les autres utilisateurs ne voient pas les changements.",
            "ACID résume les garanties : Atomicité (tout ou rien), Cohérence (les contraintes restent respectées), Isolation (les transactions simultanées ne se gênent pas), Durabilité (une fois validées, les données survivent à une panne).",
            "Sans BEGIN, la plupart des SGBD sont en mode autocommit : chaque instruction est une petite transaction validée immédiatement.",
            "SAVEPOINT nom pose un point de retour à l'intérieur d'une transaction : ROLLBACK TO nom annule seulement ce qui suit ce point.",
            "L'isolation a plusieurs niveaux (READ COMMITTED, REPEATABLE READ, SERIALIZABLE). Plus elle est stricte, plus elle évite les anomalies (lectures sales, lectures non répétables), mais plus elle peut ralentir.",
          ],
          codeBlocks: [
            code('sql', "-- base : boutique\nCREATE TABLE comptes (\n  id INTEGER PRIMARY KEY,\n  titulaire TEXT,\n  solde REAL CHECK (solde >= 0)\n);\nINSERT INTO comptes (titulaire, solde) VALUES ('Alice', 500), ('Bob', 200);",
                e: "Prépare deux comptes. Le CHECK interdit un solde négatif."),
            code('sql', "-- base : boutique\nBEGIN;\nUPDATE comptes SET solde = solde - 100 WHERE id = 1;\nUPDATE comptes SET solde = solde + 100 WHERE id = 2;\nCOMMIT;\nSELECT * FROM comptes;",
                e: "Virement : les deux mises à jour sont validées ensemble."),
            code('sql', "-- base : boutique\nBEGIN;\nUPDATE comptes SET solde = 0;\nROLLBACK;\nSELECT * FROM comptes;",
                e: "ROLLBACK annule la mise à zéro : les soldes sont intacts."),
            code('sql', "-- base : boutique\nBEGIN;\nUPDATE comptes SET solde = solde + 50 WHERE id = 1;\nSAVEPOINT avant_bonus;\nUPDATE comptes SET solde = solde + 1000 WHERE id = 2;\nROLLBACK TO avant_bonus;\nCOMMIT;\nSELECT * FROM comptes;",
                e: "Seul le bonus de 1000 est annulé, les +50 sont validés."),
          ],
          commonMistakes: [
            "Oublier COMMIT : les modifications sont perdues à la fermeture de la connexion.",
            "Ne pas gérer les erreurs : une requête en échec doit déclencher un ROLLBACK.",
            "Garder une transaction ouverte longtemps : elle bloque les autres utilisateurs.",
          ],
          exercises: [
            ex("Quelle instruction annule une transaction ?",
                "ROLLBACK.",
                "ROLLBACK annule toutes les modifications de la transaction."),
            ex("Dans une transaction, augmente de 5 % les salaires du département 3, puis annule avec ROLLBACK. (base employes)",
                "BEGIN; UPDATE employes SET salaire = salaire * 1.05 WHERE departement_id = 3; ROLLBACK;",
                "Après le ROLLBACK, les salaires sont revenus à leur valeur d'origine."),
          ],
          quiz: [
            q(QuizType.qcm, "Que signifie le « A » de ACID ?",
                ["Atomicité", "Adaptabilité", "Arithmétique", "Autonomie"], "Atomicité",
                "Atomicité : les opérations réussissent ou échouent ensemble."),
            tf("Sans BEGIN, chaque instruction est généralement validée automatiquement (autocommit).", true,
                "Chaque instruction forme alors sa propre transaction."),
            q(QuizType.qcm, "Quelle propriété garantit qu'une donnée validée survit à une panne ?",
                ["Durabilité", "Isolation", "Atomicité", "Cohérence"], "Durabilité",
                "Une fois le COMMIT fait, les données sont écrites durablement."),
          ],
          xp: 40,
        ),

        // ================= LEVEL 4 : EXPERT =================
        Lesson(
          id: 'sql_indexes',
          trackId: 'sql',
          levelIndex: 4,
          title: 'Index et optimisation',
          objective:
              "Accélérer les recherches, comprendre le rôle des index et lire un plan d'exécution.",
          content: [
            "Un index est une structure à part, comme l'index d'un livre, qui permet de retrouver vite les lignes ayant une certaine valeur, sans lire toute la table.",
            "Sans index, la base fait un parcours complet (SCAN) : elle lit chaque ligne. Avec un index (le plus souvent un arbre B-tree), elle va directement aux bonnes lignes (SEARCH). Sur une table d'un million de lignes, la différence est énorme.",
            "CREATE INDEX nom ON table(colonne); crée un index. Les clés primaires et les colonnes UNIQUE sont indexées automatiquement. On indexe les colonnes utilisées dans WHERE, JOIN et ORDER BY.",
            "Un index composite porte sur plusieurs colonnes, par exemple (departement_id, salaire). Il sert pour les recherches sur la première colonne, ou sur les deux, mais pas sur la deuxième seule.",
            "Les index ont un coût : chaque INSERT, UPDATE ou DELETE doit aussi les mettre à jour, et ils prennent de la place. Un index peut aussi être ignoré : LIKE '%mot' (joker au début), fonction appliquée à la colonne (UPPER(nom) = …), colonne avec très peu de valeurs différentes.",
            "EXPLAIN QUERY PLAN (SQLite) ou EXPLAIN (PostgreSQL, MySQL) montre comment la requête est exécutée : SCAN ou SEARCH, index utilisé ou non. C'est l'outil de base de toute optimisation.",
          ],
          codeBlocks: [
            code('sql', "-- base : boutique\nCREATE INDEX idx_products_price ON products(price);",
                e: "Crée un index sur la colonne price."),
            code('sql', "-- base : boutique\nEXPLAIN QUERY PLAN SELECT * FROM products WHERE price < 50;",
                e: "Le plan indique SEARCH … USING INDEX idx_products_price."),
            code('sql', "-- base : boutique\nEXPLAIN QUERY PLAN SELECT * FROM products WHERE name LIKE '%souris%';",
                e: "Ici, SCAN : aucun index ne peut servir avec un % au début."),
            code('sql', "-- base : employes\nCREATE INDEX idx_emp_dept_sal ON employes(departement_id, salaire);\nEXPLAIN QUERY PLAN\nSELECT nom FROM employes WHERE departement_id = 2 AND salaire > 40000;",
                e: "Un index composite utilisé pour les deux conditions."),
          ],
          commonMistakes: [
            "Indexer toutes les colonnes : inutile et coûteux à chaque écriture.",
            "Chercher avec LIKE '%mot', qui ne peut pas utiliser un index classique.",
            "Appliquer une fonction à la colonne indexée (WHERE UPPER(nom) = 'MARTIN') : l'index ne sert plus.",
          ],
          exercises: [
            ex("Pourquoi un index accélère-t-il les recherches ?",
                "Il évite de scanner toute la table en pointant directement vers les données.",
                "Comme un sommaire, l'index dirige vers les bonnes positions."),
            ex("Crée un index sur la colonne annee de la table films. (base films)",
                "CREATE INDEX idx_films_annee ON films(annee);",
                "Utile si on filtre ou trie souvent par année."),
            ex("Affiche le plan d'exécution d'une recherche des livres de l'auteur 1. (base bibliotheque)",
                "EXPLAIN QUERY PLAN SELECT titre FROM livres WHERE auteur_id = 1;",
                "Sans index sur auteur_id, le plan indique un SCAN de la table."),
          ],
          quiz: [
            tf("Trop d'index peuvent ralentir les insertions.", true,
                "Chaque index doit être mis à jour à chaque écriture."),
            q(QuizType.qcm, "Que fait EXPLAIN ?",
                ["Montre le plan d'exécution", "Exécute la requête 10 fois", "Supprime la table", "Renomme la table"],
                "Montre le plan d'exécution",
                "EXPLAIN révèle comment le SGBD exécute la requête."),
            q(QuizType.qcm, "Un index composite sur (a, b) peut servir pour :",
                ["WHERE a = 1", "WHERE b = 1 seul", "Aucune requête", "Seulement les INSERT"],
                "WHERE a = 1",
                "Il sert pour la première colonne, ou les deux, mais pas pour b seul."),
          ],
          xp: 45,
        ),
        Lesson(
          id: 'sql_security',
          trackId: 'sql',
          levelIndex: 4,
          title: 'Sécurité et injections SQL',
          objective:
              "Protéger ses données et se prémunir contre les injections SQL.",
          content: [
            "Une injection SQL est une attaque où un utilisateur glisse du code SQL dans une saisie (formulaire, URL…) pour détourner la requête. C'est l'une des failles web les plus courantes et les plus graves.",
            "Elle apparaît quand on construit la requête en collant la saisie dans le texte SQL. Si la requête est … WHERE nom = '<saisie>' et que l'attaquant tape ' OR '1'='1, la condition devient toujours vraie et toute la table est renvoyée. Avec d'autres saisies, il peut lire d'autres tables ou supprimer des données.",
            "La protection n°1 : les requêtes préparées (paramètres liés). On écrit la requête avec des ? et on passe les valeurs à part. Le SGBD sait alors que ce sont des données, jamais du code. Tous les langages et ORM le proposent.",
            "Principe du moindre privilège : l'application se connecte avec un compte qui n'a que les droits nécessaires (GRANT SELECT, INSERT sur certaines tables), jamais en administrateur. Si une faille existe, les dégâts restent limités.",
            "Les mots de passe ne se stockent jamais en clair : on stocke une empreinte calculée avec un algorithme lent et salé (bcrypt, Argon2). MD5 et SHA-1 seuls sont à proscrire.",
            "Autres réflexes : valider les entrées (type, longueur), ne pas afficher les messages d'erreur SQL détaillés aux utilisateurs, chiffrer les connexions, et faire des sauvegardes régulières et testées.",
          ],
          codeBlocks: [
            code('python', "# Vulnérable : la saisie est collée dans le SQL\nsql = \"SELECT * FROM clients WHERE nom = '\" + saisie + \"'\"",
                e: "Si saisie = ' OR '1'='1, la requête renvoie tous les clients."),
            code('sql', "-- base : boutique\n-- La requête obtenue avec la saisie : ' OR '1'='1\nSELECT * FROM clients WHERE nom = '' OR '1'='1';",
                e: "Essaie-la : toute la table s'affiche, alors qu'aucun client ne s'appelle « vide »."),
            code('dart', "// Sûr : requête préparée, la valeur est passée à part\nfinal rows = await db.rawQuery(\n  'SELECT * FROM clients WHERE nom = ?',\n  [saisie],\n);",
                e: "Le ? est remplacé par la valeur, traitée comme une donnée et jamais comme du code."),
            code('sql', "-- PostgreSQL / MySQL : un compte en lecture seule\nCREATE USER catalogue_app WITH PASSWORD '…';\nGRANT SELECT ON products, categories TO catalogue_app;",
                e: "Moindre privilège : ce compte ne peut que lire deux tables."),
          ],
          commonMistakes: [
            "Concaténer directement les variables dans le SQL.",
            "Utiliser des privilèges administrateur pour toutes les connexions.",
            "Stocker les mots de passe en clair ou avec MD5 au lieu de bcrypt ou Argon2.",
          ],
          exercises: [
            ex("Comment protège-t-on une requête contre l'injection ?",
                "Avec des requêtes préparées (paramètres liés) au lieu de concaténer les entrées.",
                "Les requêtes préparées séparent le code SQL des données."),
            ex("Écris la requête qu'obtient un attaquant qui tape ' OR '1'='1 dans une recherche par ville, puis exécute-la. (base boutique)",
                "SELECT * FROM clients WHERE ville = '' OR '1'='1';",
                "La condition '1'='1' est toujours vraie : tous les clients sont renvoyés."),
            ex("Quel droit minimal donner au compte d'une application qui ne fait qu'afficher le catalogue ?",
                "GRANT SELECT sur les tables du catalogue, et rien d'autre.",
                "Moindre privilège : pas d'INSERT, d'UPDATE ni de DELETE."),
          ],
          quiz: [
            q(QuizType.qcm, "Une injection SQL permet surtout de :",
                ["Exécuter du code non prévu sur la base", "Accélérer les requêtes", "Créer des index", "Chiffrer les données"],
                "Exécuter du code non prévu sur la base",
                "L'attaquant injecte du SQL pour lire ou modifier des données non autorisées."),
            q(QuizType.qcm, "Quelle est la meilleure protection contre l'injection SQL ?",
                ["Les requêtes préparées", "Supprimer les apostrophes à la main", "Cacher le nom des tables", "Utiliser un compte administrateur"],
                "Les requêtes préparées",
                "Les valeurs sont envoyées séparément du code SQL."),
            tf("Un mot de passe doit être stocké haché avec un algorithme lent comme bcrypt.", true,
                "Un algorithme lent et salé rend le cassage des empreintes très coûteux."),
          ],
          xp: 45,
        ),

        // ================= LEVEL 5 : ENGINEER =================
        Lesson(
          id: 'sql_scalability',
          trackId: 'sql',
          levelIndex: 5,
          title: 'Scalabilité et réplication',
          objective:
              "Comprendre comment faire monter une base en charge : réplication, partitionnement, cache.",
          content: [
            "La scalabilité est la capacité d'un système à supporter une charge croissante : plus d'utilisateurs, plus de requêtes, plus de données. Avant tout, on optimise : bons index, requêtes efficaces, pagination correcte.",
            "Deux stratégies : le scale-up (vertical), qui consiste à prendre un serveur plus puissant (simple, mais limité et coûteux), et le scale-out (horizontal), qui consiste à répartir la charge sur plusieurs serveurs (plus complexe, mais presque sans limite).",
            "La réplication copie les données d'un serveur principal (primary) vers des réplicas. Les écritures vont au principal, les lectures peuvent être réparties sur les réplicas. Elle apporte aussi la haute disponibilité : si le principal tombe, un réplica prend le relais. Contrepartie : un léger délai de réplication, pendant lequel un réplica peut afficher une donnée un peu ancienne.",
            "Le partitionnement découpe une grosse table en morceaux, par exemple par mois. Le sharding va plus loin : chaque morceau vit sur un serveur différent, selon une clé de sharding (par exemple l'id du client). Une mauvaise clé concentre toute la charge sur un seul serveur.",
            "On soulage aussi la base avec un cache (Redis) pour les données lues très souvent, et avec un pool de connexions qui réutilise les connexions au lieu d'en ouvrir une par requête.",
            "Le théorème CAP rappelle qu'en cas de coupure réseau, un système distribué doit choisir entre la cohérence (tout le monde voit la même donnée) et la disponibilité (toujours répondre). Le choix dépend du métier : une banque privilégie la cohérence, un fil d'actualité la disponibilité.",
          ],
          codeBlocks: [
            code('texte', "           écritures\nApplication ───────────► Primary\n     │                     │ réplication\n     │ lectures            ▼\n     └──────────► Réplica 1, Réplica 2",
                e: "Architecture classique : un principal pour écrire, des réplicas pour lire."),
            code('sql', "-- base : employes\n-- Pagination par clé : la page suivante après l'id 6\nSELECT id, nom FROM employes\nWHERE id > 6\nORDER BY id\nLIMIT 3;",
                e: "Rapide même sur des millions de lignes, contrairement à un OFFSET élevé qui lit puis jette les lignes sautées."),
            code('sql', "-- PostgreSQL : table partitionnée par mois\nCREATE TABLE commandes (id BIGINT, date_cmd DATE, total NUMERIC)\nPARTITION BY RANGE (date_cmd);\nCREATE TABLE commandes_2026_01 PARTITION OF commandes\nFOR VALUES FROM ('2026-01-01') TO ('2026-02-01');",
                e: "Chaque mois est stocké à part, et les requêtes sur un mois ne lisent que sa partition."),
          ],
          commonMistakes: [
            "Confondre réplication (copies identiques) et partitionnement (découpage).",
            "Oublier que l'écriture reste sur le principal dans une réplication primary/réplica.",
            "Paginer avec un OFFSET énorme : la base lit et jette toutes les lignes sautées.",
          ],
          exercises: [
            ex("Quelle différence entre réplication et sharding ?",
                "La réplication copie les données sur plusieurs serveurs ; le sharding découpe les données en morceaux distincts.",
                "Réplication = copies. Sharding = répartition par fragments."),
            ex("Affiche la « page suivante » de 3 films après l'id 4, en pagination par clé. (base films)",
                "SELECT id, titre FROM films WHERE id > 4 ORDER BY id LIMIT 3;",
                "On repart du dernier id affiché au lieu d'utiliser OFFSET."),
            ex("Pourquoi un réplica peut-il afficher une donnée un peu ancienne ?",
                "À cause du délai de réplication : les modifications du principal arrivent avec un léger retard.",
                "C'est le prix de la réplication asynchrone."),
          ],
          quiz: [
            q(QuizType.qcm, "La réplication en lecture sur plusieurs serveurs améliore surtout :",
                ["Le débit de lecture", "La vitesse d'écriture seule", "La taille disque", "Le chiffrement"],
                "Le débit de lecture",
                "Les lectures se répartissent entre réplicas, ce qui augmente le débit."),
            q(QuizType.qcm, "Ajouter des serveurs plutôt que grossir un serveur s'appelle :",
                ["Le scale-out (horizontal)", "Le scale-up (vertical)", "La normalisation", "L'indexation"],
                "Le scale-out (horizontal)",
                "Le scale-up consiste à prendre une machine plus puissante."),
            tf("Le sharding copie toutes les données sur chaque serveur.", false,
                "Le sharding répartit des morceaux différents sur chaque serveur ; c'est la réplication qui copie."),
          ],
          xp: 50,
        ),
      ];
}
