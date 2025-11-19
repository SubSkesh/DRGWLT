import 'dart:io';
import 'package:flutter/material.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/services/local_image_service.dart';

class PersonGridCard extends StatefulWidget {
  final Person person;
  final Function(LongPressStartDetails details)? onLongPress;
  final VoidCallback? onTap; // <--- 1. AGGIUNGI QUESTO

  const PersonGridCard({
    super.key,
    required this.person,
    this.onLongPress,
    this.onTap, // <--- 2. AGGIUNGI QUESTO
  });

  @override
  State<PersonGridCard> createState() => _PersonGridCardState();
}

class _PersonGridCardState extends State<PersonGridCard> {
  File? _agentImage;

  @override
  void initState() {
    super.initState();
    _loadAgentImage();
  }

  @override
  void didUpdateWidget(PersonGridCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.person.id != widget.person.id ||
        oldWidget.person.localImagePath != widget.person.localImagePath) {
      setState(() {
        _agentImage = null;
      });
      _loadAgentImage();
    }
  }

  Future<void> _loadAgentImage() async {
    if (widget.person.localImagePath != null) {
      final image = await LocalImageService.getAgentImage(widget.person.localImagePath);
      if (mounted) {
        setState(() {
          _agentImage = image;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap, // <--- 3. COLLEGALO QUI
      onLongPressStart: widget.onLongPress,
      child: Container(
        // Il resto del widget rimane invariato...
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAgentAvatar(theme),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.person.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... _buildAgentAvatar e altri metodi helper rimangono uguali ...
  Widget _buildAgentAvatar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _agentImage != null
          ? CircleAvatar(
        radius: 40,
        backgroundImage: FileImage(_agentImage!),
      )
          : CircleAvatar(
        radius: 40,
        backgroundColor: _getTypeColor(widget.person.personType, theme).withOpacity(0.2),
        child: Icon(
          _getTypeIcon(widget.person.personType),
          size: 32,
          color: _getTypeColor(widget.person.personType, theme),
        ),
      ),
    );
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
}