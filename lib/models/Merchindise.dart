enum Category { drug, metal, plasticCutlery, other }

abstract class Merchandise {
  // Proprietà di base
  final String id;
  String name;
  Category category;
  double quantity;
  double purchasePrice;     // prezzo al pezzo o unitario
  double currentPrice;      // prezzo di mercato attuale

  // Storico transazioni
  final List<Transaction> transactions = [];

  Merchandise({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.purchasePrice,
    required this.currentPrice,
  });

  // Registra un’operazione di acquisto o vendita
  void addTransaction(Transaction tx) {
    // aggiorno quantità
    quantity += (tx.type == TxType.purchase ? tx.amount : -tx.amount);
    transactions.add(tx);
  }

  // Calcola il margine netto di una transazione
  double profitFor(Transaction tx) {
    double price = tx.type == TxType.purchase ? purchasePrice : currentPrice;
    return (tx.pricePerUnit - price) * tx.amount;
  }

  // Aggiorna il prezzo di mercato
  void updateCurrentPrice(double newPrice) {
    currentPrice = newPrice;
  }

  @override
  String toString() {
    return '[$category] $name x$quantity @ buy:$purchasePrice sell:$currentPrice';
  }
}

enum TxType { purchase, sale }

class Transaction {
  final TxType type;
  final double amount;
  final double pricePerUnit;
  final DateTime timestamp;

  Transaction({
    required this.type,
    required this.amount,
    required this.pricePerUnit,
    DateTime? timestamp,
  }) : this.timestamp = timestamp ?? DateTime.now();
}