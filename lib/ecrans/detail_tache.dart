import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';
import 'formulaire_tache.dart';

class DetailTache extends StatelessWidget {
  const DetailTache({super.key, required this.tache, required this.aujourdhui});

  final Tache tache;
  final DateTime aujourdhui;

  Future<void> _modifier(BuildContext context) async {
    final modifiee = await Navigator.of(context).push<Tache>(
      MaterialPageRoute<Tache>(
        builder: (_) => FormulaireTache(id: tache.id, initiale: tache),
      ),
    );

    if (!context.mounted || modifiee == null) return;

    Navigator.of(context).pop<Tache>(modifiee);
  }

  @override
  Widget build(BuildContext context) {
    final enRetard = estEnRetard(tache, aujourdhui: aujourdhui);
    final couleurs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la tâche')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tache.titre, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Text('Priorité : ${tache.priorite.libelle}'),
            const SizedBox(height: 16),
            Text(
              'Échéance : ${libelleEcheance(tache.echeance)}',
              style: TextStyle(color: enRetard ? couleurs.error : null),
            ),
            if (enRetard) ...[
              const SizedBox(height: 8),
              Text('En retard', style: TextStyle(color: couleurs.error)),
            ],
            const SizedBox(height: 16),
            Text(tache.faite ? 'État : faite' : 'État : à faire'),
            const SizedBox(height: 24),
            Text('Note', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(tache.note ?? 'Aucune note'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                final modifiee = tache.copyWith(faite: !tache.faite);
                Navigator.of(context).pop<Tache>(modifiee);
              },
              icon: Icon(tache.faite ? Icons.undo : Icons.check),
              label: Text(
                tache.faite ? 'Marquer à faire' : 'Marquer comme faite',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _modifier(context),
              icon: const Icon(Icons.edit),
              label: const Text('Modifier'),
            ),
          ],
        ),
      ),
    );
  }
}
