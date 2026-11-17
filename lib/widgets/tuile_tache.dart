import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';

class TuileTache extends StatelessWidget {
  const TuileTache({
    super.key,
    required this.tache,
    required this.aujourdhui,
    required this.onBasculer,
    this.onOuvrir,
  });

  final Tache tache;
  final DateTime aujourdhui;
  final VoidCallback onBasculer;
  final VoidCallback? onOuvrir;

  @override
  Widget build(BuildContext context) {
    final enRetard = estEnRetard(tache, aujourdhui: aujourdhui);
    final couleurs = Theme.of(context).colorScheme;
    final couleurPriorite = switch (tache.priorite) {
      Priorite.basse => couleurs.onSurfaceVariant,
      Priorite.normale => couleurs.primary,
      Priorite.haute => couleurs.error,
    };

    return ListTile(
      leading: Checkbox(
        key: ValueKey('faite-${tache.id}'),
        value: tache.faite,
        onChanged: (_) => onBasculer(),
      ),
      title: Text(
        tache.titre,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          decoration: tache.faite
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      subtitle: Text(
        libelleEcheance(tache.echeance),
        style: TextStyle(
          color: enRetard ? couleurs.error : couleurs.onSurfaceVariant,
        ),
      ),
      trailing: Tooltip(
        message: 'Priorité : ${tache.priorite.libelle}',
        child: Icon(
          Icons.flag,
          color: couleurPriorite,
          semanticLabel: 'Priorité : ${tache.priorite.libelle}',
        ),
      ),
      onTap: onOuvrir,
    );
  }
}
