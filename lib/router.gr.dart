// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AddDealScreen]
class AddDealRoute extends PageRouteInfo<AddDealRouteArgs> {
  AddDealRoute({
    Key? key,
    required TxType dealType,
    VoidCallback? onDealCreated,
    dynamic preSelectedWalletId,
    List<PageRouteInfo>? children,
  }) : super(
         AddDealRoute.name,
         args: AddDealRouteArgs(
           key: key,
           dealType: dealType,
           onDealCreated: onDealCreated,
           preSelectedWalletId: preSelectedWalletId,
         ),
         initialChildren: children,
       );

  static const String name = 'AddDealRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddDealRouteArgs>();
      return AddDealScreen(
        key: args.key,
        dealType: args.dealType,
        onDealCreated: args.onDealCreated,
        preSelectedWalletId: args.preSelectedWalletId,
      );
    },
  );
}

class AddDealRouteArgs {
  const AddDealRouteArgs({
    this.key,
    required this.dealType,
    this.onDealCreated,
    this.preSelectedWalletId,
  });

  final Key? key;

  final TxType dealType;

  final VoidCallback? onDealCreated;

  final dynamic preSelectedWalletId;

  @override
  String toString() {
    return 'AddDealRouteArgs{key: $key, dealType: $dealType, onDealCreated: $onDealCreated, preSelectedWalletId: $preSelectedWalletId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddDealRouteArgs) return false;
    return key == other.key &&
        dealType == other.dealType &&
        onDealCreated == other.onDealCreated &&
        preSelectedWalletId == other.preSelectedWalletId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      dealType.hashCode ^
      onDealCreated.hashCode ^
      preSelectedWalletId.hashCode;
}

/// generated route for
/// [AddWalletScreen]
class AddWalletRoute extends PageRouteInfo<void> {
  const AddWalletRoute({List<PageRouteInfo>? children})
    : super(AddWalletRoute.name, initialChildren: children);

  static const String name = 'AddWalletRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddWalletScreen();
    },
  );
}

/// generated route for
/// [AuthGate]
class AuthGateRoute extends PageRouteInfo<void> {
  const AuthGateRoute({List<PageRouteInfo>? children})
    : super(AuthGateRoute.name, initialChildren: children);

  static const String name = 'AuthGateRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthGate();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [StatsScreen]
class StatsRoute extends PageRouteInfo<void> {
  const StatsRoute({List<PageRouteInfo>? children})
    : super(StatsRoute.name, initialChildren: children);

  static const String name = 'StatsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StatsScreen();
    },
  );
}

/// generated route for
/// [WalletDetailScreen]
class WalletDetailRoute extends PageRouteInfo<WalletDetailRouteArgs> {
  WalletDetailRoute({
    Key? key,
    required String walletId,
    List<PageRouteInfo>? children,
  }) : super(
         WalletDetailRoute.name,
         args: WalletDetailRouteArgs(key: key, walletId: walletId),
         initialChildren: children,
       );

  static const String name = 'WalletDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WalletDetailRouteArgs>();
      return WalletDetailScreen(key: args.key, walletId: args.walletId);
    },
  );
}

class WalletDetailRouteArgs {
  const WalletDetailRouteArgs({this.key, required this.walletId});

  final Key? key;

  final String walletId;

  @override
  String toString() {
    return 'WalletDetailRouteArgs{key: $key, walletId: $walletId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WalletDetailRouteArgs) return false;
    return key == other.key && walletId == other.walletId;
  }

  @override
  int get hashCode => key.hashCode ^ walletId.hashCode;
}

/// generated route for
/// [WelcomeScreen]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomeScreen();
    },
  );
}
