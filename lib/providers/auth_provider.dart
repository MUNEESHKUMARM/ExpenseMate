import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_sync_service.dart';

/// Provider that manages authentication state and user info.
/// Uses Firebase Authentication with Google Sign-In.
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreSyncService _syncService = FirestoreSyncService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  // --- Getters ---

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _user != null;
  String? get error => _error;

  String? get displayName => _user?.displayName;
  String? get email => _user?.email;
  String? get photoUrl => _user?.photoURL;
  String? get userId => _user?.uid;

  AuthService get authService => _authService;
  FirestoreSyncService get syncService => _syncService;

  /// Initialize auth and Firestore services.
  /// Call after Firebase.initializeApp().
  void initialize() {
    _authService.initialize();
    _syncService.initialize();

    // Check for existing sign-in
    _user = _authService.currentUser;
    if (_user != null) {
      debugPrint('✅ AuthProvider: Existing user found — ${_user!.displayName}');
    }
    notifyListeners();
  }

  /// Sign in with Google.
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithGoogle();
      if (_user == null) {
        _error = 'Sign-in cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out from Google and Firebase.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear any error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
