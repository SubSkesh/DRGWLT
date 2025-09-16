// lib/widgets/radial_action.dart
import 'package:flutter/material.dart';

typedef RadialActionCallback = void Function();

class RadialAction {
  final IconData icon;
  final String label;
  final Color? color;
  final RadialActionCallback onSelect;
  final double innerRadius;
  final double outerRadius;


  const RadialAction({
    required this.icon,
    required this.label,
    required this.onSelect,
    this.color,
    this.innerRadius = 40,   // raggio interno "vuoto"
    this.outerRadius = 120,  // raggio esterno menu
  });
}
