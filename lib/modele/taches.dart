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

final class Tache {
  Tache({
    required this.id,
    required this.titre,
    this.priorite = Priorite.normale,
    this.echeance = const SansEcheance(),
    this.note,
    this.faite = false,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Ne doit pas etre vide');
    }

    if (titre.trim().isEmpty) {
      throw ArgumentError.value(titre, 'titre', 'Ne doit pas être vide');
    }
  }

  final String id;
  final String titre;
  final Priorite priorite;
  final Echeance echeance;
  final String? note;
  final bool faite;

  Tache copyWith({
    String? titre,
    Priorite? priorite,
    Echeance? echeance,
    String? note,
    bool supprimerNote = false,
    bool? faite,
  }) {
    return Tache(
      id: id,
      titre: titre ?? this.titre,
      priorite: priorite ?? this.priorite,
      echeance: echeance ?? this.echeance,
      note: supprimerNote ? null : (note ?? this.note),
      faite: faite ?? this.faite,
    );
  }
}

Tache tacheDepuisJson(Map<String, Object?> json) {
  switch (json) {
    case {
      'id': String id,
      'title': String title,
      'priority': String code,
      'done': bool faite,
    }:
      if (id.trim().isEmpty || title.trim().isEmpty) {
        throw FormatException('Identifiant ou titre vide');
      }

      final priorite = prioriteDepuisCode(code);

      if (priorite == null) {
        throw FormatException('Priorité inconnue : $code');
      }

      final Echeance echeance;
      final due = json['due'];

      if (due == null) {
        echeance = const SansEcheance();
      } else if (due is String) {
        echeance = EcheanceDate(_dateDepuisJson(due));
      } else {
        throw FormatException('Échéance invalide : $due');
      }

      final String? noteLue = switch (json['note']) {
        null => null,
        String valeur => valeur,
        _ => throw FormatException('La note doit être une chaîne'),
      };

      return Tache(
        id: id,
        titre: title,
        priorite: priorite,
        echeance: echeance,
        note: noteLue,
        faite: faite,
      );
    default:
      throw FormatException('Document de tache mal forme');
  }
}

DateTime _dateDepuisJson(String texte) {
  if (!RegExp(r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$').hasMatch(texte)) {
    throw FormatException('Format de date invalide : $texte');
  }

  final annee = int.parse(texte.substring(0, 4));
  final mois = int.parse(texte.substring(5, 7));
  final jour = int.parse(texte.substring(8, 10));

  final date = DateTime(annee, mois, jour);

  if (date.year != annee || date.month != mois || date.day != jour) {
    throw FormatException('Date inexistante : $texte');
  }

  return date;
}

//A2
String libelleEcheance(Echeance echeance) => switch (echeance) {
  SansEcheance() => 'sans échéance',
  EcheanceDate(:final date) => 'pour le ${date.day}/${date.month}',
  EcheanceHebdomadaire(:final jour) => 'chaque ${_joursSemaine[jour - 1]}',
};

const _joursSemaine = [
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];

bool estEnRetard(Tache tache, {required DateTime aujourdhui}) {
  if (tache.faite) return false;

  return switch (tache.echeance) {
    SansEcheance() => false,
    EcheanceHebdomadaire() => false,
    EcheanceDate(:final date) => DateTime(
      date.year,
      date.month,
      date.day,
    ).isBefore(DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day)),
  };
}

({int faites, int total}) bilan(Iterable<Tache> taches) {
  var faites = 0;
  var total = 0;

  for (final tache in taches) {
    total++;

    if (tache.faite) {
      faites++;
    }
  }

  return (faites: faites, total: total);
}

List<Tache> aFaire(
  Iterable<Tache> taches, {
  Priorite auMoins = Priorite.basse,
}) {
  final resultat = [
    for (final tache in taches)
      if (!tache.faite && tache.priorite.index >= auMoins.index) tache,
  ];

  resultat.sort((a, b) {
    final comparaisonPriorite = b.priorite.index.compareTo(a.priorite.index);

    if (comparaisonPriorite != 0) {
      return comparaisonPriorite;
    }

    return a.titre.compareTo(b.titre);
  });

  return resultat;
}
