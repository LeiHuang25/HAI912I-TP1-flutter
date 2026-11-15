import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../donnees/exemples.dart';
import '../modele/taches.dart';

class ListeTaches extends StatefulWidget {
  const ListeTaches({super.key});

  @override
  State<ListeTaches> createState() => _ListeTachesState();
}

class _ListeTachesState extends State<ListeTaches> {
  late final List<Tache> _taches;
  int _prochainNumero = 1;

  @override
  void initState() {
    super.initState();

    final documents = jsonDecode(tachesExempleJson) as List<dynamic>;

    _taches = [
      for (final document in documents)
        tacheDepuisJson(Map<String, Object?>.from(document as Map)),
    ];
  }

  void _ajouterExemple() {
    String id;

    do {
      id = 'ajout-${_prochainNumero++}';
    } while (_taches.any((tache) => tache.id == id));

    final nouvelle = Tache(id: id, titre: 'Nouvelle tâche $id');

    setState(() {
      _taches.add(nouvelle);
    });
  }

  void _basculerTache(Tache tache) {
    final index = _taches.indexWhere((element) => element.id == tache.id);

    if (index == -1) return;

    final actuelle = _taches[index];

    setState(() {
      _taches[index] = actuelle.copyWith(faite: !actuelle.faite);
    });
  }

  @override
  Widget build(BuildContext context) {
    final statistiques = bilan(_taches);
    final restantes = statistiques.total - statistiques.faites;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('$restantes à faire'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _taches.length,
              itemBuilder: (context, index) {
                final tache = _taches[index];

                return ListTile(
                  leading: Checkbox(
                    key: ValueKey('faite-${tache.id}'),
                    value: tache.faite,
                    onChanged: (_) => _basculerTache(tache),
                  ),
                  title: Text(tache.titre),
                  subtitle: Text(tache.priorite.libelle),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterExemple,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}
