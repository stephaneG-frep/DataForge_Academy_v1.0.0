/// Glossary entries: term -> clear definition.
class GlossaryData {
  GlossaryData._();

  static const Map<String, String> entries = {
    'Table': 'Ensemble structuré de données organisé en lignes et colonnes.',
    'Colonne': 'Un attribut (propriété) d\'une table, ex : nom, prix.',
    'Ligne / enregistrement': 'Un élément complet d\'une table, ex : un produit précis.',
    'Clé primaire (PK)': 'Colonne ou ensemble de colonnes qui identifie chaque ligne de façon unique.',
    'Clé étrangère (FK)': 'Colonne qui référence la clé primaire d\'une autre table pour créer une relation.',
    'Index': 'Structure qui accélère les recherches sur une colonne.',
    'Vue (VIEW)': 'Requête enregistrée présentée comme une table virtuelle.',
    'Requête (Query)': 'Demande d\'information envoyée à la base, le plus souvent en SELECT.',
    'SGBD / SGBDR': 'Logiciel qui gère une base ; SGBDR = relationnel.',
    'SQL': 'Structured Query Language : langage des bases relationnelles.',
    'NoSQL': 'Famille de bases non relationnelles (document, clé-valeur, graphe...).',
    'Transaction': 'Séquence d\'opérations exécutées comme un tout (ACID).',
    'ACID': 'Atomicité, Cohérence, Isolation, Durabilité : propriétés des transactions.',
    'COMMIT': 'Valide définitivement les modifications d\'une transaction.',
    'ROLLBACK': 'Annule les modifications d\'une transaction.',
    'Jointure (JOIN)': 'Opération qui associe des lignes de plusieurs tables.',
    'INNER JOIN': 'Jointure qui ne garde que les lignes correspondantes dans les deux tables.',
    'LEFT JOIN': 'Jointure qui garde toutes les lignes de la table gauche.',
    'GROUP BY': 'Regroupe les lignes par valeur pour appliquer des agrégats.',
    'HAVING': 'Filtre les groupes après un GROUP BY.',
    'Fonction d\'agrégation': 'COUNT, SUM, AVG, MIN, MAX : calcule sur plusieurs lignes.',
    'Sous-requête': 'Requête SELECT imbriquée dans une autre requête.',
    'Normalisation': 'Processus d\'organisation des données pour réduire la redondance.',
    'Forme normale (1NF/2NF/3NF)': 'Règles de normalisation garantissant une structure propre.',
    'Cardinalité': 'Nombre de relations entre entités : 1-1, 1-N, N-N.',
    'Table de liaison': 'Table intermédiaire pour résoudre une relation N-N.',
    'Injection SQL': 'Attaque qui insère du code SQL malveillant dans une saisie.',
    'Requête préparée': 'Requête dont les valeurs sont passées en paramètres liés, sécurisée.',
    'ORM': 'Mapping objet-relationnel : lie les tables à des objets du langage.',
    'API REST': 'Interface HTTP pour lire/créer/modifier/supprimer des ressources.',
    'Réplication': 'Copie des données sur plusieurs serveurs pour disponibilité et lecture.',
    'Sharding': 'Partitionnement horizontal des données sur plusieurs machines.',
    'Scalabilité': 'Capacité à gérer une charge croissante.',
    'Sauvegarde (backup)': 'Copie de sécurité des données pour restauration.',
    'Noeud (node)': 'Serveur d\'un cluster de bases de données.',
  };
}

/// Cheatsheet groups: category -> list of (snippet, description).
class CheatSheetData {
  CheatSheetData._();

