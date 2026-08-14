import 'package:flutter/material.dart';

/// App-wide constants for categories, colors, and configuration.

/// Default monthly budget limit
const double defaultMonthlyBudget = 50000.0;

/// List of expense categories with their icons and colors
class CategoryData {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryData({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// All available categories for transactions
final List<CategoryData> expenseCategories = [
  CategoryData(name: 'Food', icon: Icons.restaurant_rounded, color: const Color(0xFFFF6B6B)),
  CategoryData(name: 'Travel', icon: Icons.flight_rounded, color: const Color(0xFF4ECDC4)),
  CategoryData(name: 'Shopping', icon: Icons.shopping_bag_rounded, color: const Color(0xFFFFE66D)),
  CategoryData(name: 'Bills', icon: Icons.receipt_long_rounded, color: const Color(0xFF95E1D3)),
  CategoryData(name: 'Entertainment', icon: Icons.movie_rounded, color: const Color(0xFFA8E6CF)),
  CategoryData(name: 'Health', icon: Icons.favorite_rounded, color: const Color(0xFFFF8A80)),
  CategoryData(name: 'Education', icon: Icons.school_rounded, color: const Color(0xFF80D8FF)),
  CategoryData(name: 'Salary', icon: Icons.account_balance_wallet_rounded, color: const Color(0xFF69F0AE)),
  CategoryData(name: 'Freelance', icon: Icons.laptop_mac_rounded, color: const Color(0xFFB388FF)),
  CategoryData(name: 'Investment', icon: Icons.trending_up_rounded, color: const Color(0xFFFFD180)),
  CategoryData(name: 'Gift', icon: Icons.card_giftcard_rounded, color: const Color(0xFFFF80AB)),
  CategoryData(name: 'Other', icon: Icons.more_horiz_rounded, color: const Color(0xFFCFD8DC)),
];

/// Income-specific categories
final List<String> incomeCategories = [
  'Salary',
  'Freelance',
  'Investment',
  'Gift',
  'Other',
];

/// Expense-specific categories
final List<String> expenseCategoriesList = [
  'Food',
  'Travel',
  'Shopping',
  'Bills',
  'Entertainment',
  'Health',
  'Education',
  'Other',
];

/// Get CategoryData by name
CategoryData getCategoryData(String name) {
  return expenseCategories.firstWhere(
    (c) => c.name == name,
    orElse: () => expenseCategories.last,
  );
}

/// Gradient colors used throughout the app
class AppGradients {
  static const List<Color> primaryGradient = [
    Color(0xFF7C4DFF),
    Color(0xFF4A38AE),
  ];

  static const List<Color> incomeGradient = [
    Color(0xFF00C9A7),
    Color(0xFF00897B),
  ];

  static const List<Color> expenseGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFC62828),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF7C4DFF),
    Color(0xFF448AFF),
  ];

  static const List<Color> darkCardGradient = [
    Color(0xFF1E1E2E),
    Color(0xFF2D2D44),
  ];
}
