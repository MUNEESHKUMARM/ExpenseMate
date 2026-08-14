import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/helpers.dart';
import '../widgets/glass_surface.dart';
import '../widgets/glass_input_field.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_background.dart';
import 'login_screen.dart';

/// Full settings screen with Apple Liquid Glass styling.
/// Sections: Account, Budget Display & Edit, Appearance, Data Management, App Info.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _budgetController;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    _budgetController = TextEditingController(
      text: provider.monthlyBudget.toStringAsFixed(0),
    );
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final val = double.tryParse(_budgetController.text);
    if (val != null && val > 0) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await provider.setMonthlyBudget(val, userId: authProvider.userId);
      setState(() => _saved = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _saved = false);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Budget saved successfully!'),
            backgroundColor: const Color(0xFF7C4DFF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<SettingsProvider>().isLight;
    final textColor = isLight ? const Color(0xFF1A1A2E) : Colors.white;
    final subtextColor = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.6);
    final dimColor = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.45);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: GlassBackground(
        isLight: isLight,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Consumer3<TransactionProvider, AuthProvider, SettingsProvider>(
              builder: (context, txnProvider, authProvider, settingsProvider, _) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  children: [
                    const SizedBox(height: 8),

                    // ── Account Section ──
                    _buildAccountSection(
                      authProvider,
                      txnProvider,
                      isLight,
                      textColor,
                      subtextColor,
                      dimColor,
                    ),
                    const SizedBox(height: 24),

                    // ── Current Budget Display ──
                    _buildBudgetDisplay(
                      txnProvider,
                      isLight,
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 24),

                    // ── Update Budget Section ──
                    _buildBudgetEdit(isLight, textColor, subtextColor, dimColor),
                    const SizedBox(height: 24),

                    // ── Appearance Section ──
                    _buildAppearanceSection(
                      settingsProvider,
                      isLight,
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 24),

                    // ── Data Management Section ──
                    _buildDataSection(
                      txnProvider,
                      authProvider,
                      settingsProvider,
                      isLight,
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 24),

                    // ── App Info ──
                    _buildAppInfo(isLight, subtextColor, dimColor),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ─── Account Section ───
  Widget _buildAccountSection(
    AuthProvider auth,
    TransactionProvider txn,
    bool isLight,
    Color textColor,
    Color subtextColor,
    Color dimColor,
  ) {
    return GlassSurface(
      isLight: isLight,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Icon(Icons.person_rounded, color: textColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Account',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (auth.isSignedIn) ...[
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                    backgroundImage: auth.photoUrl != null ? NetworkImage(auth.photoUrl!) : null,
                    child: auth.photoUrl == null
                        ? Icon(Icons.person_rounded, color: textColor, size: 28)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.displayName ?? 'User',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        auth.email ?? '',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Cloud Sync Button
            GlassButton(
              label: txn.isSyncing ? 'Syncing...' : 'Sync Data Now',
              icon: Icons.cloud_sync_rounded,
              isLoading: txn.isSyncing,
              accentColor: const Color(0xFF448AFF),
              isLight: isLight,
              onPressed: txn.isSyncing
                  ? null
                  : () async {
                      await txn.syncToCloud(auth.userId!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Data synced successfully!'),
                            backgroundColor: const Color(0xFF00C9A7),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        );
                      }
                    },
            ),
            const SizedBox(height: 12),

            // Logout Glass Button
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.25), width: 0.8),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Signed out'),
                          backgroundColor: dimColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 20),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isLight ? Colors.black : Colors.white).withValues(alpha: isLight ? 0.03 : 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_off_rounded, color: dimColor, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to sync your data across devices',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subtextColor, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassButton(
              label: auth.isLoading ? 'Signing in...' : 'Sign in with Google',
              icon: Icons.login_rounded,
              isLoading: auth.isLoading,
              accentColor: const Color(0xFF7C4DFF),
              isLight: isLight,
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      final success = await auth.signInWithGoogle();
                      if (success && auth.userId != null && mounted) {
                        final txnProvider = Provider.of<TransactionProvider>(
                          context,
                          listen: false,
                        );
                        await txnProvider.syncFromCloud(auth.userId!);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Signed in & synced successfully!'),
                              backgroundColor: const Color(0xFF00C9A7),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          );
                        }
                      }
                    },
            ),
          ],
        ],
      ),
    );
  }

  // ─── Budget Display ───
  Widget _buildBudgetDisplay(
    TransactionProvider provider,
    bool isLight,
    Color textColor,
    Color subtextColor,
  ) {
    return GlassSurface(
      isLight: isLight,
      glowColor: const Color(0xFF7C4DFF),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFF7C4DFF),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Current Monthly Budget',
            style: TextStyle(
              color: subtextColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              formatCurrency(provider.monthlyBudget),
              key: ValueKey(provider.monthlyBudget),
              style: TextStyle(
                color: textColor,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildUsagePill(provider, isLight),
        ],
      ),
    );
  }

  // ─── Budget Edit ───
  Widget _buildBudgetEdit(
    bool isLight,
    Color textColor,
    Color subtextColor,
    Color dimColor,
  ) {
    return GlassSurface(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.edit_rounded, color: textColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Update Budget',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          GlassInputField(
            controller: _budgetController,
            label: 'Monthly Limit (₹)',
            hint: 'Enter new budget amount',
            icon: Icons.currency_rupee_rounded,
            keyboardType: TextInputType.number,
            isLight: isLight,
            textColor: textColor,
            dimColor: dimColor,
          ),
          const SizedBox(height: 20),

          GlassButton(
            label: _saved ? 'Saved!' : 'Save Budget',
            icon: _saved ? Icons.check_circle_rounded : Icons.save_rounded,
            accentColor: const Color(0xFF7C4DFF),
            isLight: isLight,
            onPressed: _saveBudget,
          ),
        ],
      ),
    );
  }

  // ─── Appearance Section ───
  Widget _buildAppearanceSection(
    SettingsProvider settings,
    bool isLight,
    Color textColor,
    Color subtextColor,
  ) {
    return GlassSurface(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.palette_rounded, color: textColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Appearance',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Custom animated theme toggle card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isLight ? Colors.black : Colors.white).withValues(alpha: isLight ? 0.03 : 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isLight ? Colors.black : Colors.white).withValues(alpha: isLight ? 0.06 : 0.08),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isLight ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: const Color(0xFF7C4DFF),
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLight ? 'Light Mode' : 'AMOLED Dark Mode',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLight ? 'Clean and bright interface' : 'Pure black for OLED displays',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Smooth Animated Switch Control
                GestureDetector(
                  onTap: () => settings.toggleTheme(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    width: 58,
                    height: 32,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isLight ? const Color(0xFFFFB74D) : const Color(0xFF7C4DFF),
                      boxShadow: [
                        BoxShadow(
                          color: (isLight ? const Color(0xFFFFB74D) : const Color(0xFF7C4DFF)).withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      alignment: isLight ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          isLight ? Icons.wb_sunny_rounded : Icons.nightlight_rounded,
                          size: 15,
                          color: isLight ? const Color(0xFFFFB74D) : const Color(0xFF7C4DFF),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Data Section ───
  Widget _buildDataSection(
    TransactionProvider txnProvider,
    AuthProvider authProvider,
    SettingsProvider settingsProvider,
    bool isLight,
    Color textColor,
    Color subtextColor,
  ) {
    return GlassSurface(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Data Management',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _showResetConfirmation(
                txnProvider,
                authProvider,
                settingsProvider,
                isLight,
                textColor,
              ),
              icon: const Icon(Icons.restart_alt_rounded, color: Colors.redAccent, size: 20),
              label: const Text(
                'Reset All Data',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Colors.red.withValues(alpha: 0.4),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Deletes all transactions, resets budget, and clears saved preferences.',
            style: TextStyle(color: subtextColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── App Info ───
  Widget _buildAppInfo(bool isLight, Color subtextColor, Color dimColor) {
    return GlassSurface(
      isLight: isLight,
      fillOpacity: isLight ? 0.03 : 0.04,
      child: Column(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: dimColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Expense Mate v2.0',
            style: TextStyle(
              color: subtextColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your personal finance companion',
            style: TextStyle(
              color: dimColor,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsagePill(TransactionProvider provider, bool isLight) {
    final percentage = (provider.budgetUsagePercentage * 100).clamp(0, 999);
    final exceeded = provider.isBudgetExceeded;
    final color = exceeded ? const Color(0xFFFF6B6B) : const Color(0xFF00C9A7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            exceeded ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            exceeded
                ? '${percentage.toStringAsFixed(0)}% used — Over budget!'
                : '${percentage.toStringAsFixed(0)}% used this month',
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(
    TransactionProvider txnProvider,
    AuthProvider authProvider,
    SettingsProvider settingsProvider,
    bool isLight,
    Color textColor,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isLight ? const Color(0xFFF5F5FF) : const Color(0xFF050505),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: (isLight ? Colors.black : Colors.white).withValues(alpha: 0.1),
            width: 0.8,
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 24),
            const SizedBox(width: 8),
            Text('Reset All Data', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete all transactions and reset all settings? This action cannot be undone.',
          style: TextStyle(
            color: textColor.withValues(alpha: 0.75),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: textColor.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await txnProvider.deleteAllTransactions(userId: authProvider.userId);
              await settingsProvider.resetAllData();
              if (mounted) {
                _budgetController.text = '50000';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All data has been reset'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
