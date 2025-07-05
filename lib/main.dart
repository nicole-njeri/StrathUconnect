import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:strathapp/firebase_options.dart';
import 'package:strathapp/widgets/auth_wrapper.dart';
import 'screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StrathUConnectApp());
}

class StrathUConnectApp extends StatelessWidget {
  const StrathUConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StrathUConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.copyWith(
            displayLarge: const TextStyle(fontSize: 20),
            displayMedium: const TextStyle(fontSize: 20),
            displaySmall: const TextStyle(fontSize: 20),
            headlineLarge: const TextStyle(fontSize: 20),
            headlineMedium: const TextStyle(fontSize: 20),
            headlineSmall: const TextStyle(fontSize: 20),
            titleLarge: const TextStyle(fontSize: 20),
            titleMedium: const TextStyle(fontSize: 20),
            titleSmall: const TextStyle(fontSize: 20),
            bodyLarge: const TextStyle(fontSize: 20),
            bodyMedium: const TextStyle(fontSize: 20),
            bodySmall: const TextStyle(fontSize: 20),
            labelLarge: const TextStyle(fontSize: 20),
            labelMedium: const TextStyle(fontSize: 20),
            labelSmall: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("An error occurred: ${snapshot.error}")),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in, show AuthWrapper to handle role-based navigation
          return const AuthWrapper();
        } else {
          // Not signed in
          return const LoginScreen();
        }
      },
    );
  }
}
