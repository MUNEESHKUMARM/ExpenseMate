import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/helpers.dart';
import '../widgets/animated_count_up.dart';
import '../widgets/budget_alert_banner.dart';
import '../widgets/glass_surface.dart';
import '../widgets/staggered_fade_slide.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/chart_widgets.dart';
import 'add_transaction_screen.dart';

/// Dashboard screen — Hero view of Expense Mate.
/// Apple Liquid Glass floating composition with total balance count-up,
/// glowing user profile header, income/expense cards, budget progress bar,
/// smart insights, and recent transactions.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _alertDismissed = false;

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<SettingsProvider>().isLight;

    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          color: const Color(0xFF7C4DFF),
          backgroundColor: isLight ? Colors.white : const Color(0xFF050505),
          onRefresh: () async {
            setState(() => _alertDismissed = false);
            await provider.loadTransactions();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Profile Header + Balance + Budget ──
              SliverToBoxAdapter(
                child: StaggeredFadeSlide(
                  index: 0,
                  child: _LiquidHeader(provider: provider, isLight: isLight),
                ),
              ),

              // ── Main Dashboard Body Content ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),

                    // Budget alert banner
                    if (!_alertDismissed && provider.budgetAlertLevel != 'none')
                      StaggeredFadeSlide(
                        index: 1,
                        child: BudgetAlertBanner(
                          alertLevel: provider.budgetAlertLevel,
                          percentage: provider.budgetUsagePercentage * 100,
                          isLight: isLight,
                          onDismiss: () => setState(() => _alertDismissed = true),
                        ),
                      ),

                    // Smart insight pill
                    StaggeredFadeSlide(
                      index: 2,
                      child: _LiquidInsightPill(
                        text: provider.weeklyInsightText,
                        icon: Icons.lightbulb_rounded,
                        isLight: isLight,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Income & Expense floating cards
                    StaggeredFadeSlide(
                      index: 3,
                      child: Row(
                        children: [
                          Expanded(
                            child: _LiquidMiniCard(
                              title: 'Income',
                              amount: provider.totalIncome,
                              icon: Icons.arrow_downward_rounded,
                              color: const Color(0xFF00C9A7),
                              isLight: isLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LiquidMiniCard(
                              title: 'Expense',
                              amount: provider.totalExpense,
                              icon: Icons.arrow_upward_rounded,
                              color: const Color(0xFFFF6B6B),
                              isLight: isLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Expense breakdown pie chart in Liquid Glass container
                    StaggeredFadeSlide(
                      index: 4,
                      child: GlassSurface(
                        isLight: isLight,
                        glowColor: const Color(0xFF7C4DFF),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              'Expense Breakdown',
                              Icons.pie_chart_rounded,
                              isLight,
                            ),
                            const SizedBox(height: 18),
                            ExpensePieChart(
                              categoryTotals: provider.categoryExpenseTotals,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent transactions section header
                    StaggeredFadeSlide(
                      index: 5,
                      child: _sectionHeader(
                        'Recent Transactions',
                        Icons.history_rounded,
                        isLight,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Transaction list / Empty state
                    if (provider.recentTransactions.isEmpty)
                      StaggeredFadeSlide(
                        index: 6,
                        child: _emptyTransactions(isLight),
                      )
                    else
                      ...provider.recentTransactions
                          .asMap()
                          .entries
                          .map(
                            (entry) => StaggeredFadeSlide(
                              index: 6 + entry.key,
                              child: TransactionListItem(
                                transaction: entry.value,
                                isLight: isLight,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddTransactionScreen(
                                      transaction: entry.value,
                                    ),
                                  ),
                                ),
                                onDelete: () => provider.deleteTransaction(entry.value.id!),
                              ),
                            ),
                          ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, IconData icon, bool isLight) {
    return Row(
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
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
            color: isLight ? const Color(0xFF1A1A2E) : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _emptyTransactions(bool isLight) {
    return GlassSurface(
      isLight: isLight,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 48,
            color: (isLight ? Colors.black : Colors.white).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: TextStyle(
              color: (isLight ? Colors.black : Colors.white).withValues(alpha: 0.5),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add your first transaction',
            style: TextStyle(
              color: (isLight ? Colors.black : Colors.white).withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Liquid Insight Pill
// ─────────────────────────────────────────────────────────────────

class _LiquidInsightPill extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isLight;

  const _LiquidInsightPill({
    required this.text,
    required this.icon,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 18,
      blur: 10,
      fillOpacity: 0.05,
      isLight: isLight,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: const Color(0xFF7C4DFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isLight
                    ? const Color(0xFF1A1A2E).withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Liquid Mini Income/Expense Card
// ─────────────────────────────────────────────────────────────────

class _LiquidMiniCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isLight;

  const _LiquidMiniCard({
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
                  border: Border.all(
                    color: color.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
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
          AnimatedCountUp(
            targetValue: amount,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Liquid Header — profile avatar ring, balance & budget cards
// ─────────────────────────────────────────────────────────────────

class _LiquidHeader extends StatelessWidget {
  final TransactionProvider provider;
  final bool isLight;

  const _LiquidHeader({required this.provider, this.isLight = false});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final progress = provider.monthlyBudget > 0
        ? (provider.currentMonthExpense / provider.monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final exceeded = provider.isBudgetExceeded;
    final barColor = exceeded ? const Color(0xFFFF6B6B) : const Color(0xFF00C9A7);
    final textColor = isLight ? const Color(0xFF1A1A2E) : Colors.white;
    final subtextColor = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header Row
          InkWell(
            onTap: () => provider.loadTransactions(),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  if (auth.isSignedIn) ...[
                    // Circular Avatar with Luminous Glow Ring
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF).withValues(alpha: 0.25),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 23,
                        backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                        backgroundImage:
                            auth.photoUrl != null ? NetworkImage(auth.photoUrl!) : null,
                        child: auth.photoUrl == null
                            ? Icon(Icons.person_rounded, color: textColor, size: 24)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${auth.displayName?.split(' ').first ?? 'User'} 👋',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Save More, Stress Less',
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                        border: Border.all(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(9),
                      child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expense Mate',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Smart finance companion',
                            style: TextStyle(color: subtextColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Total Balance Liquid Glass Card ──
          GlassSurface(
            isLight: isLight,
            glowColor: const Color(0xFF7C4DFF),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: (isLight ? Colors.black : Colors.white).withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFF7C4DFF),
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedCountUp(
                  targetValue: provider.balance,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Monthly Budget Progress Liquid Glass Card ──
          GlassSurface(
            isLight: isLight,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pie_chart_rounded, color: barColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Monthly Budget',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (exceeded)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Exceeded!',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Smooth animated progress bar fill
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 7,
                        backgroundColor:
                            (isLight ? Colors.black : Colors.white).withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedCountUp(
                          targetValue: provider.currentMonthExpense,
                          style: TextStyle(
                            color: barColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                        Text(
                          ' spent',
                          style: TextStyle(
                            color: barColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'of ${formatCurrency(provider.monthlyBudget)}',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
