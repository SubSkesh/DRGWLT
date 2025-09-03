import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/models/good.dart';

class DealCalculator {
  // ========== CALCOLI FONDAMENTALI ==========

  /// Calcola il valore totale del deal (amount × pricePerUnit)
  static double calculateTotal(Deal deal) {
    return deal.amount * deal.pricePerUnit;//quantità * prezzo
  }

  /// Calcola il margine di profitto in percentuale
  static double? calculateProfitMargin({
    required Deal saleDeal,
    required Deal purchaseDeal,
  }) {
    if (saleDeal.type != TxType.sale || purchaseDeal.type != TxType.purchase) {
      return null;
    }

    final profit = saleDeal.total - purchaseDeal.total;
    return (profit / purchaseDeal.total) * 100;
  }

  // ========== CONVERSIONI UNITÀ ==========

  /// Converte tra unità di misura con tabella predefinita
  static double convertUnit({
    required double amount,
    required Unit fromUnit,
    required Unit toUnit,
  }) {
    return fromUnit.convertTo(amount, toUnit);
  }
  /// Calcola il prezzo per unità target dopo conversione
  static double calculatePriceInTargetUnit({
    required Deal deal,
    required Unit targetUnit,
  }) {
    return deal.unit.convertPrice(deal.pricePerUnit, targetUnit);
  }

  // ========== CALCOLI AVANZATI CON GOOD ==========

  /// Calcola il valore normalizzato nell'unità base del good
  static double calculateNormalizedValue(Deal deal, Good good) {
    final amountInBaseUnit = convertUnit(
      amount: deal.amount,
      fromUnit: deal.unit,
      toUnit: good.baseUnit,
    );

    return amountInBaseUnit * deal.pricePerUnit;
  }

  /// Confronta due deal in unità comparabili
  static double calculatePriceDifference(Deal deal1, Deal deal2, Good good) {
    final price1 = calculatePriceInTargetUnit(deal: deal1, targetUnit: good.baseUnit);
    final price2 = calculatePriceInTargetUnit(deal: deal2, targetUnit: good.baseUnit);

    return price1 - price2;
  }

  // ========== ANALISI DI PERFORMANCE ==========

  /// Calcola il ROI (Return On Investment) indica quanta quantità devi vendere (o a che prezzo minimo) per coprire i costi.
  static double? calculateROI(Deal purchase, Deal sale) {
    if (purchase.type != TxType.purchase || sale.type != TxType.sale) {
      return null;
    }

    final profit = sale.total - purchase.total;
    return (profit / purchase.total) * 100;
  }

  /// Calcola il break-even point ovvero
  static double calculateBreakEvenPoint(Deal purchase, double sellingPricePerUnit) {
    return purchase.pricePerUnit / sellingPricePerUnit;
  }

  // ========== UTILITIES ==========

  /// Filtra deals per tipo
  static List<Deal> filterByType(List<Deal> deals, TxType type) {
    return deals.where((deal) => deal.type == type).toList();
  }

  /// Ordina deals per data
  static List<Deal> sortByDate(List<Deal> deals, {bool descending = true}) {
    deals.sort((a, b) => descending
        ? b.timestamp.compareTo(a.timestamp)
        : a.timestamp.compareTo(b.timestamp));
    return deals;
  }

  /// Trova il deal più recente
  static Deal? findLatestDeal(List<Deal> deals) {
    if (deals.isEmpty) return null;
    return sortByDate(deals).first;
  }
}