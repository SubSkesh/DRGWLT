import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:drgwallet/screens/homescreen.dart';
import 'package:drgwallet/screens/loginscreen.dart';
import 'package:drgwallet/screens/registerscreen.dart';
import 'package:drgwallet/screens/splashscreen.dart';
import 'package:drgwallet/screens/welcomescreen.dart';
import 'package:drgwallet/utils/auth_gate.dart';
import 'package:drgwallet/screens/add_deal_screen.dart';
import 'package:drgwallet/screens/wallet_detail_screen.dart';
import 'package:drgwallet/screens/profile_screen.dart';
import 'package:drgwallet/screens/stats_screen.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/screens/add_wallet_screen.dart';
import 'package:drgwallet/screens/todeletescreen.dart';


part 'router.gr.dart'; // Questo sarà generato da build_runner

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: AuthGateRoute.page, initial: true),
    AutoRoute(page: SplashRoute.page),
    AutoRoute(page: WelcomeRoute.page),
    // Nuove route aggiunte
    AutoRoute(page: AddDealRoute.page),
    AutoRoute(page: WalletDetailRoute.page),
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: StatsRoute.page),
    AutoRoute(page: AddWalletRoute.page),
    //da eliminare
    AutoRoute(page: ToDeleteRoute.page),
  ];
}