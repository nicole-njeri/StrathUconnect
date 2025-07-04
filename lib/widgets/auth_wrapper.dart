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
        if (role == null) {
          // Fallback UI for missing role
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'No role assigned to your account.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please contact support or your administrator.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Optionally sign out and return to login
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          );
        }
        debugPrint('User role: $role');
        if (role == 'admin') {
          return const AdminPanelScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
