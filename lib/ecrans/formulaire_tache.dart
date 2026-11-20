import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';

class FormulaireTache extends StatefulWidget {
  const FormulaireTache({super.key, required this.id});

  final String id;

  @override
  State<FormulaireTache> createState() => _FormulaireTacheState();
}

class _FormulaireTacheState extends State<FormulaireTache> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _noteController = TextEditingController();

  Priorite _priorite = Priorite.normale;
  DateTime? _date;

  Future<void> _choisirDate() async {
    final maintenant = DateTime.now();
    final aujourdHui = DateTime(
      maintenant.year,
      maintenant.month,
      maintenant.day,
    );

    final dateInitiale = _date;
    final initiale = dateInitiale == null || dateInitiale.isBefore(aujourdHui)
        ? aujourdHui
        : dateInitiale;
    final choix = await showDatePicker(
      context: context,
      initialDate: initiale,
      firstDate: aujourdHui,
      lastDate: DateTime(aujourdHui.year + 10, 12, 31),
    );

    if (!mounted || choix == null) return;

    setState(() {
      _date = choix;
    });
  }

  void _enregistrer() {
    if (!_formKey.currentState!.validate()) return;

    final note = _noteController.text.trim();
    final date = _date;

    final nouvelle = Tache(
      id: widget.id,
      titre: _titreController.text.trim(),
      priorite: _priorite,
      echeance: date == null ? const SansEcheance() : EcheanceDate(date),
      note: note.isEmpty ? null : note,
    );

    Navigator.of(context).pop<Tache>(nouvelle);
  }

  @override
  void dispose() {
    _titreController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = _date;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle tâche')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const ValueKey('champ-titre'),
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (valeur) {
                  final titre = valeur?.trim() ?? '';

                  if (titre.isEmpty) {
                    return 'Le titre est obligatoire';
                  }

                  if (titre.length > 60) {
                    return 'Le titre ne doit pas dépasser 60 caractères';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Priorite>(
                initialValue: _priorite,
                decoration: const InputDecoration(
                  labelText: 'Priorité',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final priorite in Priorite.values)
                    DropdownMenuItem(
                      value: priorite,
                      child: Text(priorite.libelle),
                    ),
                ],
                onChanged: (valeur) {
                  if (valeur == null) return;

                  setState(() {
                    _priorite = valeur;
                  });
                },
              ),
              const SizedBox(height: 20),
              FormField<DateTime>(
                validator: (_) {
                  final dateChoisie = _date;

                  if (dateChoisie == null) return null;

                  final maintenant = DateTime.now();
                  final aujourdHui = DateTime(
                    maintenant.year,
                    maintenant.month,
                    maintenant.day,
                  );
                  final jourChoisi = DateTime(
                    dateChoisie.year,
                    dateChoisie.month,
                    dateChoisie.day,
                  );
                  if (jourChoisi.isBefore(aujourdHui)) {
                    return 'La date ne peut pas être antérieure à aujourd’hui';
                  }
                  return null;
                },
                builder: (champ) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Échéance',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        date == null
                            ? 'sans échéance'
                            : libelleEcheance(EcheanceDate(date)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _choisirDate,
                            icon: const Icon(Icons.calendar_month),
                            label: const Text('Choisir une date'),
                          ),
                          if (date != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _date = null;
                                });
                              },
                              child: const Text('Retirer la date'),
                            ),
                        ],
                      ),
                      if (champ.hasError) ...[
                        const SizedBox(height: 8),
                        Text(
                          champ.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const ValueKey('champ-note'),
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Note facultative',
                  border: OutlineInputBorder(),
                ),
                validator: (valeur) {
                  final note = valeur?.trim() ?? '';

                  if (note.length > 200) {
                    return 'La note ne doit pas dépasser 200 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _enregistrer,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
