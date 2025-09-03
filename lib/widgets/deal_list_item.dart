import 'package:flutter/material.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/enum.dart';

class DealListItem extends StatelessWidget {
  final Deal deal;
  final VoidCallback onTap;

  const DealListItem({
    super.key,
    required this.deal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          deal.type == TxType.purchase ? Icons.shopping_cart : Icons.sell,
          color: deal.type == TxType.purchase ? Colors.red : Colors.green,
        ),
        title: Text(
          deal.type == TxType.purchase ? 'Acquisto' : 'Vendita',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${deal.amount} ${deal.unit.toString().split('.').last}'),
            Text('€${deal.pricePerUnit.toStringAsFixed(2)}/unità'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '€${deal.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (deal.isPending)
              const Text(
                'In attesa',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}