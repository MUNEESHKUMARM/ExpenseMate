import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';
import '../services/preferences_service.dart';
import '../services/firestore_sync_service.dart';
import '../utils/constants.dart';

/// Provider that manages all transaction state and business logic.
/// Separates data management from UI, notifying listeners on changes.
/// Supports both local SQLite and optional Firestore cloud sync.
class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final PreferencesService _prefs = PreferencesService();
  final FirestoreSyncService _syncService = FirestoreSyncService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  double _monthlyBudget = defaultMonthlyBudget;

  // --- Getters ---

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  double get monthlyBudget => _monthlyBudget;

  /// Total income from all transactions
  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Total expenses from all transactions
  double get totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Current balance (income - expenses)
  double get balance => totalIncome - totalExpense;

  /// Last 5 transactions for the dashboard
  List<TransactionModel> get recentTransactions =>
      _transactions.take(5).toList();

  /// Current month's expenses
  double get currentMonthExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.isExpense &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Whether the current month's budget has been exceeded
  bool get isBudgetExceeded => currentMonthExpense > _monthlyBudget;

  /// Budget usage percentage (0.0 to 1.0+)
  double get budgetUsagePercentage =>
      _monthlyBudget > 0 ? currentMonthExpense / _monthlyBudget : 0.0;

  /// Category-wise expense totals for charts
  Map<String, double> get categoryExpenseTotals {
    final Map<String, double> totals = {};
    for (final t in _transactions.where((t) => t.isExpense)) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    return totals;
  }

  /// Weekly expense totals for the current week (Mon-Sun)
  Map<int, double> get weeklyExpenseTotals {
    final now = DateTime.now();
    // Find the Monday of the current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final Map<int, double> dailyTotals = {
      1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0,
    };

    for (final t in _transactions.where((t) => t.isExpense)) {
      if (t.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(endOfWeek)) {
        dailyTotals[t.date.weekday] =
            (dailyTotals[t.date.weekday] ?? 0) + t.amount;
      }
    }
    return dailyTotals;
  }

  /// Monthly expense totals for the current year
  Map<int, double> get monthlyExpenseTotals {
    final now = DateTime.now();
    final Map<int, double> totals = {};
    for (int i = 1; i <= 12; i++) {
      totals[i] = 0;
    }
    for (final t in _transactions.where((t) => t.isExpense)) {
      if (t.date.year == now.year) {
        totals[t.date.month] = (totals[t.date.month] ?? 0) + t.amount;
      }
    }
    return totals;
  }

  /// The highest spending category name and amount
  MapEntry<String, double>? get highestSpendingCategory {
    final totals = categoryExpenseTotals;
    if (totals.isEmpty) return null;
    return totals.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
  }

  /// Current week's total expenses (Mon-Sun)
  double get currentWeekExpense {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    return _transactions
        .where((t) =>
            t.isExpense &&
            t.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Budget alert level: 'none', 'warning' (80%+), or 'exceeded' (100%+)
  String get budgetAlertLevel {
    final usage = budgetUsagePercentage;
    if (usage >= 1.0) return 'exceeded';
    if (usage >= 0.8) return 'warning';
    return 'none';
  }

  /// Smart insight for weekly spending
  String get weeklyInsightText {
    final weekTotal = currentWeekExpense;
    if (weekTotal == 0) return 'No expenses this week yet.';

    // Find top category this week
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final Map<String, double> weekCats = {};
    for (final t in _transactions.where((t) =>
        t.isExpense &&
        t.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))))) {
      weekCats[t.category] = (weekCats[t.category] ?? 0) + t.amount;
    }
    if (weekCats.isEmpty) return 'No expenses this week yet.';
    final top = weekCats.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return 'You spent most on ${top.key} this week';
  }

  /// Smart insight for monthly spending
  String get monthlyInsightText {
    final monthTotal = currentMonthExpense;
    if (monthTotal == 0) return 'No expenses this month yet.';

    final highest = highestSpendingCategory;
    if (highest == null) return 'No expenses this month yet.';
    return 'Highest spending: ${highest.key} this month';
  }

  // --- Initialization ---

  /// Initialize preferences and load saved budget.
  Future<void> initPreferences() async {
    await _prefs.init();
    _monthlyBudget = _prefs.loadBudget();
    notifyListeners();
  }

  // --- Data Operations ---

  /// Load all transactions from the database.
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _dbHelper.getTransactions();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new transaction (SQLite first, Firestore in background).
  Future<void> addTransaction(TransactionModel transaction,
      {String? userId}) async {
    try {
      // 1. Save to SQLite — fast local write.
      final localId = await _dbHelper.insertTransaction(transaction);
      final saved = transaction.copyWith(id: localId);

      // 2. Optimistic update — insert at the front of the list immediately.
      _transactions.insert(0, saved);
      notifyListeners(); // Dashboard refreshes instantly.

      // 3. Fire Firestore in the background — never block the UI.
      if (userId != null && _syncService.isAvailable) {
        _syncService
            .syncTransaction(userId, saved)
            .timeout(const Duration(seconds: 10))
            .then((firestoreId) async {
              if (firestoreId != null) {
                await _dbHelper.updateFirestoreId(localId, firestoreId);
              }
            })
            .catchError((e) {
              debugPrint('Firestore sync skipped (add): $e');
            });
      }
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      // On SQLite failure, reload from DB to restore consistent state.
      await loadTransactions();
    }
  }

  /// Update an existing transaction (SQLite first, Firestore in background).
  Future<void> updateTransaction(TransactionModel transaction,
      {String? userId}) async {
    try {
      // 1. Update in SQLite — fast local write.
      await _dbHelper.updateTransaction(transaction);

      // 2. Optimistic update — replace in-memory entry immediately.
      final idx = _transactions.indexWhere((t) => t.id == transaction.id);
      if (idx != -1) {
        _transactions[idx] = transaction;
      }
      notifyListeners(); // Dashboard refreshes instantly.

      // 3. Fire Firestore in the background — never block the UI.
      if (userId != null && _syncService.isAvailable) {
        _syncService
            .syncTransaction(userId, transaction)
            .timeout(const Duration(seconds: 10))
            .catchError((e) {
              debugPrint('Firestore sync skipped (update): $e');
              return null; // Required: handler must return String? to match Future<String?>.
            });
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      // On SQLite failure, reload from DB to restore consistent state.
      await loadTransactions();
    }
  }

  /// Delete a transaction by ID (SQLite first, Firestore in background).
  Future<void> deleteTransaction(int id, {String? userId}) async {
    // Find in memory before removing (needed for Firestore ID).
    final transaction = _transactions.firstWhere(
      (t) => t.id == id,
      orElse: () => TransactionModel(
        title: '', amount: 0, type: 'Expense',
        category: 'Other', date: DateTime.now(),
      ),
    );

    try {
      // 1. Delete from SQLite — fast local write.
      await _dbHelper.deleteTransaction(id);

      // 2. Optimistic update — remove from in-memory list immediately.
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners(); // Dashboard refreshes instantly.

      // 3. Fire Firestore in the background — never block the UI.
      if (userId != null &&
          _syncService.isAvailable &&
          transaction.firestoreId != null) {
        _syncService
            .deleteFromCloud(userId, transaction.firestoreId)
            .timeout(const Duration(seconds: 10))
            .catchError((e) {
              debugPrint('Firestore sync skipped (delete): $e');
            });
      }
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      // On SQLite failure, reload from DB to restore consistent state.
      await loadTransactions();
    }
  }

  /// Set the monthly budget limit and persist it.
  Future<void> setMonthlyBudget(double budget, {String? userId}) async {
    _monthlyBudget = budget;
    await _prefs.saveBudget(budget);

    // Cloud sync if user is signed in
    if (userId != null && _syncService.isAvailable) {
      await _syncService.syncBudget(userId, budget);
    }

    notifyListeners();
  }

  /// Delete all transactions (for data reset)
  Future<void> deleteAllTransactions({String? userId}) async {
    try {
      await _dbHelper.deleteAllTransactions();

      // Cloud sync if user is signed in
      if (userId != null && _syncService.isAvailable) {
        await _syncService.deleteAllUserData(userId);
      }

      _transactions = [];
      _monthlyBudget = defaultMonthlyBudget;
      await _prefs.saveBudget(defaultMonthlyBudget);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting all transactions: $e');
    }
  }

  // --- Cloud Sync Operations ---

  /// Initialize the Firestore sync service.
  void initSyncService() {
    _syncService.initialize();
  }

  /// Sync all local transactions to the cloud.
  Future<void> syncToCloud(String userId) async {
    if (!_syncService.isAvailable) return;

    _isSyncing = true;
    notifyListeners();

    try {
      await _syncService.syncToCloud(userId, _transactions);
      await _syncService.syncBudget(userId, _monthlyBudget);
    } catch (e) {
      debugPrint('Error syncing to cloud: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Pull transactions from cloud and merge with local data.
  Future<void> syncFromCloud(String userId) async {
    if (!_syncService.isAvailable) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final cloudTransactions = await _syncService.loadFromCloud(userId);

      if (cloudTransactions.isNotEmpty) {
        // Clear local and replace with cloud data
        await _dbHelper.deleteAllTransactions();
        for (final t in cloudTransactions) {
          await _dbHelper.insertTransaction(t);
        }
        await loadTransactions();
      }

      // Sync budget from cloud
      final cloudBudget = await _syncService.loadBudget(userId);
      if (cloudBudget != null) {
        _monthlyBudget = cloudBudget;
        await _prefs.saveBudget(cloudBudget);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error syncing from cloud: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Filter transactions by type, category, and date range
  List<TransactionModel> getFilteredTransactions({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _transactions.where((t) {
      if (type != null && type != 'All' && t.type != type) return false;
      if (category != null && category != 'All' && t.category != category) {
        return false;
      }
      if (startDate != null && t.date.isBefore(startDate)) return false;
      if (endDate != null) {
        // Include the entire end day
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        if (t.date.isAfter(endOfDay)) return false;
      }
      return true;
    }).toList();
  }
}
