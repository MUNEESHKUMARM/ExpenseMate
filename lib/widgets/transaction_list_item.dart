import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'glass_surface.dart';

/// Liquid Glass transaction item with glowing category icon,
/// crisp currency typography, and smooth swipe-to-delete interaction.
class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isLight;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final categoryData = getCategoryData(transaction.category);
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? const Color(0xFF00C9A7) : const Color(0xFFFF6B6B);
    final textColor = isLight ? const Color(0xFF1A1A2E) : Colors.white;

    return Dismissible(
      key: Key('transaction_${transaction.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.25), width: 0.8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
            SizedBox(width: 6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: GlassSurface(
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          blur: 10,
          fillOpacity: 0.05,
          borderOpacity: 0.09,
          glowColor: categoryData.color,
          isLight: isLight,
          onTap: onTap,
          child: Row(
            children: [
              // Category icon with soft glow ring
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryData.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: categoryData.color.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: categoryData.color.withValues(alpha: 0.1),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Icon(categoryData.icon, color: categoryData.color, size: 22),
              ),
              const SizedBox(width: 14),

              // Title and category badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryData.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: categoryData.color.withValues(alpha: 0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            transaction.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: categoryData.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatRelativeDate(transaction.date),
                          style: TextStyle(
                            color: (isLight ? Colors.black : Colors.white).withValues(alpha: 0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount formatting
              Text(
                '${isIncome ? '+' : '-'}${formatCurrency(transaction.amount)}',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
