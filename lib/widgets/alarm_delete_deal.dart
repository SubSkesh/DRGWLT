import 'package:flutter/material.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/enum.dart';

class DealAlarmDelete extends StatelessWidget {
  final Deal deal;

  const DealAlarmDelete({
    super.key,
    required this.deal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Costruiamo una descrizione leggibile del deal
    final String typeStr = deal.type == TxType.purchase ? "Purchase" : "Sale";
    final String desc = "$typeStr of ${deal.amount} ${deal.unit.symbol}";

    final destructiveButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.error,
      foregroundColor: theme.colorScheme.onError,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 8),
          const Text('Confirm Delete'),
        ],
      ),
      content: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
          children: [
            const TextSpan(text: "Are you sure you want to delete this deal:\n\n"),
            TextSpan(
              text: desc, // Es: "Purchase of 50.0 g"
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: "\nValue: ${deal.currency.symbol}${deal.total.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: "\n\nThis action cannot be undone."),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Undo'),
        ),
        ElevatedButton(
          style: destructiveButtonStyle,
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}