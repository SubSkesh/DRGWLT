import 'package:drgwallet/models/wallet.dart';
import 'package:flutter/material.dart';

// Questo widget ora è pulito. Il suo unico compito è mostrare il dialog
// e restituire 'true' per conferma o 'false' per annullamento.
class WalletAlarmDelete extends StatelessWidget {
  final Wallet wallet;

  const WalletAlarmDelete({
    super.key,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final destructiveButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.error,
      foregroundColor: theme.colorScheme.onError,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: theme.colorScheme.error, size: 28),
          const SizedBox(width: 8),
          Text(
            "Confirm Deletion",
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
          children: [
            const TextSpan(text: "Are you sure you want to delete the wallet \""),
            TextSpan(
              text: wallet.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: "\"?\nThis action cannot be undone."),
          ],
        ),
      ),
      actions: [
        // Pulsante Annulla: chiude il dialog e restituisce 'false'
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"), // Lascia che Flutter gestisca il colore
        ),
        // Pulsante Elimina: chiude il dialog e restituisce 'true'
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: destructiveButtonStyle,
          child: const Text("Delete"),
        ),
      ],
    );
  }
}