import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/models/wallet.dart';import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/widgets/custom_bottom_nav.dart';
import 'package:drgwallet/widgets/deal_list_item.dart';
import 'package:drgwallet/widgets/wallet_card.dart';
import 'package:drgwallet/widgets/add_fab.dart';
import 'package:drgwallet/theme/app_theme.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/services/person_service.dart';
import 'package:drgwallet/widgets/radial_action.dart';
import 'package:drgwallet/widgets/add_fab_agents.dart';
import 'package:drgwallet/widgets/radial_context_menu.dart';
import 'package:drgwallet/widgets/drag_context_menu.dart' as drag_context_menu;
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:drgwallet/widgets/alarm_delete_wallet.dart';

import '../widgets/person_card.dart';

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _onAddPressed(TxType? dealType) {
    if (dealType != null) {
      context.router.push(AddDealRoute(dealType: dealType));
    } else {
      _createNewWallet();
    }
  }

  void _createNewWallet() {
    context.router.push(AddWalletRoute());
  }

  void _addNewPerson() {
    context.router.push(AddAgentRoute(initialType: null));
  }

  void _openWalletDetails(Wallet wallet) {
    context.router.push(WalletDetailRoute(walletId: wallet.id));
  }

  void _openDealDetails(Deal deal) {
    // Implementa l'apertura dei dettagli del deal
  }

  void _onItemTapped(int index) {
    ref.read(selectedTabProvider.notifier).setTab(index);// Aggiungi questa riga per aggiornare il selectedTabProvider con l'indice dell'elemento selezionato
  }

  Future<void> _showRadialContextMenu(
      BuildContext context, Offset position, List<RadialAction> actions) async {
    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => RadialContextMenu(
        position: position,
        actions: actions,
        onClose: () => overlayEntry.remove,// this is the callback that will be called when the context menu is closed
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
  void _onAddAgentPressed(PersonType? personType) {
    if (personType != null) {
      context.router.push(AddAgentRoute(initialType: personType));}}

      // Funzione per costruire il FAB in base al tab selezionato
  Widget _buildFAB(int selectedIndex) {
    switch (selectedIndex) {
      case 0: // Tab Wallet
        return AddFloatingButton(onAddPressed: _onAddPressed);
      case 1: // Tab Agents
        return AddAgentsFloatingButton(onAddPressed: _onAddAgentPressed);
      case 2: // Tab Goods
      // Se hai bisogno di un FAB specifico per Goods, crealo qui
        return AddFloatingButton(onAddPressed: _onAddPressed);
      case 3: // Tab Stats
      // Se hai bisogno di un FAB specifico per Stats, crealo qui
        return AddFloatingButton(onAddPressed: _onAddPressed);
      default:
        return AddFloatingButton(onAddPressed: _onAddPressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = ref.watch(selectedTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('DRG Wallet',
          style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.primary),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.account_circle, color: theme.iconTheme.color),
          onPressed: () => context.router.push(const ProfileRoute()),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildCurrentTab(selectedIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        actions: [  BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
          BottomNavigationBarItem(
            icon: ImageIcon(Image.asset('assets/icons/discussion_meeting_people_icon.png').image),//Image.asset('assets/icons/discussion_meeting_people_icon.png',),
            label: 'Agents',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(Image.asset('assets/icons/exchange_goods_icon.png',).image),
            label: 'Goods',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),],
      ),
      floatingActionButton: _buildFAB(selectedIndex),//AddFloatingButton(onAddPressed: _onAddPressed),
    );
  }

  Widget _buildCurrentTab(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return _buildWalletsTab();
      case 1:
        return _buildAgentsTab();
      case 2:
        return _buildStatsTab();
      default:
        return _test();
    }
  }

  Widget _buildWalletsTab() {
    final theme = Theme.of(context);
    final walletsAsync = ref.watch(userWalletsProvider);

    return walletsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
      error: (error, stack) => Center(
        child: Text('Errore: $error', style: theme.textTheme.bodyLarge),
      ),
      data: (wallets) {
        if (wallets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Nessun wallet trovato', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _createNewWallet(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Crea il primo wallet'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: wallets.length,
          itemBuilder: (context, index) {
            final wallet = wallets[index];
            return GestureDetector(
              onTap: () => _openWalletDetails(wallet),
              // onLongPressStart: (details) async {
              //   final actions = [
              //     RadialAction(
              //       icon: Icons.edit,
              //       label: 'Modifica',
              //       onSelect: () => print('Modifica wallet'),
              //       color: Colors.blue,//this is the color of the button when pressed
              //     ),
              //     RadialAction(
              //       icon: Icons.copy,
              //       label: 'Duplica',
              //       onSelect: () => print('Duplica wallet'),
              //     ),
              //     RadialAction(
              //       icon: Icons.delete,
              //       label: 'Elimina',
              //       onSelect: () => print('Elimina wallet'),
              //       color: Colors.red,
              //     ),
              //   ];
              //
              //   await _showRadialContextMenu(context, details.globalPosition, actions);
              //   /*details.globalPosition è una proprietà dell'oggetto LongPressStartDetails, che viene passato al callback onLongPressStart.
              //   - È un oggetto Offset, quindi contiene:
              //    - dx: distanza orizzontale dal bordo sinistro dello schermo.
              //    - dy: distanza verticale dal bordo superiore dello schermo.
              //    */
              // },
              onLongPressStart: (details) async {
                final actions = [
                  drag_context_menu.ContextAction(
                    icon: Icons.edit,
                    label: 'Modifica',
                    color:theme.colorScheme.primary,
                  ),
                  drag_context_menu.ContextAction(
                    icon: Icons.copy,
                    label: 'Duplica',
                    color:theme.colorScheme.primary,
                  ),
                  drag_context_menu.ContextAction(
                    icon: Icons.delete,
                    label: 'Elimina',
                    color: Colors.red,
                  ),
                ];

                final selectedIndex = await drag_context_menu.showDragContextMenu(
                  context,
                  details.globalPosition,
                  actions,
                  'homescreen',
                  mode: drag_context_menu.MenuOpenMode.dragToSelect,);

                if (selectedIndex != null) {
                  switch (selectedIndex) {
                    case 0:
                      context.router.push(ModifyWalletRoute(walletid: wallet.id));
                      break;
                    case 1:
                      print('Duplica wallet');
                      break;
                    case 2:
                      showDialog(
                        context: context,
                        builder: (ctx) => WalletAlarmDelete(
                          walletName: wallet.name,
                          onConfirm: () async {
                            final walletService = ref.read(walletServiceProvider); // ✅ prendi l'istanza dal provider
                            await walletService.deleteWallet(wallet.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Wallet eliminato con successo")),
                            );
                          },
                        ),
                      );
                      break;
                  }
                }
              },
              child: WalletCard(
                wallet: wallet,
                onTap: () => _openWalletDetails(wallet),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAgentsTab() {
    final theme = Theme.of(context);
    final PersonService _personService = PersonService();
    final personsAsync = ref.watch(personsProvider);

    PersonType _filterType = PersonType.anon;
    return  personsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Errore: $error')),
      data: (persons) {
        // Filtra le persone in base al tipo selezionato
        final filteredPersons = _filterType == PersonType.anon
            ? persons
            : persons.where((p) => p.personType == _filterType).toList();

        if (filteredPersons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                // const SizedBox(height: 16),
                Text(
                  _filterType == PersonType.anon
                      ? 'No agents found'
                      : _filterType == PersonType.supplier
                      ? 'No supplier agents found'//in inglese sarebbe Supplier no agents found
                      : 'No customer agents found',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _addNewPerson(),
                  child: const Text('Add new agent'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredPersons.length,
          itemBuilder: (context, index) {
            final person = filteredPersons[index];
            return personCard(person: person,);
          },
        );
      },
    );
  }

  Widget _buildStatsTab() {
    final theme = Theme.of(context);
    return Center(
      child: Text('Statistiche - In sviluppo', style: theme.textTheme.bodyLarge),
    );
  }
  Widget _test(){
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [SliverAppBar( expandedHeight: 150.0,
      floating: true,
      backgroundColor: theme.colorScheme.primary,
      pinned: false,
      leading: Image.asset('assets/icons/savings.png'),

      iconTheme: theme.iconTheme,
      flexibleSpace: const FlexibleSpaceBar(
        title: Text('Available seats'),
      ),

     ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return ListTile(
                title: Text('Item #$index'),
              );
            },
            childCount: 50, // Number of items in the list
          ),
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) => Card(child: Center(child: Text('Grid Item $index'))),
            childCount: 35, // Number of items in the grid
          ),
        ),
      ]
    );

  }
}


