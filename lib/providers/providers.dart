import 'package:drgwallet/services/firebase_authservice.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/services/deal_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/wallet.dart';
part 'providers.g.dart';

@riverpod
AuthService authService( ref) => AuthService();

@riverpod
WalletService walletService( ref) => WalletService();

@riverpod
DealService dealService( ref) => DealService();

@riverpod
Stream<User?> authStateChanges( ref) {
  return FirebaseAuth.instance.authStateChanges();
}
@riverpod
Stream<List<Deal>> userDeals( ref) {
  final dealService = ref.watch(dealServiceProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  return dealService.getUserDeals(user.uid);
}

@riverpod
Stream<List<Wallet>> userWallets( ref) {
  final walletService = ref.watch(walletServiceProvider);
  return walletService.getUserWallets();
}

@riverpod
class SelectedTab extends _$SelectedTab {
  @override
  int build() => 0;

  void setTab(int index) => state = index;//Il metodo setTab() è definito nel notifier, non nel valore dello stato
}
// providers.dart - CORREGGI QUESTO
// providers.dart
@riverpod
Stream<int> walletDealsCount( ref, String walletId) {
  final walletService = ref.watch(walletServiceProvider);
  return walletService.getWalletDealsCount(walletId);
}


@riverpod
class MenuOpen extends _$MenuOpen {
  @override
  bool build() => false;

  void setOpen(bool isOpen) {
    state = isOpen;
  }
}