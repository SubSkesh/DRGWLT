// lib/widgets/deal_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/widgets/person_avatar.dart'; // Assicurati che questo import sia corretto

// 1. Converti a ConsumerWidget e accetta 'dealId'
class DealListItem extends ConsumerWidget {
  final String dealId;

  // Il costruttore ora vuole 'dealId'
  const DealListItem({super.key, required this.dealId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Usa Riverpod per caricare i dati del singolo deal
    final dealAsync = ref.watch(enrichedDealProvider(dealId));
    final theme = Theme.of(context);

    // 3. Usa .when() per gestire caricamento, errore e dati pronti
    return dealAsync.when(
      loading: () => Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: Colors.grey.shade200),
          title: Container(
            height: 12,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.only(right: 100),
          ),
          subtitle: Container(
            height: 10,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.only(right: 40),
          ),
        ),
      ),
      error: (err, st) => Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red.shade100,
            child: const Icon(Icons.error, color: Colors.red),
          ),
          title: const Text('Errore nel caricare il deal'),
        ),
      ),
      data: (deal) {
        final color = deal.type == TxType.purchase ? Colors.red : Colors.green;
        final person = deal.person;

        Widget leadingWidget;
        if (person != null) {
          leadingWidget = Hero(
            tag: 'deal_icon_${deal.id}',
            child: PersonAvatar(person: person, size: 40),
          );
        } else {
          final icon = deal.type == TxType.purchase ? Icons.arrow_downward : Icons.arrow_upward;
          leadingWidget = Hero(
            tag: 'deal_icon_${deal.id}',
            child: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: leadingWidget,
            title: Text(
              '${deal.currency.symbol}${deal.total.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              person?.name ?? '${deal.amount} ${deal.unit.symbol}',
            ),
            trailing: deal.isPending
                ? const Icon(Icons.pending_actions, color: Colors.orange, size: 20)
                : const Icon(Icons.check_circle, color: Colors.green, size: 20),
            onTap: () {
              // L'ID del deal è già disponibile tramite la variabile 'dealId' del widget
              context.router.push(DealDetailRoute(dealId: dealId));
            },
          ),
        );
      },
    );
  }
}
