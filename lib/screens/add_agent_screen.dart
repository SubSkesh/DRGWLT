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
      if (user == null) throw Exception('Utente non autenticato');

      await _personService.createPerson(
        name: _nameController.text.trim(),
        personType: _selectedType,
        ownerId: user.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getTypeLabel(_selectedType)} creato con successo!'),
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
        return 'Fornitore';
      case PersonType.buyer:
        return 'Acquirente';
      case PersonType.anon:
        return 'Agente anonimo';
    }
  }

  String _getTypeDescription(PersonType type) {
    switch (type) {
      case PersonType.supplier:
        return 'Persona o azienda da cui acquisti merci o servizi';
      case PersonType.buyer:
        return 'Persona o azienda a cui vendi merci o servizi';
      case PersonType.anon:
        return 'Contatto generico senza specifica di ruolo';
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
        title: const Text('Nuovo Agente'),
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
                            'Aggiungi un nuovo agente',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gli agenti ti aiutano a organizzare fornitori e clienti',
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
                  labelText: 'Nome agente',
                  hintText: 'Inserisci il nome completo o ragione sociale',
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
                    return 'Il nome è obbligatorio';
                  }
                  if (value.trim().length < 2) {
                    return 'Il nome deve avere almeno 2 caratteri';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),

              // Selezione tipo con card interattive
              Text(
                'Tipo di agente',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Scegli il ruolo principale di questo agente',
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
                    color: isSelected
                        ? _getTypeColor(type, theme).withOpacity(0.1)
                        : theme.cardTheme.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? _getTypeColor(type, theme)
                            : Colors.transparent,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getTypeIcon(type),
                        color: _getTypeColor(type, theme),
                        size: 28,
                      ),
                      title: Text(
                        _getTypeLabel(type),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(type, theme),
                        ),
                      ),
                      subtitle: Text(
                        _getTypeDescription(type),
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: isSelected
                          ? Icon(
                        Icons.check_circle,
                        color: _getTypeColor(type, theme),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
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
                      'CREA AGENTE',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
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