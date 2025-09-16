import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/services/deal_service.dart';
import 'package:drgwallet/utils/wallet_calculator.dart';
import 'package:flutter/material.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/utils/deal_calculator.dart';
import 'package:drgwallet/theme/app_theme.dart';
import'package:drgwallet/models/enum.dart';
import 'package:drgwallet/widgets/add_fab_deal.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class WalletDetailScreen extends ConsumerStatefulWidget {
  final String walletId;

  const WalletDetailScreen({super.key, required this.walletId});

  @override
  ConsumerState<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends ConsumerState<WalletDetailScreen> {
  final WalletService _walletService = WalletService();
  final DealService _dealService = DealService();

  // UniqueKey _refreshKey = UniqueKey(); // VARIABILE PER REFRESH DEL LISTVIEW BUILDER
  Wallet? _wallet;
  List<Deal> _deals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  void _onAddPressed(TxType? dealType) {
    if (dealType != null) {
      context.router.push(
        AddDealRoute(
          dealType: dealType,
          preSelectedWalletId: widget.walletId,
          // ← Passa l'ID del wallet corrente
          onDealCreated: _loadWalletData, // Passa direttamente la funzione


        ),
      );
    }
  }

  Future<void> _loadWalletData() async {
    try {
      final wallet = await _walletService.getWalletWithStats(widget.walletId);
      final deals = await _walletService.getWalletDeals(widget.walletId);

      setState(() {
        _wallet = wallet;
        _deals = deals;
        _isLoading = false;
      });
    } catch (e) {
      // Gestisci errore
      setState(() {
        _isLoading = false;
      });
    }
  }
  //TODO:AGGIUNGERE òA RPTTA èER IL DETTAGLIO DEAL
  // void _dealDetail(String dealID) {
  //   context.router.push(
  //     const DealDetailRoute(dealID),
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_wallet == null) {
      return const Scaffold(
        body: Center(child: Text('Wallet non trovato')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _wallet!.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Game',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _wallet!.desc ?? '',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatRow(
                        'Total Deals', _wallet!.totalDeals?.toString() ?? '0'),
                    _buildStatRow('Total Spent',
                        '€${_wallet!.totalSpent?.toStringAsFixed(2) ??
                            "0.00"}'),
                    _buildStatRow('Totale Guadagnato',
                        '€${_wallet!.totalEarned?.toStringAsFixed(2) ??
                            "0.00"}'),
                    _buildStatRow('Profitto Netto',
                        '€${_wallet!.netProfit?.toStringAsFixed(2) ?? "0.00"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last Deals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _deals.isEmpty
                  ? const Center(child: Text('Nessun deal trovato'))
                  : ListView(
                children: ListTile.divideTiles(
                  context: context, // Aggiunto context qui, spesso richiesto
                  color: theme.colorScheme.primary,
                  tiles: _deals.map(
                        (deal) =>
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor:theme.colorScheme.secondary, // Colore per SELL (o un altro tipo)
                            child: Icon(
                              deal.type == TxType.sale
                                  ? Icons.shopping_cart // Icona per BUY
                                  : Icons.sell, // Icona per SELL
                              color: Colors.white, // Colore dell'icona, se necessario
                            ),
                          ),
                          title: Text(
                            deal.type
                                .toString()
                                .split('.')
                                .last,
                            style: theme.textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                              '${deal.amount} x €${deal.pricePerUnit
                                  .toStringAsFixed(2)}'),

                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${deal.date.day}/${deal.date.month}/${deal.date.year}'),
                              Text('€${deal.total.toStringAsFixed(2)}'),
                            ],
                          ),
                       // onTap: _dealDetail(walletid,deal.id) ,
                        ),
                  ),
                ).toList(),
              ),
              // : ListView.builder(
              //     itemCount: _deals.length,
              //     itemBuilder: (context, index) {
              //       final deal = _deals[index];
              //       return ListTile(
              //         title: Text(
              //           deal.type.toString().split('.').last,
              //           style: theme.textTheme.bodyLarge,
              //         ),
              //         subtitle: Text(
              //             '${deal.amount} x €${deal.pricePerUnit.toStringAsFixed(2)}'),
              //         trailing: Text('€${deal.total.toStringAsFixed(2)}'),
              //       );
              //     },
              //   ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 55.0),
        child: AddDealFloatingButton(onAddPressed: _onAddPressed),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyLarge,),
          Text(value),
        ],
      ),
    );
  }
}