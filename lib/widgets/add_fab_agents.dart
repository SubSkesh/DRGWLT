// widgets/add_agents_fab.dart
import 'package:flutter/material.dart';
import 'package:drgwallet/models/person.dart';

class AddAgentsFloatingButton extends StatelessWidget {
  final Function(PersonType) onAddPressed;

  const AddAgentsFloatingButton({
    super.key,
    required this.onAddPressed,
  });

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Nuovo Agente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.inventory, color: Colors.blue),
                title: const Text('Fornitore'),
                subtitle: const Text('Da cui acquisti merci'),
                onTap: () {
                  Navigator.pop(context);
                  onAddPressed(PersonType.supplier);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.green),
                title: const Text('Acquirente'),
                subtitle: const Text('A cui vendi merci'),
                onTap: () {
                  Navigator.pop(context);
                  onAddPressed(PersonType.buyer);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.grey),
                title: const Text('Contatto generico'),
                subtitle: const Text('Senza ruolo specifico'),
                onTap: () {
                  Navigator.pop(context);
                  onAddPressed(PersonType.anon);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddMenu(context),
      child: const Icon(Icons.person_add),
      tooltip: 'Aggiungi agente',
    );
  }
}