import '../models/lesson_models.dart';

/// Standalone quiz bank covering all question types.
class QuizBank {
  QuizBank._();

  static const List<QuizItem> all = [
    // ---- QCM ----
    QuizItem(
      type: QuizType.qcm,
      question: 'Quelle commande SQL sert à lire des données ?',
      options: ['SELECT', 'DELETE', 'UPDATE', 'INSERT'],
      correctAnswer: 'SELECT',
      explanation: 'SELECT est l\'instruction de lecture d\'une table.',
    ),
    QuizItem(
      type: QuizType.qcm,
      question: 'Quel opérateur trie les résultats du plus grand au plus petit ?',
      options: ['ORDER BY ... DESC', 'ORDER BY ... ASC', 'SORT DOWN', 'GROUP BY ... DESC'],
      correctAnswer: 'ORDER BY ... DESC',
      explanation: 'DESC (descendant) trie du plus grand au plus petit.',
    ),
    QuizItem(
      type: QuizType.qcm,
      question: 'La clé primaire d\'une table doit être :',
      options: ['Unique et non nulle', 'Toujours numérique', 'Une date', 'Cachée'],
      correctAnswer: 'Unique et non nulle',
      explanation: 'La clé primaire identifie chaque ligne de façon unique.',
    ),
    QuizItem(
      type: QuizType.qcm,
      question: 'INNER JOIN entre deux tables retourne :',
      options: [
        'Les lignes qui correspondent dans les deux tables',
        'Toutes les lignes de gauche',
        'Une seule ligne',
        'Aucune ligne'
      ],
      correctAnswer: 'Les lignes qui correspondent dans les deux tables',
      explanation: 'INNER JOIN ne garde que les correspondances.',
    ),

    // ---- Vrai / Faux ----
    QuizItem(
      type: QuizType.trueFalse,
      question: 'SELECT modifie les données d\'une table.',
      options: ['Faux', 'Vrai'],
      correctAnswer: 'Faux',
      explanation: 'SELECT est une opération de lecture, elle ne modifie rien.',
    ),
    QuizItem(
      type: QuizType.trueFalse,
      question: 'HAVING filtre les groupes, WHERE filtre les lignes.',
      options: ['Vrai', 'Faux'],
      correctAnswer: 'Vrai',
      explanation: 'WHERE avant le regroupement, HAVING après.',
    ),
    QuizItem(
      type: QuizType.trueFalse,
      question: 'Une clé étrangère peut référencer une ligne inexistante.',
      options: ['Faux', 'Vrai'],
      correctAnswer: 'Faux',
      explanation: 'L\'intégrité référentielle l\'interdit.',
    ),

    // ---- Compléter une requête ----
    QuizItem(
      type: QuizType.completeQuery,
      question: 'Complète : compter tous les produits',
      options: ['SELECT COUNT(*) FROM produits;', 'SELECT products FROM count;', 'COUNT * products;', 'SELECT * COUNT products;'],
      correctAnswer: 'SELECT COUNT(*) FROM produits;',
      explanation: 'COUNT(*) compte toutes les lignes de la table produits.',
    ),
    QuizItem(
      type: QuizType.completeQuery,
      question: 'Complète pour filtrer les produits à moins de 30',
      options: [
        'SELECT * FROM produits WHERE prix < 30;',
        'SELECT * FROM produits HAVING prix < 30;',
        'SELECT * FROM produits LIMIT 30;',
        'SELECT * FROM produits WHERE prix = 30;'
      ],
      correctAnswer: 'SELECT * FROM produits WHERE prix < 30;',
      explanation: 'WHERE filtre les lignes selon la condition prix < 30.',
    ),

    // ---- Trouver une erreur ----
    QuizItem(
      type: QuizType.findError,
      question: 'Trouve l\'erreur : SELECT name FROM products WHERE;',
      options: ['La condition WHERE est incomplète', 'name n\'existe pas', 'Il faut LIMIT', 'products est faux'],
      correctAnswer: 'La condition WHERE est incomplète',
      explanation: 'WHERE doit être suivi d\'une condition, ex : WHERE prix < 50.',
    ),
    QuizItem(
      type: QuizType.findError,
      question: 'Trouve l\'erreur : SELECT * FROM films ORDRE BY annee;',
      options: ['"ORDRE" est mal orthographié (ORDER)', 'films n\'existe pas', 'Il manque le WHERE', 'annee est inconnu'],
      correctAnswer: '"ORDRE" est mal orthographié (ORDER)',
      explanation: 'Le mot-clé correct est ORDER BY, pas ORDRE BY.',
    ),

    // ---- Prédire un résultat ----
    QuizItem(
      type: QuizType.predictResult,
      question: 'SELECT COUNT(*) FROM produits WHERE prix > 1000000;',
      options: ['0', '1', '10', 'Une erreur'],
      correctAnswer: '0',
      explanation: 'Aucun produit n\'est si cher, donc COUNT renvoie 0.',
    ),
    QuizItem(
      type: QuizType.predictResult,
      question: 'SELECT 5 + 3; (en SQLite)',
      options: ['8', '53', '5+3', 'Erreur'],
      correctAnswer: '8',
      explanation: 'SQL évalue l\'expression arithmétique 5 + 3 = 8.',
    ),

    // ---- Écrire une requête ----
    QuizItem(
      type: QuizType.writeQuery,
      question: 'Écris la requête qui sélectionne toutes les colonnes de la table clients.',
      options: ['SELECT * FROM clients;'],
      correctAnswer: 'SELECT * FROM clients;',
      explanation: 'L\'astérisque sélectionne toutes les colonnes.',
    ),
  ];
}
