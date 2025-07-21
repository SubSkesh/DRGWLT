import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  Future<void> signOut() async => await _auth.signOut();

  Stream<User?> get userChanges => _auth.authStateChanges();
}

// Future<void> logout() async {
//   await FirebaseAuth.instance.signOut();
//   print("Utente disconnesso");
// }
