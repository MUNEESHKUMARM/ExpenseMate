// Matte transparent dark fintech UI — Apple Liquid Glass Edition
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/transaction_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transaction_list_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/glass_background.dart';
import 'widgets/glass_surface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Edge-to-edge: transparent system bars ──
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // ── Initialize Firebase (graceful fallback if not configured) ──
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized');
  } catch (e) {
    debugPrint('⚠️ Firebase not configured — running in offline mode: $e');
  }

  // ── Initialize Settings ──
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(ExpenseTrackerApp(
    firebaseInitialized: firebaseInitialized,
    settingsProvider: settingsProvider,
  ));
}

/// Root widget – sets up MultiProvider, Liquid Glass theme, and the home shell.
class ExpenseTrackerApp extends StatelessWidget {
  final bool firebaseInitialized;
  final SettingsProvider settingsProvider;

  const ExpenseTrackerApp({
    super.key,
    required this.firebaseInitialized,
    required this.settingsProvider,
  });

  static const _seedColor = Color(0xFF7C4DFF);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(
          create: (_) {
            final provider = TransactionProvider();
            provider.initPreferences();
            provider.loadTransactions();
            if (firebaseInitialized) {
              provider.initSyncService();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();
            if (firebaseInitialized) {
              authProvider.initialize();
            }
            return authProvider;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final isLight = settings.isLight;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isLight ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness:
                isLight ? Brightness.dark : Brightness.light,
            systemNavigationBarDividerColor: Colors.transparent,
          ));

          return MaterialApp(
            title: 'Expense Mate',
            debugShowCheckedModeBanner: false,

            // ── Dark Liquid Glass Theme ──
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: _seedColor,
                brightness: Brightness.dark,
                surface: const Color(0xFF050505),
              ),
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.dark().textTheme,
              ),
              scaffoldBackgroundColor: Colors.transparent,
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
              bottomSheetTheme: BottomSheetThemeData(
                backgroundColor: const Color(0xFF050505),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                ),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: const Color(0xFF050505),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                ),
              ),
            ),

            // ── Light Liquid Theme ──
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: _seedColor,
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.light().textTheme,
              ),
              scaffoldBackgroundColor: Colors.transparent,
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFF1A1A2E),
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
              bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: Color(0xFFF8F8FF),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: const Color(0xFFF8F8FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),

            themeMode: settings.flutterThemeMode,
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.isSignedIn) {
                  return const HomeShell();
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}

/// Home shell with floating Apple Liquid Glass navigation dock and neon FAB.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    TransactionListScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<SettingsProvider>().isLight;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        isLight: isLight,
        child: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _screens[_currentIndex],
          ),
        ),
      ),

      // ── Apple Liquid Glass Floating Action Button ──
      floatingActionButton: _LiquidFAB(
        onPressed: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AddTransactionScreen(),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Floating Apple-Style Liquid Glass Bottom Navigation Dock ──
      bottomNavigationBar: _LiquidNavBar(
        currentIndex: _currentIndex,
        isLight: isLight,
        onTap: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SettingsScreen(),
                transitionDuration: const Duration(milliseconds: 400),
                reverseTransitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
              ),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Liquid Floating Action Button with micro-bounce & neon glow pulse
// ─────────────────────────────────────────────────────────────────

class _LiquidFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const _LiquidFAB({required this.onPressed});

  @override
  State<_LiquidFAB> createState() => _LiquidFABState();
}

class _LiquidFABState extends State<_LiquidFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.06,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.45),
                    blurRadius: 20,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Floating Apple-Style Liquid Glass Navigation Dock
// ─────────────────────────────────────────────────────────────────

class _LiquidNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isLight;

  const _LiquidNavBar({
    required this.currentIndex,
    required this.onTap,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: bottomPadding > 0 ? bottomPadding : 16,
      ),
      child: GlassSurface(
        padding: EdgeInsets.zero,
        borderRadius: 28,
        blur: 16,
        fillOpacity: isLight ? 0.08 : 0.07,
        borderOpacity: isLight ? 0.12 : 0.15,
        isLight: isLight,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LiquidNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
                isLight: isLight,
              ),
              _LiquidNavItem(
                icon: Icons.receipt_long_rounded,
                label: 'History',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
                isLight: isLight,
              ),
              const SizedBox(width: 56), // Space for centered FAB
              _LiquidNavItem(
                icon: Icons.analytics_rounded,
                label: 'Analytics',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
                isLight: isLight,
              ),
              _LiquidNavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: false,
                onTap: () => onTap(3),
                isLight: isLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLight;

  const _LiquidNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isLight
        ? Colors.black.withValues(alpha: 0.38)
        : Colors.white.withValues(alpha: 0.4);
    final activeColor = const Color(0xFF7C4DFF);
    final color = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active Tab Indicator Capsule with Neon Glow
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isSelected ? 26 : 0,
              height: 3.5,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.6),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
