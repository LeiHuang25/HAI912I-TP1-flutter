// Un premier test de widget qui vérifie que l'application démarre.
// Gardez-le (adaptez-le si votre écran change de titre)
// et écrivez vos propres tests dans ce dossier
// (partie F du sujet, fiche « Tests » de l'annexe).
import 'package:flutter_test/flutter_test.dart';
import 'package:mes_taches/main.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets("l'application démarre et affiche son titre", (tester) async {
    await tester.pumpWidget(const MesTachesApp());

    expect(find.text('Mes tâches'), findsOneWidget);
  });

  testWidgets('cocher puis décocher une tâche met à jour le compteur', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    expect(find.text('5 à faire'), findsOneWidget);

    final caseTache = find.byKey(const ValueKey('faite-t2'));

    expect(caseTache, findsOneWidget);
    expect(tester.widget<Checkbox>(caseTache).value, isFalse);

    await tester.tap(caseTache);
    await tester.pump();

    expect(find.text('4 à faire'), findsOneWidget);
    expect(tester.widget<Checkbox>(caseTache).value, isTrue);

    await tester.tap(caseTache);
    await tester.pump();

    expect(find.text('5 à faire'), findsOneWidget);
    expect(tester.widget<Checkbox>(caseTache).value, isFalse);
  });

  testWidgets('les filtres changent la liste sans changer le compteur global', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    expect(find.byType(Checkbox), findsNWidgets(6));
    expect(find.text('5 à faire'), findsOneWidget);

    await tester.tap(find.text('Faites'));
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.text('Installer Flutter'), findsOneWidget);
    expect(find.text('Relire le CM 01'), findsNothing);
    expect(find.text('5 à faire'), findsOneWidget);

    await tester.tap(find.text('À faire'));
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsNWidgets(5));
    expect(find.text('Installer Flutter'), findsNothing);
    expect(find.text('Relire le CM 01'), findsOneWidget);
    expect(find.text('5 à faire'), findsOneWidget);

    await tester.tap(find.text('Toutes'));
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsNWidgets(6));
    expect(find.text('5 à faire'), findsOneWidget);
  });

  testWidgets('cocher sous un filtre met à jour la bonne tâche', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    await tester.tap(find.text('À faire'));
    await tester.pumpAndSettle();

    final caseT2 = find.byKey(const ValueKey('faite-t2'));

    await tester.tap(caseT2);
    await tester.pumpAndSettle();

    expect(find.text('Relire le CM 01'), findsNothing);
    expect(find.text('4 à faire'), findsOneWidget);

    await tester.tap(find.text('Faites'));
    await tester.pumpAndSettle();

    expect(find.text('Installer Flutter'), findsOneWidget);
    expect(find.text('Relire le CM 01'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('faite-t2')));
    await tester.pumpAndSettle();

    expect(find.text('Relire le CM 01'), findsNothing);
    expect(find.text('5 à faire'), findsOneWidget);

    await tester.tap(find.text('À faire'));
    await tester.pumpAndSettle();

    expect(find.text('Relire le CM 01'), findsOneWidget);
  });

  testWidgets('affiche un message centré quand le filtre ne retient rien', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    await tester.tap(find.text('Faites'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('faite-t1')));
    await tester.pumpAndSettle();

    expect(find.text('Aucune tâche faite'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.text('6 à faire'), findsOneWidget);

    expect(
      find.ancestor(
        of: find.text('Aucune tâche faite'),
        matching: find.byType(Center),
      ),
      findsWidgets,
    );
  });

  testWidgets('l’écran principal ne déborde pas de 360 à 1280 pixels', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final largeur in [360.0, 800.0, 1280.0]) {
      tester.view.physicalSize = Size(largeur, 800);

      await tester.pumpWidget(const MesTachesApp());
      await tester.pumpAndSettle();

      expect(find.text('Toutes'), findsOneWidget);
      expect(find.text('À faire'), findsOneWidget);
      expect(find.text('Faites'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('ouvre le détail puis revient sans modifier la tâche', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    await tester.tap(find.text('Relire le CM 01'));
    await tester.pumpAndSettle();

    expect(find.text('Détail de la tâche'), findsOneWidget);
    expect(find.text('Relire le CM 01'), findsOneWidget);
    expect(find.text('Priorité : Normale'), findsOneWidget);
    expect(find.text('Échéance : sans échéance'), findsOneWidget);
    expect(find.text('État : à faire'), findsOneWidget);
    expect(find.text('records, patterns, classes scellées'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Détail de la tâche'), findsNothing);
    expect(find.text('5 à faire'), findsOneWidget);
    expect(
      tester.widget<Checkbox>(find.byKey(const ValueKey('faite-t2'))).value,
      isFalse,
    );
  });

  testWidgets(
    'agir depuis le détail met à jour la bonne tâche sous un filtre',
    (tester) async {
      await tester.pumpWidget(const MesTachesApp());

      await tester.tap(find.text('À faire'));
      await tester.pumpAndSettle();

      // Deuxième tâche affichée sous le filtre « À faire ».
      await tester.tap(find.text('Faire les courses'));
      await tester.pumpAndSettle();

      expect(find.text('Détail de la tâche'), findsOneWidget);
      expect(find.text('État : à faire'), findsOneWidget);

      final bouton = find.widgetWithText(FilledButton, 'Marquer comme faite');

      await tester.ensureVisible(bouton);
      await tester.tap(bouton);
      await tester.pumpAndSettle();

      expect(find.text('Détail de la tâche'), findsNothing);
      expect(find.text('Faire les courses'), findsNothing);
      expect(find.text('Relire le CM 01'), findsOneWidget);
      expect(find.text('4 à faire'), findsOneWidget);

      await tester.tap(find.text('Faites'));
      await tester.pumpAndSettle();

      expect(find.text('Faire les courses'), findsOneWidget);
      expect(find.text('Installer Flutter'), findsOneWidget);
      expect(find.text('Relire le CM 01'), findsNothing);

      await tester.tap(find.text('Faire les courses'));
      await tester.pumpAndSettle();

      expect(find.text('État : faite'), findsOneWidget);

      final boutonRetour = find.widgetWithText(FilledButton, 'Marquer à faire');

      await tester.ensureVisible(boutonRetour);
      await tester.tap(boutonRetour);
      await tester.pumpAndSettle();

      expect(find.text('Faire les courses'), findsNothing);
      expect(find.text('5 à faire'), findsOneWidget);

      await tester.tap(find.text('À faire'));
      await tester.pumpAndSettle();

      expect(find.text('Faire les courses'), findsOneWidget);
    },
  );
}
