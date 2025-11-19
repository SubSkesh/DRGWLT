import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/widgets/person_avatar.dart';
import 'package:drgwallet/widgets/person_card.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DealDetailScreen extends ConsumerWidget {
  final String dealId;

  const DealDetailScreen({super.key, required this.dealId});

  // --- LOGICA DI SELEZIONE PERSONA (Popup Grid) ---
  Future<void> _showPersonSelectionDialog(
      BuildContext context, WidgetRef ref, Deal deal) async {
    final theme = Theme.of(context);
    final personsAsync = ref.read(personsProvider);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title:  Text('Select Agent',style:theme.textTheme.headlineMedium!.copyWith(color:theme.colorScheme.primary)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  )
                ],
              ),
              body: personsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Error: $e")),
                data: (persons) {
                  return Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: persons.length,
                          itemBuilder: (ctx, index) {
                            final person = persons[index];
                            return PersonGridCard(
                              key: ValueKey(person.id),
                              person: person,
                              onTap: () async {
                                final dealService = ref.read(dealServiceProvider);
                                final updatedDeal = deal.copyWith(personId: person.id);
                                await dealService.updateDeal(updatedDeal);

                                ref.invalidate(enrichedDealProvider(deal.id));
                                ref.invalidate(personsProvider);
                                Navigator.of(sheetContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Assigned to ${person.name}'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              onLongPress: (details) async {
                                Navigator.of(sheetContext).pop();
                                await sheetContext.router.push(
                                  AddAgentRoute(
                                    initialType: person.personType,
                                    personToEdit: person,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.of(sheetContext).pop();
                            await sheetContext.router.push(
                              AddAgentRoute(initialType: PersonType.supplier),
                            );
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Create New Agent'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dealAsync = ref.watch(enrichedDealProvider(dealId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Deal Detail',
          style: theme.textTheme.headlineSmall,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modify Deal',
            onPressed: () => context.router.push(ModifyDealRoute(dealId: dealId)),
          ),
        ],
      ),
      body: dealAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error loading deal: $e")),
        data: (deal) {
          final isPurchase = deal.type == TxType.purchase;
          final color = isPurchase ? Colors.redAccent : Colors.green;
          final sign = isPurchase ? '-' : '+';
          final person = deal.person;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // 1. HEADER: AVATAR (Cliccabile)
                GestureDetector(
                  onTap: () => _showPersonSelectionDialog(context, ref, deal),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'person_avatar_${deal.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surfaceContainerHighest,
                              width: 4,
                            ),
                          ),
                          child: person != null
                              ? PersonAvatar(person: person, size: 90)
                              : CircleAvatar(
                            radius: 45,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              person?.name ?? 'Assigns Person',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600
                                ,color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.edit, size: 14, color: theme.colorScheme.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. PREZZO E STATO
                Text(
                  '$sign${deal.total.toStringAsFixed(2)}${deal.currency.symbol}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -1.0,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusPill(deal, theme),

                const SizedBox(height: 40),

                // 3. GRIGLIA DETTAGLI (Ripristinata a Riquadri!)
                // Row 1: Quantity | Price
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                          theme,
                          'Quantity',
                          '${deal.amount} ${deal.unit.symbol}',
                          Icons.scale_outlined
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoTile(
                          theme,
                          'Price/Unit',
                          '${deal.currency.symbol}${deal.pricePerUnit}',
                          Icons.sell_outlined
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 2: Date | Wallet
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                          theme,
                          'Date',
                          DateFormat('dd MMM yyyy').format(deal.date),
                          Icons.calendar_today_outlined
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, _) {
                          final wallets = ref.watch(userWalletsProvider).asData?.value ?? [];
                          String wName = 'Unknown';
                          try {
                            wName = wallets.firstWhere((w) => w.id == deal.walletId).name;
                          } catch (_) {}
                          return _buildInfoTile(
                              theme,
                              'Wallet',
                              wName,
                              Icons.account_balance_wallet_outlined
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildStatusPill(Deal deal, ThemeData theme) {
    final isPending = deal.isPending;
    final color = isPending ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            isPending ? 'PENDING CONFIRMATION' : 'CONFIRMED',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Questo è il widget a riquadro che ti piaceva
  Widget _buildInfoTile(ThemeData theme, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                overflow: TextOverflow.ellipsis
            ),
          ),
        ],
      ),
    );
  }
}