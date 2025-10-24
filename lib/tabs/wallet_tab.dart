import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/theme/app_theme.dart';
import 'package:drgwallet/widgets/wallet_card.dart';
import 'package:drgwallet/widgets/add_fab.dart';
import 'package:drgwallet/widgets/drag_context_menu.dart' as drag_context_menu;
import 'package:drgwallet/widgets/alarm_delete_wallet.dart';
import 'package:drgwallet/models/enum.dart';

class WalletsTab extends ConsumerStatefulWidget {
  const WalletsTab({super.key});

  @override
  ConsumerState<WalletsTab> createState() => _WalletsTabState();
}

class _WalletsTabState extends ConsumerState<WalletsTab> {
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

  void _showWalletContextMenu(LongPressStartDetails details, Wallet wallet) async {
    final actions = [
      drag_context_menu.ContextAction(
        icon: Icons.edit,
        label: 'Modifica',
        color: Theme.of(context).colorScheme.primary,
      ),
      drag_context_menu.ContextAction(
        icon: Icons.copy,
        label: 'Duplica',
        color: Theme.of(context).colorScheme.primary,
      ),
      drag_context_menu.ContextAction(
        icon: Icons.delete,
        label: 'Elimina',
        color: Colors.red,
      ),
    ];

    final selectedIndex = await drag_context_menu.showDragContextMenu(
      context,
      details.globalPosition,//rapresenta la posizione globale della finestra in cui viene mostrato il menu
      actions,
      'homescreen',
      mode: drag_context_menu.MenuOpenMode.dragToSelect,
    );

    if (selectedIndex != null) {
      switch (selectedIndex) {
        case 0:
          context.router.push(ModifyWalletRoute(walletid: wallet.id));
          break;
        case 1:
          print('Duplica wallet');
          break;
        case 2:
          _showDeleteDialog(context,wallet);
          break;
      }
    }
  }

  void _showDeleteDialog(BuildContext pageContext, Wallet walletToDelete) async {
    // Istanzia il tuo service qui o recuperalo da un provider
    final walletService = WalletService();

    // Usa il context della PAGINA, non del dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: pageContext,
      builder: (dialogContext) => WalletAlarmDelete(wallet: walletToDelete),
    );

    // Controlla se il widget è ancora "montato" prima di usare il context.
    // È una buona pratica dopo operazioni asincrone.
    if (!pageContext.mounted) return;

    // Esegui l'eliminazione solo se l'utente ha premuto "Delete" (restituisce true)
    if (shouldDelete == true) {
      try {
        // 1. Esegui la logica di eliminazione
        await walletService.deleteWallet(walletToDelete.id);

        // 2. Mostra un messaggio di successo usando il context della pagina
        ScaffoldMessenger.of(pageContext).showSnackBar(
          SnackBar(
            content: Text('"${walletToDelete.name}" successfully deleted.'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        // 3. In caso di errore, mostra un messaggio di errore
        ScaffoldMessenger.of(pageContext).showSnackBar(
          SnackBar(
            content: Text('Error during deletion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Widget _buildEmptyWalletsState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Nessun wallet trovato',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _createNewWallet,
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

  Widget _buildWalletsList(List<Wallet> wallets) {
    return ListView.builder(
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];
        return GestureDetector(
          onTap: () => _openWalletDetails(wallet),
          onLongPressStart: (details) => _showWalletContextMenu(details, wallet),
          child: WalletCard(
            wallet: wallet,
            onTap: () => _openWalletDetails(wallet),
          ),
        );
      },
    );
  }

  Widget _buildWalletsContent() {
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
          return _buildEmptyWalletsState();
        }
        return _buildWalletsList(wallets);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wallets',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
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
      body: _buildWalletsContent(),
      floatingActionButton: AddFloatingButton(onAddPressed: _onAddPressed),
    );
  }
}