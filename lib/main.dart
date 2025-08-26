import 'package:flutter/material.dart';
import 'features/account/presentation/account_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/storage/hive_store.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/reports/presentation/reports_screen.dart';
import 'features/health/presentation/health_screen.dart';
import 'features/goals/presentation/goals_screen.dart';
import 'features/budgets/presentation/budgets_screen.dart';
import 'features/points/presentation/points_screen.dart';
import 'features/achievements/presentation/achievements_screen.dart';
import 'features/battle/presentation/budget_battle_screen.dart';
import 'data/services/profile_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveStore.init();
  runApp(const MoneyQuestApp());
}

class MoneyQuestApp extends StatelessWidget {
  const MoneyQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoneyQuest',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        cardTheme: const CardThemeData(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/account': (ctx) => const AccountScreen(),
        '/': (ctx) => const _Gate(),
        '/onboarding': (ctx) => const OnboardingScreen(),
        '/root': (ctx) => const _RootNav(),
      },
    );
  }
}

class _Gate extends StatefulWidget {
  const _Gate({super.key});
  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  final _profile = ProfileService();

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final onboarded = await _profile.isOnboarded();
    if (!mounted) return;
    if (onboarded) {
      Navigator.pushReplacementNamed(context, '/root');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _RootNav extends StatefulWidget {
  const _RootNav({super.key});
  @override
  State<_RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<_RootNav> {
  int index = 0;
  final pages = const [
    HomeScreen(),
    ReportsScreen(),
    HealthScreen(),
    GoalsScreen(),
    BudgetsScreen(),
    PointsScreen(),
    AchievementsScreen(),
    BudgetBattleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Диаграммы'),
          NavigationDestination(icon: Icon(Icons.monitor_heart_outlined), selectedIcon: Icon(Icons.monitor_heart), label: 'ФинЗдоровье'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Цели'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Бюджеты'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Баллы'),
          NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: 'Достижения'),
          NavigationDestination(icon: Icon(Icons.sports_esports_outlined), selectedIcon: Icon(Icons.sports_esports), label: 'Челлендж'),
        ],
      ),
    );
  }
}
