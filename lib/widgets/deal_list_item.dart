import 'package:flutter/material.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/enum.dart';

class DealListItem extends StatelessWidget {
  final Deal deal;

  const DealListItem({
    super.key,
    required this.deal,

  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondary,
          child: Icon(
            deal.type == TxType.purchase ? Icons.shopping_cart : Icons.sell,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          deal.type == TxType.purchase ? 'Purchase' : 'Sell',
          style:theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold,fontFamily: 'Akira',color: theme.colorScheme.primary),// const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${deal.amount} ${deal.unit.toString().split('.').last} x €${deal.pricePerUnit.toStringAsFixed(2)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // pallino stato
            Row(
              mainAxisSize: MainAxisSize.min,//
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: deal.isPending ? Colors.orange : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  '${deal.date.day}/${deal.date.month}/${deal.date.year}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '€${deal.total.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall?.copyWith(// il copywith funziona così: prende un oggetto con proprietàs e crea un nuovo oggetto con le proprietà modificate
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
       // onTap: onTap,
      ),
    );
  }
}
