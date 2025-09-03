import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/theme/app_theme.dart';
import '../router.dart'; // importa il router generato

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    Future.wait([
      Firebase.initializeApp(),
      Future.delayed(const Duration(seconds: 2)),
    ]).then((_) {
      context.router.replace(const AuthGateRoute()); // Usa replace
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wallet,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'DRG Wallet',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            LoadingAnimationWidget.newtonCradle(
              color: theme.colorScheme.primary,
              size: 130,
            ),
          ],
        ),
      ),
    );
  }
}