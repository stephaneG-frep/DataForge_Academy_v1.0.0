import '../models/lesson_models.dart';

/// Core "SQL" track lessons — the deepest pedagogical content.
/// Levels: Débutant(0) → Database Engineer(5).
class SqlTrackLessons {
  SqlTrackLessons._();

  static CodeBlock code(String lang, String c, {String? e}) => CodeBlock(lang, c, explanation: e);

  static List<Lesson> all() => [
        // ================= LEVEL 0 : DÉBUTANT =================
        Lesson(
          id: 'sql_intro',
          trackId: 'sql',
          levelIndex: 0,
          title: 'Qu\'est-ce qu\'une base de données ?',
          objective:
              'Comprendre le rôle d\'une base de données et le vocabulaire de base (table, colonne, ligne, clé).',
          content: [
            'Une base de données (BDD) est un ensemble organisé de données stockées de manière structurée et persistante. Pense à elle comme à un très grand classeur où chaque "fiche" est enregistrée proprement.',
            'Dans une base de données relationnelle, les données sont rangées dans des TABLES. Une table ressemble à un tableau Excel : des lignes (les enregistrements) et des colonnes (les attributs/propriétés).',
            'Exemple : une table "employes" avec les colonnes id, nom, prenom, salaire. Chaque ligne est un employé, chaque colonne une information le concernant.',
            'SQL (Structured Query Language) est le langage universel qui permet de créer, lire, modifier et supprimer des données dans une base relationnelle. C\'est LE langage des bases de données.',
            'Avantage clé du relationnel : l\'intégrité. On peut garantir que chaque employé appartient à un département existant grâce aux clés et aux relations.',
          ],
          codeBlocks: [
            code('sql', '-- Vue d\'une table "employes"\n'
                'id | nom    | prenom | salaire\n'
                '---|--------|--------|-------\n'
                '1  | Martin | Sophie | 42000\n'
                '2  | Bernard| Paul   | 35000',
                e: 'Chaque colonne = attribut, chaque ligne = enregistrement.'),
          ],
          commonMistakes: [
            'Confondre la base de données (le conteneur) et le SGBD (le logiciel qui la gère, ex : PostgreSQL).',
            'Penser que les tables sont en vrac : elles sont reliées par des relations.',
          ],
          exercises: [
            ExerciseItem(
                'Dans une table, qu\'appelle-t-on une "ligne" ?',
                'Un enregistrement complet correspondant à un élément réel (un employé, un produit...).',
                'Chaque ligne regroupe toutes les valeurs d\'un même enregistrement.'),
            ExerciseItem(
                'Comment s\'appelle le langage des bases de données relationnelles ?',
                'SQL (Structured Query Language).',
                'SQL sert à interroger et manipuler les données.'),
          ],
          quiz: [
            QuizItem(
              type: QuizType.qcm,
              question: 'Une table est :',
              options: ['Un ensemble de colonnes et de lignes', 'Un fichier texte', 'Une formule', 'Un programme'],
              correctAnswer: 'Un ensemble de colonnes et de lignes',
              explanation:
                  'Une table est un structure en lignes (enregistrements) et colonnes (attributs).',
            ),
          ],
          xp: 20,
        ),
        Lesson(
          id: 'sql_select',
          trackId: 'sql',
          levelIndex: 0,
          title: 'SELECT : lire des données',
          objective:
              'Écrire sa première requête SELECT pour afficher des colonnes d\'une table.',
          content: [
            'SELECT est l\'instruction la plus utilisée. Elle sert à LIRE des données : tu choisis les colonnes et la table.',
            'La syntaxe minimale : SELECT colonne FROM table;',
            'Le point-virgule termine une instruction SQL (optionnel dans certains outils, recommandé).',
            'Pour sélectionner TOUTES les colonnes, utilise l\'astérisque (étoile) : SELECT * FROM table;',
            'Tu peux sélectionner plusieurs colonnes séparées par des virgules, et ajouter des ALIASES (surnoms) avec AS pour renommer le résultat.',
          ],
          codeBlocks: [
            code('sql', 'SELECT nom, prenom FROM employes;',
                e: 'Affiche les colonnes nom et prenom de toutes les lignes.'),
            code('sql', 'SELECT * FROM products;',
                e: 'Affiche toutes les colonnes de la table products.'),
            code('sql', 'SELECT nom AS nom_employe FROM employes;',
                e: 'Renomme la colonne "nom" en "nom_employe" dans le résultat.'),
          ],
          commonMistakes: [
            'Oublier le FROM : SELECT nom; ne marche pas sans table.',
            'Mettre une virgule en trop après la dernière colonne.',
            'Confondre le point-virgule final avec la syntaxe.',
          ],
          exercises: [
            ExerciseItem(
                'Écris la requête pour afficher uniquement les colonnes name et price de la table products.',
                'SELECT name, price FROM products;',
                'On liste les colonnes séparées par des virgules après SELECT.'),
          ],
          quiz: [
            QuizItem(
              type: QuizType.completeQuery,
              question:
                  'Complète : afficher toutes les colonnes de la table films',
              options: ['SELECT * FROM films;', 'SELECT all films;', 'FROM films SELECT;', 'SHOW films;'],
              correctAnswer: 'SELECT * FROM films;',
              explanation:
                  'L\'astérisque * sélectionne toutes les colonnes, FROM précise la table.',
            ),
            QuizItem(
              type: QuizType.trueFalse,
              question: 'SELECT affiche les lignes d\'une table mais ne les modifie jamais.',
              options: ['Vrai', 'Faux'],
              correctAnswer: 'Vrai',
              explanation:
                  'SELECT est une requête de lecture : elle ne change pas les données.',
            ),
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
              'Filtrer les résultats avec WHERE et les opérateurs de comparaison.',
          content: [
            'WHERE permet de ne garder que les lignes qui respectent une condition.',
            'Opérateurs de comparaison : = (égal), != ou <> (différent), >, <, >=, <=.',
            'Les texte se comparent avec des guillemets simples : WHERE nom = \'Martin\'.',
            'On peut combiner des conditions avec AND (les deux doivent être vraies) et OR (au moins une doit être vraie).',
            'IN permet de tester plusieurs valeurs, BETWEEN pour un intervalle, LIKE pour une recherche partielle.',
          ],
          codeBlocks: [
            code('sql', 'SELECT name, price FROM products\nWHERE price < 50;',
                e: 'Affiche les produits à moins de 50.'),
            code('sql', 'SELECT name FROM products\nWHERE category_id = 1 AND price > 20;',
                e: 'Les deux conditions doivent être vraies.'),
            code('sql', 'SELECT name FROM products\nWHERE name LIKE \'%souris%\';',
                e: 'Le % remplace n\'importe quelle suite de caractères.'),
          ],
          commonMistakes: [
            'Utiliser = au lieu de = pour comparer des textes (avec les guillemets).',
            'Oublier les guillemets autour des chaînes de caractères.',
            'Confondre AND/OR dans des conditions mélangées.',
          ],
          exercises: [
            ExerciseItem(
                'Affiche les produits dont le prix est compris entre 30 et 60.',
                'SELECT name, price FROM products WHERE price BETWEEN 30 AND 60;',
                'BETWEEN inclut les bornes.'),
          ],
          quiz: [
            QuizItem(
              type: QuizType.qcm,
              question: 'Quel opérateur signifie "différent de" ?',
              options: ['!=', '==', '&&', '!'],
              correctAnswer: '!=',
              explanation: '!= (ou <>) teste l\'inégalité en SQL.',
            ),
            QuizItem(
              type: QuizType.findError,
              question: 'Trouve l\'erreur : SELECT name WHERE price < 50',
              options: ['Il manque FROM', 'price est inconnu', 'Il manque ;', 'name est mal écrit'],
              correctAnswer: 'Il manque FROM',
              explanation:
                  'WHERE s\'utilise avec FROM : SELECT name FROM products WHERE price < 50.',
            ),
          ],
          xp: 30,
        ),
        Lesson(
          id: 'sql_order_group',
          trackId: 'sql',
          levelIndex: 1,
          title: 'ORDER BY et fonctions d\'agrégation',
          objective:
              'Trier les résultats et calculer des statistiques (COUNT, SUM, AVG, MIN, MAX).',
          content: [
            'ORDER BY trie les résultats, de façon ascendante (ASC, par défaut) ou descendante (DESC).',
            'Les fonctions d\'agrégation calculent une valeur à partir de plusieurs lignes : COUNT compte, SUM additionne, AVG fait la moyenne, MIN/MAX trouvent les extrêmes.',
            'Elles s\'utilisent sans FROM ? Non — toujours avec FROM, mais elles retournent UNE seule ligne globale.',
            'Attention : SELECT name, AVG(price) n\'a pas de sens sans GROUP BY (voir niveau intermédiaire).',
          ],
          codeBlocks: [
            code('sql', 'SELECT name, price FROM products\nORDER BY price DESC;',
                e: 'Trie du plus cher au moins cher.'),
            code('sql', 'SELECT COUNT(*) AS nb FROM products;',
                e: 'Compte le nombre total de lignes.'),
            code('sql', 'SELECT AVG(price) AS prix_moyen FROM products;',
                e: 'Calcule le prix moyen de tous les produits.'),
          ],
          commonMistakes: [
            'Écrire ORDER BY price DESC pour trier au plus cher (c\'est correct !).',
            'Oublier qu\'une colonne non-agrégée doit être dans GROUP BY.',
            'Croire que ORDER BY vient avant WHERE (il vient après).',
          ],
          exercises: [
            ExerciseItem(
                'Compte le nombre de produits dont le prix est inférieur à 50.',
                'SELECT COUNT(*) FROM products WHERE price < 50;',
                'On filtre d\'abord avec WHERE, puis COUNT compte les lignes restantes.'),
          ],
          quiz: [
            QuizItem(
              type: QuizType.qcm,
              question: 'Que retourne AVG(price) ?',
              options: ['Le prix le plus bas', 'La moyenne des prix', 'Le nombre de prix', 'La somme des prix'],
              correctAnswer: 'La moyenne des prix',
              explanation: 'AVG calcule la moyenne arithmétique.'),
            QuizItem(
              type: QuizType.predictResult,
              question: 'SELECT COUNT(*) FROM produits WHERE prix < 0;',
              options: ['0', '1', 'Toutes les lignes', 'Une erreur'],
              correctAnswer: '0',
              explanation: 'Aucun produit n\'a un prix négatif, donc COUNT renvoie 0.',
            ),
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
              'Associer des lignes de plusieurs tables avec INNER JOIN.',
          content: [
            'Le vrai pouvoir des bases relationnelles, ce sont les liaisons entre tables via des clés étrangères.',
            'INNER JOIN ne retourne que les lignes qui ont une correspondance dans les DEUX tables.',
            'La syntaxe : SELECT colonnes FROM table1 INNER JOIN table2 ON table1.cle = table2.cle;',
            'ON précise la condition de correspondance. On préfixe souvent les colonnes par le nom de la table pour éviter l\'ambiguïté.',
            'Il existe aussi LEFT JOIN (garde toutes les lignes de gauche), RIGHT JOIN et FULL JOIN selon le SGBD.',
          ],
          codeBlocks: [
            code('sql', 'SELECT e.nom, d.nom AS departement\nFROM employes e\nJOIN departements d ON e.departement_id = d.id;',
                e: 'Affiche chaque employé avec son département.'),
            code('sql', 'SELECT p.name, c.nom AS categorie\nFROM products p\nLEFT JOIN categories c ON p.category_id = c.id;',
                e: 'LEFT JOIN garde tous les produits, même sans catégorie.'),
          ],
          commonMistakes: [
            'Oublier la condition ON : un JOIN sans ON est un produit cartésien.',
            'Ne pas préfixer les colonnes qui existent dans les deux tables (colonne ambiguë).',
            'Choisir le mauvais type de JOIN (LEFT plutôt qu\'INNER).',
          ],
          exercises: [
            ExerciseItem(
                'Affiche le titre de chaque livre avec le nom de son auteur.',
                'SELECT l.titre, a.nom FROM livres l JOIN auteurs a ON l.auteur_id = a.id;',
                'On joint livres et auteurs sur la clé auteur_id.'),
          ],
          quiz: [
            QuizItem(
              type: QuizType.qcm,
              question: 'Que retourne INNER JOIN ?',
              options: [
                'Seulement les lignes qui correspondent dans les deux tables',
                'Toutes les lignes de la table de gauche',
                'Toutes les lignes des deux tables',
                'Aucune ligne'
              ],
              correctAnswer: 'Seulement les lignes qui correspondent dans les deux tables',
              explanation:
                  'INNER JOIN exclut les lignes sans correspondance dans l\'autre table.',
            ),
          ],
          xp: 35,
        ),
        Lesson(
          id: 'sql_group_having',
          trackId: 'sql',
          levelIndex: 2,
          title: 'GROUP BY et HAVING',
          objective:
              'Grouper des lignes pour calculer des agrégats par groupe.',
          content: [
            'GROUP BY regroupe les lignes qui ont la même valeur dans une colonne, et permet d\'appliquer des agrégats par groupe.',
            'Exemple : compter les produits par catégorie → GROUP BY category_id + COUNT(*).',
            'HAVING filtre les GROUPES (contrairement à WHERE qui filtre les lignes avant le regroupement).',
            'Ordre logique : WHERE (filtre lignes) → GROUP BY → HAVING (filtre groupes) → ORDER BY.',
          ],
          codeBlocks: [
            code('sql', 'SELECT category_id, COUNT(*) AS nb\nFROM products\nGROUP BY category_id;',
                e: 'Compte combien de produits par catégorie.'),
            code('sql', 'SELECT category_id, COUNT(*) AS nb\nFROM products\nGROUP BY category_id\nHAVING COUNT(*) > 3;',
                e: 'Ne garde que les catégories avec plus de 3 produits.'),
          ],
          commonMistakes: [
            'Utiliser WHERE pour filtrer des agrégats (il faut HAVING).',
            'Sélectionner une colonne non présente dans GROUP BY.',
          ],
          exercises: [
            ExerciseItem(
                'Affiche le nombre d\'employés par département.',
                'SELECT departement_id, COUNT(*) AS nb FROM employes GROUP BY departement_id;',
                'GROUP BY département puis COUNT.'),
          ],
          quiz: [
            QuizItem(
              type: QuizType.trueFalse,
              question: 'HAVING s\'applique aux groupes, WHERE aux lignes.',
              options: ['Vrai', 'Faux'],
              correctAnswer: 'Vrai',
              explanation: 'WHERE filtre avant le regroupement, HAVING filtre après.',
            ),
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
              'Utiliser des requêtes imbriquées pour résoudre des questions complexes.',
          content: [
            'Une sous-requête est une requête SELECT placée à l\'intérieur d\'une autre requête.',
            'On peut l\'utiliser dans WHERE, FROM ou SELECT. Elle peut retourner une valeur unique, une liste ou une table.',
            'Sous-requête scalaire (une seule valeur) : WHERE prix = (SELECT MAX(prix) FROM produits).',
            'Sous-requête de liste : WHERE id IN (SELECT ...).',
            'Sous-requête comme table dans FROM : SELECT * FROM (SELECT ...) AS t.',
          ],
          codeBlocks: [
            code('sql', 'SELECT name, price FROM products\nWHERE price = (SELECT MAX(price) FROM products);',
                e: 'Le produit le plus cher.'),
            code('sql', 'SELECT nom FROM employes\nWHERE id IN (SELECT departement_id FROM departements WHERE ville = \'Paris\');',
                e: 'Les employés des départements de Paris.'),
          ],
          commonMistakes: [
            'Sous-requête qui retourne plusieurs lignes là où on attend une seule valeur.',
            'Oublier l\'alias pour une sous-requête dans FROM.',
          ],
          exercises: [
            ExerciseItem(
                'Trouve le produit le plus cher.',
                'SELECT name, price FROM products WHERE price = (SELECT MAX(price) FROM products);',
                'La sous-requête calcule le max du prix.'),
          ],
          quiz: [
            QuizItem(
              type: QuizType.qcm,
              question: 'Où peut se placer une sous-requête dans une requête ?',
              options: ['Dans WHERE, FROM ou SELECT', 'Seulement dans SELECT', 'Après le point-virgule', 'Jamais'],
              correctAnswer: 'Dans WHERE, FROM ou SELECT',
              explanation:
                  'Les sous-requêtes peuvent apparaître dans plusieurs clauses selon le besoin.',
            ),
          ],
          xp: 40,
        ),
        Lesson(
          id: 'sql_transactions',
          trackId: 'sql',
          levelIndex: 3,
          title: 'Transactions et ACID',
          objective:
              'Comprendre les transactions pour garantir l\'intégrité des données.',
          content: [
            'Une transaction est un ensemble d\'opérations qui doivent réussir TOUTES ensemble, ou échouer TOUTES ensemble.',
            'ACID est l\'acronyme des propriétés : Atomicité, Cohérence, Isolation, Durabilité.',
            'Atomicité : tout ou rien. Cohérence : l\'état reste valide. Isolation : les transactions concurrentes ne se gênent pas. Durabilité : les données survivent aux pannes.',
            'BEGIN TRANSACTION démarre, COMMIT valide définitivement, ROLLBACK annule.',
          ],
          codeBlocks: [
            code('sql', 'BEGIN TRANSACTION;\nUPDATE comptes SET solde = solde - 100 WHERE id = 1;\nUPDATE comptes SET solde = solde + 100 WHERE id = 2;\nCOMMIT;',
                e: 'Virement bancaire : les deux opérations sont atomiques.'),
            code('sql', 'BEGIN;\nUPDATE comptes SET solde = solde - 100 WHERE id = 1;\nROLLBACK;',
                e: 'Annule la modification.'),
          ],
          commonMistakes: [
            'Oublier COMMIT et perdre ses modifications.',
            'Ne pas gérer les erreurs : une requête en échec doit déclencher un ROLLBACK.',
          ],
          exercises: [
            ExerciseItem(
                'Quelle instruction annule une transaction ?',
                'ROLLBACK.',
                'ROLLBACK replie toutes les modifications de la transaction.'),
          ],
          quiz: [
            QuizItem(
              type: QuizType.qcm,
              question: 'Que signifie le "A" de ACID ?',
              options: ['Atomicité', 'Adaptabilité', 'Arithmétique', 'Autonomie'],
              correctAnswer: 'Atomicité',
              explanation: 'Atomicité = les opérations réussissent ou échouent ensemble.',
            ),
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
              'Accélérer les recherches et comprendre le rôle des index.',
          content: [
            'Un index est une structure (comme un sommaire de livre) qui accélère les recherches sur une colonne.',
            'Sans index, la base lit toute la table (scan complet). Avec, elle saute directement aux données (B-tree, hash).',
            'CREATE INDEX crée un index. Les clés primaires et les colonnes UNIQUE ont déjà un index automatique.',
            'Trop d\'index ralentissent les INSERT/UPDATE/DELETE (il faut les maintenir). Il faut indexer les colonnes utilisées dans WHERE et JOIN.',
            'EXPLAIN QUERY PLAN (SQLite) ou EXPLAIN (PostgreSQL) montre comment la requête est exécutée : c\'est l\'outil de l\'optimisation.',
          ],
          codeBlocks: [
            code('sql', 'CREATE INDEX idx_products_price ON products(price);',
                e: 'Crée un index sur la colonne price.'),
            code('sql', 'EXPLAIN QUERY PLAN SELECT * FROM products WHERE price < 50;',
                e: 'Analyse le plan d\'exécution de la requête.'),
          ],
          commonMistakes: [
            'Indexer toutes les colonnes (inutile et coûteux).',
            'Chercher avec LIKE \'%mot\' qui ne peut pas utiliser l\'index classique.',
          ],
          exercises: [
            ExerciseItem(
                'Pourquoi un index accélère-t-il les recherches ?',
                'Il évite de scanner toute la table en pointant directement vers les données.',
                'Comme un sommaire, l\'index dirige vers les bonnes positions.'),
          ],
          quiz: [
            QuizItem(
              type: QuizType.trueFalse,
              question: 'Trop d\'index peuvent ralentir les insertions.',
              options: ['Vrai', 'Faux'],
              correctAnswer: 'Vrai',
              explanation:
                  'Chaque index doit être mis à jour à chaque écriture.',
            ),
            QuizItem(
              type: QuizType.findError,
              question: 'Que fait EXPLAIN ?',
              options: [
                'Montre le plan d\'exécution',
                'Exécute la requête 10 fois',
                'Supprime la table',
                'Renomme la table'
              ],
              correctAnswer: 'Montre le plan d\'exécution',
              explanation: 'EXPLAIN révèle comment le SGBD exécute la requête.',
            ),
          ],
          xp: 45,
        ),
        Lesson(
          id: 'sql_security',
          trackId: 'sql',
          levelIndex: 4,
          title: 'Sécurité et injections SQL',
          objective:
              'Protéger ses données et se prémunir contre les injections SQL.',
          content: [
            'Une injection SQL est une attaque où un utilisateur insère du code SQL malveillant dans une saisie, pour manipuler la base.',
            'Exemple vulnérable : SELECT * FROM user WHERE name = \'\$input\'. Si l\'utilisateur tape \' OR \'1\'=\'1, la condition est toujours vraie.',
            'La protection n°1 : les REQUÊTES PRÉPARÉES (paramètres liés). Le SGBD distingue le code et les données.',
            'Autres bonnes pratiques : le principe du moindre privilège (utilisateurs SQL limités), jamais de mots de passe en clair, validation des entrées, échappement.',
          ],
          codeBlocks: [
            code('sql', '-- Vulnérable\nSELECT * FROM users WHERE username = \'\$input\';',
                e: 'Si input = \' OR \'1\'=\'1 → retourne tout.'),
            code('sql', '-- Sûr (requête préparée)\nSELECT * FROM users WHERE username = ?;  -- ? = valeur liée',
                e: 'Le paramètre est traité comme des données, jamais comme du code.'),
          ],
          commonMistakes: [
            'Concaténer directement les variables dans le SQL.',
            'Utiliser des privilèges admin pour toutes les connexions.',
          ],
          exercises: [
            ExerciseItem(
                'Comment protège-t-on une requête contre l\'injection ?',
                'Avec des requêtes préparées (paramètres liés) au lieu de concaténer les entrées.',
                'Les requêtes préparées séparent le code SQL des données.'),
          ],
          quiz: [
            QuizItem(
              type: QuizType.qcm,
              question: 'Une injection SQL permet surtout de :',
              options: ['Exécuter du code non prévu sur la base', 'Accélérer les requêtes', 'Créer des index', 'Chiffrer les données'],
              correctAnswer: 'Exécuter du code non prévu sur la base',
              explanation:
                  'L\'attaquant injecte du SQL pour lire ou modifier des données non autorisées.',
            ),
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
              'Comprendre comment faire monter en charge une base, réplication et partitionnement.',
          content: [
            'La scalabilité est la capacité d\'un système à gérer une charge croissante (plus d\'utilisateurs, plus de données).',
            'Deux approches : monter en puissance (scale-up, un serveur plus gros) ou s\'étendre (scale-out, plusieurs serveurs).',
            'La réplication copie les données sur plusieurs serveurs : lecture répartie, haute disponibilité, sauvegarde.',
            'Le partitionnement (sharding) découpe les données en morceaux répartis sur plusieurs machines.',
            'On choisit entre cohérence forte et disponibilité selon l\'usage (théorème CAP).',
          ],
          codeBlocks: [
            code('sql', '-- Idée de réplication: répliquer la table lecture sur plusieurs nœuds\n-- SELECT peut aller sur un réplica en lecture seule\nSELECT * FROM produits;  -- réparti',
                e: 'Les lectures peuvent se répartir sur plusieurs réplicas.'),
          ],
          commonMistakes: [
            'Confondre réplication (copies) et partitionnement (découpage).',
            'Oublier que l\'écriture reste sur le maître dans une réplication maître-esclave.',
          ],
          exercises: [
            ExerciseItem(
                'Quelle différence entre réplication et sharding ?',
                'La réplication copie les données sur plusieurs serveurs ; le sharding découpe les données en morceaux distincts.',
                'Réplication = copies. Sharding = répartition par fragments.'),
          ],
          quiz: [
            QuizItem(
              type: QuizType.qcm,
              question: 'La réplication en lecture sur plusieurs serveurs améliore surtout :',
              options: ['Le débit de lecture', 'La vitesse d\'écriture seule', 'La taille disque', 'Le chiffrement'],
              correctAnswer: 'Le débit de lecture',
              explanation: 'Les lectures se répartissent entre réplicas, augmentant le débit.'),
          ],
          xp: 50,
        ),
      ];
}
