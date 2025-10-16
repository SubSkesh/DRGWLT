import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/services/person_service.dart';
import 'package:drgwallet/theme/app_theme.dart';
import 'package:drgwallet/widgets/person_card.dart';
import 'package:drgwallet/widgets/add_fab_agents.dart';
import 'package:drgwallet/widgets/drag_context_menu.dart' as drag_context_menu;

class AgentsTab extends ConsumerStatefulWidget {
  const AgentsTab({super.key});

  @override
  ConsumerState<AgentsTab> createState() => _AgentsTabState();
}

class _AgentsTabState extends ConsumerState<AgentsTab> {
  PersonType _filterType = PersonType.anon;
  final PersonService _personService = PersonService();

  void _onAddPressed(PersonType? personType) {
    context.router.push(AddAgentRoute(initialType: personType));
  }

  void _addNewPerson() {
    context.router.push(AddAgentRoute(initialType: null));
  }

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
          _editPerson(context, person);
          break;
        case 1:
          _deletePerson(context, person);
          break;
      }
    }
  }

  void _editPerson(BuildContext context, Person person) {
    // Implementa la modifica della persona
    // context.router.push(EditPersonRoute(person: person));
    print('Modifica persona: ${person.name}');
  }

  void _deletePerson(BuildContext context, Person person) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete "${person.name}"? '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Undo'),
          ),
          TextButton(style: Theme.of(context).textButtonTheme.style ,
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _personService.deletePerson(person.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${person.name}" successfully deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                ref.refresh(personsProvider);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Errore durante l\'eliminazione: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Elimina',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAgentsState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _filterType == PersonType.anon
                ? 'No agents found'
                : _filterType == PersonType.supplier
                ? 'No supplier agents found'
                : 'No customer agents found',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _addNewPerson,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add new agent'),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsList(List<Person> filteredPersons) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPersons.length,
      itemBuilder: (context, index) {
        final person = filteredPersons[index];
        return GestureDetector(
          onLongPressStart: (details) {
            _showPersonContextMenu(context, details.globalPosition, person);
          },
          child: personCard(person: person),
        );
      },
    );
  }

  Widget _buildAgentsContent() {
    final personsAsync = ref.watch(personsProvider);

    return personsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Errore: $error')),
      data: (persons) {
        final filteredPersons = _filterType == PersonType.anon
            ? persons
            : persons.where((p) => p.personType == _filterType).toList();

        if (filteredPersons.isEmpty) {
          return _buildEmptyAgentsState();
        }

        return _buildAgentsList(filteredPersons);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:  Text('Agents', style: theme.textTheme.headlineLarge?.copyWith(
          color: theme.colorScheme.primary),),

        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
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
            icon: Icon(Icons.filter_list, color: theme.iconTheme.color),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.account_circle, color: theme.iconTheme.color),
          onPressed: () => context.router.push(const ProfileRoute()),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildAgentsContent(),
      floatingActionButton: AddAgentsFloatingButton(
        onAddPressed: _onAddPressed,
      ),
    );
  }
}