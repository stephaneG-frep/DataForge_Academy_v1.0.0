import '../models/table_models.dart';

/// The practice databases available in the Playground.
class PracticeData {
  PracticeData._();

  static const List<String> ids = ['boutique', 'bibliotheque', 'films', 'employes', 'ecole'];

  static PracticeDatabase database(String id) {
    switch (id) {
      case 'boutique':
        return _boutique;
      case 'bibliotheque':
        return _bibliotheque;
      case 'films':
        return _films;
      case 'employes':
        return _employes;
      case 'ecole':
        return _ecole;
      default:
        return _boutique;
    }
  }

  static Map<String, String> meta(String id) {
    switch (id) {
      case 'boutique':
        return {'name': 'Boutique', 'icon': 'shopping_cart',
          'desc': 'Produits, catégories et clients d\'une boutique e-commerce.'};
      case 'bibliotheque':
        return {'name': 'Bibliothèque', 'icon': 'menu_book',
          'desc': 'Livres, auteurs et emprunts d\'une bibliothèque.'};
      case 'films':
        return {'name': 'Films', 'icon': 'movie',
          'desc': 'Films, genres et acteurs.'};
      case 'employes':
        return {'name': 'Employés', 'icon': 'badge',
          'desc': 'Employés, départements et salaires d\'une entreprise.'};
      case 'ecole':
        return {'name': 'École', 'icon': 'school',
          'desc': 'Étudiants, cours et notes d\'une école.'};
      default:
        return {'name': id, 'icon': 'storage', 'desc': ''};
    }
  }

  // ---------------- EMPLOYES ----------------
  static final PracticeDatabase _employes = PracticeDatabase(
    id: 'employes',
    name: 'Employés',
    description: 'Employés, départements et salaires d\'une entreprise.',
    tables: [
      TableDef('departements', [
        ColumnDef('id', 'INTEGER PRIMARY KEY'),
        ColumnDef('nom', 'TEXT NOT NULL'),
        ColumnDef('ville', 'TEXT'),
      ], [
        RowDef([1, 'Ventes', 'Paris']),
        RowDef([2, 'Informatique', 'Lyon']),
        RowDef([3, 'Ressources humaines', 'Paris']),
        RowDef([4, 'Finance', 'Marseille']),
        RowDef([5, 'Marketing', 'Paris']),
        // No employee and no city yet: used by the LEFT JOIN / NULL lessons.
        RowDef([6, 'Juridique', null]),
      ]),
      TableDef('employes', [
        ColumnDef('id', 'INTEGER PRIMARY KEY'),
        ColumnDef('nom', 'TEXT NOT NULL'),
        ColumnDef('prenom', 'TEXT'),
        ColumnDef('departement_id', 'INTEGER'),
        ColumnDef('salaire', 'REAL'),
        ColumnDef('embauche', 'TEXT'),
        ColumnDef('manager_id', 'INTEGER'), // self-reference (NULL = no manager)
      ], [
        RowDef([1, 'Martin', 'Sophie', 2, 42000, '2018-03-12', 7]),
        RowDef([2, 'Bernard', 'Paul', 1, 35000, '2019-07-01', null]),
        RowDef([3, 'Dubois', 'Marie', 3, 38000, '2016-11-20', null]),
        RowDef([4, 'Petit', 'Jean', 4, 50000, '2015-02-10', null]),
        RowDef([5, 'Durand', 'Luc', 2, 45000, '2020-09-15', 7]),
        RowDef([6, 'Lefebvre', 'Emma', 1, 33000, '2021-05-03', 2]),
        RowDef([7, 'Moreau', 'Hugo', 2, 52000, '2014-01-08', null]),
        RowDef([8, 'Simon', 'Léa', 5, 31000, '2022-04-18', 12]),
        RowDef([9, 'Laurent', 'Tom', 4, 47000, '2017-08-25', 4]),
        RowDef([10, 'Garcia', 'Chloé', 3, 36000, '2023-02-14', 3]),
        RowDef([11, 'Roux', 'Nathan', 1, 29000, '2023-10-01', 2]),
        RowDef([12, 'Fournier', 'Manon', 5, 34000, '2019-06-30', null]),
      ]),
    ],
  );

