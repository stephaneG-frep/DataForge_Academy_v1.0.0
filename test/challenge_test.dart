import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dataforge_academy/data/challenge_data.dart';
import 'package:dataforge_academy/database/playground_database.dart';
import 'package:dataforge_academy/database/practice_data.dart';
import 'package:dataforge_academy/models/challenge_models.dart';
import 'package:dataforge_academy/models/table_models.dart';
import 'package:dataforge_academy/utils/challenge_checker.dart';

/// Other correct ways to solve a challenge: they must be accepted.
const _alsoCorrect = <String, List<String>>{
  'ch_01': ['select e.nom, e.prenom, e.salaire from employes e where e.salaire < 40000 order by 3 desc'],
  'ch_03': ['SELECT category_id, COUNT(id) FROM products GROUP BY category_id ORDER BY 2 DESC;'],
  'ch_09': ["SELECT nom, ville FROM clients WHERE COALESCE(email, '') = '';"],
  'ch_10': ["SELECT name, price FROM products WHERE SUBSTR(name, 1, 3) = 'Jeu' ORDER BY price;"],
  'ch_11': ['SELECT ville FROM clients GROUP BY ville;'],
  'ch_12': ['SELECT titre, note FROM films WHERE note >= 8.8 ORDER BY note DESC;'],
  'ch_13': ['SELECT nom, prenom, salaire FROM employes WHERE (departement_id = 1 OR departement_id = 3 OR departement_id = 5) AND salaire >= 30000 AND salaire <= 36000;'],
  'ch_14': ['SELECT nom FROM departements WHERE id NOT IN (SELECT departement_id FROM employes);',
            'SELECT d.nom FROM departements d WHERE NOT EXISTS (SELECT 1 FROM employes e WHERE e.departement_id = d.id);'],
  'ch_18': ["SELECT nom, prenom, embauche FROM employes WHERE embauche BETWEEN '2023-01-01' AND '2023-12-31';",
            "SELECT nom, prenom, embauche FROM employes WHERE embauche LIKE '2023%';"],
  'ch_15': ['SELECT e.nom, (SELECT m.nom FROM employes m WHERE m.id = e.manager_id) FROM employes e WHERE e.manager_id IS NOT NULL;'],
  'ch_16': ["SELECT name, CASE WHEN price >= 60 THEN 'premium' WHEN price >= 20 THEN 'moyen' ELSE 'petit prix' END FROM products;"],
  'ch_17': ['SELECT a.nom, COUNT(l.id) FROM livres l JOIN auteurs a ON a.id = l.auteur_id GROUP BY a.nom HAVING COUNT(l.id) > 1;'],
  'ch_25': ['SELECT nom FROM categories UNION ALL SELECT nom FROM clients;'],
  'ch_07': ['SELECT name, price FROM products ORDER BY price DESC LIMIT 1;'],
  'ch_19': ['WITH m AS (SELECT AVG(note) AS moy FROM notes WHERE cours_id = 4) SELECT e.nom, n.note FROM notes n JOIN etudiants e ON e.id = n.etudiant_id, m WHERE n.cours_id = 4 AND n.note > m.moy;'],
  'ch_20': ['SELECT DISTINCT a.nom FROM auteurs a JOIN livres l ON l.auteur_id = a.id WHERE l.disponible = 0;'],
  'ch_21': ['WITH m AS (SELECT departement_id, AVG(salaire) AS moy FROM employes GROUP BY departement_id) SELECT e.nom, e.salaire FROM employes e JOIN m ON m.departement_id = e.departement_id WHERE e.salaire > m.moy;'],
  'ch_22': ['SELECT e.departement_id, e.nom, e.salaire FROM employes e WHERE e.salaire = (SELECT MAX(salaire) FROM employes WHERE departement_id = e.departement_id);'],
  'ch_23': ['SELECT e.nom, ROUND(AVG(n.note), 1) AS moyenne, ROW_NUMBER() OVER (ORDER BY AVG(n.note) DESC) AS rang FROM notes n JOIN etudiants e ON e.id = n.etudiant_id GROUP BY e.nom ORDER BY moyenne DESC;'],
  'ch_24': ['SELECT e.nom, e.embauche, (SELECT SUM(salaire) FROM employes x WHERE x.embauche <= e.embauche) AS cumul FROM employes e ORDER BY e.embauche;'],
};

