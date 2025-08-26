import 'package:flutter/material.dart';
import '../../../data/services/budgets_service.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});
  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final _svc = BudgetsService();
  double _inc = 0, _exp = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final inc = await _svc.totalIncome();
    final exp = await _svc.totalExpense();
    if (!mounted) return;
    setState(() {
      _inc = inc;
      _exp = exp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final left = (_inc - _exp).toStringAsFixed(2);
    return Scaffold(
      appBar: AppBar(title: const Text('Бюджеты')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Итоги'),
              subtitle: Text('Доход: ${_inc.toStringAsFixed(2)} ₽ • Расход: ${_exp.toStringAsFixed(2)} ₽'),
              trailing: Text('Остаток: $left ₽'),
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<(DateTime day, double balance)>>(
            future: _svc.cumulativeTrend(),
            builder: (ctx, snap) {
              final data = snap.data ?? [];
              if (data.isEmpty) {
                return const Card(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Пока нет данных по тренду'),
                ));
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Тренд баланса'),
                      const SizedBox(height: 8),
                      Text('Старт: ${data.first.$2.toStringAsFixed(2)} ₽ → Сейчас: ${data.last.$2.toStringAsFixed(2)} ₽'),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
