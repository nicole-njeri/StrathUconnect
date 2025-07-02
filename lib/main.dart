import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:strathapp/firebase_options.dart';
import 'package:strathapp/widgets/auth_wrapper.dart';
import 'screens/login_screen.dart';

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
      theme: ThemeData(primarySwatch: Colors.red, fontFamily: 'Poppins'),
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
