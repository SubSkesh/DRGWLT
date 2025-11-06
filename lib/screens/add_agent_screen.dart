import 'dart:io';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/services/person_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

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
  File? _image;
  final _picker = ImagePicker();

  PersonType _selectedType = PersonType.supplier;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    } else {
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
        imageFile: _image,
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

        context.router.pop();
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

  // 🎯 METODO PER RITAGLIARE L'IMMAGINE (SEMPLIFICATO)
  Future<void> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Quadrato
        compressQuality: 85,
        maxWidth: 500,
        maxHeight: 500,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop image',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error into cropping: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 📸 METODO SEMPLIFICATO PER SCATTARE FOTO
  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        await _cropImage(file); // ← RITAGLIO AUTOMATICO
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore scatto foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🖼️ METODO SEMPLIFICATO PER GALLERIA
  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        await _cropImage(file); // ← RITAGLIO AUTOMATICO
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore selezione galleria: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // WIDGET PER ICON BUTTON
  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: 24),
            color: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Agent',
          style: theme.textTheme.headlineLarge!.copyWith(color: theme.colorScheme.primary, ),
        ),
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
              // Sezione immagine
              Center(
                child: Column(
                  children: [
                    _image != null
                        ? CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_image!),
                    )
                        : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surface,
                        border: Border.all(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // DUE ICON BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton(
                          icon: Icons.camera_alt,
                          label: 'Take Photo',
                          onPressed: _takePhoto,
                          theme: theme,
                        ),
                        const SizedBox(width: 20),
                        _buildIconButton(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          onPressed: _pickFromGallery,
                          theme: theme,
                        ),
                      ],
                    ),
                  ],
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

              // Titolo sezione tipo agente
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

              // SEZIONE SCROLLABILE
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: PersonType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return Card(
                        elevation: isSelected ? 4 : 1,
                        color: theme.colorScheme.surface,
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
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.grey,
                            size: 28,
                          ),
                          title: Text(
                            _getTypeLabel(type),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.grey,
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
                ),
              ),

              const SizedBox(height: 16),

              // Pulsante di creazione
              ElevatedButton(
                onPressed: _isLoading ? null : _createAgent,
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