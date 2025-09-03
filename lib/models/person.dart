import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String id;
  final String name;
  final List<String> dealIds;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final bool isSupplier;

  const Person({
    required this.id,
    required this.name,
    this.dealIds = const [],
    required this.createdAt,
    this.lastUpdated,
    required this.isSupplier,
  });

  // Metodo helper per tipo di persona
  String get type => isSupplier ? 'Fornitore' : 'Cliente';

  // Metodo helper per contare i deals
  int get dealsCount => dealIds.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Person &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              dealIds == other.dealIds &&
              createdAt == other.createdAt &&
              lastUpdated == other.lastUpdated &&
              isSupplier == other.isSupplier);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      dealIds.hashCode ^
      createdAt.hashCode ^
      lastUpdated.hashCode ^
      isSupplier.hashCode;

  @override
  String toString() {
    return 'Person{' +
        ' id: $id,' +
        ' name: $name,' +
        ' dealIds: $dealIds,' +
        ' createdAt: $createdAt,' +
        ' lastUpdated: $lastUpdated,' +
        ' isSupplier: $isSupplier,' +
        '}';
  }

  Person copyWith({
    String? id,
    String? name,
    List<String>? dealIds,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isSupplier,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      dealIds: dealIds ?? this.dealIds,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSupplier: isSupplier ?? this.isSupplier,
    );
  }

  // PER FIRESTORE - SENZA ID
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dealIds': dealIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
      'isSupplier': isSupplier,
    };
  }

  // DA FIRESTORE - CON ID SEPARATO
  factory Person.fromMap(Map<String, dynamic> map, String id) {
    return Person(
      id: id,
      name: map['name'] as String,
      dealIds: List<String>.from(map['dealIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
      isSupplier: map['isSupplier'] as bool,
    );
  }
}