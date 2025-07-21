
import 'package:auto_route/auto_route.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:drgwallet/screens/homescreen.dart';
import 'package:drgwallet/screens/loginscreen.dart';
import 'package:drgwallet/screens/register.dart';
import 'package:drgwallet/screens/splashscreen.dart';
import 'package:drgwallet/screens/welcomescreen.dart';
import 'package:drgwallet/utils/auth_gate.dart';
part 'router.gr.dart'; // Questo sarà generato da build_runner

@AutoRouterConfig()
class AppRouter extends RootStackRouter  {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: LoginRoute.page),
    //AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: AuthGateRoute.page),
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: WelcomeRoute.page),


  ];
}


