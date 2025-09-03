import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/utils/wallet_calculator.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  /// Crea un nuovo wallet Firestore
  Future<Wallet> createWallet(String name, {String? desc}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final walletRef = _firestore.collection('wallets').doc();
    final now = DateTime.now();

    await walletRef.set({
      'owner': user.uid,
      'name': name,
      'desc': desc ?? '',
      'createdAt': Timestamp.fromDate(now),
    });

    return Wallet(
      id: walletRef.id,
      ownerID: user.uid,
      name: name,
      desc: desc,
      createdAt: now,
    );
  }

  /// Restituisce tutti i wallet di un utente (senza metriche calcolate)
  Stream<List<Wallet>> getUserWallets() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    return _firestore
        .collection('wallets')
        .where('owner', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()// CREA UNO STREAM DI DATI DA FIRESTORE di wallet ordinati in ordine discendente e che matchino con l'id dell'utente corrente
        .map((snapshot) => snapshot.docs.map((doc) {// la mappa interna mappa i documenti in oggetti wallet e li aggiunge alla lista la mappa esterna crea una lista di wallet
      final data = doc.data();
      if (data != null) {
        return Wallet(
          id: doc.id,
          ownerID: data['owner'] as String,
          name: data['name'] as String,
          desc: data['desc'] as String?,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      } else {
        throw Exception('Dati del wallet nulli');
      }
    }).toList());
  }
  Stream<Wallet> getWalletStream(String walletId) {
    return _firestore.collection('wallets').doc(walletId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Wallet non trovato');
      }
      // Passa la mappa dei dati E l'ID come parametri separati
      return Wallet.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Stream<List<Deal>> getWalletDealsStream(String walletId) {
    return _firestore.collection('deals')
        .where('walletId', isEqualTo: walletId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      // Stessa logica per Deal, se anche lui ha fromMap con 2 parametri
      return Deal.fromMap(doc.data(), doc.id);
    }).toList());
  }
  /// Ottiene i deals per un wallet specifico con filtri opzionali
  Future<List<Deal>> getWalletDeals(
      String walletId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    Query query = _firestore
        .collection('deals')
        .where('walletId', isEqualTo: walletId)
        .orderBy('date', descending: true);

    // Applica filtri data se forniti
    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      if (data != null && data is Map<String, dynamic>) {
        return Deal.fromMap(data, doc.id);
      } else {
        throw Exception('Dati del deal nulli');
      }
    }).toList();
  }

  /// Carica un wallet completo con statistiche calcolate per un periodo specifico
  Future<Wallet> getWalletWithStats(
      String walletId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    final walletDoc = await _firestore.collection('wallets').doc(walletId).get();

    if (!walletDoc.exists) {
      throw Exception('Wallet non trovato');
    }

    final data = walletDoc.data();
    if (data == null) {
      throw Exception('Dati del wallet nulli');
    }

    final baseWallet = Wallet(
      id: walletDoc.id,
      ownerID: data['owner'] as String,
      name: data['name'] as String,
      desc: data['desc'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );

    final deals = await getWalletDeals(
      walletId,
      startDate: startDate,
      endDate: endDate,
    );

    return WalletCalculator.enrichWithCalculations(
      wallet: baseWallet,
      deals: deals,
      goods: [],
    );
  }

  /// Ottiene statistiche del wallet per periodo
  Future<Map<String, dynamic>> getWalletStatsByPeriod(
      String walletId, {
        required DateTime startDate,
        required DateTime endDate,
      }) async {
    final deals = await getWalletDeals(
      walletId,
      startDate: startDate,
      endDate: endDate,
    );

    final wallet = await getWalletWithStats(
      walletId,
      startDate: startDate,
      endDate: endDate,
    );

    return {
      'wallet': wallet,
      'periodDeals': deals.length,
      'periodSpent': wallet.totalSpent,
      'periodEarned': wallet.totalEarned,
      'periodNetProfit': wallet.netProfit,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
// Aggiungi questo metodo al WalletService
  Future<int> getWalletDealsCount(String walletId) async {
    final snapshot = await _firestore
        .collection('deals')
        .where('walletId', isEqualTo: walletId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }
  /// Aggiorna un wallet esistente
  Future<void> updateWallet(String walletId, String newName, {String? newDesc}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final walletRef = _firestore.collection('wallets').doc(walletId);
    final walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      throw Exception('Wallet non trovato');
    }

    final data = walletDoc.data();
    if (data == null || data['owner'] != user.uid) {
      throw Exception('Wallet non trovato o non autorizzato');
    }

    await walletRef.update({
      'name': newName,
      'desc': newDesc ?? '',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Elimina un wallet
  Future<void> deleteWallet(String walletId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final walletRef = _firestore.collection('wallets').doc(walletId);
    final walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      throw Exception('Wallet non trovato');
    }

    final data = walletDoc.data();
    if (data == null || data['owner'] != user.uid) {
      throw Exception('Wallet non trovato o non autorizzato');
    }

    await walletRef.delete();
  }

  /// Metodo privato per eliminare i deals di un wallet (opzionale)
  Future<void> _deleteWalletDeals(String walletId) async {
    final dealsSnapshot = await _firestore
        .collection('deals')
        .where('walletId', isEqualTo: walletId)
        .get();

    final batch = _firestore.batch();
    for (final doc in dealsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}