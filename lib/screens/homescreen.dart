import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/services/deal_service.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/widgets/custom_bottom_nav.dart';
import 'package:drgwallet/widgets/deal_list_item.dart';
import 'package:drgwallet/widgets/wallet_card.dart';
import 'package:drgwallet/widgets/add_fab.dart';
import 'package:drgwallet/theme/app_theme.dart'; // Importa il tema

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DealService _dealService = DealService();
  final WalletService _walletService = WalletService();
  late Stream<List<Deal>> _dealsStream;
  late Stream<List<Wallet>> _walletsStream;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _dealsStream = _dealService.getUserDeals(user.uid);
    _walletsStream = _walletService.getUserWallets();
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddPressed(TxType? dealType) {
    if (dealType != null) {
      context.router.push(AddDealRoute(dealType: dealType));
    } else {
      _createNewWallet(context);
    }
  }

  void _createNewWallet(BuildContext context) {
    // Implementa la creazione wallet
    context.router.push(AddWalletRoute());

  }

  void _openWalletDetails(Wallet wallet) {
    context.router.push(WalletDetailRoute(walletId: wallet.id));// passso alla schermata dei dettagli del wallet  l'id del wallet selezionato
  }

  void _openDealDetails(Deal deal) {
    // Implementa l'apertura dei dettagli del deal
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Usa il tema dall'context

    return Scaffold(
      appBar: AppBar(
        title: Text('DRG Wallet', style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.primary),),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        leading:
          IconButton(
            icon: Icon(Icons.account_circle, color: theme.iconTheme.color),
            onPressed: () => context.router.push(const ProfileRoute()),
          ),

      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildCurrentTab(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: AddFloatingButton(onAddPressed: _onAddPressed),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildWalletsTab();
      case 1:
        return _buildDealsTab();
      case 2:
        return _buildStatsTab();
      default:
        return _buildWalletsTab();
    }
  }

  Widget _buildDealsTab() {
    final theme = Theme.of(context);

    return StreamBuilder<List<Deal>>(
      stream: _dealsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Errore: ${snapshot.error}',
                style: theme.textTheme.bodyLarge),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        final deals = snapshot.data!;

        if (deals.isEmpty) {
          return Center(
            child: Text('Nessun deal trovato',
                style: theme.textTheme.bodyLarge),
          );
        }

        return ListView.builder(
          itemCount: deals.length,
          itemBuilder: (context, index) {
            final deal = deals[index];
            return DealListItem(
              deal: deal,
              onTap: () => _openDealDetails(deal),
            );
          },
        );
      },
    );
  }

  Widget _buildWalletsTab() {
    final theme = Theme.of(context);

    return StreamBuilder<List<Wallet>>(
      stream: _walletsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Errore: ${snapshot.error}',
                style: theme.textTheme.bodyLarge),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        final wallets = snapshot.data!; // Usa la lista dei wallet

        if (wallets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Nessun wallet trovato',
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _createNewWallet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
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
            return WalletCard(
              wallet: wallet,
              onTap: () => _openWalletDetails(wallet),
              walletService: WalletService(),// scorciatoia per passare il servizio di wallet al widget
            );
          },
        );
      },
    );
  }

  Widget _buildStatsTab() {
    final theme = Theme.of(context);

    return Center(
      child: Text('Statistiche - In sviluppo',
          style: theme.textTheme.bodyLarge),
    );
  }
}