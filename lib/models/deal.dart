// lib/models/deal.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'enum.dart';
import 'person.dart';

// Classe helper per il copyWith
class _Undefined {
  const _Undefined();
}

class Deal {
  final String id;
  final String walletId;
  final String goodId;
  final String? personId;
  final TxType type;
  final double amount;
  final Value currency;
  final Unit unit;
  final double pricePerUnit;
  final DateTime timestamp;
  final bool isPending;
  final DateTime date;
  final Person? person;

  Deal({
    required this.id,
    required this.walletId,
    required this.goodId,
    this.personId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.unit,
    required this.pricePerUnit,
    required this.timestamp,
    required this.isPending,
    required this.date,
    this.person,
  });

  double get total => amount * pricePerUnit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Deal && runtimeType == other.runtimeType && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Deal{id: $id, personId: $personId, total: $total}';
  }

  Deal copyWith({
    String? id,
    String? walletId,
    String? goodId,
    TxType? type,
    double? amount,
    Value? currency,
    Unit? unit,
    double? pricePerUnit,
    dynamic personId = const _Undefined(),
    DateTime? timestamp,
    bool? isPending,
    DateTime? date,
    dynamic person = const _Undefined(),
  }) {
    return Deal(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      goodId: goodId ?? this.goodId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      personId: personId is _Undefined ? this.personId : personId as String?,
      timestamp: timestamp ?? this.timestamp,
      isPending: isPending ?? this.isPending,
      date: date ?? this.date,
      person: person is _Undefined ? this.person : person as Person?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'walletId': walletId,
      'goodId': goodId,
      'type': type.name, // Salva sempre con .name (es. "purchase")
      'amount': amount,
      'currency': currency.name,
      'unit': unit.name,
      'pricePerUnit': pricePerUnit,
      'personId': personId,
      'timestamp': Timestamp.fromDate(timestamp),
      'date': Timestamp.fromDate(date),
      'isPending': isPending,
    };
  }

  // --- FACTORY FROMMAP ROBUSTO E SICURO ---
  factory Deal.fromMap(Map<String, dynamic> map, String id) {
    // Funzione helper per recuperare l'enum in modo super-sicuro
    T _enumFromString<T extends Enum>(List<T> values, String? name, T defaultValue) {
      if (name == null) return defaultValue;
      // Pulisce la stringa, rimuovendo "NomeEnum." se presente
      final cleanName = name.split('.').last;
      try {
        // Cerca l'enum per nome nella lista dei valori
        return values.firstWhere(
              (e) => e.name == cleanName,
          // Se non lo trova, non lancia un errore ma ritorna il valore di default
          orElse: () => defaultValue,
        );
      } catch (e) {
        return defaultValue;
      }
    }

    return Deal(
      id: id,
      walletId: map['walletId'] as String,
      goodId: map['goodId'] as String,
      type: _enumFromString(TxType.values, map['type'], TxType.purchase),
      amount: (map['amount'] as num? ?? 0).toDouble(), // Aggiunto ?? 0 per sicurezza
      currency: _enumFromString(Value.values, map['currency'], Value.euro), // Corretto da euro a eur
      unit: _enumFromString(Unit.values, map['unit'], Unit.gram), // Corretto da gram a g
      pricePerUnit: (map['pricePerUnit'] as num? ?? 0).toDouble(), // Aggiunto ?? 0
      personId: map['personId'] as String?,
      timestamp: (map['timestamp'] as Timestamp? ?? Timestamp.now()).toDate(), // Aggiunto ??
      date: (map['date'] as Timestamp? ?? Timestamp.now()).toDate(), // Aggiunto ??
      isPending: map['isPending'] as bool? ?? false, // Aggiunto ??
    );
  }
}
