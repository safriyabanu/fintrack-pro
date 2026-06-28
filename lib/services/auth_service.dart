import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  // Sign Up
  static Future<UserCredential?> signUp(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Login
  static Future<UserCredential?> login(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if logged in
  static bool get isLoggedIn => _auth.currentUser != null;
}