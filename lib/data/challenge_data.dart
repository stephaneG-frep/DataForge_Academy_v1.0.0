import '../models/challenge_models.dart';

/// Programming challenges verified against the practice databases.
///
/// The checker compares the rows returned (see ChallengeChecker): each
/// description therefore states which columns to display, in which order.
/// When the mission requires a sort, `orderByColumn` names the column the
/// user's rows must be sorted on (ties in any order).
///
/// Progress is stored by challenge id: never rename an existing id.
class ChallengeData {
  ChallengeData._();

  static const List<Challenge> all = [
    // ======================= NIVEAU 1 =======================
    Challenge(
      id: 'ch_01',
      databaseId: 'employes',
      title: 'Classer les salaires',
      description:
          'Mission : affiche le nom, le prénom et le salaire des employés qui gagnent moins de 40 000 €, du plus haut salaire au plus bas.',
      hint:
          'Filtre avec WHERE salaire < 40000 puis trie avec ORDER BY ... DESC.',
      solution:
          'SELECT nom, prenom, salaire FROM employes WHERE salaire < 40000 ORDER BY salaire DESC;',
      explanation:
          'WHERE filtre les lignes, ORDER BY salaire DESC trie du plus grand au plus petit.',
      level: 1,
      xp: 30,
      tags: ['WHERE', 'ORDER BY'],
      orderByColumn: 'salaire',
      orderDescending: true,
    ),
    Challenge(
      id: 'ch_02',
      databaseId: 'boutique',
      title: 'Produits bon marché',
      description:
          'Mission : affiche le nom et le prix des produits qui coûtent moins de 50 €, du plus cher au moins cher.',
      hint: 'Filtre price < 50 puis ORDER BY price DESC.',
      solution:
          'SELECT name, price FROM products WHERE price < 50 ORDER BY price DESC;',
      explanation:
          'WHERE price < 50 garde les produits à moins de 50 €, DESC trie du plus cher en premier.',
      level: 1,
      xp: 30,
      tags: ['WHERE', 'ORDER BY', 'comparaison'],
      orderByColumn: 'price',
      orderDescending: true,
    ),
    Challenge(
      id: 'ch_09',
      databaseId: 'boutique',
      title: 'Clients sans e-mail',
      description:
          "Mission : affiche le nom et la ville des clients qui n'ont pas d'adresse e-mail renseignée.",
      hint: 'Une valeur absente se teste avec IS NULL, jamais avec = NULL.',
      solution: 'SELECT nom, ville FROM clients WHERE email IS NULL;',
      explanation:
          "email = NULL n'est jamais vrai : seule la condition IS NULL trouve les valeurs manquantes.",
      level: 1,
      xp: 30,
      tags: ['NULL', 'WHERE'],
    ),
    Challenge(
      id: 'ch_10',
      databaseId: 'boutique',
      title: 'Les jeux',
      description:
          'Mission : affiche le nom et le prix des produits dont le nom commence par « Jeu », du moins cher au plus cher.',
      hint: "LIKE 'Jeu%' : le % remplace n'importe quelle suite de caractères.",
      solution:
          "SELECT name, price FROM products WHERE name LIKE 'Jeu%' ORDER BY price ASC;",
      explanation:
          "LIKE 'Jeu%' garde les noms qui commencent par « Jeu », ORDER BY price trie par prix croissant.",
      level: 1,
      xp: 30,
      tags: ['LIKE', 'ORDER BY'],
      orderByColumn: 'price',
    ),
    Challenge(
      id: 'ch_11',
      databaseId: 'boutique',
      title: 'Villes desservies',
      description:
          'Mission : affiche la liste des villes où habitent les clients, chaque ville une seule fois.',
      hint: 'DISTINCT supprime les doublons du résultat.',
      solution: 'SELECT DISTINCT ville FROM clients;',
      explanation:
          'SELECT DISTINCT ville renvoie chaque valeur une seule fois. GROUP BY ville donnerait le même résultat.',
      level: 1,
      xp: 30,
      tags: ['DISTINCT'],
    ),

    // ======================= NIVEAU 2 =======================
    Challenge(
      id: 'ch_03',
      databaseId: 'boutique',
      title: 'Produits par catégorie',
      description:
          "Mission : pour chaque catégorie, affiche l'identifiant de la catégorie (category_id) et le nombre de produits qu'elle contient.",
      hint: 'Utilise GROUP BY category_id et COUNT(*).',
      solution:
          'SELECT category_id, COUNT(*) AS nb FROM products GROUP BY category_id;',
      explanation:
          'GROUP BY regroupe par catégorie, COUNT(*) compte les produits de chaque groupe.',
      level: 2,
      xp: 40,
      tags: ['GROUP BY', 'COUNT'],
    ),
    Challenge(
      id: 'ch_08',
      databaseId: 'films',
      title: 'Films postérieurs à 2000',
      description:
          "Mission : affiche le titre, l'année et la note des films sortis après l'an 2000, du plus récent au plus ancien.",
      hint: 'WHERE annee > 2000 puis ORDER BY annee DESC.',
      solution:
          'SELECT titre, annee, note FROM films WHERE annee > 2000 ORDER BY annee DESC;',
      explanation: 'Filtrage par année puis tri décroissant des années.',
      level: 2,
      xp: 35,
      tags: ['WHERE', 'ORDER BY'],
      orderByColumn: 'annee',
      orderDescending: true,
    ),
    Challenge(
      id: 'ch_12',
      databaseId: 'films',
      title: 'Top 3 des films',
      description:
          'Mission : affiche le titre et la note des 3 films les mieux notés, du mieux noté au moins bien noté.',
      hint: 'Trie par note décroissante, puis garde 3 lignes avec LIMIT.',
      solution: 'SELECT titre, note FROM films ORDER BY note DESC LIMIT 3;',
      explanation:
          "LIMIT n'a de sens qu'après un ORDER BY : sinon les 3 lignes renvoyées sont quelconques.",
      level: 2,
      xp: 35,
      tags: ['ORDER BY', 'LIMIT'],
      orderByColumn: 'note',
      orderDescending: true,
    ),
    Challenge(
      id: 'ch_13',
      databaseId: 'employes',
      title: 'Salaires intermédiaires',
      description:
          'Mission : affiche le nom, le prénom et le salaire des employés des départements 1, 3 ou 5 qui gagnent entre 30 000 et 36 000 €, bornes comprises.',
      hint: 'departement_id IN (1, 3, 5) AND salaire BETWEEN … AND …',
      solution:
          'SELECT nom, prenom, salaire FROM employes WHERE departement_id IN (1, 3, 5) AND salaire BETWEEN 30000 AND 36000;',
      explanation:
          'IN remplace plusieurs OR, BETWEEN inclut les deux bornes.',
      level: 2,
      xp: 40,
      tags: ['IN', 'BETWEEN'],
    ),
    Challenge(
      id: 'ch_14',
      databaseId: 'employes',
      title: 'Le département oublié',
      description:
          "Mission : affiche le nom des départements qui n'ont aucun employé.",
      hint:
          'LEFT JOIN des départements vers les employés, puis garde les lignes où l\'employé est NULL.',
      solution:
          'SELECT d.nom FROM departements d LEFT JOIN employes e ON e.departement_id = d.id WHERE e.id IS NULL;',
      explanation:
          'LEFT JOIN garde tous les départements ; ceux sans correspondance ont des colonnes employé à NULL.',
      level: 2,
      xp: 40,
      tags: ['LEFT JOIN', 'NULL'],
    ),
    Challenge(
      id: 'ch_18',
      databaseId: 'employes',
      title: 'Les recrues de 2023',
      description:
          "Mission : affiche le nom, le prénom et la date d'embauche des employés embauchés en 2023.",
      hint:
          "Les dates sont au format AAAA-MM-JJ : strftime('%Y', embauche) extrait l'année.",
      solution:
          "SELECT nom, prenom, embauche FROM employes WHERE strftime('%Y', embauche) = '2023';",
      explanation:
          "strftime('%Y') extrait l'année sous forme de texte. BETWEEN '2023-01-01' AND '2023-12-31' fonctionne aussi.",
      level: 2,
      xp: 40,
      tags: ['dates', 'fonctions'],
    ),

    // ======================= NIVEAU 3 =======================
    Challenge(
      id: 'ch_04',
      databaseId: 'employes',
      title: 'Employés et départements',
      description:
          'Mission : affiche le nom de chaque employé suivi du nom de son département.',
      hint:
          'Fais une jointure entre employes et departements via departement_id.',
      solution:
          'SELECT e.nom, d.nom AS departement FROM employes e JOIN departements d ON e.departement_id = d.id;',
      explanation:
          'INNER JOIN relie les deux tables sur la clé étrangère departement_id = id.',
      level: 3,
      xp: 50,
      tags: ['JOIN', 'relations'],
    ),
    Challenge(
      id: 'ch_05',
      databaseId: 'bibliotheque',
      title: 'Auteurs et leurs livres',
      description:
          "Mission : affiche le titre de chaque livre disponible suivi du nom de son auteur.",
      hint:
          'JOIN livres et auteurs sur auteur_id, puis filtre disponible = 1.',
      solution:
          'SELECT l.titre, a.nom FROM livres l JOIN auteurs a ON l.auteur_id = a.id WHERE l.disponible = 1;',
      explanation:
          'La jointure associe livre et auteur, WHERE filtre les livres disponibles.',
      level: 3,
      xp: 50,
      tags: ['JOIN', 'WHERE'],
    ),
    Challenge(
      id: 'ch_06',
      databaseId: 'ecole',
      title: 'Moyenne par cours',
      description:
          "Mission : affiche l'identifiant de chaque cours (cours_id) et sa note moyenne, uniquement pour les cours dont la moyenne dépasse 10.",
      hint:
          'GROUP BY cours_id + AVG(note), puis filtre le groupe avec HAVING.',
      solution:
          'SELECT cours_id, AVG(note) AS moyenne FROM notes GROUP BY cours_id HAVING AVG(note) > 10;',
      explanation:
          'HAVING filtre les groupes (les cours) après le calcul de la moyenne.',
      level: 3,
      xp: 55,
      tags: ['GROUP BY', 'HAVING', 'AVG'],
    ),
    Challenge(
      id: 'ch_15',
      databaseId: 'employes',
      title: 'Qui est mon manager ?',
      description:
          'Mission : affiche le nom de chaque employé suivi du nom de son manager, pour les employés qui ont un manager.',
      hint:
          'Auto-jointure : employes e JOIN employes m ON e.manager_id = m.id.',
      solution:
          'SELECT e.nom, m.nom AS manager FROM employes e JOIN employes m ON e.manager_id = m.id;',
      explanation:
          'La même table apparaît deux fois avec deux alias : e pour l\'employé, m pour son manager.',
      level: 3,
      xp: 50,
      tags: ['auto-jointure', 'JOIN'],
    ),
    Challenge(
      id: 'ch_16',
      databaseId: 'boutique',
      title: 'Gammes de prix',
      description:
          "Mission : affiche le nom de chaque produit et sa gamme : « petit prix » en dessous de 20 €, « moyen » de 20 € à moins de 60 €, « premium » à partir de 60 €.",
      hint:
          "CASE WHEN price < 20 THEN 'petit prix' WHEN … THEN … ELSE … END",
      solution:
          "SELECT name, CASE WHEN price < 20 THEN 'petit prix' WHEN price < 60 THEN 'moyen' ELSE 'premium' END AS gamme FROM products;",
      explanation:
          'Les conditions de CASE sont testées dans l\'ordre : la première vraie l\'emporte.',
      level: 3,
      xp: 50,
      tags: ['CASE'],
    ),
    Challenge(
      id: 'ch_17',
      databaseId: 'bibliotheque',
      title: 'Auteurs prolifiques',
      description:
          "Mission : affiche le nom de chaque auteur et son nombre de livres, uniquement pour les auteurs qui ont au moins 2 livres.",
      hint:
          'Joins auteurs et livres, GROUP BY auteur, puis HAVING COUNT(*) >= 2.',
      solution:
          'SELECT a.nom, COUNT(*) AS nb_livres FROM auteurs a JOIN livres l ON l.auteur_id = a.id GROUP BY a.id, a.nom HAVING COUNT(*) >= 2;',
      explanation:
          'La jointure apporte le nom, GROUP BY compte par auteur, HAVING filtre les groupes.',
      level: 3,
      xp: 55,
      tags: ['JOIN', 'GROUP BY', 'HAVING'],
    ),
    Challenge(
      id: 'ch_25',
      databaseId: 'boutique',
      title: 'Annuaire',
      description:
          'Mission : affiche dans une seule colonne les noms des clients puis les noms des catégories.',
      hint: 'Deux SELECT d\'une colonne chacun, réunis par UNION.',
      solution: 'SELECT nom FROM clients UNION SELECT nom FROM categories;',
      explanation:
          'UNION empile les résultats de deux requêtes qui ont le même nombre de colonnes.',
      level: 3,
      xp: 45,
      tags: ['UNION'],
    ),

    // ======================= NIVEAU 4 =======================
    Challenge(
      id: 'ch_07',
      databaseId: 'boutique',
      title: 'Le produit le plus cher',
      description:
          'Mission : affiche le nom et le prix du produit le plus cher de la boutique.',
      hint: 'Utilise une sous-requête avec MAX(price).',
      solution:
          'SELECT name, price FROM products WHERE price = (SELECT MAX(price) FROM products);',
      explanation:
          'La sous-requête calcule le prix maximum, la requête principale filtre dessus.',
      level: 4,
      xp: 60,
      tags: ['sous-requête', 'MAX'],
    ),
    Challenge(
      id: 'ch_19',
      databaseId: 'ecole',
      title: 'Au-dessus de la moyenne',
      description:
          "Mission : pour le cours 4 (SQL avancé), affiche le nom des étudiants et leur note, uniquement pour ceux dont la note dépasse la moyenne de ce cours.",
      hint:
          'Compare la note à la moyenne de CE cours : (SELECT AVG(note) FROM notes WHERE cours_id = 4).',
      solution:
          'SELECT e.nom, n.note FROM notes n JOIN etudiants e ON e.id = n.etudiant_id WHERE n.cours_id = 4 AND n.note > (SELECT AVG(note) FROM notes WHERE cours_id = 4);',
      explanation:
          'La sous-requête calcule la moyenne du cours 4 (18,75) ; la requête principale garde les notes au-dessus. Attention : la moyenne de toutes les notes (14,1) donnerait un autre résultat.',
      level: 4,
      xp: 60,
      tags: ['sous-requête', 'JOIN', 'AVG'],
    ),
    Challenge(
      id: 'ch_20',
      databaseId: 'bibliotheque',
      title: 'Livres empruntés',
      description:
          'Mission : affiche le nom des auteurs dont au moins un livre est actuellement emprunté (non disponible).',
      hint:
          'WHERE EXISTS (SELECT 1 FROM livres l WHERE l.auteur_id = a.id AND l.disponible = 0)',
      solution:
          'SELECT a.nom FROM auteurs a WHERE EXISTS (SELECT 1 FROM livres l WHERE l.auteur_id = a.id AND l.disponible = 0);',
      explanation:
          "EXISTS teste pour chaque auteur s'il existe au moins un livre emprunté. Une jointure avec DISTINCT marche aussi.",
      level: 4,
      xp: 60,
      tags: ['EXISTS', 'sous-requête corrélée'],
    ),
    Challenge(
      id: 'ch_21',
      databaseId: 'employes',
      title: 'Mieux payés que leur département',
      description:
          'Mission : affiche le nom et le salaire des employés payés plus que la moyenne de leur propre département.',
      hint:
          'Sous-requête corrélée : (SELECT AVG(salaire) FROM employes WHERE departement_id = e.departement_id).',
      solution:
          'SELECT e.nom, e.salaire FROM employes e WHERE e.salaire > (SELECT AVG(salaire) FROM employes WHERE departement_id = e.departement_id);',
      explanation:
          'La sous-requête est recalculée pour chaque employé, avec la moyenne de SON département. Une CTE des moyennes par département marche aussi.',
      level: 4,
      xp: 65,
      tags: ['sous-requête corrélée', 'AVG'],
    ),

    // ======================= NIVEAU 5 =======================
    Challenge(
      id: 'ch_22',
      databaseId: 'employes',
      title: 'Le mieux payé de chaque département',
      description:
          "Mission : pour chaque département, affiche l'identifiant du département (departement_id), le nom et le salaire de l'employé le mieux payé.",
      hint:
          'Classe les employés avec RANK() OVER (PARTITION BY departement_id ORDER BY salaire DESC) dans une CTE, puis garde le rang 1.',
      solution:
          'WITH r AS (SELECT departement_id, nom, salaire, RANK() OVER (PARTITION BY departement_id ORDER BY salaire DESC) AS rang FROM employes) SELECT departement_id, nom, salaire FROM r WHERE rang = 1;',
      explanation:
          'Le fenêtrage classe dans chaque département sans fusionner les lignes ; le filtre sur le rang se fait en dehors, dans la requête principale.',
      level: 5,
      xp: 70,
      tags: ['fenêtrage', 'CTE', 'RANK'],
    ),
    Challenge(
      id: 'ch_23',
      databaseId: 'ecole',
      title: 'Bulletin de notes',
      description:
          "Mission : affiche le nom de chaque étudiant, sa moyenne arrondie à une décimale (moyenne) et son rang (rang, 1 = meilleure moyenne), du premier au dernier.",
      hint:
          'ROUND(AVG(note), 1) et RANK() OVER (ORDER BY AVG(note) DESC) dans la même requête groupée par étudiant.',
      solution:
          'SELECT e.nom, ROUND(AVG(n.note), 1) AS moyenne, RANK() OVER (ORDER BY AVG(n.note) DESC) AS rang FROM etudiants e JOIN notes n ON n.etudiant_id = e.id GROUP BY e.id, e.nom ORDER BY rang;',
      explanation:
          'Une fonction de fenêtrage peut s\'appliquer au résultat d\'un GROUP BY : ici, elle classe les moyennes.',
      level: 5,
      xp: 70,
      tags: ['fenêtrage', 'RANK', 'GROUP BY'],
      orderByColumn: 'rang',
    ),

    // ======================= NIVEAU 6 =======================
    Challenge(
      id: 'ch_24',
      databaseId: 'employes',
      title: 'Masse salariale cumulée',
      description:
          "Mission : affiche le nom, la date d'embauche (embauche) et la masse salariale cumulée (cumul : somme des salaires de tous les employés embauchés jusqu'à cette date incluse), par ordre d'embauche.",
      hint: 'SUM(salaire) OVER (ORDER BY embauche) calcule un total courant.',
      solution:
          'SELECT nom, embauche, SUM(salaire) OVER (ORDER BY embauche) AS cumul FROM employes ORDER BY embauche;',
      explanation:
          'Avec un ORDER BY dans la fenêtre, SUM devient un cumul ligne après ligne. Une sous-requête corrélée donne le même résultat, en moins efficace.',
      level: 6,
      xp: 80,
      tags: ['fenêtrage', 'SUM', 'cumul'],
      orderByColumn: 'embauche',
    ),
  ];
}
