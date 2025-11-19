import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/widgets/person_avatar.dart';
import 'package:intl/intl.dart'; // Assicurati di avere intl nel pubspec.yaml per le date

class DealListItem extends ConsumerWidget {
  final String dealId;

  const DealListItem({super.key, required this.dealId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealAsync = ref.watch(enrichedDealProvider(dealId));
    final theme = Theme.of(context);

    return dealAsync.when(
      loading: () => _buildLoadingSkeleton(),
      error: (err, st) => const SizedBox(), // Nascondi in caso di errore o mostra icona piccola
      data: (deal) {
        final isPurchase = deal.type == TxType.purchase;
        final color = isPurchase ? Colors.redAccent : Colors.green;
        final person = deal.person;

        // Formattazione Data (es: "12 Oct" o "14:30")
        final dateStr = DateFormat('dd MMM').format(deal.date);

        // Segno + o - davanti al prezzo
        final sign = isPurchase ? '-' : '+';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.router.push(DealDetailRoute(dealId: dealId)),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Row(
                children: [
                  // 1. AVATAR
                  Hero(
                    tag: 'deal_icon_${deal.id}',
                    child: person != null
                        ? PersonAvatar(person: person, size: 48)
                        : Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPurchase ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 2. INFO CENTRALI (Nome e Quantità)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person?.name ?? (isPurchase ? 'Purchase' : 'Sale'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${deal.amount.toStringAsFixed(1)} ${deal.unit.symbol}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            // Separatore puntino
                            if (deal.isPending) ...[
                              const SizedBox(width: 6),
                              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(
                                'Pending',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10
                                ),
                              )
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 3. PREZZO E DATA (Allineati a destra)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$sign${deal.total.toStringAsFixed(2)}${deal.currency.symbol}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: -0.5, // Tocco moderno per i numeri
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Skeleton minimale per il loading
  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 14, color: Colors.grey.shade200),
                const SizedBox(height: 6),
                Container(width: 60, height: 10, color: Colors.grey.shade200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}