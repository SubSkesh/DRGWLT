import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drgwallet/services/user_service.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userData = await _userService.getUserProfile(user.uid);
        setState(() {
          _userData = userData.toMap();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // Navigate to auth gate or welcome screen
      context.router.push(const AuthGateRoute());
    } catch (e) {
      // Handle error
    }
  }
  void _onPressAction() {
    context.router.push(const ToDeleteRoute());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
        actions: [
          IconButton(
            onPressed:_onPressAction,
            icon: const Icon(Icons.account_balance_wallet_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userData != null) ...[
              _buildProfileItem('Nome', _userData!['displayName'] ?? 'Non specificato'),
              _buildProfileItem('Email', _userData!['email'] ?? 'Non specificato'),
              _buildProfileItem('Data registrazione',
                  _userData!['createdAt'] != null
                      ? _userData!['createdAt'].toDate().toString()
                      : 'Non specificato'),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(value),
          const Divider(),
        ],
      ),
    );
  }
}