import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_surface.dart';
import '../widgets/glass_button.dart';
import '../main.dart'; // To access HomeShell

/// Premium First-Impression Login Screen.
/// Liquid Glass styling with ambient glow background, entrance animations,
/// and polished sign-in feedback while preserving all AuthProvider logic.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    ));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<SettingsProvider>().isLight;
    final textColor = isLight ? const Color(0xFF1A1A2E) : Colors.white;
    final subtextColor = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        isLight: isLight,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Glowing App Logo Container
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isLight ? Colors.black : Colors.white).withValues(alpha: 0.08),
                        border: Border.all(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF).withValues(alpha: 0.35),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // App Branding
                    Text(
                      'Expense Mate',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Smart finance. Save More, Stress Less.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    // Liquid Glass Welcome & Sign-In Card
                    GlassSurface(
                      isLight: isLight,
                      borderRadius: 28,
                      blur: 16,
                      fillOpacity: 0.08,
                      borderOpacity: 0.15,
                      glowColor: const Color(0xFF7C4DFF),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to sync your data seamlessly across all devices',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),

                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return GlassButton(
                                label: auth.isLoading ? 'Signing in...' : 'Sign in with Google',
                                icon: auth.isLoading ? null : Icons.login_rounded,
                                isLoading: auth.isLoading,
                                accentColor: const Color(0xFF7C4DFF),
                                isLight: isLight,
                                onPressed: auth.isLoading
                                    ? null
                                    : () async {
                                        final success = await auth.signInWithGoogle();
                                        if (success && auth.userId != null && context.mounted) {
                                          final txnProvider = Provider.of<TransactionProvider>(
                                            context,
                                            listen: false,
                                          );
                                          await txnProvider.syncFromCloud(auth.userId!);
                                          if (context.mounted) {
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(builder: (_) => const HomeShell()),
                                            );
                                          }
                                        } else if (auth.error != null && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(auth.error!),
                                              backgroundColor: Colors.red.shade400,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
