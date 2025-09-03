import 'package:flutter/material.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/services/wallet_service.dart';

class WalletCard extends StatefulWidget {
  final Wallet wallet;
  final VoidCallback onTap;
  final WalletService walletService;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.onTap,
    required this.walletService,
  });

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  late Future<int> _dealsCountFuture;

  @override
  void initState() {
    super.initState();
    _dealsCountFuture = widget.walletService.getWalletDealsCount(widget.wallet.id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet, size: 36),
        title: Text(
          widget.wallet.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.wallet.desc != null) Text(widget.wallet.desc!),
            const SizedBox(height: 4),
            FutureBuilder<int>(
              future: _dealsCountFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Caricamento deals...');
                } else if (snapshot.hasError) {
                  return const Text('Errore nel caricamento');
                } else {
                  return Text('Numero Deal: ${snapshot.data ?? 0}');
                }
              },
            ),
            if (widget.wallet.totalSpent != null)
              Text('Speso: €${widget.wallet.totalSpent!.toStringAsFixed(2)}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: widget.onTap,
      ),
    );
  }
}