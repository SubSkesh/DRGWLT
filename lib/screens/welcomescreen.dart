import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:drgwallet/theme/app_theme.dart';
import '../router.dart'; // per LoginRoute, RegisterRoute

@RoutePage()
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {//- Fornisce un Ticker: un “metronomo” che batte a ogni frame del displa

  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(//gestisce il tempo dell’animazione
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    // Avvia il fade-in all’apertura
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkTheme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo o Icona
                Icon(Icons.account_balance_wallet,
                    size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 24),

                // Titolo
                Text(
                  'Welcome',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge,

                ),
                const SizedBox(height: 16),

                // Sottotitolo
                Text(
                  'DrgWallet è lʼapp che ti aiuta a gestire le tue finanze in modo semplice e sicuro.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Elenco feature
                _buildFeature(
                  iconPath: 'assets/icons/profit.png',
                  text: 'Organizza al meglio ogni entrata e uscita.',
                  theme: theme,
                ),
                _buildFeature(
                  iconPath: 'assets/icons/savings.png',
                  text: 'Monitora i tuoi risparmi… con discrezione.',
                  theme: theme,
                ),
                _buildFeature(
                  iconPath: 'assets/icons/sercurityapp.png',
                  text: 'Affida tutto a un sistema facile e sicuro',
                  theme: theme,
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: () {
                    context.router.push(const SplashRoute());
                  },
                  child: const Text('Crea un account'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    context.router.push(const LoginRoute());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onPrimary,
                    backgroundColor: theme.colorScheme.primary,

                  ),
                  child: const Text('Accedi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

Widget _buildFeature({
  required String iconPath,
  required String text,
  required ThemeData theme,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        // per PNG:
         Image.asset(iconPath, width: 24, height: 24, color: theme.colorScheme.primary),


        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ],
    ),
  );
}

