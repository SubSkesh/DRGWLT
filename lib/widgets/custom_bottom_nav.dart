import 'package:flutter/material.dart';
import 'package:drgwallet/theme/app_theme.dart';


class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> actions;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.actions,
  });


  @override
  Widget build(BuildContext context) {
    final theme= Theme.of(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items:
        this.actions,
    );
  }
}