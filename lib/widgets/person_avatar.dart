// person_avatar.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:drgwallet/models/person.dart';

class PersonAvatar extends StatelessWidget {
  final Person person;
  final double size;

  const PersonAvatar({
    super.key,
    required this.person,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    // Prima prova con l'immagine locale
    if (person.localImagePath != null && person.localImagePath!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(File(person.localImagePath!)),
      );
    }
    // Poi con la photoUrl
    else if (person.photoUrl != null && person.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(person.photoUrl!),
      );
    }
    // Infine icona di default basata sul tipo
    else {
      final icon = _getPersonIcon(person.personType);
      final color = _getPersonColor(person.personType);
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color, size: size * 0.6),
      );
    }
  }

  IconData _getPersonIcon(PersonType type) {
    switch (type) {
      case PersonType.supplier:
        return Icons.local_shipping;
      case PersonType.buyer:
        return Icons.shopping_cart;
      case PersonType.anon:
        return Icons.person;
    }
  }

  Color _getPersonColor(PersonType type) {
    switch (type) {
      case PersonType.supplier:
        return Colors.blue;
      case PersonType.buyer:
        return Colors.green;
      case PersonType.anon:
        return Colors.grey;
    }
  }
}