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
      details.globalPosition,
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
          _showDeleteWalletDialog(wallet);
          break;
      }
    }
  }

  void _showDeleteWalletDialog(Wallet wallet) {
    showDialog(
      context: context,
      builder: (ctx) => WalletAlarmDelete(
        walletName: wallet.name,
        onConfirm: () async {
          final walletService = ref.read(walletServiceProvider);
          await walletService.deleteWallet(wallet.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Wallet eliminato con successo")),
            );
          }
        },
      ),
    );
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
          'DRG Wallets',
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