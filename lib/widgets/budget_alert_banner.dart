import 'package:flutter/material.dart';
import 'glass_surface.dart';

/// A transparent liquid-style alert banner for budget warnings.
/// Uses luminous border stroke and soft glow fill.
class BudgetAlertBanner extends StatelessWidget {
  final String alertLevel;
  final double percentage;
  final VoidCallback? onDismiss;
  final bool isLight;

  const BudgetAlertBanner({
    super.key,
    required this.alertLevel,
    required this.percentage,
    this.onDismiss,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    if (alertLevel == 'none') return const SizedBox.shrink();

    final isExceeded = alertLevel == 'exceeded';
    final accentColor = isExceeded ? const Color(0xFFFF6B6B) : const Color(0xFFFFA726);
    final icon = isExceeded
        ? Icons.error_rounded
        : Icons.warning_amber_rounded;
    final message = isExceeded
        ? 'Budget exceeded! You\'ve spent ${percentage.toStringAsFixed(0)}%'
        : 'Careful! ${percentage.toStringAsFixed(0)}% of budget used';
    final subtitle = isExceeded
        ? 'Consider reducing your expenses this month'
        : 'You\'re approaching your monthly limit';
    final textColor = isLight ? const Color(0xFF1A1A2E) : Colors.white;

    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0, -0.8), end: Offset.zero),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, offset, child) {
        return FractionalTranslation(
          translation: offset,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassSurface(
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          blur: 12,
          fillOpacity: 0.08,
          borderOpacity: 0.2,
          glowColor: accentColor,
          isLight: isLight,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: textColor.withValues(alpha: 0.6),
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
