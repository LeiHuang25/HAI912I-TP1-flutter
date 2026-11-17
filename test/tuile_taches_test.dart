import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/modele/taches.dart';
import 'package:mes_taches/widgets/tuile_tache.dart';

void main() {
  Widget application({
    required Tache tache,
    VoidCallback? onBasculer,
    VoidCallback? onOuvrir,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TuileTache(
          tache: tache,
          aujourdhui: DateTime(2026, 12, 2),
          onBasculer: onBasculer ?? () {},
          onOuvrir: onOuvrir,
        ),
      ),
    );
  }

  testWidgets('affiche le titre, la priorité et l’échéance', (tester) async {
    final tache = Tache(
      id: 't1',
      titre: 'Lire Dart',
      priorite: Priorite.haute,
      echeance: EcheanceDate(DateTime(2026, 12, 3)),
    );

    await tester.pumpWidget(application(tache: tache));

    expect(find.text('Lire Dart'), findsOneWidget);
    expect(find.text('pour le 3/12'), findsOneWidget);
    expect(find.byTooltip('Priorité : Haute'), findsOneWidget);

    final titre = tester.widget<Text>(find.text('Lire Dart'));

    expect(titre.style?.decoration, TextDecoration.none);
  });

  testWidgets('barre le titre d’une tâche faite', (tester) async {
    final tache = Tache(id: 't1', titre: 'Lire Dart', faite: true);

    await tester.pumpWidget(application(tache: tache));

    final titre = tester.widget<Text>(find.text('Lire Dart'));

    expect(titre.style?.decoration, TextDecoration.lineThrough);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('signale une échéance en retard avec la couleur d’alerte', (
    tester,
  ) async {
    final tache = Tache(
      id: 't1',
      titre: 'Lire Dart',
      echeance: EcheanceDate(DateTime(2026, 12, 1)),
    );

    await tester.pumpWidget(application(tache: tache));

    final finder = find.text('pour le 1/12');
    final texte = tester.widget<Text>(finder);
    final couleurs = Theme.of(tester.element(finder)).colorScheme;

    expect(texte.style?.color, couleurs.error);
  });

  testWidgets('une tâche faite ne porte pas la couleur de retard', (
    tester,
  ) async {
    final tache = Tache(
      id: 't1',
      titre: 'Lire Dart',
      echeance: EcheanceDate(DateTime(2026, 12, 1)),
      faite: true,
    );

    await tester.pumpWidget(application(tache: tache));

    final finder = find.text('pour le 1/12');
    final texte = tester.widget<Text>(finder);
    final couleurs = Theme.of(tester.element(finder)).colorScheme;

    expect(texte.style?.color, couleurs.onSurfaceVariant);
  });

  testWidgets('transmet les actions sans modifier la tâche', (tester) async {
    var basculements = 0;
    var ouvertures = 0;
    final tache = Tache(id: 't1', titre: 'Lire Dart');

    await tester.pumpWidget(
      application(
        tache: tache,
        onBasculer: () => basculements++,
        onOuvrir: () => ouvertures++,
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(basculements, 1);
    expect(ouvertures, 0);
    expect(tache.faite, isFalse);

    await tester.tap(find.text('Lire Dart'));
    await tester.pump();

    expect(ouvertures, 1);
    expect(basculements, 1);
  });

  testWidgets('un titre long reste sur une ligne de 360 à 1280 pixels', (
    tester,
  ) async {
    const titreLong =
        'Préparer le compte-rendu détaillé du projet Flutter '
        'et vérifier toutes les fonctionnalités avant la remise';

    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final largeur in [360.0, 800.0, 1280.0]) {
      tester.view.physicalSize = Size(largeur, 800);

      await tester.pumpWidget(
        application(
          tache: Tache(id: 'long', titre: titreLong, priorite: Priorite.haute),
        ),
      );
      await tester.pumpAndSettle();

      final titre = tester.widget<Text>(find.text(titreLong));

      expect(titre.maxLines, 1);
      expect(titre.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    }
  });
}
