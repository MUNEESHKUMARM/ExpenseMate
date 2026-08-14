import 'package:flutter/material.dart';
import '../utils/helpers.dart';

/// A card showing monthly budget usage with a progress bar.
/// Changes color when budget is exceeded.
class BudgetCard extends StatelessWidget {
  final double spent;
  final double budget;

  const BudgetCard({super.key, required this.spent, required this.budget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.5) : 0.0;
    final exceeded = spent > budget;
    final progressColor = exceeded ? const Color(0xFFFF6B6B) : const Color(0xFF6C63FF);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: exceeded
            ? Border.all(color: Colors.red.withValues(alpha: 0.4), width: 1.5)
            : null,
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.account_balance_wallet_rounded,
                  color: progressColor, size: 20),
                const SizedBox(width: 8),
                Text('Monthly Budget', style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15,
                  color: theme.colorScheme.onSurface)),
              ]),
              if (exceeded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
                    SizedBox(width: 4),
                    Text('Exceeded!', style: TextStyle(
                      color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: progressColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${formatCurrency(spent)} spent',
                style: TextStyle(color: progressColor, fontWeight: FontWeight.w600, fontSize: 13)),
              Text('of ${formatCurrency(budget)}',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