  // ---------------- BOUTIQUE ----------------
  static final PracticeDatabase _boutique = PracticeDatabase(
    id: 'boutique',
    name: 'Boutique',
    description: 'Produits, catégories et clients d\'une boutique e-commerce.',
    tables: [
      TableDef('categories', [
        ColumnDef('id', 'INTEGER PRIMARY KEY'),
        ColumnDef('nom', 'TEXT NOT NULL'),
      ], [
        RowDef([1, 'Informatique']),
        RowDef([2, 'Audio']),
        RowDef([3, 'Accessoires']),
        RowDef([4, 'Jeux vidéo']),
      ]),
      TableDef('products', [
        ColumnDef('id', 'INTEGER PRIMARY KEY'),
        ColumnDef('name', 'TEXT NOT NULL'),
        ColumnDef('price', 'REAL'),
        ColumnDef('category_id', 'INTEGER'),
        ColumnDef('stock', 'INTEGER'),
      ], [
        RowDef([1, 'Clavier mécanique', 79.99, 1, 25]),
        RowDef([2, 'Souris sans fil', 29.99, 1, 60]),
        RowDef([3, 'Écran 27 pouces', 249.50, 1, 12]),
        RowDef([4, 'Casque Bluetooth', 59.90, 2, 40]),
        RowDef([5, 'Enceinte portable', 89.00, 2, 18]),
        RowDef([6, 'Micro-casque gaming', 45.25, 2, 30]),
        RowDef([7, 'Tapis de souris', 12.99, 3, 100]),
        RowDef([8, 'Support ordinateur', 34.99, 3, 55]),
        RowDef([9, 'Manette de jeu', 54.99, 4, 22]),
        RowDef([10, 'Jeu de stratégie', 19.80, 4, 35]),
        RowDef([11, 'Jeu de course', 24.95, 4, 28]),
        RowDef([12, 'Housse clavier', 8.50, 3, 0]),
      ]),
      TableDef('clients', [
        ColumnDef('id', 'INTEGER PRIMARY KEY'),
        ColumnDef('nom', 'TEXT'),
        ColumnDef('email', 'TEXT'),
        ColumnDef('ville', 'TEXT'),
      ], [
        RowDef([1, 'Alice Martin', 'alice@example.com', 'Paris']),
        RowDef([2, 'Bob Dupont', 'bob@example.com', 'Lyon']),
        RowDef([3, 'Chloé Bernard', 'chloe@example.com', 'Marseille']),
        RowDef([4, 'David Petit', 'david@example.com', 'Paris']),
        RowDef([5, 'Emma Durand', 'emma@example.com', 'Toulouse']),
        RowDef([6, 'Farid Haddad', null, 'Lille']), // no email: NULL lesson
      ]),
    ],
  );

  // ---------------- BIBLIOTHEQUE ----------------
  static final PracticeDatabase _bibliotheque = PracticeDatabase(
    id: 'bibliotheque',
    name: 'Bibliothèque',
    description: 'Livres, auteurs et emprunts d\'une bibliothèque.',
    tables: [
      TableDef('auteurs', [
        ColumnDef('id', 'INTEGER PRIMARY KEY'),
        ColumnDef('nom', 'TEXT NOT NULL'),
        ColumnDef('nationalite', 'TEXT'),
      ], [
        RowDef([1, 'Victor Hugo', 'Française']),
        RowDef([2, 'George Orwell', 'Britannique']),
        RowDef([3, 'J.K. Rowling', 'Britannique']),
        RowDef([4, 'Albert Camus', 'Française']),
        RowDef([5, 'Haruki Murakami', 'Japonaise']),
      ]),
      TableDef('livres', [
        ColumnDef('id', 'INTEGER PRIMARY KEY'),
        ColumnDef('titre', 'TEXT NOT NULL'),
        ColumnDef('auteur_id', 'INTEGER'),
        ColumnDef('annee', 'INTEGER'),
        ColumnDef('disponible', 'INTEGER'),
      ], [
        RowDef([1, 'Les Misérables', 1, 1862, 1]),
        RowDef([2, 'Notre-Dame de Paris', 1, 1831, 0]),
        RowDef([3, '1984', 2, 1949, 1]),
        RowDef([4, 'La Ferme des animaux', 2, 1945, 1]),
        RowDef([5, 'Harry Potter à l\'école des sorciers', 3, 1997, 0]),
        RowDef([6, 'L\'Étranger', 4, 1942, 1]),
        RowDef([7, 'La Peste', 4, 1947, 0]),
        RowDef([8, 'Kafka sur le rivage', 5, 2002, 1]),
      ]),
    ],
  );

