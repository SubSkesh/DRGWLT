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
  final String? photoUrl;

  const Person({
    required this.id,
    required this.name,
    required this.ownerId,
    this.dealIds = const [],
    required this.createdAt,
    this.lastUpdated,
    required this.personType,
    this.photoUrl,
  });

  // Metodo helper per tipo di persona
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

  // Metodo helper per contare i deals
  int get dealsCount => dealIds.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Person &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              ownerId == other.ownerId &&
              dealIds == other.dealIds &&
              createdAt == other.createdAt &&
              lastUpdated == other.lastUpdated &&
              personType == other.personType &&
              photoUrl == other.photoUrl);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      ownerId.hashCode ^
      dealIds.hashCode ^
      createdAt.hashCode ^
      lastUpdated.hashCode ^
      personType.hashCode ^
      photoUrl.hashCode;

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
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // PER FIRESTORE - SENZA ID
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'dealIds': dealIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
      'personType': personType.toString().split('.').last,
      'photoUrl': photoUrl,
    };
  }

  // DA FIRESTORE - CON ID SEPARATO
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
      photoUrl: map['photoUrl'] as String?,
    );
  }

  // Helper per convertire stringa a PersonType
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