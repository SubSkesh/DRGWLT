import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/services/person_service.dart';
import 'package:drgwallet/services/local_image_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_auth/firebase_auth.dart';

@RoutePage()
class AddAgentScreen extends ConsumerStatefulWidget {
  final PersonType? initialType;
  final Person? personToEdit;

  const AddAgentScreen({
    super.key,
    this.initialType,
    this.personToEdit,
  });

  @override
  ConsumerState<AddAgentScreen> createState() => _AddAgentScreenState();
}

class _AddAgentScreenState extends ConsumerState<AddAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  late PersonType _selectedType;
  File? _newImageFile;
  File? _existingLocalImage;
  bool _isLoading = false;

  bool get _isEditing => widget.personToEdit != null;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? PersonType.anon;

    if (_isEditing) {
      _nameController.text = widget.personToEdit!.name;
      _selectedType = widget.personToEdit!.personType;
      _loadExistingImage();
    }
  }

  Future<void> _loadExistingImage() async {
    if (widget.personToEdit?.localImagePath != null) {
      final file = await LocalImageService.getAgentImage(widget.personToEdit!.localImagePath);
      if (mounted && file != null) {
        setState(() {
          _existingLocalImage = file;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- GESTIONE IMMAGINE (CORRETTA) ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        // Rimosso parametro top-level errato 'aspectRatioPresets'
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            // Definisci qui i preset per Android
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            // Definisci qui i preset per iOS
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _newImageFile = File(croppedFile.path);
        });
      }
    }
  }

  // --- SALVATAGGIO ---
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final personService = ref.read(personServiceProvider);
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user == null) throw Exception("User not logged in");

      if (_isEditing) {
        await personService.updatePerson(
          personId: widget.personToEdit!.id,
          name: _nameController.text.trim(),
          personType: _selectedType,
          ownerId: user.uid,
          imageFile: _newImageFile,
        );
      } else {
        await personService.createPerson(
          name: _nameController.text.trim(),
          personType: _selectedType,
          ownerId: user.uid,
          imageFile: _newImageFile,
        );
      }

      ref.invalidate(personsProvider);

      if (mounted) {
        context.router.pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Agent updated' : 'Agent created'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'New Agent'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator()))
          else
            TextButton(
              onPressed: _save,
              child: Text(
                'SAVE',
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. AVATAR PICKER
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Hero(
                      tag: _isEditing ? 'person_avatar_${widget.personToEdit!.id}' : 'new_avatar',
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.surfaceContainerHighest, width: 4),
                          image: _getAvatarImage(),
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        child: _getAvatarChild(theme),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.surface, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 2. NAME INPUT
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Enter Name',
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
              ),

              const SizedBox(height: 40),

              // 3. ROLE SELECTION
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ROLE',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildRoleCard(theme, PersonType.supplier, Icons.inventory_2_outlined, 'Supplier')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildRoleCard(theme, PersonType.buyer, Icons.shopping_bag_outlined, 'Buyer')),
                ],
              ),
              const SizedBox(height: 12),
              _buildRoleCard(theme, PersonType.anon, Icons.person_outline, 'Generic Contact', isFullWidth: true),

            ],
          ),
        ),
      ),
    );
  }

  // --- UI HELPERS ---

  DecorationImage? _getAvatarImage() {
    if (_newImageFile != null) {
      return DecorationImage(image: FileImage(_newImageFile!), fit: BoxFit.cover);
    }
    if (_existingLocalImage != null) {
      return DecorationImage(image: FileImage(_existingLocalImage!), fit: BoxFit.cover);
    }
    return null;
  }

  Widget? _getAvatarChild(ThemeData theme) {
    if (_newImageFile != null || _existingLocalImage != null) return null;
    return Icon(Icons.person, size: 60, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5));
  }

  Widget _buildRoleCard(ThemeData theme, PersonType type, IconData icon, String label, {bool isFullWidth = false}) {
    final isSelected = _selectedType == type;
    final activeColor = type == PersonType.supplier ? Colors.blue : (type == PersonType.buyer ? Colors.green : Colors.grey);
    final borderColor = isSelected ? activeColor : theme.colorScheme.outline.withOpacity(0.1);
    final bgColor = isSelected ? activeColor.withOpacity(0.1) : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3);

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? activeColor : theme.colorScheme.onSurfaceVariant, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}