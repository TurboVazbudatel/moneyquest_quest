import 'package:flutter/material.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../../core/services/first_run_service.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
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
  final _firstRun = FirstRunService();final _profile = ProfileService();
  String? _name;

  @override
  void initState() {
    super.initState();
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

}
