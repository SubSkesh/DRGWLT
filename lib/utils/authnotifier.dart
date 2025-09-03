import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class AuthNotifier extends ChangeNotifier {
  late final Stream<User?> _authStream;
  late final StreamSubscription _subscription;

  AuthNotifier() {
    _authStream = FirebaseAuth.instance.authStateChanges();
    _subscription = _authStream.listen((_) {
      notifyListeners(); // ogni volta che cambia lo stato, notifica gli ascoltatori
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