  static const Map<String, List<List<String>>> categories = {
    'SELECT & filtrage': [
      ['SELECT * FROM table;', 'Toutes les colonnes, toutes les lignes.'],
      ['SELECT col1, col2 FROM table;', 'Colonnes choisies.'],
      ['SELECT * FROM t WHERE prix < 50;', 'Filtrer les lignes.'],
      ['SELECT * FROM t WHERE prix BETWEEN 10 AND 20;', 'Intervalle inclusif.'],
      ["SELECT * FROM t WHERE nom LIKE 'A%';", 'Commence par A.'],
      ["SELECT * FROM t WHERE ville IN ('Paris','Lyon');", 'Liste de valeurs.'],
    ],
    'Tri & distinct': [
      ['SELECT * FROM t ORDER BY prix;', 'Tri croissant (défaut).'],
      ['SELECT * FROM t ORDER BY prix DESC;', 'Tri décroissant.'],
      ['SELECT DISTINCT ville FROM t;', 'Valeurs uniques.'],
      ['SELECT * FROM t ORDER BY a DESC, b ASC;', 'Tri multi-colonnes.'],
    ],
    'Agrégats': [
      ['SELECT COUNT(*) FROM t;', 'Nombre de lignes.'],
      ['SELECT SUM(prix) FROM t;', 'Somme.'],
      ['SELECT AVG(prix) FROM t;', 'Moyenne.'],
      ['SELECT MIN(prix), MAX(prix) FROM t;', 'Extrêmes.'],
      ['SELECT GRP, COUNT(*) FROM t GROUP BY GRP;', 'Comptage par groupe.'],
      ['SELECT GRP, COUNT(*) n FROM t GROUP BY GRP HAVING COUNT(*) > 3;', 'Filtrer les groupes.'],
    ],
    'Jointures': [
      ['SELECT * FROM a JOIN b ON a.id = b.a_id;', 'INNER JOIN.'],
      ['SELECT * FROM a LEFT JOIN b ON a.id = b.a_id;', 'Garde toute la gauche.'],
      ['SELECT * FROM a, b WHERE a.id = b.a_id;', 'Jointure implicite.'],
    ],
    'INSERT / UPDATE / DELETE': [
      ["INSERT INTO t (col) VALUES ('v');", 'Insérer.'],
      ['UPDATE t SET col = 5 WHERE id = 1;', 'Modifier.'],
      ['DELETE FROM t WHERE id = 1;', 'Supprimer.'],
      ['DELETE FROM t;', 'Tout supprimer (attention !).'],
    ],
    'DDL': [
      ['CREATE TABLE t (id INTEGER PRIMARY KEY, nom TEXT);', 'Créer une table.'],
      ['ALTER TABLE t ADD COLUMN age INTEGER;', 'Ajouter une colonne.'],
      ['DROP TABLE t;', 'Supprimer une table.'],
      ['CREATE INDEX idx ON t(col);', 'Créer un index.'],
      ['CREATE VIEW v AS SELECT ...;', 'Créer une vue.'],
    ],
    'Transactions': [
      ['BEGIN; ...; COMMIT;', 'Valider une transaction.'],
      ['BEGIN; ...; ROLLBACK;', 'Annuler.'],
    ],
    'Limite par SGBD': [
      ['SELECT * FROM t LIMIT 10;', 'SQLite / MySQL / PostgreSQL.'],
      ['SELECT TOP 10 * FROM t;', 'SQL Server / T-SQL.'],
      ['SELECT * FROM t FETCH FIRST 10 ROWS ONLY;', 'Oracle / standard.'],
    ],
  };
}

/// Comparator: the same query expressed across SGBD with explanations.
class ComparatorData {
  ComparatorData._();

  static const Map<String, String> dbFlavors = {
    'SQL standard': 'Standard ANSI/ISO utilisable partout.',
    'SQLite': 'Embarqué, souple, AUCUN serveur.',
    'PostgreSQL': 'Robuste, riche en types, respectueux du standard.',
    'MySQL': 'Web, performant en lecture.',
    'SQL Server': 'Entreprise Microsoft, T-SQL.',
    'Oracle': 'Grandes entreprises, PL/SQL.',
  };

  static const String limitQuery = 'Récupérer les 10 premiers enregistrements :';
  static const Map<String, String> limitByDb = {
    'SQL standard': 'SELECT * FROM t FETCH FIRST 10 ROWS ONLY;',
    'SQLite': 'SELECT * FROM t LIMIT 10;',
    'PostgreSQL': 'SELECT * FROM t LIMIT 10;',
    'MySQL': 'SELECT * FROM t LIMIT 10;',
    'SQL Server': 'SELECT TOP 10 * FROM t;',
    'Oracle': 'SELECT * FROM t FETCH FIRST 10 ROWS ONLY;',
  };

  static const String autoIncrementQuery = 'Auto-incrémenter une clé primaire :';
  static const Map<String, String> autoIncrementByDb = {
    'SQL standard': 'GENERATED AS IDENTITY (conforme).',
    'SQLite': 'INTEGER PRIMARY KEY AUTOINCREMENT',
    'PostgreSQL': 'SERIAL  ou  GENERATED ALWAYS AS IDENTITY',
    'MySQL': 'INT AUTO_INCREMENT PRIMARY KEY',
    'SQL Server': 'INT IDENTITY(1,1) PRIMARY KEY',
    'Oracle': 'NUMBER GENERATED ALWAYS AS IDENTITY',
  };

  static const String stringsQuery = 'Comparer des chaînes (sensible à la casse) :';
  static const Map<String, String> stringsByDb = {
    'SQL standard': 'WHERE UPPER(nom) = \'DUPONT\'  (portable)',
    'SQLite': "WHERE nom = 'DUPONT'  (CI par défaut)",
    'PostgreSQL': "WHERE nom = 'DUPONT'  (sensible par défaut, citext pour ignorer)",
    'MySQL': "WHERE BINARY nom = 'DUPONT'  (CI par défaut)",
    'SQL Server': "WHERE nom COLLATE Latin1_General_CS_AS = 'Dupont'",
    'Oracle': "WHERE nom = 'Dupont'  (sensible) ou REGEXP_LIKE",
  };

  static const String concatQuery = 'Concaténer des chaînes :';
  static const Map<String, String> concatByDb = {
    'SQL standard': 'col1 || col2',
    'SQLite': '"a" || "b"',
    'PostgreSQL': "'a' || 'b'  ou CONCAT(a,b)",
    'MySQL': 'CONCAT(a, b)  (|| est un OU logique !)',
    'SQL Server': 'a + b',
    'Oracle': "'a' || 'b'",
  };

  static const String concatExplanation =
      'Voici le piège classique : le même opérateur || ou + a un sens différent selon le SGBD. '
      'MySQL utilise CONCAT() car || est réservé au OU logique. Connaître ces différences est essentiel '
      'pour écrire du SQL portable entre bases.';

  static const List<List<String>> rows = [
    [],
  ];
}
