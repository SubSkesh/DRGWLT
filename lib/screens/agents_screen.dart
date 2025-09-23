// screens/agents_screen.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/widgets/drag_context_menu.dart' as drag_context_menu;
import 'package:drgwallet/services/person_service.dart';
import 'package:drgwallet/widgets/person_card.dart';
import 'package:async/async.dart';
import 'package:drgwallet/widgets/add_fab_agents.dart';

@RoutePage()
class AgentsScreen extends ConsumerStatefulWidget {
  const AgentsScreen({super.key});

  @override
  ConsumerState<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends ConsumerState<AgentsScreen> {
  final PersonService _personService = PersonService();
  PersonType _filterType = PersonType.anon; // 'all' is represented by anon
  void _onAddPressed(PersonType personType) {
    // Naviga alla schermata di aggiunta persona con il tipo pre-selezionato
    context.router.push(AddAgentRoute(initialType: personType));
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personsAsync = ref.watch(personsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agents'),
        actions: [
          PopupMenuButton<PersonType>(
            onSelected: (value) {
              setState(() => _filterType = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: PersonType.anon,
                child: Text('Tutti'),
              ),
              const PopupMenuItem(
                value: PersonType.supplier,
                child: Text('Fornitori'),
              ),
              const PopupMenuItem(
                value: PersonType.buyer,
                child: Text('Acquirenti'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: personsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Errore: $error')),
        data: (persons) {
          // Filtra le persone in base al tipo selezionato
          final filteredPersons = _filterType == PersonType.anon
              ? persons
              : persons.where((p) => p.personType == _filterType).toList();

          if (filteredPersons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _filterType == PersonType.anon
                        ? 'Nessun agente trovato'
                        : _filterType == PersonType.supplier
                        ? 'Nessun fornitore trovato'
                        : 'Nessun acquirente trovato',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  // ElevatedButton(
                  //   onPressed: () => _addNewPerson(context),
                  //   child: const Text('Aggiungi il primo agente'),
                  // ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredPersons.length,
            itemBuilder: (context, index) {
              final person = filteredPersons[index];
              return personCard(person: person,);
            },
          );
        },
      ),
        floatingActionButton: AddAgentsFloatingButton(
          onAddPressed: _onAddPressed,
    ),);
  }


  }

  // void _addNewPerson(BuildContext context) {
  //   context.router.push(const AddPersonRoute());
  // }

  // void _showPersonDetails(BuildContext context, Person person) {
  //   context.router.push(PersonDetailRoute(personId: person.id));
  // }

  void _showPersonContextMenu(
      BuildContext context,
      Offset position,
      Person person,
      ) async {
    final actions = [
      drag_context_menu.ContextAction(
        icon: Icons.edit,
        label: 'Modifica',
        color: Theme.of(context).colorScheme.primary,
      ),
      drag_context_menu.ContextAction(
        icon: Icons.delete,
        label: 'Elimina',
        color: Colors.red,
      ),
    ];

    final selectedIndex = await drag_context_menu.showDragContextMenu(
      context,
      position,
      actions,
      'person_${person.id}',
      mode: drag_context_menu.MenuOpenMode.dragToSelect,
    );

    if (selectedIndex != null) {
      switch (selectedIndex) {
        case 0:
          //_editPerson(context, person);
          break;
        case 1:
         // _deletePerson(context, person);
          break;
      }
    }
  }

  // void _editPerson(BuildContext context, Person person) {
  //   context.router.push(EditPersonRoute(person: person));
  // }

  // void _deletePerson(BuildContext context, Person person) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Conferma eliminazione'),
  //       content: Text(
  //         'Sei sicuro di voler eliminare "${person.name}"? '
  //             'Questa azione non può essere annullata.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Annulla'),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             try {
  //               await _personService.deletePerson(person.id);
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text('"${person.name}" eliminato con successo'),
  //                   backgroundColor: Colors.green,
  //                 ),
  //               );
  //               ref.refresh(personsProvider);
  //             } catch (e) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text('Errore durante l\'eliminazione: $e'),
  //                   backgroundColor: Colors.red,
  //                 ),
  //               );
  //             }
  //           },
  //           child: const Text(
  //             'Elimina',
  //             style: TextStyle(color: Colors.red),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // String _formatDate(DateTime date) {
  //   return '${date.day}/${date.month}/${date.year}';
  // }
// }