import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drgwallet/models/good.dart';
import 'package:drgwallet/models/enum.dart';

class GoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Crea un nuovo good
  Future<Good> createGood({
    required String name,
    required Unit baseUnit,
    required Category category,
    String? description,
    double? currentMarketPrice,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final goodRef = _firestore.collection('goods').doc();
    final now = DateTime.now();

    final good = Good(
      id: goodRef.id,//id generato automaticamente
      name: name,
      baseUnit: baseUnit,
      category: category,
      description: description,
      currentMarketPrice: currentMarketPrice,
      createdAt: now,
      lastUpdated: now,
    );

    await goodRef.set(good.toMap());

    return good;
  }

  /// Ottiene tutti i goods di un utente
  Stream<List<Good>> getUserGoods() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    return _firestore
        .collection('goods')
        .where('ownerId', isEqualTo: user.uid) // Assicurati di aggiungere ownerId al modello Good
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      if (data != null && data is Map<String, dynamic>) {
        return Good.fromMap(data, doc.id);
      } else {
        throw Exception('Dati del good nulli o tipo non valido');
      }
    })
        .toList());
  }

  /// Ottiene un good specifico per ID
  Future<Good> getGood(String goodId) async {
    final doc = await _firestore.collection('goods').doc(goodId).get();

    if (!doc.exists) {
      throw Exception('Good non trovato');
    }

    final data = doc.data();
    if (data != null && data is Map<String, dynamic>) {
      return Good.fromMap(data, doc.id);
    } else {
      throw Exception('Dati del good nulli o tipo non valido');
    }
  }

  /// Ottiene multiple goods per IDs
  Future<List<Good>> getGoodsByIds(List<String> goodIds) async {
    if (goodIds.isEmpty) return [];

    final snapshot = await _firestore
        .collection('goods')
        .where(FieldPath.documentId, whereIn: goodIds)
        .get();

    return snapshot.docs
        .map((doc) {
      final data = doc.data();
      if (data != null && data is Map<String, dynamic>) {
        return Good.fromMap(data, doc.id);
      } else {
        throw Exception('Dati del good nulli o tipo non valido');
      }
    })
        .toList();
  }

  /// Aggiorna un good esistente
  Future<void> updateGood(Good good) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final goodRef = _firestore.collection('goods').doc(good.id);
    final goodDoc = await goodRef.get();

    if (!goodDoc.exists) {
      throw Exception('Good non trovato');
    }

    final data = goodDoc.data();
    if (data != null && data is Map<String, dynamic>) {
      if (data['ownerId'] != user.uid) {
        throw Exception('Non autorizzato');
      }

      await goodRef.update({
        'name': good.name,
        'baseUnit': good.baseUnit.toString().split('.').last,
        'category': good.category.toString().split('.').last,
        'description': good.description,
        'currentMarketPrice': good.currentMarketPrice,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('Dati del good nulli o tipo non valido');
    }
  }

  /// Elimina un good
  Future<void> deleteGood(String goodId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final goodRef = _firestore.collection('goods').doc(goodId);
    final goodDoc = await goodRef.get();

    if (!goodDoc.exists) {
      throw Exception('Good non trovato');
    }

    final data = goodDoc.data();
    if (data != null && data is Map<String, dynamic>) {
      if (data['ownerId'] != user.uid) {
        throw Exception('Non autorizzato');
      }

      await goodRef.delete();
    } else {
      throw Exception('Dati del good nulli o tipo non valido');
    }
  }

  /// Filtra goods per categoria
  Stream<List<Good>> getGoodsByCategory(Category category) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final categoryString = category.toString().split('.').last;

    return _firestore
        .collection('goods')
        .where('ownerId', isEqualTo: user.uid)
        .where('category', isEqualTo: categoryString)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      if (data != null && data is Map<String, dynamic>) {
        return Good.fromMap(data, doc.id);
      } else {
        throw Exception('Dati del good nulli o tipo non valido');
      }
    })
        .toList());
  }

  /// Cerca goods per nome
  Stream<List<Good>> searchGoods(String query) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    return _firestore
        .collection('goods')
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      if (data != null && data is Map<String, dynamic>) {
        return Good.fromMap(data, doc.id);
      } else {
        throw Exception('Dati del good nulli o tipo non valido');
      }
    })
        .where((good) => good.name.toLowerCase().contains(query.toLowerCase()))
        .toList());
  }
}