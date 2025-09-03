import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/services/deal_service.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

@RoutePage()
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final DealService _dealService = DealService();
  final WalletService _walletService = WalletService();

  List<Map<String, dynamic>> _stats = [];
  Map<String, dynamic> _overallStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final wallets = await _walletService.getUserWallets().first;

      List<Map<String, dynamic>> allStats = [];
      double totalSpent = 0;
      double totalEarned = 0;
      int totalDeals = 0;

      for (final wallet in wallets) {
        final walletWithStats = await _walletService.getWalletWithStats(wallet.id);

        allStats.add({
          'name': wallet.name,
          'totalDeals': walletWithStats.totalDeals ?? 0,
          'totalSpent': walletWithStats.totalSpent ?? 0,
          'totalEarned': walletWithStats.totalEarned ?? 0,
          'netProfit': walletWithStats.netProfit ?? 0,
        });

        totalSpent += walletWithStats.totalSpent ?? 0;
        totalEarned += walletWithStats.totalEarned ?? 0;
        totalDeals += walletWithStats.totalDeals ?? 0;
      }

      setState(() {
        _stats = allStats;
        _overallStats = {
          'totalDeals': totalDeals,
          'totalSpent': totalSpent,
          'totalEarned': totalEarned,
          'netProfit': totalEarned - totalSpent,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _stats.isEmpty
          ? const Center(child: Text('Nessuna statistica disponibile'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallStatsCard(),
            const SizedBox(height: 16),
            _buildWalletStatsList(),
            const SizedBox(height: 16),
            _buildProfitComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riepilogo Generale',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Totale Deal', _overallStats['totalDeals'].toString()),
            _buildStatRow('Totale Speso', '€${_overallStats['totalSpent'].toStringAsFixed(2)}'),
            _buildStatRow('Totale Guadagnato', '€${_overallStats['totalEarned'].toStringAsFixed(2)}'),
            _buildStatRow(
              'Profitto Netto',
              '€${_overallStats['netProfit'].toStringAsFixed(2)}',
              color: _overallStats['netProfit'] >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletStatsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiche per Wallet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._stats.map((stat) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildStatRow('Deal', stat['totalDeals'].toString()),
                _buildStatRow('Speso', '€${stat['totalSpent'].toStringAsFixed(2)}'),
                _buildStatRow('Guadagnato', '€${stat['totalEarned'].toStringAsFixed(2)}'),
                _buildStatRow(
                  'Profitto',
                  '€${stat['netProfit'].toStringAsFixed(2)}',
                  color: stat['netProfit'] >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildProfitComparison() {
    // Trova il wallet con il profitto più alto e più basso
    if (_stats.length < 2) return const SizedBox();

    _stats.sort((a, b) => b['netProfit'].compareTo(a['netProfit']));
    final mostProfitable = _stats.first;
    final leastProfitable = _stats.last;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confronto Profitti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildComparisonRow(
                'Più redditizio',
                mostProfitable['name'],
                '€${mostProfitable['netProfit'].toStringAsFixed(2)}',
                Colors.green
            ),
            const SizedBox(height: 8),
            _buildComparisonRow(
                'Meno redditizio',
                leastProfitable['name'],
                '€${leastProfitable['netProfit'].toStringAsFixed(2)}',
                leastProfitable['netProfit'] >= 0 ? Colors.green : Colors.red
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String walletName, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                walletName,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}