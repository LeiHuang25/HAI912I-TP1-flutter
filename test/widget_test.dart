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

  testWidgets('crée une tâche et la rend visible dans la liste', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle tâche'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('champ-titre')),
      '  Préparer le rapport  ',
    );

    await tester.enterText(
      find.byKey(const ValueKey('champ-note')),
      '  Vérifier les captures  ',
    );

    final enregistrer = find.widgetWithText(FilledButton, 'Enregistrer');

    await tester.ensureVisible(enregistrer);
    await tester.tap(enregistrer);
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle tâche'), findsNothing);
    expect(find.text('6 à faire'), findsOneWidget);

    final nouveauTitre = find.text('Préparer le rapport');

    await tester.scrollUntilVisible(
      nouveauTitre,
      150,
      scrollable: find.byType(Scrollable),
    );

    await tester.tap(nouveauTitre);
    await tester.pumpAndSettle();

    expect(find.text('Priorité : Normale'), findsOneWidget);
    expect(find.text('Échéance : sans échéance'), findsOneWidget);
    expect(find.text('État : à faire'), findsOneWidget);
    expect(find.text('Vérifier les captures'), findsOneWidget);
  });

  testWidgets('quitter le formulaire sans enregistrer n’ajoute rien', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('champ-titre')),
      'Tâche abandonnée',
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('5 à faire'), findsOneWidget);
    expect(find.text('Tâche abandonnée'), findsNothing);
  });

  testWidgets('un titre vide ou composé d’espaces garde le formulaire ouvert', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    final enregistrer = find.widgetWithText(FilledButton, 'Enregistrer');

    await tester.ensureVisible(enregistrer);
    await tester.tap(enregistrer);
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle tâche'), findsOneWidget);
    expect(find.text('Le titre est obligatoire'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('champ-titre')), '   ');

    await tester.ensureVisible(enregistrer);
    await tester.tap(enregistrer);
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle tâche'), findsOneWidget);
    expect(find.text('Le titre est obligatoire'), findsOneWidget);
  });

  testWidgets('refuse un titre de 61 caractères puis accepte 60 caractères', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    final titre61 = List.filled(61, 'a').join();
    final titre60 = List.filled(60, 'a').join();
    final champTitre = find.byKey(const ValueKey('champ-titre'));
    final enregistrer = find.widgetWithText(FilledButton, 'Enregistrer');

    await tester.enterText(champTitre, titre61);
    await tester.ensureVisible(enregistrer);
    await tester.tap(enregistrer);
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle tâche'), findsOneWidget);
    expect(
      find.text('Le titre ne doit pas dépasser 60 caractères'),
      findsOneWidget,
    );

    await tester.enterText(champTitre, titre60);
    await tester.ensureVisible(enregistrer);
    await tester.tap(enregistrer);
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle tâche'), findsNothing);
    expect(find.text('6 à faire'), findsOneWidget);
  });

  testWidgets('refuse une note de 201 caractères puis accepte 200 caractères', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('champ-titre')),
      'Lire Dart',
    );

    final champNote = find.byKey(const ValueKey('champ-note'));
    final enregistrer = find.widgetWithText(FilledButton, 'Enregistrer');

    await tester.enterText(champNote, List.filled(201, 'a').join());
    await tester.ensureVisible(enregistrer);
    await tester.tap(enregistrer);
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle tâche'), findsOneWidget);
    expect(
      find.text('La note ne doit pas dépasser 200 caractères'),
      findsOneWidget,
    );

    await tester.enterText(champNote, List.filled(200, 'a').join());
    await tester.ensureVisible(enregistrer);
    await tester.tap(enregistrer);
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle tâche'), findsNothing);
    expect(find.text('6 à faire'), findsOneWidget);
  });

  testWidgets('une note composée d’espaces devient une absence de note', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('champ-titre')),
      'Tester la note vide',
    );
    await tester.enterText(find.byKey(const ValueKey('champ-note')), '   ');

    final enregistrer = find.widgetWithText(FilledButton, 'Enregistrer');

    await tester.ensureVisible(enregistrer);
    await tester.tap(enregistrer);
    await tester.pumpAndSettle();

    final titre = find.text('Tester la note vide');

    await tester.scrollUntilVisible(
      titre,
      150,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(titre);
    await tester.pumpAndSettle();

    expect(find.text('Aucune note'), findsOneWidget);
  });

  testWidgets('crée une tâche avec une échéance choisie dans le calendrier', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('champ-titre')),
      'Tâche avec date',
    );

    await tester.tap(find.text('Choisir une date'));
    await tester.pumpAndSettle();

    final dialogue = find.byType(DatePickerDialog);
    expect(dialogue, findsOneWidget);

    final calendrier = tester.widget<DatePickerDialog>(dialogue);
    final dateChoisie = calendrier.initialDate!;

    final maintenant = DateTime.now();
    final aujourdHui = DateTime(
      maintenant.year,
      maintenant.month,
      maintenant.day,
    );

    // Les dates antérieures à aujourd’hui sont exclues.
    expect(calendrier.firstDate, aujourdHui);

    final libelleConfirmer = MaterialLocalizations.of(tester.element(dialogue))
        .okButtonLabel;

    await tester.tap(
      find.descendant(of: dialogue, matching: find.text(libelleConfirmer)),
    );
    await tester.pumpAndSettle();

    final libelle = 'pour le ${dateChoisie.day}/${dateChoisie.month}';

    expect(find.text(libelle), findsOneWidget);

    final enregistrer = find.widgetWithText(FilledButton, 'Enregistrer');

    await tester.ensureVisible(enregistrer);
    await tester.tap(enregistrer);
    await tester.pumpAndSettle();

    expect(find.text('6 à faire'), findsOneWidget);

    final titre = find.text('Tâche avec date');

    await tester.scrollUntilVisible(
      titre,
      150,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(titre);
    await tester.pumpAndSettle();

    expect(find.text('Échéance : $libelle'), findsOneWidget);
  });
}
