import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drgwallet/screens/loginscreen.dart';
import 'package:drgwallet/screens/homescreen.dart';
import 'package:drgwallet/screens/splashscreen.dart';
import 'package:drgwallet/screens/welcomescreen.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(name: 'AuthGateRoute')

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),//emette un oggetto user:- All’avvio, emette l’ultimo stato (utente loggato o null), si aggiorna ad ogni refresh o quando scade la sessione

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return WelcomeScreen();
      },
    );

  }
}
