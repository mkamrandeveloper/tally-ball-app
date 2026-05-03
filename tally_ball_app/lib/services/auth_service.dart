import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with Email
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Email
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Use singleton instance and authenticate() as per v7.0.0 breaking changes
      final gsi.GoogleSignInAccount? googleUser = await gsi.GoogleSignIn.instance.authenticate();

      if (googleUser == null) return null; // User cancelled

      // Obtain the auth details from the request
      final gsi.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await gsi.GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
