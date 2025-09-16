import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import '../router/router.dart';

@RoutePage(name: 'AuthGateRoute')
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (user) {
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {//"Aspetta che il frame corrente sia completamente costruito, poi esegui questo codice."
            context.router.replaceAll([const HomeRoute()]);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.router.replaceAll([const WelcomeRoute()]);
          });
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}