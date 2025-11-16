// lib/widgets/deal_detail_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/widgets/person_avatar.dart';

class DealDetailHeader extends ConsumerWidget {
  final String dealId;

  const DealDetailHeader({super.key, required this.dealId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Questo widget osserva solo il provider del deal arricchito
    final dealAsync = ref.watch(enrichedDealProvider(dealId));
    final theme = Theme.of(context);

    // Usa .when per gestire caricamento ed errore solo per questo pezzo di UI
    return dealAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => const Text('Error loading header'),
      data: (deal) {
        final person = deal.person;
        final color = deal.type == TxType.purchase ? Colors.red : Colors.green;
        final typeText = deal.type == TxType.purchase ? 'PURCHASE' : 'SALE';

        Widget leadingWidget;
        if (person != null) {
          leadingWidget = PersonAvatar(person: person, size: 60);
        } else {
          final icon = deal.type == TxType.purchase ? Icons.arrow_downward : Icons.arrow_upward;
          leadingWidget = CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 30),
          );
        }

        return Row(
          children: [
            Hero(
              tag: 'deal_icon_${deal.id}',
              child: Material(
                color: Colors.transparent,
                child: leadingWidget,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${deal.currency.symbol}${deal.total.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    person?.name ?? typeText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${deal.amount.toStringAsFixed(2)} ${deal.unit.symbol}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
