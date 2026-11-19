import 'package:flutter/material.dart' show Icons;

import '../models/project_models.dart';

/// Practical projects.
class ProjectData {
  ProjectData._();

  static const List<Project> all = [
    Project(
      id: 'proj_bibliotheque',
      title: 'Bibliothèque',
      icon: Icons.menu_book,
      colorName: 'cyan',
      summary:
          'Gère des livres, auteurs et emprunts avec un schéma relationnel 1-N.',
      spec:
          'Objectif : modéliser une bibliothèque. Chaque livre appartient à un auteur. Un livre peut être emprunté. On veut suivre les disponibilités et retrouver les livres d\'un auteur.',
      tables: [
        PillarTable('auteurs', 'CREATE TABLE auteurs (\n  id INTEGER PRIMARY KEY,\n  nom TEXT NOT NULL\n);', 'Chaque écrivain.'),
        PillarTable('livres', 'CREATE TABLE livres (\n  id INTEGER PRIMARY KEY,\n  titre TEXT NOT NULL,\n  auteur_id INTEGER,\n  annee INTEGER,\n  disponible INTEGER DEFAULT 1,\n  FOREIGN KEY (auteur_id) REFERENCES auteurs(id)\n);', 'Chaque ouvrage, relié à son auteur.'),
      ],
      relations:
          'Relation 1-N : un auteur possède plusieurs livres. La table "livres" porte la clé étrangère auteur_id.',
      sampleData: 'John Ronald Reuel Tolkien (2 livres), Agatha Christie (3 livres), etc.',
      tasks: [
        ProjectTask(
          id: 'pb1',
          title: 'Créer le schéma',
          description:
              'Écris le CREATE TABLE pour les tables auteurs et livres avec la clé étrangère.',
          difficulty: 'Facile',
          solution:
              'Créer table auteurs(id PK, nom), table livres(id PK, titre, auteur_id FK, annee, disponible).',
          solutionSql: 'CREATE TABLE auteurs (id INTEGER PRIMARY KEY, nom TEXT NOT NULL);\nCREATE TABLE livres (id INTEGER PRIMARY KEY, titre TEXT NOT NULL, auteur_id INTEGER, annee INTEGER, disponible INTEGER DEFAULT 1, FOREIGN KEY (auteur_id) REFERENCES auteurs(id));',
          explanation:
              'La clé étrangère auteur_id référence auteurs.id pour relier les tables.',
        ),
        ProjectTask(
          id: 'pb2',
          title: 'Afficher chaque livre avec son auteur',
          description: 'Écris la requête qui associe titre et nom de l\'auteur.',
          difficulty: 'Moyen',
          solution: 'SELECT l.titre, a.nom FROM livres l JOIN auteurs a ON l.auteur_id = a.id;',
          solutionSql: 'SELECT l.titre, a.nom FROM livres l JOIN auteurs a ON l.auteur_id = a.id;',
          explanation: 'La jointure INNER JOIN relie les deux tables sur la clé étrangère.',
        ),
        ProjectTask(
          id: 'pb3',
          title: 'Nombre de livres par auteur',
          description:
              'Compte le nombre de livres écrits par chaque auteur.',
          difficulty: 'Moyen',
          solution:
              'SELECT a.nom, COUNT(l.id) AS nb FROM auteurs a LEFT JOIN livres l ON l.auteur_id = a.id GROUP BY a.id, a.nom;',
          solutionSql: 'SELECT a.nom, COUNT(l.id) AS nb FROM auteurs a LEFT JOIN livres l ON l.auteur_id = a.id GROUP BY a.id, a.nom;',
          explanation:
              'GROUP BY par auteur et COUNT. LEFT JOIN garde les auteurs sans livre.',
        ),
      ],
      estimatedXp: 120,
    ),
    Project(
      id: 'proj_recettes',
      title: 'Livres de recettes',
      icon: Icons.restaurant_menu,
      colorName: 'orange',
      summary:
          'Améliore ton modèle de données avec des relations N-N.',
      spec:
          'Modéliser un livre de cuisine : des recettes, des ingrédients, et la relation N-N entre les deux (une recette contient plusieurs ingrédients, un ingrédient apparaît dans plusieurs recettes).',
      tables: [
        PillarTable('recettes', 'CREATE TABLE recettes (\n  id INTEGER PRIMARY KEY,\n  titre TEXT NOT NULL,\n  duree INTEGER\n);', 'Chaque plat.'),
        PillarTable('ingredients', 'CREATE TABLE ingredients (\n  id INTEGER PRIMARY KEY,\n  nom TEXT NOT NULL\n);', 'Chaque ingrédient.'),
        PillarTable('recette_ingredient', 'CREATE TABLE recette_ingredient (\n  recette_id INTEGER,\n  ingredient_id INTEGER,\n  quantite TEXT,\n  PRIMARY KEY (recette_id, ingredient_id),\n  FOREIGN KEY (recette_id) REFERENCES recettes(id),\n  FOREIGN KEY (ingredient_id) REFERENCES ingredients(id)\n);', 'Table de liaison N-N.'),
      ],
      relations:
          'Relation N-N entre recettes et ingrédients, résolue par une table de liaison.',
      sampleData: 'Recettes (Crêpes, Pizza), ingrédients (Farine, œufs, fromage...).',
      tasks: [
        ProjectTask(
          id: 'pr1',
          title: 'Créer la table de liaison',
          description:
              'Crée la table recette_ingredient qui relie recettes et ingredients.',
          difficulty: 'Moyen',
          solution:
              'Créer une table de liaison avec les deux clés étrangères et une clé primaire composite.',
          solutionSql: 'CREATE TABLE recette_ingredient (recette_id INTEGER, ingredient_id INTEGER, quantite TEXT, PRIMARY KEY (recette_id, ingredient_id), FOREIGN KEY (recette_id) REFERENCES recettes(id), FOREIGN KEY (ingredient_id) REFERENCES ingredients(id));',
          explanation:
              'La clé primaire composite (recette_id, ingredient_id) évite les doublons.',
        ),
        ProjectTask(
          id: 'pr2',
          title: 'Ingrédients d\'une recette',
          description:
              'Affiche les ingrédients de la recette "Crêpes" avec leur quantité.',
          difficulty: 'Difficile',
          solution:
              'SELECT i.nom, ri.quantite FROM recette_ingredient ri JOIN ingredients i ON i.id = ri.ingredient_id JOIN recettes r ON r.id = ri.recette_id WHERE r.titre = \'Crêpes\';',
          solutionSql: "SELECT i.nom, ri.quantite FROM recette_ingredient ri JOIN ingredients i ON i.id = ri.ingredient_id JOIN recettes r ON r.id = ri.recette_id WHERE r.titre = 'Crêpes';",
          explanation:
              'Double jointure en passant par la table de liaison.',
        ),
      ],
      estimatedXp: 100,
    ),
    Project(
      id: 'proj_employes',
      title: 'Gestion des employés',
      icon: Icons.badge,
      colorName: 'blue',
      summary:
          'Gère une entreprise : départements, employés, salaires et statistiques.',
      spec:
          'Modéliser une entreprise. Chaque employé est affecté à un département et a un salaire. Calculer des statistiques (salaires moyens par département, effectifs).',
      tables: [
        PillarTable('departements', 'CREATE TABLE departements (id INTEGER PRIMARY KEY, nom TEXT NOT NULL);', 'Chaque service.'),
        PillarTable('employes', 'CREATE TABLE employes (id INTEGER PRIMARY KEY, nom TEXT, prenom TEXT, departement_id INTEGER, salaire REAL, FOREIGN KEY (departement_id) REFERENCES departements(id));', 'Chaque salarié.'),
      ],
      relations: '1-N : un département a de nombreux employés (clé étrangère departement_id).',
      sampleData: 'Départements (Ventes, Informatique, RH), employés variés.',
      tasks: [
        ProjectTask(
          id: 'pe1',
          title: 'Salaire moyen par département',
          description:
              'Calcule le salaire moyen par département, en affichant le nom du département.',
          difficulty: 'Moyen',
          solution:
              'SELECT d.nom, AVG(e.salaire) AS moy FROM employes e JOIN departements d ON e.departement_id = d.id GROUP BY d.nom;',
          solutionSql: 'SELECT d.nom, AVG(e.salaire) AS moy FROM employes e JOIN departements d ON e.departement_id = d.id GROUP BY d.nom;',
          explanation:
              'JOIN puis GROUP BY par département et AVG du salaire.',
        ),
        ProjectTask(
          id: 'pe2',
          title: 'Employés les mieux payés',
          description:
              'Liste les employés dont le salaire est supérieur à la moyenne de leur département.',
          difficulty: 'Expert',
          solution:
              'Utiliser une sous-requête corrélée ou une fenêtre : SELECT e.nom, e.salaire FROM employes e WHERE e.salaire > (SELECT AVG(e2.salaire) FROM employes e2 WHERE e2.departement_id = e.departement_id);',
          solutionSql: 'SELECT e.nom, e.salaire FROM employes e WHERE e.salaire > (SELECT AVG(e2.salaire) FROM employes e2 WHERE e2.departement_id = e.departement_id);',
          explanation:
              'La sous-requête corrélée recalcule la moyenne du département pour chaque employé.',
        ),
      ],
      estimatedXp: 130,
    ),
    Project(
      id: 'proj_ecommerce',
      title: 'Boutique e-commerce',
      icon: Icons.shopping_cart,
      colorName: 'green',
      summary:
          'Commande complète d\'une boutique : produits, clients, commandes, lignes.',
      spec:
          'Modéliser une boutique e-commerce. Des clients passent des commandes, chaque commande contient plusieurs lignes de produits. Gérer les stocks.',
      tables: [
        PillarTable('clients', 'CREATE TABLE clients (id INTEGER PRIMARY KEY, nom TEXT, email TEXT);', 'Les acheteurs.'),
        PillarTable('produits', 'CREATE TABLE produits (id INTEGER PRIMARY KEY, nom TEXT, prix REAL, stock INTEGER);', 'Le catalogue.'),
        PillarTable('commandes', 'CREATE TABLE commandes (id INTEGER PRIMARY KEY, client_id INTEGER, date TEXT, FOREIGN KEY (client_id) REFERENCES clients(id));', 'Chaque commande d\'un client.'),
        PillarTable('lignes', 'CREATE TABLE lignes (id INTEGER PRIMARY KEY, commande_id INTEGER, produit_id INTEGER, quantite INTEGER, FOREIGN KEY (commande_id) REFERENCES commandes(id), FOREIGN KEY (produit_id) REFERENCES produits(id));', 'Détail des produits par commande.'),
      ],
      relations:
          '1-N (client → commandes), 1-N (commande → lignes), N-1 (ligne → produit).',
      sampleData: 'Plusieurs clients, produits, commandes reliées à leurs lignes.',
      tasks: [
        ProjectTask(
          id: 'pecom1',
          title: 'Total de chaque commande',
          description:
              'Calcule le montant total de chaque commande (somme prix × quantité).',
          difficulty: 'Difficile',
          solution:
              'SELECT c.id, SUM(p.prix * l.quantite) AS total FROM commandes c JOIN lignes l ON l.commande_id = c.id JOIN produits p ON p.id = l.produit_id GROUP BY c.id;',
          solutionSql: 'SELECT c.id, SUM(p.prix * l.quantite) AS total FROM commandes c JOIN lignes l ON l.commande_id = c.id JOIN produits p ON p.id = l.produit_id GROUP BY c.id;',
          explanation:
              'Trois jointures + GROUP BY par commande + SUM du prix×quantité.',
        ),
        ProjectTask(
          id: 'pecom2',
          title: 'Produits en rupture de stock',
          description: 'Liste les produits dont le stock est à zéro.',
          difficulty: 'Facile',
          solution: 'SELECT nom FROM produits WHERE stock = 0;',
          solutionSql: 'SELECT nom FROM produits WHERE stock = 0;',
          explanation: 'Simple filtre WHERE sur la colonne stock.',
        ),
      ],
      estimatedXp: 150,
    ),
    Project(
      id: 'proj_social',
      title: 'Réseau social simplifié',
      icon: Icons.people,
      colorName: 'purple',
      summary:
          'Modélise des relations d\'abonnements et de publications.',
      spec:
          'Modéliser un mini-réseau social : des utilisateurs publient des messages ; un utilisateur peut suivre d\'autres utilisateurs (relation N-N auto-référencée).',
      tables: [
        PillarTable('utilisateurs', 'CREATE TABLE utilisateurs (id INTEGER PRIMARY KEY, pseudo TEXT);', 'Les comptes.'),
        PillarTable('publications', 'CREATE TABLE publications (id INTEGER PRIMARY KEY, auteur_id INTEGER, contenu TEXT, date TEXT, FOREIGN KEY (auteur_id) REFERENCES utilisateurs(id));', 'Les messages.'),
        PillarTable('abonnements', 'CREATE TABLE abonnements (suiveur_id INTEGER, suivi_id INTEGER, PRIMARY KEY (suiveur_id, suivi_id), FOREIGN KEY (suiveur_id) REFERENCES utilisateurs(id), FOREIGN KEY (suivi_id) REFERENCES utilisateurs(id));', 'Relation N-N auto-référencée.'),
      ],
      relations: 'N-N auto-référencée entre utilisateurs via abonnements.',
      sampleData: 'Utilisateurs qui se suivent, publications variées.',
      tasks: [
        ProjectTask(
          id: 'ps1',
          title: 'Publications d\'un utilisateur',
          description:
              'Affiche les publications d\'un utilisateur précis ainsi que son pseudo.',
          difficulty: 'Moyen',
          solution:
              'SELECT u.pseudo, p.contenu FROM publications p JOIN utilisateurs u ON p.auteur_id = u.id WHERE u.pseudo = \'Alice\';',
          solutionSql: "SELECT u.pseudo, p.contenu FROM publications p JOIN utilisateurs u ON p.auteur_id = u.id WHERE u.pseudo = 'Alice';",
          explanation:
              'Jointure entre publications et utilisateurs, filtrée par pseudo.',
        ),
        ProjectTask(
          id: 'ps2',
          title: 'Utilisateurs suivis par un compte',
          description:
              'Liste les pseudos suivis par un utilisateur donné.',
          difficulty: 'Difficile',
          solution:
              'SELECT u2.pseudo FROM abonnements a JOIN utilisateurs u1 ON u1.id = a.suiveur_id JOIN utilisateurs u2 ON u2.id = a.suivi_id WHERE u1.pseudo = \'Alice\';',
          solutionSql: "SELECT u2.pseudo FROM abonnements a JOIN utilisateurs u1 ON u1.id = a.suiveur_id JOIN utilisateurs u2 ON u2.id = a.suivi_id WHERE u1.pseudo = 'Alice';",
          explanation:
              'Double jointure sur la table de liaison auto-référencée.',
        ),
      ],
      estimatedXp: 140,
    ),
    Project(
      id: 'proj_bancaire',
      title: 'Système bancaire fictif',
      icon: Icons.account_balance_wallet,
      colorName: 'red',
      summary:
          'Gère comptes, transactions et intégrité avec les contraintes.',
      spec:
          'Modéliser une banque : des clients ont des comptes, les comptes passent des transactions. Garantir que le solde ne devient jamais négatif et que les virements restent cohérents (transactions).',
      tables: [
        PillarTable('clients', 'CREATE TABLE clients (id INTEGER PRIMARY KEY, nom TEXT);', 'Les titulaires.'),
        PillarTable('comptes', 'CREATE TABLE comptes (id INTEGER PRIMARY KEY, client_id INTEGER, solde REAL CHECK (solde >= 0), FOREIGN KEY (client_id) REFERENCES clients(id));', 'Les comptes bancaires avec contrainte de solde.'),
        PillarTable('transactions', 'CREATE TABLE transactions (id INTEGER PRIMARY KEY, compte_id INTEGER, type TEXT, montant REAL, date TEXT, FOREIGN KEY (compte_id) REFERENCES comptes(id));', 'Chaque opération.'),
      ],
      relations: '1-N (client → comptes), 1-N (compte → transactions).',
      sampleData: 'Clients, comptes avec soldes, transactions historiques.',
      tasks: [
        ProjectTask(
          id: 'pbk1',
          title: 'Contrainte de solde',
          description:
              'Explique comment empêcher un solde négatif et écris le CREATE TABLE.',
          difficulty: 'Moyen',
          solution:
              'Ajouter CHECK (solde >= 0) dans la définition du compte.',
          solutionSql: 'CREATE TABLE comptes (id INTEGER PRIMARY KEY, client_id INTEGER, solde REAL CHECK (solde >= 0), FOREIGN KEY (client_id) REFERENCES clients(id));',
          explanation: 'La contrainte CHECK empêche d\'insérer un solde négatif.',
        ),
        ProjectTask(
          id: 'pbk2',
          title: 'Total des transactions d\'un compte',
          description:
              'Calcule la somme des transactions pour chaque compte.',
          difficulty: 'Difficile',
          solution:
              'SELECT compte_id, SUM(montant) AS total FROM transactions GROUP BY compte_id;',
          solutionSql: 'SELECT compte_id, SUM(montant) AS total FROM transactions GROUP BY compte_id;',
          explanation: 'GROUP BY par compte et SUM des montants.',
        ),
      ],
      estimatedXp: 150,
    ),
    Project(
      id: 'proj_final',
      title: 'Projet final : Database Engineer',
      icon: Icons.workspace_premium,
      colorName: 'navy',
      summary:
          'Projet intégrateur : concevoir, optimiser et sécuriser un système complet.',
      spec:
          'Projet final. Conçois un système de gestion de commandes complet avec : conception normalisée (3NF), index pertinents, transaction pour un virement, vue d\'analyse des ventes, et protection contre l\'injection SQL. Livre un schéma SQL complet justifié.',
      tables: [
        PillarTable('client', 'CREATE TABLE client (id INTEGER PRIMARY KEY, nom TEXT);', 'Entité client (3NF).'),
        PillarTable('produit', 'CREATE TABLE produit (id INTEGER PRIMARY KEY, nom TEXT, prix REAL, stock INTEGER);', 'Entité produit.'),
        PillarTable('commande', 'CREATE TABLE commande (id INTEGER PRIMARY KEY, client_id INTEGER, total REAL, status TEXT, FOREIGN KEY (client_id) REFERENCES client(id));', 'Entité commande.'),
        PillarTable('ligne_commande', 'CREATE TABLE ligne_commande (commande_id INTEGER, produit_id INTEGER, quantite INTEGER, PRIMARY KEY (commande_id, produit_id), FOREIGN KEY (commande_id) REFERENCES commande(id), FOREIGN KEY (produit_id) REFERENCES produit(id));', 'Table de liaison N-N.'),
      ],
      relations:
          'Client 1-N Commande ; Commande N-N Produit via ligne_commande. Normalisation 3NF.',
      sampleData: 'Jeu de données complet de test pour les analyses.',
      tasks: [
        ProjectTask(
          id: 'pf1',
          title: 'Schéma 3NF complet',
          description:
              'Assemble le schéma complet normalisé et explique la décomposition.',
          difficulty: 'Expert',
          solution:
              'Séparer client, produit, commande et ligne_commande, chacune en 3NF.',
          solutionSql: 'CREATE TABLE client (id INTEGER PRIMARY KEY, nom TEXT);\nCREATE TABLE produit (id INTEGER PRIMARY KEY, nom TEXT, prix REAL, stock INTEGER);\nCREATE TABLE commande (id INTEGER PRIMARY KEY, client_id INTEGER, total REAL, FOREIGN KEY (client_id) REFERENCES client(id));\nCREATE TABLE ligne_commande (commande_id INTEGER, produit_id INTEGER, quantite INTEGER, PRIMARY KEY (commande_id, produit_id), FOREIGN KEY (commande_id) REFERENCES commande(id), FOREIGN KEY (produit_id) REFERENCES produit(id));',
          explanation:
              'Chaque table ne dépend que de sa clé primaire : 3NF respectée.',
        ),
        ProjectTask(
          id: 'pf2',
          title: 'Analyse des ventes',
          description:
              'Écris une requête calculant le chiffre d\'affaires par client.',
          difficulty: 'Difficile',
          solution:
              'SELECT c.nom, SUM(l.quantite * p.prix) AS ca FROM client c JOIN commande co ON co.client_id = c.id JOIN ligne_commande l ON l.commande_id = co.id JOIN produit p ON p.id = l.produit_id GROUP BY c.nom;',
          solutionSql: 'SELECT c.nom, SUM(l.quantite * p.prix) AS ca FROM client c JOIN commande co ON co.client_id = c.id JOIN ligne_commande l ON l.commande_id = co.id JOIN produit p ON p.id = l.produit_id GROUP BY c.nom;',
          explanation:
              'Plusieurs jointures et aggrégation pour produire le chiffre d\'affaires.',
        ),
      ],
      estimatedXp: 250,
    ),
  ];
}
