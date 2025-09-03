import 'deal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Buyer {
  final String id; // ID del documento Firestore
  String name;
  final List<String> dealIds; // Riferimenti ai deal invece dell'oggetto completo
  DateTime? lastUpdated;

  //<editor-fold desc="Data Methods">
  Buyer({
    required this.id,
    required this.name,
    this.dealIds = const [],
    this.lastUpdated,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Buyer &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name
          );


  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode;


  @override
  String toString() {
    return 'Buyer{' +
        ' id: $id,' +
        ' name: $name,' +
        '}';
  }


  Buyer copyWith({
    String? id,
    String? name,
  }) {
    return Buyer(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
    };
  }

  factory Buyer.fromMap(Map<String, dynamic> map) {
    return Buyer(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }


//</editor-fold>
}