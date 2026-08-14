import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/chart_widgets.dart';
import '../widgets/glass_surface.dart';
import '../widgets/staggered_fade_slide.dart';

/// Analytics Screen — Apple Liquid Glass presentation.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _showWeekly = true;

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<SettingsProvider>().isLight;
    final textColor = isLight ? const Color(0xFF1A1A2E) : Colors.white;
    final subtextColor = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.5);

    return Consumer<TransactionProvider>(
      builder: (context, p, _) {
        final highest = p.highestSpendingCategory;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            StaggeredFadeSlide(
              index: 0,
              child: Text(
                'Analytics',
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 4),
            StaggeredFadeSlide(
              index: 0,
              child: Text(
                'Understand your spending patterns',
                style: TextStyle(color: subtextColor, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),

            // Week / Month spending summary cards
            StaggeredFadeSlide(
              index: 1,
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'This Week',
                      amount: p.currentWeekExpense,
                      icon: Icons.calendar_view_week_rounded,
                      color: const Color(0xFF7C4DFF),
                      isLight: isLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'This Month',
                      amount: p.currentMonthExpense,
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFF448AFF),
                      isLight: isLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Insight pills
            StaggeredFadeSlide(
              index: 2,
              child: _InsightPill(
                text: p.weeklyInsightText,
                icon: Icons.lightbulb_rounded,
                isLight: isLight,
              ),
            ),
            const SizedBox(height: 8),
            StaggeredFadeSlide(
              index: 2,
              child: _InsightPill(
                text: p.monthlyInsightText,
                icon: Icons.insights_rounded,
                isLight: isLight,
              ),
            ),
            const SizedBox(height: 24),

            // Highest spending category insight card
            if (highest != null) ...[
              StaggeredFadeSlide(
                index: 3,
                child: _insightCard(highest, isLight, textColor),
              ),
              const SizedBox(height: 24),
            ],

            // Category Pie Chart Container
            StaggeredFadeSlide(
              index: 4,
              child: _section(
                'Category Breakdown',
                Icons.pie_chart_rounded,
                isLight,
                textColor,
                child: ExpensePieChart(categoryTotals: p.categoryExpenseTotals),
              ),
            ),
            const SizedBox(height: 20),

            // Weekly / Monthly Bar Chart Container
            StaggeredFadeSlide(
              index: 5,
              child: _section(
                _showWeekly ? 'Weekly Spending' : 'Monthly Spending',
                Icons.bar_chart_rounded,
                isLight,
                textColor,
                trailing: _toggle(isLight),
                child: SpendingBarChart(
                  data: _showWeekly ? p.weeklyExpenseTotals : p.monthlyExpenseTotals,
                  isWeekly: _showWeekly,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category details section header
            StaggeredFadeSlide(
              index: 6,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(Icons.list_alt_rounded, size: 16, color: Color(0xFF7C4DFF)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Category Details',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Category list tiles
            ...p.categoryExpenseTotals.entries.toList().asMap().entries.map(
              (e) => StaggeredFadeSlide(
                index: 7 + e.key,
                child: _catTile(e.value, isLight, textColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _insightCard(MapEntry<String, double> h, bool l, Color tc) {
    final c = getCategoryData(h.key);
    final sc = l ? const Color(0xFF1A1A2E).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.55);

    return GlassSurface(
      isLight: l,
      glowColor: c.color,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.color.withValues(alpha: 0.25), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: c.color.withValues(alpha: 0.1),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Icon(c.icon, color: c.color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Highest Spending', style: TextStyle(color: sc, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(h.key, style: TextStyle(color: tc, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(formatCurrency(h.value), style: TextStyle(color: sc, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    IconData icon,
    bool l,
    Color tc, {
    required Widget child,
    Widget? trailing,
  }) {
    return GlassSurface(
      isLight: l,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF7C4DFF)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: tc, letterSpacing: 0.2),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _toggle(bool l) {
    final bc = l ? Colors.black : Colors.white;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bc.withValues(alpha: l ? 0.04 : 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bc.withValues(alpha: l ? 0.06 : 0.08), width: 0.8),
      ),
      child: Row(
        children: [
          _tBtn('W', _showWeekly, () => setState(() => _showWeekly = true), l),
          _tBtn('M', !_showWeekly, () => setState(() => _showWeekly = false), l),
        ],
      ),
    );
  }

  Widget _tBtn(String s, bool a, VoidCallback f, bool l) {
    return GestureDetector(
      onTap: f,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: a ? const Color(0xFF7C4DFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: a
              ? [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Text(
          s,
          style: TextStyle(
            color: a ? Colors.white : (l ? Colors.black45 : Colors.white.withValues(alpha: 0.45)),
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _catTile(MapEntry<String, double> e, bool l, Color tc) {
    final c = getCategoryData(e.key);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassSurface(
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        blur: 10,
        fillOpacity: 0.05,
        isLight: l,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.color.withValues(alpha: 0.2), width: 0.8),
              ),
              child: Icon(c.icon, color: c.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                e.key,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: tc),
              ),
            ),
            Text(
              formatCurrency(e.value),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFFFF6B6B),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isLight;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      glowColor: color,
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: (isLight ? Colors.black : Colors.white).withValues(alpha: 0.55),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCurrency(amount),
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightPill extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isLight;

  const _InsightPill({required this.text, required this.icon, this.isLight = false});

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 14,
      blur: 8,
      fillOpacity: 0.04,
      isLight: isLight,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF7C4DFF)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isLight ? const Color(0xFF1A1A2E).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.6),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
