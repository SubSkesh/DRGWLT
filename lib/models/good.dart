import 'package:cloud_firestore/cloud_firestore.dart';
import 'enum.dart';

class Good {
  final String id;
  final String name;
  final Unit baseUnit;
  final Category category;
  final String? description;
  final double? currentMarketPrice;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  const Good({
    required this.id,
    required this.name,
    required this.baseUnit,
    required this.category,
    this.description,
    this.currentMarketPrice,
    required this.createdAt,
    this.lastUpdated,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Good &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              baseUnit == other.baseUnit &&
              category == other.category &&
              description == other.description &&
              currentMarketPrice == other.currentMarketPrice &&
              createdAt == other.createdAt &&
              lastUpdated == other.lastUpdated);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      baseUnit.hashCode ^
      category.hashCode ^
      description.hashCode ^
      currentMarketPrice.hashCode ^
      createdAt.hashCode ^
      lastUpdated.hashCode;

  @override
  String toString() {
    return 'Good{' +
        ' id: $id,' +
        ' name: $name,' +
        ' baseUnit: $baseUnit,' +
        ' category: $category,' +
        ' description: $description,' +
        ' currentMarketPrice: $currentMarketPrice,' +
        ' createdAt: $createdAt,' +
        ' lastUpdated: $lastUpdated,' +
        '}';
  }

  Good copyWith({
    String? id,
    String? name,
    Unit? baseUnit,
    Category? category,
    String? description,
    double? currentMarketPrice,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Good(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUnit: baseUnit ?? this.baseUnit,
      category: category ?? this.category,
      description: description ?? this.description,
      currentMarketPrice: currentMarketPrice ?? this.currentMarketPrice,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // PER FIRESTORE - SENZA ID
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'baseUnit': baseUnit.toString().split('.').last, // Salva come stringa
      'category': category.toString().split('.').last, // Salva come stringa
      'description': description,
      'currentMarketPrice': currentMarketPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  // DA FIRESTORE - CON ID SEPARATO
  factory Good.fromMap(Map<String, dynamic> map, String id) {
    return Good(
      id: id,
      name: map['name'] as String,
      baseUnit: _stringToUnit(map['baseUnit'] as String),
      category: _stringToCategory(map['category'] as String),
      description: map['description'] as String?,
      currentMarketPrice: map['currentMarketPrice'] as double?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  // Helper per convertire stringa a Unit
  static Unit _stringToUnit(String unitString) {
    return Unit.values.firstWhere(
          (unit) => unit.toString().split('.').last == unitString,
      orElse: () => Unit.gram,
    );
  }

  // Helper per convertire stringa a Category
  static Category _stringToCategory(String categoryString) {
    return Category.values.firstWhere(
          (category) => category.toString().split('.').last == categoryString,
      orElse: () => Category.other,
    );
  }
}