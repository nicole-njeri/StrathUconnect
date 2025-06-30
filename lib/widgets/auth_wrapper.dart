import 'package:flutter/material.dart';
import 'package:strathapp/screens/admin_panel_screen.dart';
import 'package:strathapp/screens/home_screen.dart';
import 'package:strathapp/services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _redirectUser();
  }

  Future<void> _redirectUser() async {
    final role = await _authService.getUserRole();

    if (!mounted) return;

    if (role == 'admin') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while we determine the user's role
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
