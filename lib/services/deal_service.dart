import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drgwallet/models/deal.dart';

class DealService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Crea un nuovo deal
  Future<void> createDeal(Deal deal) async {
    await _firestore.collection('deals').doc(deal.id).set(deal.toMap());
  }
  Future<void> cloneDeal(Deal deal) async {
    final clone = deal.copyWith(id: null);
    await createDeal(clone);
  }
// // 1. Crea un nuovo deal (Alternativa Semplificata)
//   Future<void> createDeal(Deal deal) async {
//     if (deal.id == null) {
//       // Se l'ID è nullo, crea un nuovo documento e Firestore genererà l'ID.
//       // Poi prendi quell'ID e salvalo nell'oggetto deal prima di chiamare toMap(),
//       // oppure assicurati che toMap() non includa un campo 'id' se deve essere autogenerato.
//       // L'opzione più pulita è spesso aggiornare l'oggetto deal.
//       final newDocRef = _firestore.collection('deals').doc(); // Genera riferimento con nuovo ID
//       // Crea una versione del deal che include il nuovo ID per il salvataggio
//       final dealWithId = deal.copyWith(id: newDocRef.id);
//       await newDocRef.set(dealWithId.toMap());
//     } else {
//       // Se l'ID è fornito, usa quello per creare o sovrascrivere.
//       await _firestore.collection('deals').doc(deal.id).set(deal.toMap());
//     }
//   }
//
// // cloneDeal rimane invariato, ora funzionerà correttamente
//   Future<void> cloneDeal(Deal deal) async {
//     final clone = deal.copyWith(id: null);

    // 2. Leggi tutti i deal di un utente (stream in tempo reale)
  Stream<List<Deal>> getUserDeals(String userId) {
    return _firestore
        .collection('deals')
        .where('walletId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      if (data != null) {
        return Deal.fromMap(data, doc.id);
      } else {
        throw Exception('Dati del documento nulli');
      }
    })
        .toList());
  }
  // Metodo per ottenere un singolo deal
  Future<Deal?> getDeal(String dealId) async {
    try {
      final doc = await _firestore.collection('deals').doc(dealId).get();
      if (doc.exists) {
        return Deal.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Errore nel caricamento del deal: $e');
    }
  }


  // 3. Filtra deals per periodo
  Stream<List<Deal>> getUserDealsByDateRange(
      String userId, {
        required DateTime startDate,
        required DateTime endDate,
      }) {
    return _firestore
        .collection('deals')
        .where('walletId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      if (data != null) {
        return Deal.fromMap(data, doc.id);
      } else {
        throw Exception('Dati del documento nulli');
      }
    })
        .toList());
  }

  // 4. Filtra deals per mese
  Stream<List<Deal>> getUserDealsByMonth(String userId, int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    return getUserDealsByDateRange(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // 5. Filtra deals per anno
  Stream<List<Deal>> getUserDealsByYear(String userId, int year) {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    return getUserDealsByDateRange(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // 6. Filtra deals per data specifica
  Stream<List<Deal>> getUserDealsByDate(String userId, DateTime date) {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return getUserDealsByDateRange(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // 7. Aggiorna un deal esistente
  Future<void> updateDeal(Deal deal) async {
    await _firestore.collection('deals').doc(deal.id).update(deal.toMap());
  }

  // 8. Elimina un deal
  Future<void> deleteDeal(String dealId) async {
    await _firestore.collection('deals').doc(dealId).delete();
  }

  // 9. Metodo per ottenere statistiche per periodo
  Future<Map<String, dynamic>> getDealStatsByPeriod(
      String userId, {
        required DateTime startDate,
        required DateTime endDate,
      }) async {
    final dealsSnapshot = await _firestore
        .collection('deals')
        .where('walletId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    final deals = dealsSnapshot.docs
        .map((doc) {
      final data = doc.data();
      if (data != null) {
        return Deal.fromMap(data, doc.id);
      } else {
        throw Exception('Dati del documento nulli');
      }
    })
        .toList();

    final purchases = deals.where((deal) => deal.type == TxType.purchase).toList();
    final sales = deals.where((deal) => deal.type == TxType.sale).toList();

    final totalPurchases = purchases.fold(0.0, (sum, deal) => sum + deal.total);
    final totalSales = sales.fold(0.0, (sum, deal) => sum + deal.total);
    final netProfit = totalSales - totalPurchases;

    return {
      'totalDeals': deals.length,
      'totalPurchases': purchases.length,
      'totalSales': sales.length,
      'totalPurchaseValue': totalPurchases,
      'totalSalesValue': totalSales,
      'netProfit': netProfit,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
  Future<void> approveDeal(String dealId) async {//cambia lo stato da pending a concluso
    await _firestore.collection('deals').doc(dealId).update({
      'isPending': false,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectDeal(String dealId, String reason) async {
    await _firestore.collection('deals').doc(dealId).update({
      'isPending': false,
      'rejected': true,
      'rejectionReason': reason,
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Deal>> getPendingDeals(String walletId) {
    return _firestore
        .collection('deals')
        .where('walletId', isEqualTo: walletId)
        .where('isPending', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      if (data != null && data is Map<String, dynamic>) {
        return Deal.fromMap(data, doc.id);
      } else {
        throw Exception('Dati del deal nulli o tipo non valido');
      }
    })
        .toList());
  }

}