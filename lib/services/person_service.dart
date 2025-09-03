import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drgwallet/models/person.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/enum.dart';

class PersonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Crea una nuova persona
  Future<Person> createPerson({
    required String name,
    required bool isSupplier,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final personRef = _firestore.collection('persons').doc();
    final now = DateTime.now();

    final person = Person(
      id: personRef.id,
      name: name,
      isSupplier: isSupplier,
      createdAt: now,
      lastUpdated: now,
    );

    await personRef.set({
      ...person.toMap(),
      'ownerId': user.uid, // Aggiungi ownerId per sicurezza
    });

    return person;
  }

  /// Ottiene tutte le persone di un utente
  Stream<List<Person>> getUserPersons({bool? isSupplier}) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    Query query = _firestore
        .collection('persons')
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('name');

    if (isSupplier != null) {
      query = query.where('isSupplier', isEqualTo: isSupplier);
    }

    return query
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      if (data != null && data is Map<String, dynamic>) {
        return Person.fromMap(data, doc.id);
      } else {
        throw Exception('Dati della persona nulli o tipo non valido');
      }
    })
        .toList());
  }

  /// Ottiene una persona specifica per ID
  Future<Person> getPerson(String personId) async {
    final doc = await _firestore.collection('persons').doc(personId).get();

    if (!doc.exists) {
      throw Exception('Persona non trovata');
    }

    final data = doc.data();
    if (data != null && data is Map<String, dynamic>) {
      return Person.fromMap(data, doc.id);
    } else {
      throw Exception('Dati della persona nulli o tipo non valido');
    }
  }

  /// Aggiorna una persona esistente
  Future<void> updatePerson(Person person) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final personRef = _firestore.collection('persons').doc(person.id);
    final personDoc = await personRef.get();

    if (!personDoc.exists) {
      throw Exception('Persona non trovata');
    }

    final data = personDoc.data();
    if (data != null && data is Map<String, dynamic>) {
      if (data['ownerId'] != user.uid) {
        throw Exception('Non autorizzato');
      }

      await personRef.update({
        'name': person.name,
        'isSupplier': person.isSupplier,
        'dealIds': person.dealIds,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('Dati della persona nulli o tipo non valido');
    }
  }

  /// Elimina una persona
  Future<void> deletePerson(String personId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final personRef = _firestore.collection('persons').doc(personId);
    final personDoc = await personRef.get();

    if (!personDoc.exists) {
      throw Exception('Persona non trovata');
    }

    final data = personDoc.data();
    if (data != null && data is Map<String, dynamic>) {
      if (data['ownerId'] != user.uid) {
        throw Exception('Non autorizzato');
      }

      await personRef.delete();
    } else {
      throw Exception('Dati della persona nulli o tipo non valido');
    }
  }

  /// Aggiunge un deal ID alla lista dealIds di una persona
  Future<void> addDealToPerson(String personId, String dealId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final personRef = _firestore.collection('persons').doc(personId);
    final personDoc = await personRef.get();

    if (!personDoc.exists) {
      throw Exception('Persona non trovata');
    }

    final data = personDoc.data();
    if (data != null && data is Map<String, dynamic>) {
      if (data['ownerId'] != user.uid) {
        throw Exception('Non autorizzato');
      }

      final currentDealIds = List<String>.from(data['dealIds'] ?? []);
      if (!currentDealIds.contains(dealId)) {
        currentDealIds.add(dealId);
        await personRef.update({
          'dealIds': currentDealIds,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } else {
      throw Exception('Dati della persona nulli o tipo non valido');
    }
  }

  /// Rimuove un deal ID dalla lista dealIds di una persona
  Future<void> removeDealFromPerson(String personId, String dealId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final personRef = _firestore.collection('persons').doc(personId);
    final personDoc = await personRef.get();

    if (!personDoc.exists) {
      throw Exception('Persona non trovata');
    }

    final data = personDoc.data();
    if (data != null && data is Map<String, dynamic>) {
      if (data['ownerId'] != user.uid) {
        throw Exception('Non autorizzato');
      }

      final currentDealIds = List<String>.from(data['dealIds'] ?? []);
      currentDealIds.remove(dealId);

      await personRef.update({
        'dealIds': currentDealIds,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('Dati della persona nulli o tipo non valido');
    }
  }

  /// Cerca persone per nome
  Stream<List<Person>> searchPersons(String query, {bool? isSupplier}) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    Query queryBuilder = _firestore
        .collection('persons')
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('name');

    if (isSupplier != null) {
      queryBuilder = queryBuilder.where('isSupplier', isEqualTo: isSupplier);
    }

    return queryBuilder
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      if (data != null && data is Map<String, dynamic>) {
        return Person.fromMap(data, doc.id);
      } else {
        throw Exception('Dati della persona nulli o tipo non valido');
      }
    })
        .where((person) => person.name.toLowerCase().contains(query.toLowerCase()))
        .toList());
  }

  Future<double> getPersonTotalValue(String personId, {TxType? type}) async {
    final deals = await _getDealsByPersonId(personId); // deve restituire List<Deal>

    final filteredDeals = type != null
        ? deals.where((deal) => deal.type == type).toList()
        : deals;

    final total = filteredDeals.fold<double>(0.0, (sum, deal) => sum + deal.total);

    return total;
  }


  /// Calcola i soldi scambiati in un periodo specifico
  Future<double> getPersonValueInPeriod(
      String personId, {
        required DateTime startDate,
        required DateTime endDate,
        TxType? type,
      }) async {
    final deals = await _getDealsByPersonId(personId); // deve tornare List<Deal>

    final periodDeals = deals.where((deal) =>
    deal.date.isAfter(startDate) &&
        deal.date.isBefore(endDate) &&
        (type == null || deal.type == type)).toList();

    final total = periodDeals.fold<double>(0.0, (sum, deal) => sum + deal.total);

    return total;
  }

  /// Ottiene la cronologia acquisti/vendite di una persona
  Future<List<Deal>> getPersonDealsHistory(
      String personId, {
        TxType? type,
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    Query query = _firestore
        .collection('deals')
        .where('personId', isEqualTo: personId)
        .orderBy('date', descending: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString().split('.').last);
    }
    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Deal.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  /// Metodo privato per ottenere i deals di una persona
  Future<List<Deal>> _getDealsByPersonId(String personId) async {
    final snapshot = await _firestore
        .collection('deals')
        .where('personId', isEqualTo: personId)
        .get();

    return snapshot.docs
        .map((doc) => Deal.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<Map<String, dynamic>> getPersonPendingStats(String personId) async {
    final deals = await _getDealsByPersonId(personId);
    final pendingDeals = deals.where((deal) => deal.isPending).toList();

    final pendingByType = {
      'purchase': pendingDeals.where((d) => d.type == TxType.purchase).toList(),
      'sale': pendingDeals.where((d) => d.type == TxType.sale).toList(),
    };

    return {
      'totalPending': pendingDeals.length,
      'pendingPurchases': pendingByType['purchase']!.length,
      'pendingSales': pendingByType['sale']!.length,
      'pendingPurchaseValue': pendingByType['purchase']!.fold(0.0, (sum, d) => sum + d.total),
      'pendingSaleValue': pendingByType['sale']!.fold(0.0, (sum, d) => sum + d.total),
      'pendingDeals': pendingDeals,
    };
  }
}