// models/person.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum PersonType { supplier, buyer, anon }

class Person {
  final String id;
  final String name;
  final String ownerId;
  final List<String> dealIds;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final PersonType personType;
  final String? localImagePath;
  final String? photoUrl;

  const Person({
    required this.id,
    required this.name,
    required this.ownerId,
    this.dealIds = const [],
    required this.createdAt,
    this.lastUpdated,
    required this.personType,
    this.localImagePath,
    this.photoUrl,
  });

  String get type {
    switch (personType) {
      case PersonType.supplier:
        return 'Supplier';
      case PersonType.buyer:
        return 'Buyer';
      case PersonType.anon:
        return 'Anon';
    }
  }

  int get dealsCount => dealIds.length;

  // --- INIZIO DELLA CORREZIONE ---
  // Ora confrontiamo gli oggetti Person solo in base al loro ID.
  // Questo è il modo corretto e risolve l'errore del Dropdown.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
  // --- FINE DELLA CORREZIONE ---

  @override
  String toString() {
    return 'Person{' +
        ' id: $id,' +
        ' name: $name,' +
        ' ownerId: $ownerId,' +
        ' dealIds: $dealIds,' +
        ' createdAt: $createdAt,' +
        ' lastUpdated: $lastUpdated,' +
        ' personType: $personType,' +
        ' localImagePath: $localImagePath,' +
        ' photoUrl: $photoUrl,' +
        '}';
  }

  Person copyWith({
    String? id,
    String? name,
    String? ownerId,
    List<String>? dealIds,
    DateTime? createdAt,
    DateTime? lastUpdated,
    PersonType? personType,
    String? localImagePath,
    String? photoUrl,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      dealIds: dealIds ?? this.dealIds,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      personType: personType ?? this.personType,
      localImagePath: localImagePath ?? this.localImagePath,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'dealIds': dealIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
      'personType': personType.toString().split('.').last,
      'localImagePath': localImagePath,
      'photoUrl': photoUrl,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map, String id) {
    return Person(
      id: id,
      name: map['name'] as String,
      ownerId: map['ownerId'] as String,
      dealIds: List<String>.from(map['dealIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
      personType: _stringToPersonType(map['personType'] as String),
      localImagePath: map['localImagePath'] as String?,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  static PersonType _stringToPersonType(String typeString) {
    switch (typeString) {
      case 'supplier':
        return PersonType.supplier;
      case 'buyer':
        return PersonType.buyer;
      case 'anon':
        return PersonType.anon;
      default:
        return PersonType.anon;
    }
  }
}
