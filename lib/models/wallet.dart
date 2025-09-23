import 'package:drgwallet/models/deal.dart';
class Wallet {
  final String id;
  final String ownerID;
  final String name;
  final String? desc;

  final DateTime createdAt;

  // Campi opzionali (calcolati in utils/wallet_calculcator.dart)
  final int? totalDeals;
  final double? totalSpent;
  final double? totalEarned;
  final double? netProfit; //questo in poi da implementare in utils/wallet_calcuilator
  final double? currentInventoryValue;
  final double? totalAvailableQuantity;
  final double? totalInitialQuantity;
  final List<Deal>? deals;
  final Map<String, double>? profitPerCategory;  // somma delle quantità acquistate in assoluto (anche se vendute)

  const Wallet({
    required this.id,
    required this.ownerID,
    required this.name,
    required this.createdAt,
    this.totalDeals,
    this.totalSpent,
    this.totalEarned,
    this.netProfit,
    this.currentInventoryValue,
    this.totalAvailableQuantity,
    this.totalInitialQuantity,
    this.deals,
    this.profitPerCategory,
    this.desc,
  });

  //<@override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Wallet &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              ownerID == other.ownerID &&
              name == other.name &&

              createdAt == other.createdAt &&
              totalDeals == other.totalDeals &&
              totalSpent == other.totalSpent &&
              totalEarned == other.totalEarned &&
              netProfit == other.netProfit &&
              currentInventoryValue == other.currentInventoryValue &&
              totalAvailableQuantity == other.totalAvailableQuantity &&
              totalInitialQuantity == other.totalInitialQuantity &&
              deals == other.deals &&
              profitPerCategory == other.profitPerCategory &&
              desc == other.desc
          );


  @override
  int get hashCode =>
      id.hashCode ^
      ownerID.hashCode ^
      name.hashCode ^

      createdAt.hashCode ^
      totalDeals.hashCode ^
      totalSpent.hashCode ^
      totalEarned.hashCode ^
      netProfit.hashCode ^
      currentInventoryValue.hashCode ^
      totalAvailableQuantity.hashCode ^
      totalInitialQuantity.hashCode ^
      deals.hashCode ^
      profitPerCategory.hashCode ^
      desc.hashCode;


  @override
  String toString() {
    return 'Wallet{' +
        ' id: $id,' +
        ' owner: $ownerID,' +
        ' name: $name,' +

        ' createdAt: $createdAt,' +
        ' totalDeals: $totalDeals,' +
        ' totalSpent: $totalSpent,' +
        ' totalEarned: $totalEarned,' +
        ' netProfit: $netProfit,' +
        ' currentInventoryValue: $currentInventoryValue,' +
        ' totalAvailableQuantity: $totalAvailableQuantity,' +
        ' totalInitialQuantity: $totalInitialQuantity,' +
        ' deals: $deals,' +
        ' profitPerCategory: $profitPerCategory,' +
        ' desc: $desc,' +
        '}';
  }


  Wallet copyWith({
    String? id,
    String? owner,
    String? name,
    DateTime? createdAt,
    int? totalDeals,
    double? totalSpent,
    double? totalEarned,
    double? netProfit,
    double? currentInventoryValue,
    double? totalAvailableQuantity,
    double? totalInitialQuantity,
    List<Deal>? deals,
    Map<String, double>? profitPerCategory,
    String? desc,
  }) {
    return Wallet(
      id: id ?? this.id,
      ownerID: owner ?? this.ownerID,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      totalDeals: totalDeals ?? this.totalDeals,
      totalSpent: totalSpent ?? this.totalSpent,
      totalEarned: totalEarned ?? this.totalEarned,
      netProfit: netProfit ?? this.netProfit,
      currentInventoryValue: currentInventoryValue ??
          this.currentInventoryValue,
      totalAvailableQuantity: totalAvailableQuantity ??
          this.totalAvailableQuantity,
      totalInitialQuantity: totalInitialQuantity ?? this.totalInitialQuantity,
      deals: deals ?? this.deals,
      profitPerCategory: profitPerCategory ?? this.profitPerCategory,
      desc: desc ?? this.desc,
    );
  }


  Map<String, dynamic> toMap() {
    return {
     // 'id': this.id,
      'owner': this.ownerID,
      'name': this.name,
      'createdAt': this.createdAt,
      'desc': this.desc,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map, String id) {
    return Wallet(
      id: id,
      ownerID: map['owner'] as String,
      name: map['name'] as String,
      createdAt: (map['createdAt'] ).toDate(),
      desc: map['desc'] as String,
    );
  }



}
