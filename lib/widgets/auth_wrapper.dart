import 'package:flutter/material.dart';
import 'package:strathapp/screens/admin_panel_screen.dart';
import 'package:strathapp/screens/home_screen.dart';
import 'package:strathapp/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return FutureBuilder<String?>(
      future: authService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: \\${snapshot.error}')),
          );
        }
        final role = snapshot.data;
        if (role == 'admin') {
          return const AdminPanelScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