  // ---------------- FILMS ----------------
  static final PracticeDatabase _films = PracticeDatabase(
    id: 'films',
    name: 'Films',
    description: 'Films, genres et acteurs.',
    tables: [
      TableDef('genres', [
        ColumnDef('id', 'INTEGER PRIMARY KEY'),
        ColumnDef('nom', 'TEXT NOT NULL'),
      ], [
        RowDef([1, 'Action']),
        RowDef([2, 'Comédie']),
        RowDef([3, 'Science-fiction']),
        RowDef([4, 'Drame']),
        RowDef([5, 'Animation']),
      ]),
      TableDef('films', [
        ColumnDef('id', 'INTEGER PRIMARY KEY'),
        ColumnDef('titre', 'TEXT NOT NULL'),
        ColumnDef('genre_id', 'INTEGER'),
        ColumnDef('annee', 'INTEGER'),
        ColumnDef('note', 'REAL'),
      ], [
        RowDef([1, 'Inception', 3, 2010, 8.8]),
        RowDef([2, 'The Dark Knight', 1, 2008, 9.0]),
        RowDef([3, 'Intouchables', 4, 2011, 8.6]),
        RowDef([4, 'Toy Story', 5, 1995, 8.3]),
        RowDef([5, 'Matrix', 3, 1999, 8.7]),
        RowDef([6, 'Superbad', 2, 2007, 7.6]),
        RowDef([7, 'Le Parrain', 1, 1972, 9.2]),
        RowDef([8, 'Wall-E', 5, 2008, 8.4]),
        RowDef([9, 'Interstellar', 3, 2014, 8.7]),
        RowDef([10, 'Coco', 5, 2017, 8.4]),
      ]),
    ],
  );

  // ---------------- ECOLE ----------------
  static final PracticeDatabase _ecole = PracticeDatabase(
    id: 'ecole',
    name: 'École',
    description: 'Étudiants, cours et notes d\'une école.',
    tables: [
      TableDef('etudiants', [
        ColumnDef('id', 'INTEGER PRIMARY KEY'),
        ColumnDef('nom', 'TEXT NOT NULL'),
        ColumnDef('promotion', 'TEXT'),
      ], [
        RowDef([1, 'Lucas', 'BTS SIO']),
        RowDef([2, 'Emma', 'BTS SIO']),
        RowDef([3, 'Hugo', 'Licence Info']),
        RowDef([4, 'Léa', 'Licence Info']),
        RowDef([5, 'Nathan', 'BTS SIO']),
        RowDef([6, 'Manon', 'Master Data']),
      ]),
      TableDef('cours', [
        ColumnDef('id', 'INTEGER PRIMARY KEY'),
        ColumnDef('titre', 'TEXT NOT NULL'),
        ColumnDef('prof', 'TEXT'),
      ], [
        RowDef([1, 'Bases de données', 'M. Durand']),
        RowDef([2, 'Programmation', 'Mme Martin']),
        RowDef([3, 'Réseaux', 'M. Petit']),
        RowDef([4, 'SQL avancé', 'M. Durand']),
      ]),
      TableDef('notes', [
        ColumnDef('etudiant_id', 'INTEGER'),
        ColumnDef('cours_id', 'INTEGER'),
        ColumnDef('note', 'REAL'),
      ], [
        RowDef([1, 1, 14.5]),
        RowDef([1, 2, 11.0]),
        RowDef([2, 1, 16.0]),
        RowDef([2, 3, 13.5]),
        RowDef([3, 4, 18.0]),
        RowDef([3, 1, 15.5]),
        RowDef([4, 2, 9.5]),
        RowDef([5, 1, 7.0]),
        RowDef([6, 4, 19.5]),
        RowDef([6, 2, 16.5]),
      ]),
    ],
  );
}
