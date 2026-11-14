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
}
