import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drgwallet/services/firebase_authservice.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
@RoutePage()

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  String? _error;
  final UserService _userService = UserService();//creo un istanza di UserService per utilizzare i metodi di gestione dell'utente

Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() {
    _isLoading = true;
    _error = null;
  });
  try {
    final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text, password: _passwordCtrl.text);
    if (FirebaseAuth.instance.currentUser != null && mounted) {
      context.router.replaceAll([const HomeRoute()]);
    }
  } on FirebaseAuthException catch (e) {
    if (mounted) setState(() => _error = e.message);
  } catch (e) {
    debugPrint('Firebase Auth Error: $e');
    if (FirebaseAuth.instance.currentUser == null) {
      throw e;
    }
    // Handle other potential errors if necessary
    if (mounted) setState(() => _error = 'An unexpected error occurred.');
  }finally {
    //sia in caso di successo che di errore, il blocco finally disattiva il caricamento
    if (mounted) setState(() => _isLoading = false);
  }

}


  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkTheme;
return Scaffold(
  body:
    SafeArea(
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
                onPressed: _login,
                child: const Text('Enter'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.router.push(const RegisterRoute());
                },
                child: const Text('Non hai un account? Registrati'),
              ),


            ],
          ),
        ),
      ),
    ),
    );
  }
}
///////////////////////////
