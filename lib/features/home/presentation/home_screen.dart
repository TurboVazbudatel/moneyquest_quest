import 'package:flutter/material.dart';
import 'package:moneyquest_quest/features/auth/presentation/auth_screen.dart';
import 'package:moneyquest_quest/features/reports/presentation/premium_reports_screen.dart';
import 'package:moneyquest_quest/features/subscription/presentation/subscription_screen.dart';
import 'package:moneyquest_quest/features/points/presentation/history_screen.dart';
import 'package:moneyquest_quest/data/services/points_service.dart';
import 'package:moneyquest_quest/features/settings/presentation/settings_screen.dart';
import 'package:moneyquest_quest/features/home/widgets/airi_greeting_banner.dart';
import 'package:moneyquest_quest/features/achievements/presentation/achievements_screen.dart';
import 'package:moneyquest_quest/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:moneyquest_quest/features/battle/presentation/budget_battle_screen.dart';
import 'package:moneyquest_quest/features/budgets/presentation/budgets_screen.dart';
import 'package:moneyquest_quest/features/reports/presentation/reports_screen.dart';
import 'package:moneyquest_quest/features/health/presentation/health_screen.dart';
import 'package:moneyquest_quest/core/services/greet_flag.dart';
import 'package:moneyquest_quest/data/services/profile_service.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../../core/services/first_run_service.dart';
import 'package:moneyquest_quest/core/services/first_run_service.dart';
import '../../../data/services/profile_service.dart';
import '../../transactions/presentation/add_tx_sheet.dart';
import '../../transactions/presentation/transactions_screen.dart';
import '../../budgets/presentation/budgets_manager_screen.dart';
import '../../health/presentation/health_screen.dart';
import '../../reports/presentation/reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _greet = GreetFlag();
final _profile = ProfileService();
final _firstRun = FirstRunService();
  String? _name;

  @override
  void initState() {
    super.initState();
            _showGreetingIfNeeded();
_showOnboardingIfNeeded();
_load();
  }

  Future<void> _load() async {
    final name = await _profile.getName();
    if (!mounted) return;
    setState(() => _name = name);
  }

  @override
  Widget build(BuildContext context) {
    final greet = _name?.isNotEmpty == true ? 'Привет, $_name!' : 'Привет!';
    return Scaffold(
      bottomNavigationBar: const _HomeBottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: const Text('MoneyQuest'),
        actions: [
          IconButton(
            tooltip: 'Аккаунт',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/account'),
          ),
          IconButton(
            tooltip: 'Транзакции',
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TransactionsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Бюджеты',
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BudgetsManagerScreen()),
            ),
          ),
          IconButton(
            tooltip: 'ФинЗдоровье',
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HealthScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Диаграммы',
            icon: const Icon(Icons.radar),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AiriGreetingBanner(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(radius: 24, child: Text('A')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$greet Я Airi. Давай посмотрим твой бюджет сегодня ✨',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.radar),
              title: const Text('Диаграммы'),
              subtitle: const Text('Радар доходов и расходов'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.pie_chart_outline),
              title: const Text('Бюджеты'),
              subtitle: const Text('Лимиты по категориям с прогрессом'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BudgetsManagerScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('ФинЗдоровье'),
              subtitle: const Text('Баланс доходов и расходов'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HealthScreen()),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).cardColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => const AddTxSheet(),
          );
          if (ok == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Операция сохранена')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  Future<void> _showOnboardingIfNeeded() async {
    final need = await _firstRun.needOnboarding();
    if (!mounted || !need) return;
    await _firstRun.markSeen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  Future<void> _showGreetingIfNeeded() async {
    final need = await _greet.needGreet();
    if (!mounted || !need) return;
    final name = (await _profile.getName()) ?? '';
    await _greet.markGreeted();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final txt = name.trim().isEmpty ? 'Привет! Я Airi 💚' : 'Привет, ${name.trim()}! Я Airi 💚';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Image.asset('assets/airi/half/Airi_half_01_wave.png', height: 28),
              const SizedBox(width: 12),
              Expanded(child: Text(txt)),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

}


class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: theme.colorScheme.surface,
      elevation: 6,
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home_filled),
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
            IconButton(icon: const Icon(Icons.radar_rounded),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsScreen()))),
            IconButton(icon: const Icon(Icons.account_balance_wallet_rounded),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetsScreen()))),
            IconButton(icon: const Icon(Icons.emoji_events_rounded),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AchievementsScreen()))),
            IconButton(icon: const Icon(Icons.leaderboard_rounded),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardScreen()))),
            IconButton(icon: const Icon(Icons.favorite_rounded),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HealthScreen()))),
            PopupMenuButton<String>(
              tooltip: 'Ещё',
              icon: const Icon(Icons.more_horiz_rounded),
              onSelected: (v) async {
                switch (v) {
                  case 'ch':
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetBattleScreen()));
                    break;
                  case 'complete': {
                    final pts = await PointsService().addPoints(50, reason: 'Начисление');
                    if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Завершено! +50 баллов · Всего: $pts'))); }
                    break;
                  }
                  case 'history':
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
                    break;
                  case 'subscribe':
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                    break;
                  case 'reports':
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumReportsScreen()));
                    break;
                  case 'login':
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                    break;
                  case 'settings':
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'ch', child: Text('Челленджи')),PopupMenuItem(value: 'complete', child: Text('Завершить челлендж (+50)')),
                PopupMenuItem(value: 'subscribe', child: Row(children:[Icon(Icons.star), SizedBox(width:8), Text('Premium')])),
                PopupMenuItem(value: 'login', child: Row(children:[Icon(Icons.person), SizedBox(width:8), Text('Войти')])),
                PopupMenuItem(value: 'reports', child: Row(children:[Icon(Icons.analytics), SizedBox(width:8), Text('Premium отчёты')])),
                PopupMenuItem(value: 'settings', child: Row(children:[Icon(Icons.settings), SizedBox(width:8), Text('Настройки')])),
              
                  PopupMenuItem(value: 'history', child: Text('История баллов')),],
            ),
          ],
        ),
      ),
    );
  }
}