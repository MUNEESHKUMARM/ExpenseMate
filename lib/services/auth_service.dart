import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service class for Firebase Authentication with Google Sign-In.
///
/// Provides methods for signing in/out via Google, and exposes
/// the current user state. All methods handle Firebase-not-configured
/// errors gracefully.
class AuthService {
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;
  bool _initialized = false;

  /// Initialize the auth service. Call after Firebase.initializeApp().
  void initialize() {
    try {
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
      _initialized = true;
      debugPrint('✅ AuthService initialized');
    } catch (e) {
      debugPrint('⚠️ AuthService: Firebase not configured — $e');
      _initialized = false;
    }
  }

  /// Whether Firebase Auth is available and initialized.
  bool get isAvailable => _initialized && _auth != null;

  /// The currently signed-in Firebase user, or null.
  User? get currentUser => _auth?.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => currentUser != null;

  /// Stream of auth state changes for reactive updates.
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();

  /// Sign in with Google and return the Firebase user.
  /// Returns null if sign-in was cancelled or Firebase is not configured.
  Future<User?> signInWithGoogle() async {
    if (!isAvailable) {
      debugPrint('⚠️ AuthService: Cannot sign in — Firebase not configured');
      return null;
    }

    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        debugPrint('ℹ️ Google Sign-In cancelled by user');
        return null;
      }

      // Obtain the auth details from the Google Sign-In
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth!.signInWithCredential(credential);
      debugPrint('✅ Signed in as: ${userCredential.user?.displayName}');
      return userCredential.user;
    } catch (e) {
      debugPrint('❌ Google Sign-In failed: $e');
      return null;
    }
  }

  /// Sign out from both Firebase and Google.
  Future<void> signOut() async {
    if (!isAvailable) return;

    try {
      await _googleSignIn?.signOut();
      await _auth?.signOut();
      debugPrint('✅ Signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
    }
  }
}
