enum TxType { purchase, sale }

enum Category { drug, metal, plasticCutlery, other }

enum Unit {
  gram(1.0),
  kilogram(1000.0),
  ton(1000000.0),
  piece(1.0),
  liter(1.0),
  milliliter(0.001),
  custom(1.0);

  final double baseConversionRate;

  const Unit(this.baseConversionRate);

  /// Converte un valore da questa unità a un'altra unità
  double convertTo(double value, Unit targetUnit) {
    return value * (baseConversionRate / targetUnit.baseConversionRate);
  }

  /// Converte un prezzo da questa unità a un'altra unità
  double convertPrice(double price, Unit targetUnit) {
    return price * (targetUnit.baseConversionRate / baseConversionRate);
  }

  /// Restituisce il simbolo/abbreviazione dell'unità
  String get symbol {
    switch (this) {
      case Unit.gram:
        return 'g';
      case Unit.kilogram:
        return 'kg';
      case Unit.ton:
        return 't';
      case Unit.piece:
        return 'pz';
      case Unit.liter:
        return 'L';
      case Unit.milliliter:
        return 'mL';
      case Unit.custom:
        return 'custom';
    }
  }

  /// Restituisce il nome completo dell'unità
  String get displayName {
    switch (this) {
      case Unit.gram:
        return 'Gram';
      case Unit.kilogram:
        return 'Kilogrammo';
      case Unit.ton:
        return 'Tonnellata';
      case Unit.piece:
        return 'Piece';
      case Unit.liter:
        return 'Litre';
      case Unit.milliliter:
        return 'Millilitre';
      case Unit.custom:
        return 'Personalizzato';
    }
  }
}

enum Value {
  euro('€', 'Euro'),
  dollars('\$', 'Dollars USA'),
  pounds('£', 'Pound'),
  yen('¥', 'Yen'),
  yuan('¥', 'Yuan'),
  rupee('₹', 'Rupi'),
  ruble('₽', 'Rublo'),
  australianDollar('A\$', 'Australian Dollar'),
  canadianDollar('C\$', 'Canadese Dollar'),
  swissFranc('CHF', 'Franco Swish'),
  BTC('₿', 'Bitcoin'),
  ETH('Ξ', 'Ethereum'),
  Slaps('Slaps', 'Slaps');

  final String symbol;
  final String displayName;

  const Value(this.symbol, this.displayName);

  @override
  String toString() => symbol;
}


