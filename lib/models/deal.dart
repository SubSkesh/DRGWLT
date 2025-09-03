import 'enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Deal {
  //</editor-fold>
  final String id;
  final String walletId; // a chi appartiene questo deal
  final String goodId;
  final String? personId; // <-- AGGIUNTO: fornitore o compratore
  final TxType type;
  final double amount;
  final Value currency;

  final Unit unit;     // unità di misura (grammi, kg, pezzi, ecc.)
  final double pricePerUnit;
  final DateTime timestamp;
  final bool isPending;
  final DateTime date;
  //<editor-fold desc="Data Methods">

  //<editor-fold desc="Data Methods">
   Deal({
    required this.id,
    required this.walletId,
    required this.goodId,
     required this.personId,
     required this.type,
     required this.amount,
     required this.currency,
     required this.unit,
     required this.pricePerUnit,
     required this.timestamp,
     required this.isPending,
     required this.date,
   });
  double get total => amount * pricePerUnit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          walletId == other.walletId &&
          goodId == other.goodId &&
          type == other.type &&
          amount == other.amount &&
          currency == other.currency &&
          unit == other.unit &&
          pricePerUnit == other.pricePerUnit &&
          personId == other.personId &&
          timestamp == other.timestamp &&
          isPending == other.isPending
           && date == other.date);

  @override
  int get hashCode =>
      id.hashCode ^
      walletId.hashCode ^
      goodId.hashCode ^
      type.hashCode ^
      amount.hashCode ^
      currency.hashCode ^
      unit.hashCode ^
      pricePerUnit.hashCode ^
      personId.hashCode ^
      timestamp.hashCode ^
      isPending.hashCode ^
      date.hashCode;

  @override
  String toString() {
    return 'Deal{' +
        ' id: $id,' +
        ' walletId: $walletId,' +
        ' goodId: $goodId,' +
        ' type: $type,' +
        ' amount: $amount,' +
        ' currency: $currency,' +
        ' unit: $unit,' +
        ' pricePerUnit: $pricePerUnit,' +
        ' personId: $personId,'
        ' timestamp: $timestamp,' +
        ' isPending: $isPending,' +
         ' date: $date,' +
        '}';
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
    String? personId,
    DateTime? timestamp,
    bool? isPending,
    DateTime? date,
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
      personId: personId ?? this.personId,
      timestamp: timestamp ?? this.timestamp,
      isPending: isPending ?? this.isPending,
       date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // RIMUOVI 'id': this.id, ← Non salvare l'ID nel documento

      'walletId': this.walletId,
      'goodId': this.goodId, //TODO: store as string or enum?
      'type': this.type.toString(), // Store enum as string
      'amount': this.amount,
      'currency': this.currency.toString(), // Store enum as string
      'unit': this.unit.toString(), // Store enum as string
      'pricePerUnit': this.pricePerUnit,
      'personId': this.personId,
      'timestamp': Timestamp.fromDate(this.timestamp),
       'date': Timestamp.fromDate(this.date),
      'isPending': this.isPending,
    };
  }

  factory Deal.fromMap(Map<String, dynamic> map,String id) {
    return Deal(
      id:id,
      walletId: map['walletId'] as String,
      goodId: map['goodId'] as String,
      type: TxType.values.firstWhere((e) => e.toString() == map['type']), // Retrieve enum from string
      amount: map['amount'] as double,
      currency: Value.values.firstWhere((e) => e.toString() == map['currency']), // Retrieve enum from string
      unit: Unit.values.firstWhere((e) => e.toString() == map['unit']), // Retrieve enum from string
      pricePerUnit: map['pricePerUnit'] as double,
      personId: map['personId'] as String?,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
       date: (map['date'] as Timestamp).toDate(),
      isPending: map['isPending'] as bool,
    );
  }

  //</editor-fold>
}
