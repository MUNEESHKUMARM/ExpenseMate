import 'package:intl/intl.dart';

/// Utility helper functions used across the app.

/// Format a number as currency (Indian Rupee)
String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

/// Format a number as compact currency
String formatCompactCurrency(double amount) {
  if (amount >= 10000000) {
    return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
  } else if (amount >= 100000) {
    return '₹${(amount / 100000).toStringAsFixed(1)}L';
  } else if (amount >= 1000) {
    return '₹${(amount / 1000).toStringAsFixed(1)}K';
  }
  return '₹${amount.toStringAsFixed(0)}';
}

/// Format a DateTime to a readable date string
String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

/// Format a DateTime to a short date string
String formatShortDate(DateTime date) {
  return DateFormat('dd MMM').format(date);
}

/// Format a DateTime to show relative time
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return formatDate(date);
  }
}

/// Get the name of the month from a month number
String getMonthName(int month) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return months[month];
}

/// Get the day name from a weekday number (1=Monday)
String getDayName(int weekday) {
  const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday];
}
