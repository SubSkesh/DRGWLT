import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
//import '../router/router.dart';

@RoutePage(name: 'AuthGateRoute')
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _processingLogout = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (_processingLogout) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null && !_processingLogout) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.router.replaceAll([const HomeRoute()]);
              }
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.router.replaceAll([const WelcomeRoute()]);
              }
            });
          }
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}