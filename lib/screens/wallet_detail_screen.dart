import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/services/deal_service.dart';
import 'package:drgwallet/widgets/deal_list_item.dart';
import 'package:drgwallet/utils/wallet_calculator.dart';
import 'package:flutter/material.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/utils/deal_calculator.dart';
import 'package:drgwallet/theme/app_theme.dart';
import'package:drgwallet/models/enum.dart';
import 'package:drgwallet/widgets/add_fab_deal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/widgets/drag_context_menu.dart' as drag_context_menu;


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

  UniqueKey _refreshKey = UniqueKey();

  void _onAddPressed(TxType? dealType) {
    if (dealType != null) {
      context.router.push(
        AddDealRoute(
          dealType: dealType,
          preSelectedWalletId: widget.walletId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final walletAsync = ref.watch(walletDetailsWithStatsStreamProvider(widget.walletId));
    final dealsAsync = ref.watch(walletDealsProvider(widget.walletId  ));

    return Scaffold(
      appBar: AppBar(
        title: walletAsync.when(
          data: (wallet) => Text(
            wallet.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'Game',
            ),
          ),
          loading: () => const Text("Caricamento..."),
          error: (e, _) => Text("Errore"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: walletAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text("Errore: $err")),
          data: (wallet) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(wallet.desc ?? '', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildStatRow('Total Deals', wallet.totalDeals?.toString() ?? '0'),
                      _buildStatRow('Total Spent',
                          '€${wallet.totalSpent?.toStringAsFixed(2) ?? "0.00"}'),
                      _buildStatRow('Totale Guadagnato',
                          '€${wallet.totalEarned?.toStringAsFixed(2) ?? "0.00"}'),
                      _buildStatRow('Profitto Netto',
                          '€${wallet.netProfit?.toStringAsFixed(2) ?? "0.00"}'),
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

              // LISTA DEALS
              Expanded(
                child: dealsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Center(child: Text("Errore: $err")),
                  data: (deals) {
                    if (deals.isEmpty) {
                      return const Center(child: Text('Nessun deal trovato'));
                    }
                    return ListView.builder(
                      key: _refreshKey,
                      itemCount: deals.length,
                      itemBuilder: (context, index) {
                        final deal = deals[index];
                        return GestureDetector(
                          onLongPressStart: (details) async {
                            final actions = [
                              drag_context_menu.ContextAction(
                                icon: Icons.edit,
                                label: 'Modifica',
                                color: theme.colorScheme.primary,
                              ),
                              drag_context_menu.ContextAction(
                                icon: Icons.copy,
                                  label: 'Clone',
                                  color: theme.colorScheme.primary,

                              ),
                              drag_context_menu.ContextAction(
                                icon: deal.isPending
                                    ? Icons.check_circle
                                    : Icons.pending_actions,
                                label: deal.isPending
                                    ? 'Not Pending'
                                    : 'Pending',
                                color: deal.isPending
                                    ? theme.colorScheme.primary
                                    : Colors.orange
                              ),
                              drag_context_menu.ContextAction(
                                icon: Icons.delete,
                                label: 'Elimina',
                                color: Colors.red,
                              ),
                            ];

                            final selectedIndex =
                            await drag_context_menu.showDragContextMenu(
                              context,
                              details.globalPosition,
                              actions,
                              'walletdetailscreen',
                              mode: drag_context_menu.MenuOpenMode.dragToSelect,
                            );

                            if (selectedIndex != null) {
                              switch (selectedIndex) {
                                case 0:
                                  print('Modifica deal: ${deal.id}');
                                  break;
                                case 1:
                                  print('Clone deal: ${deal.id}');
                                  await
                                  _dealService.createDeal(deal.copyWith(date: DateTime.now(),id: DateTime.now().millisecondsSinceEpoch.toString()));
                                case 2:
                                  final updateDeal =
                                  deal.copyWith(isPending: !deal.isPending);
                                  await _dealService.updateDeal(updateDeal);
                                  break;
                                case 3:
                                  print('Elimina deal: ${deal.id}');
                                  // await _dealService.deleteDeal(deal.id!);
                                  break;
                              }
                            }
                          },
                          child: DealListItem(
                            deal: deal,
                          //  onTap: () {
                              // TODO: navigazione dettaglio deal

                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
          Text(label, style: theme.textTheme.bodyLarge),
          Text(value),
        ],
      ),
    );
  }
}
