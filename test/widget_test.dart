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
}
