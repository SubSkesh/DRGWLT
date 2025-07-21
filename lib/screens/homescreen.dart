import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drgwallet/services/firebase_authservice.dart';
import 'package:auto_route/auto_route.dart';
@RoutePage()

class HomeScreen extends StatelessWidget {
  // Istanza locale del servizio, così non tocchiamo AuthService
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {

        final user =FirebaseAuth.instance.currentUser; // riceve i dati

        return Scaffold(
          appBar: AppBar(
            title: Text('Home'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                tooltip: 'Esci',
                onPressed: () async {
                  await authService.signOut();
                  // AuthGate si occuperà di ripristinare la LoginPage
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Benvenuto, ${user?.email ?? 'utente'}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.exit_to_app),
                  label: Text('Logout'),
                  onPressed: () async {
                    await authService.signOut();
                  },
                ),
              ],
            ),
          ),
        );
      }

}