/// Model class representing a financial transaction.
/// Supports both income and expense types with category classification.
/// Includes Firestore serialization for cloud sync.
class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // 'Income' or 'Expense'
  final String category;
  final DateTime date;
  final String? firestoreId; // Cloud document ID for Firestore sync

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.firestoreId,
  });

  /// Convert a TransactionModel to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'firestoreId': firestoreId,
    };
  }

  /// Create a TransactionModel from a Map (database row)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      firestoreId: map['firestoreId'] as String?,
    );
  }

  /// Convert to a Map for Firestore storage (includes userId)
  Map<String, dynamic> toFirestoreMap(String userId) {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'userId': userId,
      'localId': id,
    };
  }

  /// Create a TransactionModel from a Firestore document
  factory TransactionModel.fromFirestore(
      Map<String, dynamic> data, String docId) {
    return TransactionModel(
      id: data['localId'] as int?,
      title: data['title'] as String,
      amount: (data['amount'] as num).toDouble(),
      type: data['type'] as String,
      category: data['category'] as String,
      date: DateTime.parse(data['date'] as String),
      firestoreId: docId,
    );
  }

  /// Create a copy with optional field overrides (for editing)
  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? firestoreId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      firestoreId: firestoreId ?? this.firestoreId,
    );
  }

  /// Whether this transaction is an income
  bool get isIncome => type == 'Income';

  /// Whether this transaction is an expense
  bool get isExpense => type == 'Expense';
}
