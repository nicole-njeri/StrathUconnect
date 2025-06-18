import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      print('Starting signup process for email: $email');

      // First create the user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      print('User created successfully with UID: ${userCredential.user?.uid}');

      // Then create the user profile in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('User profile created in Firestore');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during signup: ${e.code} - ${e.message}');
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
      print('Unexpected error during signup: $e');
      throw Exception('An unexpected error occurred during signup: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print('Attempting to sign in with email: $email');
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during signin: ${e.code} - ${e.message}');
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
      print('Unexpected error during signin: $e');
      throw Exception('An unexpected error occurred during sign in: $e');
    }
  }

  // Get user document from Firestore
  Future<DocumentSnapshot> getUserDetails() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print('getUserDetails: No user is currently logged in');
      throw Exception("User not logged in");
    }
    try {
      print('Fetching user details for: ${user.uid}');
      return await _firestore.collection('users').doc(user.uid).get();
    } catch (e) {
      print('Error fetching user details: $e');
      throw Exception('Failed to fetch user details: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Attempting to sign out user');
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error during sign out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      print('Attempting to send password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully');
    } catch (e) {
      print('Error sending password reset email: $e');
      throw Exception('Failed to send password reset email: $e');
    }
  }
}
