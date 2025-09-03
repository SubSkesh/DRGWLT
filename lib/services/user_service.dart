import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:drgwallet/models/user.dart' as model;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  /// Crea o aggiorna il profilo utente su Firestore
  Future<void> createUserProfile(model.User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  /// Recupera il profilo utente da Firestore e calcola walletCount
  Future<model.User> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception("User not found");
    }

    // Conta quanti wallet possiede
    final walletSnap = await _firestore
        .collection('wallets')
        .where('owner', isEqualTo: uid)
        .get();

    final user = model.User.fromMap(doc.data()!);
    return user.copyWith(walletCount: walletSnap.size);
  }

  /// Aggiorna il profilo utente
  Future<void> updateUserProfile(model.User user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  /// Comodo: recupera utente loggato con i suoi dati
  Future<model.User?> getCurrentUser() async {
    final fb.User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return getUserProfile(firebaseUser.uid);
  }
}
