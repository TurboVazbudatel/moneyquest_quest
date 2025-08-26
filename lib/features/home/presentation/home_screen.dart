import 'package:flutter/material.dart';
import '../../../data/services/profile_service.dart';
import '../../transactions/presentation/add_tx_sheet.dart';
import '../../transactions/presentation/transactions_screen.dart';
import '../../budgets/presentation/budgets_manager_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _profile = ProfileService();
  String? _name;

  @override
  void initState() {
    super.initState();
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
              leading: const Icon(Icons.sports_esports_outlined),
              title: const Text('BudgetBattle'),
              subtitle: const Text('24 часа уложиться в лимит'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/root', arguments: 7),
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
}
