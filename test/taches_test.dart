import 'package:flutter_test/flutter_test.dart';
import 'package:mes_taches/modele/taches.dart';

void main() {
  group('prioriteDepuisCode', () {
    test('convertit les trois codes reconnus', () {
      expect(prioriteDepuisCode('low'), Priorite.basse);
      expect(prioriteDepuisCode('normal'), Priorite.normale);
      expect(prioriteDepuisCode('high'), Priorite.haute);
    });

    test('renvoie null pour les codes inconnus', () {
      expect(prioriteDepuisCode('urgent'), isNull);
      expect(prioriteDepuisCode('High'), isNull);
      expect(prioriteDepuisCode(''), isNull);
    });
  });

  group('echeances', () {
    test('une echeance datee ne conserve pas les heures', () {
      final echeance = EcheanceDate(DateTime(2026, 12, 1, 15, 30));

      expect(echeance.date, DateTime(2026, 12, 1));
    });

    test('une echeance hebdomadaire accepte les jours de 1 a 7', () {
      for (var jour = 1; jour <= 7; jour++) {
        expect(EcheanceHebdomadaire(jour).jour, jour);
      }
    });

    test('une echeance hebdomadaire refuse un jour hors limites', () {
      expect(() => EcheanceHebdomadaire(0), throwsArgumentError);
      expect(() => EcheanceHebdomadaire(8), throwsArgumentError);
    });
  });

  group('Tache', () {
    test('utilise les valeurs par défaut attendues', () {
      final tache = Tache(id: 't1', titre: 'Lire');

      expect(tache.priorite, Priorite.normale);
      expect(tache.echeance, isA<SansEcheance>());
      expect(tache.note, isNull);
      expect(tache.faite, isFalse);
    });

    test('refuse un identifiant ou un titre vide', () {
      for (final valeur in ['', '   ']) {
        expect(() => Tache(id: valeur, titre: 'Lire'), throwsArgumentError);

        expect(() => Tache(id: 't1', titre: valeur), throwsArgumentError);
      }
    });

    test('copyWith modifie les champs sans changer la tâche originale', () {
      final originale = Tache(id: 't1', titre: 'Lire', note: 'Chapitre 1');
      final nouvelleEcheance = EcheanceDate(DateTime(2026, 12, 1));

      final modifiee = originale.copyWith(
        titre: 'Lire Dart',
        priorite: Priorite.haute,
        echeance: nouvelleEcheance,
        note: 'Chapitre 2',
        faite: true,
      );

      expect(identical(originale, modifiee), isFalse);
      expect(modifiee.id, originale.id);
      expect(modifiee.titre, 'Lire Dart');
      expect(modifiee.priorite, Priorite.haute);
      expect(modifiee.echeance, same(nouvelleEcheance));
      expect(modifiee.note, 'Chapitre 2');
      expect(modifiee.faite, isTrue);

      expect(originale.titre, 'Lire');
      expect(originale.priorite, Priorite.normale);
      expect(originale.echeance, isA<SansEcheance>());
      expect(originale.note, 'Chapitre 1');
      expect(originale.faite, isFalse);
    });

    test('changer seulement un champ conserve les autres', () {
      final echeance = EcheanceDate(DateTime(2026, 12, 1));
      final originale = Tache(
        id: 't1',
        titre: 'Lire',
        priorite: Priorite.haute,
        echeance: echeance,
        note: 'Chapitre 1',
      );

      final modifiee = originale.copyWith(faite: true);

      expect(modifiee.id, originale.id);
      expect(modifiee.titre, originale.titre);
      expect(modifiee.priorite, originale.priorite);
      expect(modifiee.echeance, same(echeance));
      expect(modifiee.note, originale.note);
      expect(modifiee.faite, isTrue);
      expect(originale.faite, isFalse);
    });

    test('permet de supprimer une note sans modifier l’originale', () {
      final originale = Tache(id: 't1', titre: 'Lire', note: 'Chapitre 1');

      final modifiee = originale.copyWith(supprimerNote: true);

      expect(modifiee.note, isNull);
      expect(originale.note, 'Chapitre 1');
    });

    test('permet de retirer une échéance', () {
      final originale = Tache(
        id: 't1',
        titre: 'Lire',
        echeance: EcheanceDate(DateTime(2026, 12, 1)),
      );

      final modifiee = originale.copyWith(echeance: const SansEcheance());

      expect(modifiee.echeance, isA<SansEcheance>());
      expect(originale.echeance, isA<EcheanceDate>());
    });
  });

  group('tacheDepuisJson', () {
    Map<String, Object?> documentValide() => {
      'id': 't1',
      'title': 'Apprendre Dart',
      'priority': 'high',
      'done': false,
    };

    test('lit un document sans échéance ni note', () {
      final tache = tacheDepuisJson(documentValide());

      expect(tache.id, 't1');
      expect(tache.titre, 'Apprendre Dart');
      expect(tache.priorite, Priorite.haute);
      expect(tache.faite, isFalse);
      expect(tache.echeance, isA<SansEcheance>());
      expect(tache.note, isNull);
    });

    test('lit un document avec une échéance et une note', () {
      final json = documentValide()
        ..['due'] = '2026-12-01'
        ..['note'] = 'Chapitre 1'
        ..['done'] = true;

      final tache = tacheDepuisJson(json);

      expect(tache.echeance, isA<EcheanceDate>());
      expect((tache.echeance as EcheanceDate).date, DateTime(2026, 12, 1));
      expect(tache.note, 'Chapitre 1');
      expect(tache.faite, isTrue);
    });

    test('accepte null pour les champs facultatifs', () {
      final json = documentValide()
        ..['due'] = null
        ..['note'] = null;

      final tache = tacheDepuisJson(json);

      expect(tache.echeance, isA<SansEcheance>());
      expect(tache.note, isNull);
    });

    test('ignore les champs supplémentaires', () {
      final json = documentValide()..['autre'] = 42;

      expect(tacheDepuisJson(json).id, 't1');
    });

    for (final cle in ['id', 'title', 'priority', 'done']) {
      test('refuse un document sans le champ obligatoire $cle', () {
        final json = documentValide()..remove(cle);

        expect(() => tacheDepuisJson(json), throwsFormatException);
      });

      test('refuse null pour le champ obligatoire $cle', () {
        final json = documentValide()..[cle] = null;

        expect(() => tacheDepuisJson(json), throwsFormatException);
      });

      test('refuse un mauvais type pour le champ $cle', () {
        final json = documentValide()..[cle] = 42;

        expect(() => tacheDepuisJson(json), throwsFormatException);
      });
    }

    for (final cle in ['id', 'title']) {
      for (final valeur in ['', '   ']) {
        test('refuse un champ $cle vide ou composé d’espaces : "$valeur"', () {
          final json = documentValide()..[cle] = valeur;

          expect(() => tacheDepuisJson(json), throwsFormatException);
        });
      }
    }

    test('refuse une priorité inconnue', () {
      final json = documentValide()..['priority'] = 'urgent';

      expect(() => tacheDepuisJson(json), throwsFormatException);
    });

    test('refuse une chaîne à la place du booléen done', () {
      final json = documentValide()..['done'] = 'false';

      expect(() => tacheDepuisJson(json), throwsFormatException);
    });

    test('refuse une échéance qui n’est pas une chaîne', () {
      final json = documentValide()..['due'] = 20261201;

      expect(() => tacheDepuisJson(json), throwsFormatException);
    });

    for (final valeur in [
      '',
      'demain',
      '01/12/2026',
      '2026-2-01',
      '2026-12-01T10:00:00',
      '2026-02-30',
      '2026-13-01',
      '2026-00-01',
      '2026-12-00',
    ]) {
      test('refuse la date invalide "$valeur"', () {
        final json = documentValide()..['due'] = valeur;

        expect(() => tacheDepuisJson(json), throwsFormatException);
      });
    }

    test('accepte le 29 février d’une année bissextile', () {
      final json = documentValide()..['due'] = '2028-02-29';

      final tache = tacheDepuisJson(json);

      expect((tache.echeance as EcheanceDate).date, DateTime(2028, 2, 29));
    });

    test('refuse le 29 février d’une année non bissextile', () {
      final json = documentValide()..['due'] = '2027-02-29';

      expect(() => tacheDepuisJson(json), throwsFormatException);
    });

    test('refuse une note qui n’est pas une chaîne', () {
      final json = documentValide()..['note'] = 123;

      expect(() => tacheDepuisJson(json), throwsFormatException);
    });
  });

  group('libelleEcheance', () {
    test('décrit une absence d’échéance', () {
      expect(libelleEcheance(const SansEcheance()), 'sans échéance');
    });

    test('décrit une date sans zéro initial', () {
      expect(
        libelleEcheance(EcheanceDate(DateTime(2026, 12, 1))),
        'pour le 1/12',
      );
    });

    test('décrit les sept jours de la semaine', () {
      const jours = [
        'lundi',
        'mardi',
        'mercredi',
        'jeudi',
        'vendredi',
        'samedi',
        'dimanche',
      ];

      for (var jour = 1; jour <= 7; jour++) {
        expect(
          libelleEcheance(EcheanceHebdomadaire(jour)),
          'chaque ${jours[jour - 1]}',
        );
      }
    });
  });

  group('estEnRetard', () {
    final aujourdhui = DateTime(2026, 12, 2, 18);

    test('une tâche non faite prévue la veille est en retard', () {
      final tache = Tache(
        id: 't1',
        titre: 'Lire',
        echeance: EcheanceDate(DateTime(2026, 12, 1)),
      );

      expect(estEnRetard(tache, aujourdhui: aujourdhui), isTrue);
    });

    test('une tâche faite n’est pas en retard', () {
      final tache = Tache(
        id: 't1',
        titre: 'Lire',
        echeance: EcheanceDate(DateTime(2026, 12, 1)),
        faite: true,
      );

      expect(estEnRetard(tache, aujourdhui: aujourdhui), isFalse);
    });

    test('une échéance le même jour ne dépend pas de l’heure', () {
      final tache = Tache(
        id: 't1',
        titre: 'Lire',
        echeance: EcheanceDate(DateTime(2026, 12, 2, 8)),
      );

      expect(estEnRetard(tache, aujourdhui: aujourdhui), isFalse);
    });

    test('une échéance future n’est pas en retard', () {
      final tache = Tache(
        id: 't1',
        titre: 'Lire',
        echeance: EcheanceDate(DateTime(2026, 12, 3)),
      );

      expect(estEnRetard(tache, aujourdhui: aujourdhui), isFalse);
    });

    test('une tâche sans échéance n’est pas en retard', () {
      final tache = Tache(id: 't1', titre: 'Lire');

      expect(estEnRetard(tache, aujourdhui: aujourdhui), isFalse);
    });

    test('une échéance hebdomadaire n’est jamais en retard', () {
      for (var jour = 1; jour <= 7; jour++) {
        final tache = Tache(
          id: 't$jour',
          titre: 'Lire',
          echeance: EcheanceHebdomadaire(jour),
        );

        expect(estEnRetard(tache, aujourdhui: aujourdhui), isFalse);
      }
    });
  });

  group('bilan', () {
    test('une collection vide donne zéro tâche', () {
      expect(bilan(<Tache>[]), (faites: 0, total: 0));
    });

    test('compte les tâches faites et le total', () {
      final taches = [
        Tache(id: 't1', titre: 'Lire', faite: true),
        Tache(id: 't2', titre: 'Écrire'),
        Tache(id: 't3', titre: 'Réviser', faite: true),
      ];

      expect(bilan(taches), (faites: 2, total: 3));
    });
  });

  group('aFaire', () {
    List<Tache> exemples() => [
      Tache(id: 'courses', titre: 'Courses', priorite: Priorite.basse),
      Tache(id: 'dentiste', titre: 'Dentiste'),
      Tache(id: 'passeport', titre: 'Passeport', priorite: Priorite.haute),
      Tache(
        id: 'installer',
        titre: 'Installer',
        priorite: Priorite.haute,
        faite: true,
      ),
      Tache(id: 'banque', titre: 'Banque'),
    ];

    test('filtre les tâches faites et trie par priorité puis titre', () {
      final resultat = aFaire(exemples());

      expect(resultat.map((tache) => tache.titre).toList(), [
        'Passeport',
        'Banque',
        'Dentiste',
        'Courses',
      ]);
    });

    test('respecte la priorité minimale demandée', () {
      final resultat = aFaire(exemples(), auMoins: Priorite.normale);

      expect(resultat.map((tache) => tache.titre).toList(), [
        'Passeport',
        'Banque',
        'Dentiste',
      ]);

      final urgentes = aFaire(exemples(), auMoins: Priorite.haute);

      expect(urgentes.map((tache) => tache.titre).toList(), ['Passeport']);
    });

    test(
      'ne modifie pas la collection reçue et renvoie une nouvelle liste',
      () {
        final originales = exemples();
        final avant = List<Tache>.of(originales);

        final resultat = aFaire(originales);

        expect(originales, orderedEquals(avant));
        expect(identical(resultat, originales), isFalse);

        resultat.clear();

        expect(originales, orderedEquals(avant));
      },
    );

    test('accepte une collection vide', () {
      expect(aFaire(<Tache>[]), isEmpty);
    });

    test('renvoie une liste vide si toutes les tâches sont faites', () {
      final taches = [
        Tache(id: 't1', titre: 'Lire', faite: true),
        Tache(id: 't2', titre: 'Écrire', faite: true),
      ];

      expect(aFaire(taches), isEmpty);
    });

    test('accepte une entrée non modifiable', () {
      final taches = List<Tache>.unmodifiable(exemples());

      expect(aFaire(taches), hasLength(4));
    });

    test('conserve les tâches ayant la même priorité et le même titre', () {
      final taches = [
        Tache(id: 't1', titre: 'Lire'),
        Tache(id: 't2', titre: 'Lire'),
      ];

      final resultat = aFaire(taches);

      expect(resultat, hasLength(2));
      expect(resultat.map((tache) => tache.id), unorderedEquals(['t1', 't2']));
    });
  });
}
