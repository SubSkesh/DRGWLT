import 'package:drgwallet/services/firebase_authservice.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/services/deal_service.dart';
import 'package:drgwallet/services/person_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/wallet.dart';import 'package:drgwallet/models/person.dart';
part 'providers.g.dart';

@riverpod
AuthService authService( ref) => AuthService();

@riverpod
WalletService walletService( ref) => WalletService();

@riverpod
DealService dealService( ref) => DealService();

@riverpod
PersonService personService( ref) => PersonService();

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
Future<Deal> deal(ref, String dealId) async {
  final dealService = ref.watch(dealServiceProvider);
  final deal = await dealService.getDeal(dealId);
  if (deal == null) {
    throw Exception('Deal with id $dealId not found');
  }
  return deal;
}
@riverpod
Future<Deal> enrichedDeal( ref, String dealId) async {
  final dealService = ref.watch(dealServiceProvider);
  final deal = await dealService.getDeal(dealId);
  if (deal == null) {
    throw Exception('Deal with id $dealId not found');
  }

  if (deal.personId != null && deal.personId!.isNotEmpty) {
    // Carica tutte le persone e trova quella giusta
    final persons = await ref.watch(personsProvider.future);
    try {
      final person = persons.firstWhere((p) => p.id == deal.personId);
      // Restituisci una copia del deal con l'oggetto person associato
      return deal.copyWith(person: person);
    } catch (e) {
      // La persona non è stata trovata, restituisci il deal originale
      return deal;
    }
  }

  // Nessuna persona associata, restituisci il deal originale
  return deal;
}
@riverpod
Stream<List<Wallet>> userWallets( ref) {
  final walletService = ref.watch(walletServiceProvider);
  return walletService.getUserWallets();
}

@riverpod
Stream<Wallet> walletDetails( ref, String walletId) {
  final walletService = ref.watch(walletServiceProvider);
  return walletService.getWalletStream(walletId);
}
@riverpod
Stream<Wallet> walletDetailsWithStatsStream(ref,String walletId) {
  final walletService = ref.watch(walletServiceProvider);
  return walletService.getWalletWithStatsStream(walletId);
}



@riverpod
Stream<List<Deal>> walletDeals( ref, String walletId) {
  final walletService = ref.watch(walletServiceProvider);
  return walletService.getWalletDealsStream(walletId);
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

  void open() => state = true;
  void close() => state = false;
}

@riverpod
Stream<List<Person>> persons( ref) {
  final personService = ref.watch(personServiceProvider);
  return personService.getUserPersons();
}

@riverpod
Stream<Person> person(ref, String personId) {
  final personService = ref.watch(personServiceProvider);
  // Assumi che il tuo service abbia un metodo che restituisce uno Stream
  // Se non ce l'ha, dovrai aggiungerlo.
  // Per ora, lo lascio come lo avevi, ma sappi che getPersonStream DEVE esistere.
  return personService.getPersonStream(personId);
}