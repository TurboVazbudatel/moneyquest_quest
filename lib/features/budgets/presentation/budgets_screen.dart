import 'package:flutter/material.dart';
import '../../../data/services/budgets_service.dart';
import '../../../data/services/transactions_service.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final _svc = BudgetsService();
  final _txSvc = TransactionsService();

  double _limit = 0;
  double _spent = 0;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final l = await _svc.getBudget();
    // Пересчёт трат из транзакций
    final txs = _txSvc.all();
    double totalExp = 0;
    for (final e in txs) {
      if (e['type'] == 'expense') {
        totalExp += (e['amount'] as num?)?.toDouble() ?? 0.0;
      }
    }
    await _svc.setSpent(totalExp);
    final s = await _svc.getSpent();
    setState(() {
      _limit = l;
      _spent = s;
    });
  }

  Future<void> _saveBudget() async {
    final amt = double.tryParse(_ctrl.text.replaceAll(',', '.')) ?? 0;
    if (amt <= 0) return;
    await _svc.setBudget(amt);
    _ctrl.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final percent = _limit > 0 ? (_spent / _limit).clamp(0.0, 1.0) : 0.0;
    final overLimit = _limit > 0 && _spent > _limit;

    return Scaffold(
      appBar: AppBar(title: const Text('Мой бюджет')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_limit == 0)
            const Text('Бюджет пока не установлен'),
          if (_limit > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Лимит: ${_limit.toStringAsFixed(2)} ₽'),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percent.toDouble(),
                  backgroundColor: Colors.grey.shade300,
                  color: overLimit ? Colors.red : Colors.green,
                  minHeight: 12,
                ),
                const SizedBox(height: 8),
                Text('Израсходовано: ${_spent.toStringAsFixed(2)} ₽'),
                if (overLimit)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Airi: Ты превысил лимит бюджета! Попробуй сократить траты.',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 24),
          TextField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Новый лимит (₽)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveBudget,
            child: const Text('Сохранить бюджет'),
          ),
        ],
      ),
    );
  }
}
