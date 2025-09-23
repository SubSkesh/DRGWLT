import 'package:flutter/material.dart';

class WalletAlarmDelete extends StatelessWidget {
  final String walletName;
  final VoidCallback onConfirm;

  const WalletAlarmDelete({
    super.key,
    required this.walletName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: theme.colorScheme.error, size: 28),
          const SizedBox(width: 8),
          Text(
            "Conferma eliminazione",
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        "Sei sicuro di voler eliminare il wallet \"$walletName\"?\n"
            "Questa azione non può essere annullata.",
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Chiude senza eliminare
          child: Text(
            "Annulla",
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Chiude il dialog
            onConfirm(); // Chiama la callback per eliminare davvero
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Elimina"),
        ),
      ],
    );
  }
}
