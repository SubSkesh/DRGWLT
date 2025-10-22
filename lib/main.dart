import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'utils/auth_gate.dart';
import 'theme/app_theme.dart';
import 'screens/splashscreen.dart';
import 'router.dart';// il tuo router auto_route
import 'utils/authnotifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();//- Garantisce che il binding tra il framework Flutter e la piattaforma nativa sia pronto


  // Inizializza Firebase con la nuova sintassi
  await Firebase.initializeApp( //- Inizializza il core di Firebase, caricando la configurazione generata per ogni piattaforma (Android, iOS, Web)
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});


  //final Future<void> _initFuture = _initializeApp(); //funzione che inizializza l'app

  final _appRouter = AppRouter();//la variabile che gestisce il routing1


  // static Future<void> _initializeApp() async {
  //   await Firebase.initializeApp();//connessionne ai servizi firebase(async),prepara le istanze dei servizi FirebaseAuth,FirebaseFirestore,FirebaseAnalitycs....
  //   // qui puoi aggiungere altri init (remote config, pref, ecc.)
  //   await Future.delayed(const Duration(seconds: 2));
  @override
  Widget build(BuildContext context) {
    // final _authNotifier = AuthNotifier();
    return MaterialApp.router(
      routerConfig: _appRouter.config(),// reevaluateListenable: _authNotifier,),
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
