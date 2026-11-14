enum Priorite {
  basse('Basse'),
  normale('Normale'),
  haute('Haute');

  const Priorite(this.libelle);

  final String libelle;
}

Priorite? prioriteDepuisCode(String code) => switch (code) {
  'low' => Priorite.basse,
  'normal' => Priorite.normale,
  'high' => Priorite.haute,
  _ => null,
};

sealed class Echeance {
  const Echeance();
}

final class SansEcheance extends Echeance {
  const SansEcheance();
}

final class EcheanceDate extends Echeance {
  EcheanceDate(DateTime date)
    : date = DateTime(date.year, date.month, date.day);

  final DateTime date;
}

final class EcheanceHebdomadaire extends Echeance {
  EcheanceHebdomadaire(this.jour) {
    if (jour < DateTime.monday || jour > DateTime.sunday) {
      throw ArgumentError.value(jour, 'jour', 'Doit etre compris entre 1 et 7');
    }
  }

  final int jour;
}
