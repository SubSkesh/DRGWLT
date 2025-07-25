class Good {
  final String id;
  final String name;
  final double price; // es: 50.0
  final Unit unit; // es: Unit.gram
  final String? note;

   Good({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.note,
  });

  //<@override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Good &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              price == other.price &&
              unit == other.unit &&
              note == other.note
          );


  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      price.hashCode ^
      unit.hashCode ^
      note.hashCode;


  @override
  String toString() {
    return 'Good{' +
        ' id: $id,' +
        ' name: $name,' +
        ' price: $price,' +
        ' unit: $unit,' +
        ' note: $note,' +
        '}';
  }


  Good copyWith({
    String? id,
    String? name,
    double? price,
    Unit? unit,
    String? note,
  }) {
    return Good(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      note: note ?? this.note,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'price': this.price,
      'unit': this.unit,
      'note': this.note,
    };
  }

  factory Good.fromMap(Map<String, dynamic> map) {
    return Good(
      id: map['id'] as String,
      name: map['name'] as String,
      price: map['price'] as double,
      unit: map['unit'] as Unit,
      note: map['note'] as String,
    );
  }


  //</editor-fold>

  // opzionale: per tag o info extra
}
enum Unit {
  gram,
  kilogram,
  ton,
  piece,
  liter,
  milliliter,
  custom // opzionale per qualcosa di fuori standard
}
