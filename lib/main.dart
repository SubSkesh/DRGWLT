import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/auth_gate.dart';
import 'theme/app_theme.dart';
import 'screens/splashscreen.dart';
import 'router.dart';           // il tuo router auto_route

void main() async {
  WidgetsFlutterBinding.ensureInitialized();// a che serve questo?ho trovato :Firebase.initializeApp() needs to call native code to initialize Firebase, and since the plugin needs to use platform channels to call the native code, which is done asynchronously therefore you have to call ensureInitialized() to make sure that you have an instance of the WidgetsBinding.
  await Firebase.initializeApp();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  MyApp({super.key});


  //final Future<void> _initFuture = _initializeApp(); //funzione che inizializza l'app

  final _appRouter = AppRouter();//la variabile che gestisce il routing


  // static Future<void> _initializeApp() async {
  //   await Firebase.initializeApp();//connessionne ai servizi firebase(async),prepara le istanze dei servizi FirebaseAuth,FirebaseFirestore,FirebaseAnalitycs....
  //   // qui puoi aggiungere altri init (remote config, pref, ecc.)
  //   await Future.delayed(const Duration(seconds: 2));
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(),
      title: 'DrgWallet',
      theme: AppTheme.darkTheme,
      // home: FutureBuilder<void>(
      //   future: _initFuture,
      //   builder: (context, snapshot) {//Snapshot è un contenitore con:connectionState(stato del future waiting,active,done),data(il dato),error) ognivolta che connectionstate cambia flutter chiama builder per aggiornare UI          // Finché non è `done` mostro la Splash
      //     if (snapshot.connectionState != ConnectionState.done) {
      //       return const SplashScreen();
      //     }
      //     // App pronta → il tuo AuthGate originale
      //     return AuthGate();
      //   },
      // ),
    );
  }

}

// }