/// Typical mistakes: they must be refused.
const _wrong = <String, List<String>>{
  'ch_01': ['SELECT nom, prenom, salaire FROM employes WHERE salaire < 40000 ORDER BY salaire ASC;'],
  'ch_09': ['SELECT nom, ville FROM clients WHERE email = NULL;'],
  'ch_10': ["SELECT name, price FROM products WHERE name LIKE 'Jeu%' ORDER BY price DESC;"],
  'ch_11': ['SELECT ville FROM clients;'],
  'ch_12': ['SELECT titre, note FROM films LIMIT 3;'],
  'ch_13': ['SELECT nom, prenom, salaire FROM employes WHERE departement_id IN (1, 3, 5) AND salaire > 30000 AND salaire < 36000;'],
  'ch_14': ['SELECT d.nom FROM departements d JOIN employes e ON e.departement_id = d.id WHERE e.id IS NULL;'],
  'ch_15': ['SELECT e.nom, m.nom FROM employes e JOIN employes m ON m.manager_id = e.id;'],
  'ch_16': ["SELECT name, CASE WHEN price < 60 THEN 'moyen' WHEN price < 20 THEN 'petit prix' ELSE 'premium' END FROM products;"],
  'ch_17': ['SELECT a.nom, COUNT(*) FROM auteurs a JOIN livres l ON l.auteur_id = a.id GROUP BY a.id, a.nom;'],
  'ch_19': ['SELECT e.nom, n.note FROM notes n JOIN etudiants e ON e.id = n.etudiant_id WHERE n.cours_id = 4 AND n.note > (SELECT AVG(note) FROM notes);'],
  'ch_21': ['SELECT nom, salaire FROM employes WHERE salaire > (SELECT AVG(salaire) FROM employes);'],
  'ch_23': ['SELECT e.nom, ROUND(AVG(n.note), 1) AS moyenne, RANK() OVER (ORDER BY AVG(n.note) DESC) AS rang FROM etudiants e JOIN notes n ON n.etudiant_id = e.id GROUP BY e.id, e.nom ORDER BY rang DESC;'],
  'ch_24': ['SELECT nom, embauche, SUM(salaire) OVER () AS cumul FROM employes ORDER BY embauche;'],
};

Future<CheckVerdict> _verdict(Challenge c, String sql) async {
  final pg = PlaygroundDatabase.instance;
  final user = await pg.executeReadOnly(c.databaseId, sql);
  final sol = await pg.executeReadOnly(c.databaseId, c.solution);
  return ChallengeChecker.check(c, user, sol);
}

void main() {
  setUpAll(sqfliteFfiInit);
  setUp(() => PlaygroundDatabase.instance.closeAll());

  test('identifiants uniques, niveaux 1 à 6, bases existantes', () {
    final ids = <String>{};
    for (final c in ChallengeData.all) {
      expect(ids.add(c.id), isTrue, reason: 'doublon ${c.id}');
      expect(c.level, inInclusiveRange(1, 6), reason: c.id);
      expect(PracticeData.ids, contains(c.databaseId), reason: c.id);
      expect(c.description, startsWith('Mission'), reason: c.id);
    }
    expect(ChallengeData.all.length, greaterThanOrEqualTo(25));
  });

  test('chaque niveau propose au moins un défi', () {
    final levels = ChallengeData.all.map((c) => c.level).toSet();
    expect(levels, containsAll([1, 2, 3, 4, 5, 6]));
  });

  for (final c in ChallengeData.all) {
    test('${c.id} : la solution passe sa propre correction', () async {
      QueryResult sol;
      try {
        sol = await PlaygroundDatabase.instance
            .executeReadOnly(c.databaseId, c.solution);
      } on SqlError catch (e) {
        fail('${c.id} : la solution échoue : ${e.message}');
      }
      expect(sol.rowCount, greaterThan(0), reason: '${c.id} : résultat vide');
      final col = c.orderByColumn;
      if (col != null) {
        expect(sol.columns.map((x) => x.name.toLowerCase()), contains(col.toLowerCase()),
            reason: '${c.id} : colonne de tri absente du résultat');
      }
      expect(await _verdict(c, c.solution), CheckVerdict.passed);
    });

    for (final sql in _alsoCorrect[c.id] ?? const <String>[]) {
      test('${c.id} : autre bonne réponse acceptée — $sql', () async {
        expect(await _verdict(c, sql), CheckVerdict.passed);
      });
    }

    for (final sql in _wrong[c.id] ?? const <String>[]) {
      test('${c.id} : mauvaise réponse refusée — $sql', () async {
        expect(await _verdict(c, sql), isNot(CheckVerdict.passed));
      });
    }
  }
}
