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
String _$walletDealsCountHash() => r'a0fb1308ddbacf936609c70458c4aa12e2bb22ca';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
