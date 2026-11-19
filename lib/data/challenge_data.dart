import '../models/challenge_models.dart';

/// Programming challenges verified against the practice databases.
class ChallengeData {
  ChallengeData._();

  static const List<Challenge> all = [
    Challenge(
      id: 'ch_01',
      databaseId: 'employes',
      title: 'Classer les salaires',
      description:
          'Mission : affiche les employés ayant un salaire inférieur à 40000, triés du plus haut salaire au plus bas.',
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
          'Mission : affiche les produits coûtant moins de 50 €, triés du plus cher au moins cher.',
      hint: 'Filtre price < 50 puis ORDER BY price DESC.',
      solution:
          'SELECT name, price FROM products WHERE price < 50 ORDER BY price DESC;',
      explanation:
          'WHERE price < 50 garde les produits à moins de 50, DESC trie du plus cher en premier.',
      level: 1,
      xp: 30,
      tags: ['WHERE', 'ORDER BY', 'comparaison'],
      orderByColumn: 'price',
      orderDescending: true,
    ),
    Challenge(
      id: 'ch_03',
      databaseId: 'boutique',
      title: 'Produits par catégorie',
      description:
          'Mission : compte combien de produits appartiennent à chaque catégorie.',
      hint: 'Utilise GROUP BY category_id et COUNT(*).',
      solution:
          'SELECT category_id, COUNT(*) AS nb FROM products GROUP BY category_id;',
      explanation:
          'GROUP BY regroupe par catégorie, COUNT(* ) compte chaque groupe.',
      level: 2,
      xp: 40,
      tags: ['GROUP BY', 'COUNT'],
    ),
    Challenge(
      id: 'ch_04',
      databaseId: 'employes',
      title: 'Employés et départements',
      description:
          'Mission : affiche le nom de chaque employé avec le nom de son département.',
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
          'Mission : affiche chaque titre de livre avec le nom de son auteur, pour les livres disponibles.',
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
          'Mission : calcule la note moyenne par cours, uniquement pour les cours avec une moyenne supérieure à 10.',
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
      id: 'ch_07',
      databaseId: 'boutique',
      title: 'Le produit le plus cher',
      description:
          'Mission : trouve le produit le plus cher de la boutique.',
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
      id: 'ch_08',
      databaseId: 'films',
      title: 'Films postérieurs à 2000',
      description:
          'Mission : affiche les films sortis après l\'an 2000, avec leur note, du plus récent au plus ancien.',
      hint: 'WHERE annee > 2000 puis ORDER BY annee DESC.',
      solution:
          'SELECT titre, annee, note FROM films WHERE annee > 2000 ORDER BY annee DESC;',
      explanation:
          'Filtrage par année puis tri décroissant des années.',
      level: 2,
      xp: 35,
      tags: ['WHERE', 'ORDER BY'],
      orderByColumn: 'annee',
      orderDescending: true,
    ),
  ];
}
