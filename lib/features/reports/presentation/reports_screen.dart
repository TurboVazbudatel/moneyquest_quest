import 'package:flutter/material.dart';
import '../../../data/services/transactions_service.dart';
import 'widgets/radar_income_expense.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _svc = TransactionsService();
  Map<String, double> _income = {};
  Map<String, double> _expense = {};
  late List<String> _axes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _axes = [
      ...TransactionsService.defaultExpenseCats, // базовые оси по расходам (Еда/Транспорт/…)
    ];
    _load();
  }

  Future<void> _load() async {
    final items = await _svc.all();

    final inc = <String, double>{};
    final exp = <String, double>{};

    // инициализируем нулями все оси
    for (final c in _axes) {
      inc[c] = 0;
      exp[c] = 0;
    }

    for (final e in items) {
      final cat = (e['category'] as String?) ?? 'Другое';
      final amt = (e['amount'] as num).toDouble();
      if (!_axes.contains(cat)) {
        // если категория нестандартная — складываем в "Другое"
        final other = 'Другое';
        if (!_axes.contains(other)) _axes.add(other);
      }
      final target = _axes.contains(cat) ? cat : 'Другое';

      if (e['type'] == 'income') {
        inc[target] = (inc[target] ?? 0) + amt;
      } else {
        exp[target] = (exp[target] ?? 0) + amt;
      }
    }

    if (!mounted) return;
    setState(() {
      _income = inc;
      _expense = exp;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final legend = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: const Color(0xFF32D74B), label: 'Доход'),
        const SizedBox(width: 16),
        _LegendDot(color: const Color(0xFFFF453A), label: 'Расход'),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Диаграммы')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Радар: Доход vs Расход по категориям',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          RadarIncomeExpense(
                            incomeByCat: _income,
                            expenseByCat: _expense,
                            axes: _axes,
                          ),
                          const SizedBox(height: 8),
                          legend,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(3), border: Border.all(color: color))),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
