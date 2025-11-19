// lib/screens/wallet_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/services/deal_service.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/widgets/add_fab_deal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/widgets/drag_context_menu.dart' as drag_context_menu;
import 'package:drgwallet/widgets/DealListItem.dart';
import 'package:drgwallet/widgets/alarm_delete_deal.dart';


@RoutePage()
class WalletDetailScreen extends ConsumerStatefulWidget {
  final String walletId;

  const WalletDetailScreen({super.key, required this.walletId});

  @override
  ConsumerState<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends ConsumerState<WalletDetailScreen> {
  final DealService _dealService = DealService();


  Future<void> _showDeleteDialog(BuildContext context, Deal deal) async {
    // Mostra il dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => DealAlarmDelete(deal: deal),
    );

    if (confirm == true && mounted) {
      try {
        // Esegui l'eliminazione tramite il service (già istanziato come _dealService)
        await _dealService.deleteDeal(deal.id);

        // Forza l'aggiornamento della lista e delle statistiche
        if (mounted) {
          ref.invalidate(walletDealsProvider(widget.walletId));
          ref.invalidate(walletDetailsWithStatsStreamProvider(widget.walletId));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deal deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting deal: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  void _onAddPressed(TxType? dealType) async {
    if (dealType != null) {
      // Aspetta che la schermata di aggiunta sia chiusa per aggiornare la lista
      await context.router.push(
        AddDealRoute(
          dealType: dealType,
          preSelectedWalletId: widget.walletId,
        ),
      );
      // Invalida la lista principale per mostrare il nuovo deal
      if(mounted) {
        ref.invalidate(walletDealsProvider(widget.walletId));
        ref.invalidate(walletDetailsWithStatsStreamProvider(widget.walletId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final walletAsync = ref.watch(walletDetailsWithStatsStreamProvider(widget.walletId));
    final dealsAsync = ref.watch(walletDealsProvider(widget.walletId));

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
          error: (e, _) => const Text("Errore"),
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
                      _buildStatRow('Total Spent', '€${wallet.totalSpent?.toStringAsFixed(2) ?? "0.00"}'),
                      _buildStatRow('Totale Guadagnato', '€${wallet.totalEarned?.toStringAsFixed(2) ?? "0.00"}'),
                      _buildStatRow('Profitto Netto', '€${wallet.netProfit?.toStringAsFixed(2) ?? "0.00"}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Last Deals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: dealsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Center(child: Text("Errore: $err")),
                  data: (deals) {
                    if (deals.isEmpty) {
                      return const Center(child: Text('No deals found'));
                    }
                    return ListView.builder(
                      itemCount: deals.length,
                      itemBuilder: (context, index) {
                        final deal = deals[index];
                        return GestureDetector(
                          onTap: () async {
                            await context.router.push(DealDetailRoute(dealId: deal.id));
                            if (mounted) {
                              // FORZA L'AGGIORNAMENTO DELLA LISTA E DELLE STATISTICHE
                              ref.invalidate(walletDealsProvider(widget.walletId));
                              ref.invalidate(walletDetailsWithStatsStreamProvider(widget.walletId));
                            }
                          },
                          onLongPressStart: (details) async {
                            final dealWithPerson = await ref.read(enrichedDealProvider(deal.id).future);
                            final actions = [
                              drag_context_menu.ContextAction(icon: Icons.edit, label: 'Modifica', color: theme.colorScheme.primary),
                              drag_context_menu.ContextAction(icon: Icons.copy, label: 'Clone', color: theme.colorScheme.primary),
                              drag_context_menu.ContextAction(icon: dealWithPerson.isPending ? Icons.check_circle : Icons.pending_actions, label: dealWithPerson.isPending ? 'Not Pending' : 'Pending', color: dealWithPerson.isPending ? theme.colorScheme.primary : Colors.orange),
                              drag_context_menu.ContextAction(icon: Icons.delete, label: 'Elimina', color: Colors.red),
                            ];
                            final selectedIndex = await drag_context_menu.showDragContextMenu(context, details.globalPosition, actions, 'walletdetailscreen', mode: drag_context_menu.MenuOpenMode.dragToSelect);
                            if (selectedIndex != null) {
                              switch (selectedIndex) {
                                case 0: // Modifica deal
                                  if (mounted) {
                                    await context.router.push(ModifyDealRoute(dealId: deal.id));
                                    // FORZA L'AGGIORNAMENTO DELLA LISTA E DELLE STATISTICHE
                                    ref.invalidate(walletDealsProvider(widget.walletId));
                                    ref.invalidate(walletDetailsWithStatsStreamProvider(widget.walletId));
                                  }
                                  break;

                                case 1: // Clone deal (Verifica che l'indice corrisponda alla voce 'Clone' nella tua lista actions)
                                  try {
                                    // 1. Genera un NUOVO ID univoco (fondamentale!)
                                    // Usiamo lo stesso metodo basato sul tempo usato in AddDealScreen
                                    final newId = DateTime.now().millisecondsSinceEpoch.toString();

                                    // 2. Crea una copia del deal con il nuovo ID e la data aggiornata
                                    final newDeal = dealWithPerson.copyWith(
                                      id: newId,
                                      date: DateTime.now(),       // La data operativa diventa "adesso"
                                      timestamp: DateTime.now(),  // La data di creazione tecnica diventa "adesso"
                                      // Puoi decidere se resettare lo stato pending o mantenerlo
                                      isPending: dealWithPerson.isPending,
                                    );

                                    // 3. Salva il nuovo deal su Firestore
                                    await _dealService.createDeal(newDeal);

                                    // 4. Aggiorna la UI e dai feedback all'utente
                                    // 4. Aggiorna la UI e dai feedback all'utente
                                    if (mounted) {
                                      // Invalida i provider per ricaricare la lista e le statistiche
                                      ref.invalidate(walletDealsProvider(widget.walletId));
                                      ref.invalidate(walletDetailsWithStatsStreamProvider(widget.walletId));

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Deal cloned successfully!'),
                                          backgroundColor: theme.colorScheme.primary,
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(milliseconds: 1500),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error cloning deal: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                  break;
                                case 2: // Toggle pending
                                  final updateDeal = dealWithPerson.copyWith(isPending: !dealWithPerson.isPending);
                                  await _dealService.updateDeal(updateDeal);
                                  // Per il toggle pending, invalidare il singolo item è sufficiente
                                  // e più performante.
                                  ref.invalidate(enrichedDealProvider(deal.id));
                                  break;
                                case 3: // Elimina deal
                                // await _dealService.deleteDeal(deal.id);
                                // ref.invalidate(walletDealsProvider(widget.walletId));
                                // ref.invalidate(walletDetailsWithStatsStreamProvider(widget.walletId));
                                  _showDeleteDialog(context, dealWithPerson);
                                  break;
                              }
                            }
                          },
                          child: DealListItem(dealId: deal.id),
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
        children: [Text(label, style: theme.textTheme.bodyLarge), Text(value)],
      ),
    );
  }
}
