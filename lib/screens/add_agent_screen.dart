// screens/add_agent_screen.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/services/person_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

@RoutePage()
class AddAgentScreen extends ConsumerStatefulWidget {
  final PersonType? initialType;

  const AddAgentScreen({super.key, this.initialType});

  @override
  ConsumerState<AddAgentScreen> createState() => _AddAgentScreenState();
}

class _AddAgentScreenState extends ConsumerState<AddAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _personService = PersonService();

  PersonType _selectedType = PersonType.supplier;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Imposta il tipo iniziale se fornito
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    else {
      _selectedType = PersonType.anon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createAgent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _personService.createPerson(
        name: _nameController.text.trim(),
        personType: _selectedType,
        ownerId: user.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getTypeLabel(_selectedType)} Agent created'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Torna indietro dopo il successo
        context.router.pop();

        // Refresh della lista agenti
        ref.invalidate(personsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la creazione: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getTypeLabel(PersonType type) {
    switch (type) {
      case PersonType.supplier:
        return 'Supplier';
      case PersonType.buyer:
        return 'Buyer';
      case PersonType.anon:
        return 'Anon';
    }
  }

  String _getTypeDescription(PersonType type) {
    switch (type) {
      case PersonType.supplier:
        return 'Person or company from whom you purchase goods or services';
      case PersonType.buyer:
        return 'Person or company to whom you sell goods or services';
      case PersonType.anon:
        return 'Generic contact without a specific role';

    }
  }

  IconData _getTypeIcon(PersonType type) {
    switch (type) {
      case PersonType.supplier:
        return Icons.inventory;
      case PersonType.buyer:
        return Icons.shopping_cart;
      case PersonType.anon:
        return Icons.person_outline;
    }
  }

  Color _getTypeColor(PersonType type, ThemeData theme) {
    switch (type) {
      case PersonType.supplier:
        return theme.colorScheme.primary;
      case PersonType.buyer:
        return theme.colorScheme.secondary;
      case PersonType.anon:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:  Text('New Agent',style: theme.textTheme.titleLarge,),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => context.router.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card di benvenuto
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add new agent',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Akira'
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agents help you to organize suppliers and buyers',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Campo nome
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Agent name',
                  hintText: 'Insert full name or company name',
                  hintStyle: theme.textTheme.bodyMedium,
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return ' Name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters long';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),

              // Selezione tipo con card interattive
              Text(
                'Agent type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Akira',
                ),
              ),
              Text(
                'Choose the type of agent you want to create',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),

              // Card selezione tipo
              Column(
                children: PersonType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return Card(
                    elevation: isSelected ? 4 : 1,
                    color:
                    // isSelected
                    //     ? _getTypeColor(type, theme).withOpacity(0.1)
                    //     :
                    theme.colorScheme.surface,//cardTheme.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getTypeIcon(type),
                        color:isSelected ? theme.colorScheme.primary : Colors.grey,
                        size: 28,
                      ),
                      title: Text(
                        _getTypeLabel(type),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? theme.colorScheme.primary : Colors.grey,
                        ),
                      ),
                      subtitle: Text(
                        _getTypeDescription(type),
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: isSelected
                          ? Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      )
                          : null,
                      onTap: () {
                        setState(() => _selectedType = type);
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // Pulsante di creazione
              ElevatedButton(
                onPressed: _isLoading ? null : _createAgent,
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: theme.colorScheme.primary,
                //   foregroundColor: theme.colorScheme.onPrimary,
                //   padding: const EdgeInsets.symmetric(vertical: 16),
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   elevation: 2,
                // ),
                style: theme.elevatedButtonTheme.style,
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_add, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'CREATE AGENT',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}