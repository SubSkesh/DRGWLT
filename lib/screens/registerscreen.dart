import 'package:flutter/material.dart';
import 'package:drgwallet/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart' ;
import '../theme/app_theme.dart';
import '../utils/auth_gate.dart';
import '../services/user_service.dart';
import 'package:drgwallet/models/user.dart'as my_model ;

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();


  final UserService _userService = UserService();//creo un istanza di UserService per utilizzare i metodi di gestione dell'utente


  bool _isLoading = false;//- ti dice se la tua operazione asincrona (la registrazione su Firebase) sta ancora girando o è già terminata.
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;// verifica che tutti i campi siano validi

    setState(() { // mette l’app in modalità caricamento e azzera eventuali messaggi d’errore
      _isLoading = true;
      _error = null;
    });


    try {
      // Usa try-catch separato per FirebaseAuth
      UserCredential? userCredential;// inizializza la variabile userCredential come nulla
      try {
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );// Crea l'utente con email e password forniti e restituisce le credenziali dell'utente
      } catch (e) {
        debugPrint('Firebase Auth Error: $e');// Stampa l'errore se esiste
        // Ignora l'errore di deserializzazione se l'utente è creato
        if (FirebaseAuth.instance.currentUser == null) {
          throw e;
        }// Lancia un'eccezione se l'utente non è stato creato
      }

      if (userCredential?.user != null) {// Verifica se l'utente è stato creato con successo
        final newUser = my_model.User(//per non collisionare conUser di firebase
          id: userCredential!.user!.uid,
          email: _emailCtrl.text.trim(),
          displayName: _nameCtrl.text.trim(),
          createdAt: DateTime.now(),
                                        // Fornisci valori di default o iniziali per i campi obbligatori
          walletCount: 0,               // Ad esempio, inizia con 0 wallet
          darkMode: false,              // Ad esempio, inizia con darkMode disabilitato
           photoUrl: null,            // photoUrl è opzionale, quindi puoi ometterlo o impostarlo a null
           locale: null,              // locale è opzionale
        );
        await _userService.createUserProfile(newUser);// Crea il profilo dell'utente nel database
      }

      // Forza la navigazione se l'utente esiste
      // Controlla che il widget sia ancora montato (non smontato dal widget tree),
      // poi naviga alla schermata principale sostituendo tutte le rotte precedenti.
      // Questo evita errori nel caso in cui il widget sia stato smontato prima della navigazione.


      if (FirebaseAuth.instance.currentUser != null && mounted) {
        context.router.replaceAll([const HomeRoute()]);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);//sia in caso di successo che di errore, il blocco finally disattiva il caricamento

    }
  }
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      // appBar: AppBar(title: const Text('Crea Account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Benvenuto',
                  style: theme.textTheme.headlineLarge,

                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameCtrl,
                  focusNode: _nameFocusNode,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (val) =>
                  val == null || val.isEmpty ? 'Inserisci un nickname' : null,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailCtrl,
                  focusNode: _emailFocusNode,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val != null && val.contains('@') ? null : 'Email non valida',
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  focusNode: _passwordFocusNode,
                  validator: (val) => val != null && val.length >= 6
                      ? null
                      : 'Minimo 6 caratteri',
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),

                const SizedBox(height: 12),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _register,
                  child: const Text('Registrati'),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    context.router.push(const LoginRoute());
                  },
                  child: const Text('Hai già un account? Accedi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

