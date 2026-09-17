import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

/// Singleton database helper for managing SQLite operations.
/// Handles CRUD operations for the transactions table.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Table and column names
  static const String _tableName = 'transactions';
  static const String _columnId = 'id';
  static const String _columnTitle = 'title';
  static const String _columnAmount = 'amount';
  static const String _columnType = 'type';
  static const String _columnCategory = 'category';
  static const String _columnDate = 'date';
  static const String _columnFirestoreId = 'firestoreId';

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Get or create the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create the transactions table (fresh install)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnTitle TEXT NOT NULL,
        $_columnAmount REAL NOT NULL,
        $_columnType TEXT NOT NULL,
        $_columnCategory TEXT NOT NULL,
        $_columnDate TEXT NOT NULL,
        $_columnFirestoreId TEXT
      )
    ''');
  }

  /// Handle database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add firestoreId column for cloud sync
      await db.execute(
        'ALTER TABLE $_tableName ADD COLUMN $_columnFirestoreId TEXT',
      );
    }
  }

  /// Insert a new transaction
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert(
      _tableName,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch all transactions ordered by date (newest first)
  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: '$_columnDate DESC');
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Fetch transactions filtered by type ('Income' or 'Expense')
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: '$_columnType = ?',
      whereArgs: [type],
      orderBy: '$_columnDate DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Fetch transactions filtered by category
  Future<List<TransactionModel>> getTransactionsByCategory(
    String category,
  ) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: '$_columnCategory = ?',
      whereArgs: [category],
      orderBy: '$_columnDate DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Fetch transactions within a date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: '$_columnDate BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: '$_columnDate DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Update an existing transaction
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      _tableName,
      transaction.toMap(),
      where: '$_columnId = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Update the firestoreId for a transaction after cloud sync
  Future<void> updateFirestoreId(int localId, String firestoreId) async {
    final db = await database;
    await db.update(
      _tableName,
      {'firestoreId': firestoreId},
      where: '$_columnId = ?',
      whereArgs: [localId],
    );
  }

  /// Delete a transaction by ID
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }

  /// Delete all transactions (for data reset)
  Future<int> deleteAllTransactions() async {
    final db = await database;
    return await db.delete(_tableName);
  }

  /// Get the total amount for a specific type
  Future<double> getTotalByType(String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM($_columnAmount) as total FROM $_tableName WHERE $_columnType = ?',
      [type],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get monthly totals for a specific type and year
  Future<Map<int, double>> getMonthlyTotals(String type, int year) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
      SELECT strftime('%m', $_columnDate) as month, 
             SUM($_columnAmount) as total 
      FROM $_tableName 
      WHERE $_columnType = ? AND strftime('%Y', $_columnDate) = ?
      GROUP BY month
    ''',
      [type, year.toString()],
    );

    final Map<int, double> monthlyTotals = {};
    for (final row in results) {
      final month = int.parse(row['month'] as String);
      monthlyTotals[month] = (row['total'] as num).toDouble();
    }
    return monthlyTotals;
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
