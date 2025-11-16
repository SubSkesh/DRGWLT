// deal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/widgets/deal_detail_header.dart';
import 'package:drgwallet/widgets/person_avatar.dart';
// Importa il nuovo widget per il dropdown
import 'package:drgwallet/widgets/person_dropdown.dart';
import 'package:drgwallet/models/enum.dart';


@RoutePage()
class DealDetailScreen extends ConsumerStatefulWidget {
  final String dealId;

  const DealDetailScreen({super.key, required this.dealId});

  @override
  ConsumerState<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends ConsumerState<DealDetailScreen> {
  // Non abbiamo più bisogno di service, key, o metodi _build...Dropdown qui

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.router.push(ModifyDealRoute(dealId: widget.dealId));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DealDetailHeader(dealId: widget.dealId),
            const SizedBox(height: 24),
            _buildDealInfoSection(theme),
            const SizedBox(height: 24),
            // La sezione persona ora è più pulita
            _buildPersonSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDealInfoSection(ThemeData theme) {
    // Questo widget usa ref.watch e si ricostruisce quando i dati cambiano
    final walletsAsync = ref.watch(userWalletsProvider);
    final dealAsync = ref.watch(enrichedDealProvider(widget.dealId));

    return dealAsync.when(
      loading: () => const Card(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
      error: (e,s) => const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Error"))),
      data: (deal) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Deal Information', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildInfoRow('Date', _formatDate(deal.date)),
              _buildInfoRow('Quantity', '${deal.amount.toStringAsFixed(2)} ${deal.unit.symbol}'),
              _buildInfoRow('Unit Price', '${deal.currency.symbol}${deal.pricePerUnit.toStringAsFixed(2)}/${deal.unit.symbol}'),
              _buildInfoRow('Total Amount', '${deal.currency.symbol}${deal.total.toStringAsFixed(2)}'),
              _buildInfoRow('Currency', '${deal.currency.symbol} - ${deal.currency.displayName}'),
              walletsAsync.when(
                data: (wallets) {
                  final wallet = wallets.firstWhere((w) => w.id == deal.walletId, orElse: () => Wallet(id: '', ownerID: '', name: 'Wallet not found', createdAt: DateTime.now()));
                  return _buildInfoRow('Wallet', wallet.name);
                },
                loading: () => _buildInfoRow('Wallet', 'Loading...'),
                error: (e, _) => _buildInfoRow('Wallet', 'Error'),
              ),
              _buildInfoRow('Status', deal.isPending ? 'Pending' : 'Completed', valueColor: deal.isPending ? Colors.orange : Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonSection(ThemeData theme) {
    final dealAsync = ref.watch(enrichedDealProvider(widget.dealId));
    final personsAsync = ref.watch(personsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Associated Person', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Gestiamo il caricamento dei due provider
        dealAsync.when(
            loading: () => const Card(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            error: (e, s) => const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Error loading deal"))),
            data: (deal) {
              final currentPerson = deal.person;
              return personsAsync.when(
                loading: () => const Card(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
                error: (err, st) => const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Error loading persons"))),
                data: (persons) {
                  // Una volta che abbiamo tutti i dati, costruiamo la UI
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (currentPerson != null)
                            _buildCurrentPersonInfo(currentPerson, theme)
                          else
                            _buildNoPersonAssigned(theme),
                          const SizedBox(height: 16),
                          // USA IL NUOVO WIDGET ISOLATO
                          PersonDropdown(
                            deal: deal,
                            persons: persons,
                            currentPerson: currentPerson,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
        ),
      ],
    );
  }

  Widget _buildCurrentPersonInfo(Person person, ThemeData theme) {
    return Row(
      children: [
        PersonAvatar(person: person, size: 50),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(person.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(person.type, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              Text('${person.dealsCount} deals', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoPersonAssigned(ThemeData theme) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person_outline, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'No person assigned',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withOpacity(0.7))),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: valueColor ?? theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
