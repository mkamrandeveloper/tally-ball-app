import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

/// Converts any auth-related exception into a short, human-friendly message.
///
/// Usage:
///   } on FirebaseAuthException catch (e) {
///     TallyToast.showError(context, AuthErrorHandler.message(e));
///   } catch (e) {
///     TallyToast.showError(context, AuthErrorHandler.message(e));
///   }
class AuthErrorHandler {
  AuthErrorHandler._();

  static String message(Object error) {
    // ── Firebase Authentication errors ───────────────────────────────────────
    if (error is FirebaseAuthException) {
      switch (error.code) {
        // ── Credentials ──
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return 'Incorrect email or password.';
        case 'user-not-found':
          return 'No account found with this email.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a moment and try again.';
        case 'operation-not-allowed':
          return 'Sign-in method is not enabled. Please contact support.';
        case 'requires-recent-login':
          return 'Please sign in again to continue.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method.';

        // ── Network ──
        case 'network-request-failed':
          return 'No internet connection. Please check your network.';

        // ── Google Sign-In specific ──
        case 'sign_in_canceled':
        case 'sign_in_failed':
          return 'Google sign-in was cancelled.';

        default:
          return 'Authentication failed. Please try again.';
      }
    }

    // ── Network / socket errors ──────────────────────────────────────────────
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }

    // ── Timeout ─────────────────────────────────────────────────────────────
    if (error is TimeoutException) {
      return 'The request timed out. Please try again.';
    }

    // ── Catch-all — never expose raw message ─────────────────────────────────
    return 'Something went wrong. Please try again.';
  }
}
