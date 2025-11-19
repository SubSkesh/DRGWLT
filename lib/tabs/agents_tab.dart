import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/services/person_service.dart';
import 'package:drgwallet/theme/app_theme.dart';
import 'package:drgwallet/widgets/add_fab_agents.dart';
import 'package:drgwallet/widgets/drag_context_menu.dart' as drag_context_menu;
import 'package:drgwallet/widgets/person_card.dart';

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
        label: 'Modify',
        color: Theme.of(context).colorScheme.primary,
      ),
      drag_context_menu.ContextAction(
        icon: Icons.delete,
        label: 'Delete',
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
    // Naviga alla schermata di modifica
    context.router.push(
        AddAgentRoute(
          initialType: person.personType,
          personToEdit: person,
        )
    );
  }

  void _deletePerson(BuildContext context, Person person) {
    final theme = Theme.of(context);
    final destructiveButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.error,
      foregroundColor: theme.colorScheme.onError,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error, size: 28),
            const SizedBox(width: 8), // Spaziatura
            const Text('Confirm Delete'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
            children: [
              const TextSpan(text: "Are you sure you want to delete \""),
              TextSpan(
                text: person.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: "\"?\nThis action cannot be undone."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Undo'),
          ),
          ElevatedButton(
            style: destructiveButtonStyle,
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
                // ref.refresh non è strettamente necessario con gli stream, ma ok
                ref.refresh(personsProvider);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting agent: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
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
          Icon(
            Icons.people_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _filterType == PersonType.anon
                ? 'No agents found'
                : _filterType == PersonType.supplier
                ? 'No supplier agents found'
                : 'No customer agents found',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
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
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      // FIX: Parametro gridDelegate aggiunto
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredPersons.length,
      itemBuilder: (context, index) {
        final person = filteredPersons[index];
        return PersonGridCard(
          key: ValueKey(person.id),
          person: person,
          // FIX: Tap per modificare
          onTap: () {
            context.router.push(
                AddAgentRoute(
                  initialType: person.personType,
                  personToEdit: person,
                )
            );
          },
          onLongPress: (details) {
            _showPersonContextMenu(context, details.globalPosition, person);
          },
        );
      },
    );
  }

  Widget _buildAgentsContent() {
    final personsAsync = ref.watch(personsProvider);

    return personsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
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
        title: Text(
          'Agents',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
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
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: PersonType.supplier,
                child: Text('Suppliers'),
              ),
              const PopupMenuItem(
                value: PersonType.buyer,
                child: Text('Buyers'),
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