import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/widgets/custom_bottom_nav.dart';
import 'package:drgwallet/widgets/deal_list_item.dart';
import 'package:drgwallet/widgets/wallet_card.dart';
import 'package:drgwallet/widgets/add_fab.dart';
import 'package:drgwallet/theme/app_theme.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/widgets/radial_action.dart';
import 'package:drgwallet/widgets/radial_context_menu.dart';
import 'package:drgwallet/widgets/drag_context_menu.dart' as drag_context_menu;
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _onAddPressed(TxType? dealType) {
    if (dealType != null) {
      context.router.push(AddDealRoute(dealType: dealType));
    } else {
      _createNewWallet();
    }
  }

  void _createNewWallet() {
    context.router.push(AddWalletRoute());
  }

  void _openWalletDetails(Wallet wallet) {
    context.router.push(WalletDetailRoute(walletId: wallet.id));
  }

  void _openDealDetails(Deal deal) {
    // Implementa l'apertura dei dettagli del deal
  }

  void _onItemTapped(int index) {
    ref.read(selectedTabProvider.notifier).setTab(index);// Aggiungi questa riga per aggiornare il selectedTabProvider con l'indice dell'elemento selezionato
  }

  Future<void> _showRadialContextMenu(
      BuildContext context, Offset position, List<RadialAction> actions) async {
    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => RadialContextMenu(
        position: position,
        actions: actions,
        onClose: () => overlayEntry.remove,// this is the callback that will be called when the context menu is closed
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = ref.watch(selectedTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('DRG Wallet',
          style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.primary),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.account_circle, color: theme.iconTheme.color),
          onPressed: () => context.router.push(const ProfileRoute()),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildCurrentTab(selectedIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: AddFloatingButton(onAddPressed: _onAddPressed),
    );
  }

  Widget _buildCurrentTab(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return _buildWalletsTab();
      case 1:
        return _buildDealsTab();
      case 2:
        return _buildStatsTab();
      default:
        return _buildWalletsTab();
    }
  }

  Widget _buildDealsTab() {
    final theme = Theme.of(context);
    final dealsAsync = ref.watch(userDealsProvider);

    return dealsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
      error: (error, stack) => Center(
        child: Text('Errore: $error', style: theme.textTheme.bodyLarge),
      ),
      data: (deals) {
        if (deals.isEmpty) {
          return Center(
            child: Text('Nessun deal trovato', style: theme.textTheme.bodyLarge),
          );
        }

        return ListView.builder(
          itemCount: deals.length,
          itemBuilder: (context, index) {
            final deal = deals[index];
            return DealListItem(
              deal: deal,
              onTap: () => _openDealDetails(deal),
            );
          },
        );
      },
    );
  }

  Widget _buildWalletsTab() {
    final theme = Theme.of(context);
    final walletsAsync = ref.watch(userWalletsProvider);

    return walletsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
      error: (error, stack) => Center(
        child: Text('Errore: $error', style: theme.textTheme.bodyLarge),
      ),
      data: (wallets) {
        if (wallets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Nessun wallet trovato', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _createNewWallet(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Crea il primo wallet'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: wallets.length,
          itemBuilder: (context, index) {
            final wallet = wallets[index];
            return GestureDetector(
              onTap: () => _openWalletDetails(wallet),
              // onLongPressStart: (details) async {
              //   final actions = [
              //     RadialAction(
              //       icon: Icons.edit,
              //       label: 'Modifica',
              //       onSelect: () => print('Modifica wallet'),
              //       color: Colors.blue,//this is the color of the button when pressed
              //     ),
              //     RadialAction(
              //       icon: Icons.copy,
              //       label: 'Duplica',
              //       onSelect: () => print('Duplica wallet'),
              //     ),
              //     RadialAction(
              //       icon: Icons.delete,
              //       label: 'Elimina',
              //       onSelect: () => print('Elimina wallet'),
              //       color: Colors.red,
              //     ),
              //   ];
              //
              //   await _showRadialContextMenu(context, details.globalPosition, actions);
              //   /*details.globalPosition è una proprietà dell'oggetto LongPressStartDetails, che viene passato al callback onLongPressStart.
              //   - È un oggetto Offset, quindi contiene:
              //    - dx: distanza orizzontale dal bordo sinistro dello schermo.
              //    - dy: distanza verticale dal bordo superiore dello schermo.
              //    */
              // },
              onLongPressStart: (details) async {
                final actions = [
                  drag_context_menu.ContextAction(
                    icon: Icons.edit,
                    label: 'Modifica',
                    color: Colors.blue,
                  ),
                  drag_context_menu.ContextAction(
                    icon: Icons.copy,
                    label: 'Duplica',
                  ),
                  drag_context_menu.ContextAction(
                    icon: Icons.delete,
                    label: 'Elimina',
                    color: Colors.red,
                  ),
                ];

                final selectedIndex = await drag_context_menu.showDragContextMenu(
                  context,
                  details.globalPosition,
                  actions,
                  applyOnHover: false, // Cambia a true se vuoi che si attivi subito
                );

                if (selectedIndex != null) {
                  switch (selectedIndex) {
                    case 0:
                      print('Modifica wallet');
                      break;
                    case 1:
                      print('Duplica wallet');
                      break;
                    case 2:
                      print('Elimina wallet');
                      break;
                  }
                }
              },
              child: WalletCard(
                wallet: wallet,
                onTap: () => _openWalletDetails(wallet),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsTab() {
    final theme = Theme.of(context);
    return Center(
      child: Text('Statistiche - In sviluppo', style: theme.textTheme.bodyLarge),
    );
  }
}