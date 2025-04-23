import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin credentials - In a real app, these would be stored securely in Firestore
  static const String ADMIN_COLLECTION = 'admins';

  // Sign Up
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // No error, signup successful
    } on FirebaseAuthException catch (e) {
      print("Sign Up Error: ${e.code} - ${e.message}");
      return e.message; // Return more specific Firebase error message
    } catch (e) {
      print("Sign Up General Error: $e");
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Login
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // No error, login successful
    } on FirebaseAuthException catch (e) {
      print("Login Error: ${e.code} - ${e.message}");
      return e.message; // Return more specific Firebase error message
    } catch (e) {
      print("Login General Error: $e");
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Check if the current user is an admin
  Future<bool> isAdmin() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Check the admins collection for this user's UID
      DocumentSnapshot adminDoc = await _firestore
          .collection(ADMIN_COLLECTION)
          .doc(user.uid)
          .get();

      return adminDoc.exists;
    } catch (e) {
      print("Admin check error: $e");
      return false;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}