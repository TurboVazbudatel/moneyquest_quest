import 'package:flutter/material.dart';
import '../../../data/services/transactions_service.dart';
import 'widgets/radar_income_expense.dart';

enum ReportPeriod { day, week, month }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _svc = TransactionsService();
  Map<String, double> _income = {};
  Map<String, double> _expense = {};
  late List<String> _axes; // порядок осей
  bool _loading = true;
  ReportPeriod _period = ReportPeriod.month;

  @override
  void initState() {
    super.initState();
    // БАЗА: объединяем стандартные доходные и расходные категории
    final axesSet = <String>{
      ...TransactionsService.defaultIncomeCats,
      ...TransactionsService.defaultExpenseCats,
    };
    _axes = axesSet.toList();
    _load();
  }

  DateTimeRange _rangeFor(ReportPeriod p) {
    final now = DateTime.now();
    if (p == ReportPeriod.day) {
      final start = DateTime(now.year, now.month, now.day);
      return DateTimeRange(start: start, end: start.add(const Duration(days: 1)));
    } else if (p == ReportPeriod.week) {
      final start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      return DateTimeRange(start: start, end: start.add(const Duration(days: 7)));
    } else {
      final start = DateTime(now.year, now.month, 1);
      final nextMonth = (now.month == 12)
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month + 1, 1);
      return DateTimeRange(start: start, end: nextMonth);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final range = _rangeFor(_period);
    final items = await _svc.all();

    final inc = <String, double>{};
    final exp = <String, double>{};

    // инициализируем нулями всё, что есть в _axes
    for (final c in _axes) {
      inc[c] = 0;
      exp[c] = 0;
    }

    // собираем данные и ДОБАВЛЯЕМ НОВЫЕ КАТЕГОРИИ В ОСИ
    for (final e in items) {
      final cat = (e['category'] as String?)?.trim();
      if (cat == null || cat.isEmpty) continue;

      final amt = (e['amount'] as num?)?.toDouble() ?? 0;
      final ms = (e['date'] as int?) ?? 0;
      final d = DateTime.fromMillisecondsSinceEpoch(ms);
      if (d.isBefore(range.start) || !d.isBefore(range.end)) continue;

      // динамически добавляем невиданные категории
      if (!_axes.contains(cat)) {
        _axes.add(cat);
        inc[cat] = 0;
        exp[cat] = 0;
      }

      if ((e['type'] as String?) == 'income') {
        inc[cat] = (inc[cat] ?? 0) + amt;
      } else {
        exp[cat] = (exp[cat] ?? 0) + amt;
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
      children: const [
        _LegendDot(color: Color(0xFF32D74B), label: 'Доход'),
        SizedBox(width: 16),
        _LegendDot(color: Color(0xFFFF6B6B), label: 'Расход'),
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
                  // Переключатель периода
                  Center(
                    child: SegmentedButton<ReportPeriod>(
                      segments: const [
                        ButtonSegment(value: ReportPeriod.day, label: Text('Сегодня')),
                        ButtonSegment(value: ReportPeriod.week, label: Text('Неделя')),
                        ButtonSegment(value: ReportPeriod.month, label: Text('Месяц')),
                      ],
                      selected: {_period},
                      onSelectionChanged: (s) {
                        setState(() => _period = s.first);
                        _load();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
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
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
