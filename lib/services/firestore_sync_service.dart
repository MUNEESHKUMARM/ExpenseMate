import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

/// Firestore sync service — offline-first cloud backup for transactions.
///
/// All data is scoped per user: `users/{userId}/transactions`.
/// Local SQLite remains the primary data store.
/// Cloud sync is additive — call manually when you want to push/pull data.
class FirestoreSyncService {
  FirebaseFirestore? _firestore;
  bool _initialized = false;

  /// Initialize the Firestore service. Call after Firebase.initializeApp().
  void initialize() {
    try {
      _firestore = FirebaseFirestore.instance;
      _initialized = true;
      debugPrint('✅ FirestoreSyncService initialized');
    } catch (e) {
      debugPrint('⚠️ FirestoreSyncService: Firebase not configured — $e');
      _initialized = false;
    }
  }

  /// Whether Firestore is available.
  bool get isAvailable => _initialized && _firestore != null;

  /// Get the user's transactions collection reference.
  CollectionReference<Map<String, dynamic>> _userTransactions(String userId) {
    return _firestore!.collection('users').doc(userId).collection('transactions');
  }

  /// Upload all local transactions to Firestore.
  /// Replaces the cloud collection with current local data.
  Future<void> syncToCloud(String userId, List<TransactionModel> transactions) async {
    if (!isAvailable) {
      debugPrint('⚠️ FirestoreSyncService: syncToCloud() — Firebase not configured');
      return;
    }

    try {
      final collectionRef = _userTransactions(userId);

      // Clear existing cloud data
      final existing = await collectionRef.get();
      final batch = _firestore!.batch();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      // Upload all local transactions
      for (final t in transactions) {
        final docRef = collectionRef.doc();
        batch.set(docRef, t.toFirestoreMap(userId));
      }

      await batch.commit();
      debugPrint('✅ Synced ${transactions.length} transactions to cloud');
    } catch (e) {
      debugPrint('❌ Cloud sync failed: $e');
    }
  }

  /// Load all transactions from Firestore for a given user.
  Future<List<TransactionModel>> loadFromCloud(String userId) async {
    if (!isAvailable) {
      debugPrint('⚠️ FirestoreSyncService: loadFromCloud() — Firebase not configured');
      return [];
    }

    try {
      final snapshot = await _userTransactions(userId)
          .orderBy('date', descending: true)
          .get();

      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc.data(), doc.id))
          .toList();

      debugPrint('✅ Loaded ${transactions.length} transactions from cloud');
      return transactions;
    } catch (e) {
      debugPrint('❌ Cloud load failed: $e');
      return [];
    }
  }

  /// Sync a single transaction to Firestore (upsert).
  Future<String?> syncTransaction(
      String userId, TransactionModel transaction) async {
    if (!isAvailable) {
      debugPrint('⚠️ FirestoreSyncService: syncTransaction() — Firebase not configured');
      return null;
    }

    try {
      final collectionRef = _userTransactions(userId);

      if (transaction.firestoreId != null) {
        // Update existing document
        await collectionRef
            .doc(transaction.firestoreId)
            .set(transaction.toFirestoreMap(userId));
        debugPrint('✅ Updated transaction in cloud: ${transaction.title}');
        return transaction.firestoreId;
      } else {
        // Create new document
        final docRef =
            await collectionRef.add(transaction.toFirestoreMap(userId));
        debugPrint('✅ Added transaction to cloud: ${transaction.title}');
        return docRef.id;
      }
    } catch (e) {
      debugPrint('❌ Transaction sync failed: $e');
      return null;
    }
  }

  /// Delete a transaction from Firestore.
  Future<void> deleteFromCloud(String userId, String? firestoreId) async {
    if (!isAvailable || firestoreId == null) return;

    try {
      await _userTransactions(userId).doc(firestoreId).delete();
      debugPrint('✅ Deleted transaction $firestoreId from cloud');
    } catch (e) {
      debugPrint('❌ Cloud delete failed: $e');
    }
  }

  /// Sync the monthly budget to Firestore.
  Future<void> syncBudget(String userId, double budget) async {
    if (!isAvailable) return;

    try {
      await _firestore!.collection('users').doc(userId).set({
        'monthlyBudget': budget,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ Budget synced to cloud: $budget');
    } catch (e) {
      debugPrint('❌ Budget sync failed: $e');
    }
  }

  /// Load the monthly budget from Firestore.
  Future<double?> loadBudget(String userId) async {
    if (!isAvailable) return null;

    try {
      final doc = await _firestore!.collection('users').doc(userId).get();
      if (doc.exists && doc.data()?.containsKey('monthlyBudget') == true) {
        return (doc.data()!['monthlyBudget'] as num).toDouble();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Budget load from cloud failed: $e');
      return null;
    }
  }

  /// Delete all user data from Firestore.
  Future<void> deleteAllUserData(String userId) async {
    if (!isAvailable) return;

    try {
      // Delete all transactions
      final transactions = await _userTransactions(userId).get();
      final batch = _firestore!.batch();
      for (final doc in transactions.docs) {
        batch.delete(doc.reference);
      }
      // Delete user document
      batch.delete(_firestore!.collection('users').doc(userId));
      await batch.commit();
      debugPrint('✅ All user data deleted from cloud');
    } catch (e) {
      debugPrint('❌ Failed to delete user data from cloud: $e');
    }
  }
}
