import 'package:flutter/material.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalletCard extends ConsumerWidget {  // Cambia in ConsumerWidget
  final Wallet wallet;
  final VoidCallback onTap;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsCountAsync = ref.watch(walletDealsCountProvider(wallet.id));

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet, size: 36),
        title: Text(
          wallet.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (wallet.desc != null) Text(wallet.desc!),
            const SizedBox(height: 4),
            dealsCountAsync.when(
              loading: () => const Text('Caricamento deals...'),
              error: (error, stack) => const Text('Errore nel caricamento'),
              data: (count) => Text('Numero Deal: $count'),
            ),
            if (wallet.totalSpent != null)
              Text('Speso: €${wallet.totalSpent!.toStringAsFixed(2)}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}