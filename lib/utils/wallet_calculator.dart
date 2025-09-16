import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/models/good.dart';
import 'package:drgwallet/utils/deal_calculator.dart';
import 'package:drgwallet/models/enum.dart';

class WalletCalculator {
  // ========== CALCOLI FONDAMENTALI ==========

  /// Arricchisce il wallet con tutte le metriche calcolate
  static Wallet enrichWithCalculations({
    //richiede un wallet e i deals da esso,e può ricevere una lista di goods
    required Wallet wallet,
    required List<Deal> deals,
    List<Good> goods = const [],
  }) {
    final purchaseDeals = DealCalculator.filterByType(deals, TxType.purchase);//deal di acquisto
    final saleDeals = DealCalculator.filterByType(deals, TxType.sale);//deal di vendita

    return wallet.copyWith(
      totalDeals: deals.length,
      totalSpent: _calculateTotalValue(purchaseDeals),//somma di tutti i deal di acquisto
      totalEarned: _calculateTotalValue(saleDeals),//somma di tutti i deal di vendita
      netProfit: _calculateTotalValue(saleDeals) - _calculateTotalValue(purchaseDeals),//somma di tutti i deal di vendita - somma di tutti i deal di acquisto
      currentInventoryValue: _calculateInventoryValue(deals, goods),//somma di tutti i deal di vendita - somma di tutti i deal di acquisto
      totalAvailableQuantity: _calculateAvailableQuantity(deals, goods),//somma di tutti i deal di acquisto - somma di tutti i deal di vendita
      deals: deals,
      profitPerCategory: _calculateProfitByCategory(deals, goods),//somma di tutti i deal di vendita - somma di tutti i deal di acquisto per categoria di prodotto
    );
  }

  // ========== CALCOLI AGGREGATI ==========

  static double _calculateTotalValue(List<Deal> deals) {//somma di tutti i deal di acquisto o di vendita
    return deals.fold(0.0, (sum, deal) => sum + DealCalculator.calculateTotal(deal));
  }

  static double _calculateInventoryValue(List<Deal> deals, List<Good> goods) {
    double total = 0;

    for (final deal in deals) {
      final good = _findGoodForDeal(deal, goods);

      if (deal.type == TxType.purchase) {
        total += DealCalculator.calculateTotal(deal);
      } else {
        total -= DealCalculator.calculateTotal(deal);
      }
    }

    return total;
  }

// calcola la quantità disponibile in base ai deal e ai goods
  static double _calculateAvailableQuantity(List<Deal> deals, List<Good> goods) {
    double total = 0;

    for (final deal in deals) {
      final good = _findGoodForDeal(deal, goods);

      final amountInBaseUnit = DealCalculator.convertUnit(
        amount: deal.amount,
        fromUnit: deal.unit,
        toUnit: good.baseUnit,
      );

      if (deal.type == TxType.purchase) {
        total += amountInBaseUnit;
      } else {
        total -= amountInBaseUnit;
      }
    }

    return total;
  }

  static Map<String, double> _calculateProfitByCategory(List<Deal> deals, List<Good> goods) {
    final Map<String, double> profitByCategory = {};
    final Map<String, List<Deal>> dealsByGood = {};

    // Raggruppa deals per good
    for (final deal in deals) {
      dealsByGood.putIfAbsent(deal.goodId, () => []).add(deal);
    }

    // Calcola profitto per categoria
    for (final entry in dealsByGood.entries) {
      final good = _findGoodById(entry.key, goods);
      final category = good.category.toString().split('.').last;

      final categoryDeals = entry.value;
      final purchases = DealCalculator.filterByType(categoryDeals, TxType.purchase);
      final sales = DealCalculator.filterByType(categoryDeals, TxType.sale);

      final totalSpent = _calculateTotalValue(purchases);
      final totalEarned = _calculateTotalValue(sales);
      final profit = totalEarned - totalSpent;

      profitByCategory.update(
        category,
            (existing) => existing + profit,
        ifAbsent: () => profit,
      );
    }

    return profitByCategory;
  }

  // ========== HELPERS ==========

  static Good _findGoodForDeal(Deal deal, List<Good> goods) {
    return goods.firstWhere(
          (g) => g.id == deal.goodId,
      orElse: () => Good(
        id: '',
        name: 'Unknown',
        baseUnit: Unit.gram,
        category: Category.other,
        createdAt: DateTime.now(),
      ),
    );
  }

  static Good _findGoodById(String goodId, List<Good> goods) {
    return goods.firstWhere(
          (g) => g.id == goodId,
      orElse: () => Good(
        id: '',
        name: 'Unknown',
        baseUnit: Unit.gram,
        category: Category.other,
        createdAt: DateTime.now(),
      ),
    );
  }

  // ========== ANALISI TEMPORALE ==========

  static Map<DateTime, double> calculateDailyProfit(List<Deal> deals) {
    final dailyProfit = <DateTime, double>{};

    for (final deal in deals) {
      final date = DateTime(deal.timestamp.year, deal.timestamp.month, deal.timestamp.day);
      final value = deal.type == TxType.purchase
          ? -DealCalculator.calculateTotal(deal)
          : DealCalculator.calculateTotal(deal);

      dailyProfit.update(
        date,
            (existing) => existing + value,
        ifAbsent: () => value,
      );
    }

    return dailyProfit;
  }

  // ========== METRICHE AVANZATE ==========

  static double calculateAverageTransactionValue(List<Deal> deals) {
    if (deals.isEmpty) return 0;
    return _calculateTotalValue(deals) / deals.length;
  }

  static int calculateTransactionsPerDay(List<Deal> deals) {
    if (deals.isEmpty) return 0;

    final dates = deals.map((d) => DateTime(d.timestamp.year, d.timestamp.month, d.timestamp.day)).toSet();
    return deals.length ~/ dates.length;
  }


  static Map<String, dynamic> calculatePendingStats(List<Deal> deals) {
    final pendingDeals = deals.where((deal) => deal.isPending).toList();
    final pendingPurchases = pendingDeals.where((d) => d.type == TxType.purchase);
    final pendingSales = pendingDeals.where((d) => d.type == TxType.sale);

    return {
      'totalPending': pendingDeals.length,
      'pendingPurchasesCount': pendingPurchases.length,
      'pendingSalesCount': pendingSales.length,
      'pendingPurchasesValue': pendingPurchases.fold(0.0, (sum, d) => sum + d.total),
      'pendingSalesValue': pendingSales.fold(0.0, (sum, d) => sum + d.total),
      'netPendingValue': pendingSales.fold(0.0, (sum, d) => sum + d.total) -
          pendingPurchases.fold(0.0, (sum, d) => sum + d.total),
    };
  }
}