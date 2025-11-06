// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'00e666452f01fd7f23841d9810c3af54796a3ab2';

/// See also [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$walletServiceHash() => r'b2f93e969fd703728951f0b8b62a9740cc614591';

/// See also [walletService].
@ProviderFor(walletService)
final walletServiceProvider = AutoDisposeProvider<WalletService>.internal(
  walletService,
  name: r'walletServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$walletServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletServiceRef = AutoDisposeProviderRef<WalletService>;
String _$dealServiceHash() => r'fa0523fcf9ddff292b4606ca3540a6d4a6a63406';

/// See also [dealService].
@ProviderFor(dealService)
final dealServiceProvider = AutoDisposeProvider<DealService>.internal(
  dealService,
  name: r'dealServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dealServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DealServiceRef = AutoDisposeProviderRef<DealService>;
String _$personServiceHash() => r'04755d3490c43f02460c8e49fe638be3189a540b';

/// See also [personService].
@ProviderFor(personService)
final personServiceProvider = AutoDisposeProvider<PersonService>.internal(
  personService,
  name: r'personServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$personServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PersonServiceRef = AutoDisposeProviderRef<PersonService>;
String _$authStateChangesHash() => r'dcffd14dd4bb6710b3ffaac599ec532a475daa0a';

/// See also [authStateChanges].
@ProviderFor(authStateChanges)
final authStateChangesProvider = AutoDisposeStreamProvider<User?>.internal(
  authStateChanges,
  name: r'authStateChangesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authStateChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateChangesRef = AutoDisposeStreamProviderRef<User?>;
String _$userDealsHash() => r'f95defb4a8ed8b6f785603396b1db6804412cf49';

/// See also [userDeals].
@ProviderFor(userDeals)
final userDealsProvider = AutoDisposeStreamProvider<List<Deal>>.internal(
  userDeals,
  name: r'userDealsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userDealsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserDealsRef = AutoDisposeStreamProviderRef<List<Deal>>;
String _$dealHash() => r'c065f461af91a393c9f9caa4b0c64ce01507b7f6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [deal].
@ProviderFor(deal)
const dealProvider = DealFamily();

/// See also [deal].
class DealFamily extends Family<AsyncValue<Deal>> {
  /// See also [deal].
  const DealFamily();

  /// See also [deal].
  DealProvider call(String dealId) {
    return DealProvider(dealId);
  }

  @override
  DealProvider getProviderOverride(covariant DealProvider provider) {
    return call(provider.dealId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dealProvider';
}

/// See also [deal].
class DealProvider extends AutoDisposeFutureProvider<Deal> {
  /// See also [deal].
  DealProvider(String dealId)
    : this._internal(
        (ref) => deal(ref as DealRef, dealId),
        from: dealProvider,
        name: r'dealProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product') ? null : _$dealHash,
        dependencies: DealFamily._dependencies,
        allTransitiveDependencies: DealFamily._allTransitiveDependencies,
        dealId: dealId,
      );

  DealProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dealId,
  }) : super.internal();

  final String dealId;

  @override
  Override overrideWith(FutureOr<Deal> Function(DealRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: DealProvider._internal(
        (ref) => create(ref as DealRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dealId: dealId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Deal> createElement() {
    return _DealProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DealProvider && other.dealId == dealId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dealId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DealRef on AutoDisposeFutureProviderRef<Deal> {
  /// The parameter `dealId` of this provider.
  String get dealId;
}

class _DealProviderElement extends AutoDisposeFutureProviderElement<Deal>
    with DealRef {
  _DealProviderElement(super.provider);

  @override
  String get dealId => (origin as DealProvider).dealId;
}

String _$userWalletsHash() => r'e6f5e8920551daedee26d7e2f0a0aafb7d34e804';

/// See also [userWallets].
@ProviderFor(userWallets)
final userWalletsProvider = AutoDisposeStreamProvider<List<Wallet>>.internal(
  userWallets,
  name: r'userWalletsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userWalletsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserWalletsRef = AutoDisposeStreamProviderRef<List<Wallet>>;
String _$walletDetailsHash() => r'f5f77457f6255e4fb94ff081aa307fae18b8bd52';

/// See also [walletDetails].
@ProviderFor(walletDetails)
const walletDetailsProvider = WalletDetailsFamily();

/// See also [walletDetails].
class WalletDetailsFamily extends Family<AsyncValue<Wallet>> {
  /// See also [walletDetails].
  const WalletDetailsFamily();

  /// See also [walletDetails].
  WalletDetailsProvider call(String walletId) {
    return WalletDetailsProvider(walletId);
  }

  @override
  WalletDetailsProvider getProviderOverride(
    covariant WalletDetailsProvider provider,
  ) {
    return call(provider.walletId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'walletDetailsProvider';
}

/// See also [walletDetails].
class WalletDetailsProvider extends AutoDisposeStreamProvider<Wallet> {
  /// See also [walletDetails].
  WalletDetailsProvider(String walletId)
    : this._internal(
        (ref) => walletDetails(ref as WalletDetailsRef, walletId),
        from: walletDetailsProvider,
        name: r'walletDetailsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$walletDetailsHash,
        dependencies: WalletDetailsFamily._dependencies,
        allTransitiveDependencies:
            WalletDetailsFamily._allTransitiveDependencies,
        walletId: walletId,
      );

  WalletDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.walletId,
  }) : super.internal();

  final String walletId;

  @override
  Override overrideWith(
    Stream<Wallet> Function(WalletDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WalletDetailsProvider._internal(
        (ref) => create(ref as WalletDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        walletId: walletId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Wallet> createElement() {
    return _WalletDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletDetailsProvider && other.walletId == walletId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, walletId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WalletDetailsRef on AutoDisposeStreamProviderRef<Wallet> {
  /// The parameter `walletId` of this provider.
  String get walletId;
}

class _WalletDetailsProviderElement
    extends AutoDisposeStreamProviderElement<Wallet>
    with WalletDetailsRef {
  _WalletDetailsProviderElement(super.provider);

  @override
  String get walletId => (origin as WalletDetailsProvider).walletId;
}

String _$walletDetailsWithStatsStreamHash() =>
    r'337754bfca24de811827a41ed2aec8f31f2b2377';

/// See also [walletDetailsWithStatsStream].
@ProviderFor(walletDetailsWithStatsStream)
const walletDetailsWithStatsStreamProvider =
    WalletDetailsWithStatsStreamFamily();

/// See also [walletDetailsWithStatsStream].
class WalletDetailsWithStatsStreamFamily extends Family<AsyncValue<Wallet>> {
  /// See also [walletDetailsWithStatsStream].
  const WalletDetailsWithStatsStreamFamily();

  /// See also [walletDetailsWithStatsStream].
  WalletDetailsWithStatsStreamProvider call(String walletId) {
    return WalletDetailsWithStatsStreamProvider(walletId);
  }

  @override
  WalletDetailsWithStatsStreamProvider getProviderOverride(
    covariant WalletDetailsWithStatsStreamProvider provider,
  ) {
    return call(provider.walletId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'walletDetailsWithStatsStreamProvider';
}

/// See also [walletDetailsWithStatsStream].
class WalletDetailsWithStatsStreamProvider
    extends AutoDisposeStreamProvider<Wallet> {
  /// See also [walletDetailsWithStatsStream].
  WalletDetailsWithStatsStreamProvider(String walletId)
    : this._internal(
        (ref) => walletDetailsWithStatsStream(
          ref as WalletDetailsWithStatsStreamRef,
          walletId,
        ),
        from: walletDetailsWithStatsStreamProvider,
        name: r'walletDetailsWithStatsStreamProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$walletDetailsWithStatsStreamHash,
        dependencies: WalletDetailsWithStatsStreamFamily._dependencies,
        allTransitiveDependencies:
            WalletDetailsWithStatsStreamFamily._allTransitiveDependencies,
        walletId: walletId,
      );

  WalletDetailsWithStatsStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.walletId,
  }) : super.internal();

  final String walletId;

  @override
  Override overrideWith(
    Stream<Wallet> Function(WalletDetailsWithStatsStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WalletDetailsWithStatsStreamProvider._internal(
        (ref) => create(ref as WalletDetailsWithStatsStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        walletId: walletId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Wallet> createElement() {
    return _WalletDetailsWithStatsStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletDetailsWithStatsStreamProvider &&
        other.walletId == walletId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, walletId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WalletDetailsWithStatsStreamRef on AutoDisposeStreamProviderRef<Wallet> {
  /// The parameter `walletId` of this provider.
  String get walletId;
}

class _WalletDetailsWithStatsStreamProviderElement
    extends AutoDisposeStreamProviderElement<Wallet>
    with WalletDetailsWithStatsStreamRef {
  _WalletDetailsWithStatsStreamProviderElement(super.provider);

  @override
  String get walletId =>
      (origin as WalletDetailsWithStatsStreamProvider).walletId;
}

String _$walletDealsHash() => r'0e8842a23e54345d9806d54bbfac266d558d044b';

/// See also [walletDeals].
@ProviderFor(walletDeals)
const walletDealsProvider = WalletDealsFamily();

/// See also [walletDeals].
class WalletDealsFamily extends Family<AsyncValue<List<Deal>>> {
  /// See also [walletDeals].
  const WalletDealsFamily();

  /// See also [walletDeals].
  WalletDealsProvider call(String walletId) {
    return WalletDealsProvider(walletId);
  }

  @override
  WalletDealsProvider getProviderOverride(
    covariant WalletDealsProvider provider,
  ) {
    return call(provider.walletId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'walletDealsProvider';
}

/// See also [walletDeals].
class WalletDealsProvider extends AutoDisposeStreamProvider<List<Deal>> {
  /// See also [walletDeals].
  WalletDealsProvider(String walletId)
    : this._internal(
        (ref) => walletDeals(ref as WalletDealsRef, walletId),
        from: walletDealsProvider,
        name: r'walletDealsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$walletDealsHash,
        dependencies: WalletDealsFamily._dependencies,
        allTransitiveDependencies: WalletDealsFamily._allTransitiveDependencies,
        walletId: walletId,
      );

  WalletDealsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.walletId,
  }) : super.internal();

  final String walletId;

  @override
  Override overrideWith(
    Stream<List<Deal>> Function(WalletDealsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WalletDealsProvider._internal(
        (ref) => create(ref as WalletDealsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        walletId: walletId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Deal>> createElement() {
    return _WalletDealsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletDealsProvider && other.walletId == walletId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, walletId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WalletDealsRef on AutoDisposeStreamProviderRef<List<Deal>> {
  /// The parameter `walletId` of this provider.
  String get walletId;
}

class _WalletDealsProviderElement
    extends AutoDisposeStreamProviderElement<List<Deal>>
    with WalletDealsRef {
  _WalletDealsProviderElement(super.provider);

  @override
  String get walletId => (origin as WalletDealsProvider).walletId;
}

String _$walletDealsCountHash() => r'a0fb1308ddbacf936609c70458c4aa12e2bb22ca';

/// See also [walletDealsCount].
@ProviderFor(walletDealsCount)
const walletDealsCountProvider = WalletDealsCountFamily();

/// See also [walletDealsCount].
class WalletDealsCountFamily extends Family<AsyncValue<int>> {
  /// See also [walletDealsCount].
  const WalletDealsCountFamily();

  /// See also [walletDealsCount].
  WalletDealsCountProvider call(String walletId) {
    return WalletDealsCountProvider(walletId);
  }

  @override
  WalletDealsCountProvider getProviderOverride(
    covariant WalletDealsCountProvider provider,
  ) {
    return call(provider.walletId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'walletDealsCountProvider';
}

/// See also [walletDealsCount].
class WalletDealsCountProvider extends AutoDisposeStreamProvider<int> {
  /// See also [walletDealsCount].
  WalletDealsCountProvider(String walletId)
    : this._internal(
        (ref) => walletDealsCount(ref as WalletDealsCountRef, walletId),
        from: walletDealsCountProvider,
        name: r'walletDealsCountProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$walletDealsCountHash,
        dependencies: WalletDealsCountFamily._dependencies,
        allTransitiveDependencies:
            WalletDealsCountFamily._allTransitiveDependencies,
        walletId: walletId,
      );

  WalletDealsCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.walletId,
  }) : super.internal();

  final String walletId;

  @override
  Override overrideWith(
    Stream<int> Function(WalletDealsCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WalletDealsCountProvider._internal(
        (ref) => create(ref as WalletDealsCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        walletId: walletId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _WalletDealsCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletDealsCountProvider && other.walletId == walletId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, walletId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WalletDealsCountRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `walletId` of this provider.
  String get walletId;
}

class _WalletDealsCountProviderElement
    extends AutoDisposeStreamProviderElement<int>
    with WalletDealsCountRef {
  _WalletDealsCountProviderElement(super.provider);

  @override
  String get walletId => (origin as WalletDealsCountProvider).walletId;
}

String _$personsHash() => r'6f8c6bfc4dc484c4601029fabbb82ff64c12d711';

/// See also [persons].
@ProviderFor(persons)
final personsProvider = AutoDisposeStreamProvider<List<Person>>.internal(
  persons,
  name: r'personsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$personsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PersonsRef = AutoDisposeStreamProviderRef<List<Person>>;
String _$personHash() => r'4e5a8fadcde09d7a8092de6cc12220dcfb2bb037';

/// See also [person].
@ProviderFor(person)
const personProvider = PersonFamily();

/// See also [person].
class PersonFamily extends Family<AsyncValue<Person>> {
  /// See also [person].
  const PersonFamily();

  /// See also [person].
  PersonProvider call(String personId) {
    return PersonProvider(personId);
  }

  @override
  PersonProvider getProviderOverride(covariant PersonProvider provider) {
    return call(provider.personId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'personProvider';
}

/// See also [person].
class PersonProvider extends AutoDisposeStreamProvider<Person> {
  /// See also [person].
  PersonProvider(String personId)
    : this._internal(
        (ref) => person(ref as PersonRef, personId),
        from: personProvider,
        name: r'personProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product') ? null : _$personHash,
        dependencies: PersonFamily._dependencies,
        allTransitiveDependencies: PersonFamily._allTransitiveDependencies,
        personId: personId,
      );

  PersonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.personId,
  }) : super.internal();

  final String personId;

  @override
  Override overrideWith(Stream<Person> Function(PersonRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: PersonProvider._internal(
        (ref) => create(ref as PersonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        personId: personId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Person> createElement() {
    return _PersonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonProvider && other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PersonRef on AutoDisposeStreamProviderRef<Person> {
  /// The parameter `personId` of this provider.
  String get personId;
}

class _PersonProviderElement extends AutoDisposeStreamProviderElement<Person>
    with PersonRef {
  _PersonProviderElement(super.provider);

  @override
  String get personId => (origin as PersonProvider).personId;
}

String _$selectedTabHash() => r'7b97815c38bd6bc2d0d3d000fda38b6735f0082e';

/// See also [SelectedTab].
@ProviderFor(SelectedTab)
final selectedTabProvider =
    AutoDisposeNotifierProvider<SelectedTab, int>.internal(
      SelectedTab.new,
      name: r'selectedTabProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$selectedTabHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedTab = AutoDisposeNotifier<int>;
String _$menuOpenHash() => r'5c56b5377d7cb7e0cebe457441e4ad07e45d0746';

/// See also [MenuOpen].
@ProviderFor(MenuOpen)
final menuOpenProvider = AutoDisposeNotifierProvider<MenuOpen, bool>.internal(
  MenuOpen.new,
  name: r'menuOpenProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$menuOpenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MenuOpen = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
