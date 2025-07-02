import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/admin_panel_screen.dart';
import '../screens/home_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // First create the user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Then create the user profile in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'student',
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'This email is already registered. Please use a different email or try logging in.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Email/password accounts are not enabled. Please contact support.';
          break;
        case 'weak-password':
          errorMessage =
              'The password is too weak. Please use a stronger password.';
          break;
        default:
          errorMessage = 'An error occurred during signup: ${e.message}';
      }
      throw FirebaseAuthException(code: e.code, message: errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred during signup: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage =
              'No user found with this email. Please check your email or sign up.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage =
              'This account has been disabled. Please contact support.';
          break;
        default:
          errorMessage = 'An error occurred during sign in: ${e.message}';
      }
      throw FirebaseAuthException(code: e.code, message: errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in: $e');
    }
  }

  // Get user document from Firestore
  Future<DocumentSnapshot> getUserDetails() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    try {
      return await _firestore.collection('users').doc(user.uid).get();
    } catch (e) {
      throw Exception('Failed to fetch user details: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<String?> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data()?['role'] as String?;
  }

  void navigateAfterLogin(BuildContext context) async {
    final role = await getUserRole();

    if (!context.mounted) return;

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // Get admin full name
  Future<String?> getUserFullName() async {
    User? user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['fullName'] as String?;
    } catch (e) {
      return null;
    }
  }
}
