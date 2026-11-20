import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../donnees/exemples.dart';
import '../modele/taches.dart';
import '../widgets/tuile_tache.dart';
import 'detail_tache.dart';

enum FiltreTaches { toutes, aFaire, faites }

class ListeTaches extends StatefulWidget {
  const ListeTaches({super.key});

  @override
  State<ListeTaches> createState() => _ListeTachesState();
}

class _ListeTachesState extends State<ListeTaches> {
  late final List<Tache> _taches;
  int _prochainNumero = 1;
  FiltreTaches _filtre = FiltreTaches.toutes;

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

  Future<void> _ouvrirTache(Tache tache) async {
    final modifiee = await Navigator.of(context).push<Tache>(
      MaterialPageRoute<Tache>(
        builder: (_) => DetailTache(tache: tache, aujourdhui: DateTime.now()),
      ),
    );
    if (!mounted || modifiee == null) return;

    final index = _taches.indexWhere((element) => element.id == modifiee.id);

    if (index == -1) return;

    setState(() {
      _taches[index] = modifiee;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statistiques = bilan(_taches);
    final restantes = statistiques.total - statistiques.faites;
    final visibles = _taches.where((tache) {
      return switch (_filtre) {
        FiltreTaches.toutes => true,
        FiltreTaches.aFaire => !tache.faite,
        FiltreTaches.faites => tache.faite,
      };
    }).toList();
    final aujourdhui = DateTime.now();
    final messageVide = switch (_filtre) {
      FiltreTaches.toutes => 'Aucune tâche',
      FiltreTaches.aFaire => 'Aucune tâche à faire',
      FiltreTaches.faites => 'Aucune tâche faite',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('$restantes à faire'),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<FiltreTaches>(
              segments: const [
                ButtonSegment(
                  value: FiltreTaches.toutes,
                  label: Text('Toutes'),
                ),
                ButtonSegment(
                  value: FiltreTaches.aFaire,
                  label: Text('À faire'),
                ),
                ButtonSegment(
                  value: FiltreTaches.faites,
                  label: Text('Faites'),
                ),
              ],
              selected: {_filtre},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                setState(() {
                  _filtre = selection.single;
                });
              },
            ),
          ),
          Expanded(
            child: visibles.isEmpty
                ? Center(child: Text(messageVide))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: visibles.length,
                    itemBuilder: (context, index) {
                      final tache = visibles[index];

                      return TuileTache(
                        key: ValueKey(tache.id),
                        tache: tache,
                        aujourdhui: aujourdhui,
                        onBasculer: () => _basculerTache(tache),
                        onOuvrir: () => _ouvrirTache(tache),
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
