import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/customer_home_screen.dart';
import 'screens/business_home_screen.dart';
import 'screens/admin_home_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const KuaforRandevuApp());
}

class KuaforRandevuApp extends StatelessWidget {
  const KuaforRandevuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuaför Randevu Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final authData = await _authService.loadAuthData();
      
      if (authData != null) {
        final userType = authData['userType'] as String;
        switch (userType) {
          case 'customer':
            _initialScreen = const CustomerHomeScreen();
            break;
          case 'business':
            _initialScreen = const BusinessHomeScreen();
            break;
          case 'admin':
            _initialScreen = const AdminHomeScreen();
            break;
          default:
            _initialScreen = const WelcomeScreen();
        }
      } else {
        _initialScreen = const WelcomeScreen();
      }
    } catch (e) {
      _initialScreen = const WelcomeScreen();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _initialScreen ?? const WelcomeScreen();
  }
}
