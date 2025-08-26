import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/services/finance_snapshot_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});
  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _svc = FinanceSnapshotService();

  double _score = 0.0;
  List<(DateTime day, double balance)> _series = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _svc.healthScore();
    final h = await _svc.dailyBalance(days: 30);
    if (!mounted) return;
    setState(() {
      _score = s;
      _series = h;
    });
  }

  String _advice() {
    if (_score >= 0.6) return 'Отлично! Продолжай придерживаться правил 50/30/20 и откладывай «подушку».';
    if (_score >= 0.3) return 'Неплохо. Режь 1–2 дорогие категории и зафиксируй недельный лимит.';
    return 'Нужно усилить контроль. Включи BudgetBattle и убери лишние подписки.';
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF32D74B);

    // Плейсхолдер, если нет данных — чтобы чарты не падали
    Widget _lineOrPlaceholder() {
      final s = _series;
      if (s.isEmpty) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Text('Пока нет данных для графика', style: Theme.of(context).textTheme.bodyMedium),
          ),
        );
      }

      final values = s.map((e) => e.$2).toList();
      final minVal = values.reduce((a, b) => a < b ? a : b);
      final maxVal = values.reduce((a, b) => a > b ? a : b);
      final padding = (maxVal - minVal).abs() * 0.1;
      final minY = minVal - padding;
      final maxY = maxVal + padding;

      // Интервал сетки должен быть > 0
      final range = (maxY - minY).abs();
      final interval = range > 0 ? range / 4 : 1.0;

      final step = s.length <= 1 ? 1 : (s.length / 5).ceil();

      return SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: interval, // гарантированно > 0
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: step.toDouble(), // минимум 1
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= s.length) return const SizedBox.shrink();
                    final d = s[i].$1;
                    return Text('${d.day}.${d.month}');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: const Color(0xFFB388FF),
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFB388FF).withOpacity(0.35),
                      const Color(0xFFB388FF).withOpacity(0.0),
                    ],
                  ),
                ),
                spots: [
                  for (int i = 0; i < s.length; i++) FlSpot(i.toDouble(), s[i].$2),
                ],
              ),
            ],
          ),
          // fl_chart 1.x — свойство называется duration
          duration: const Duration(milliseconds: 600),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ФинЗдоровье')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Полоска здоровья
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Индекс финансового здоровья'),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _score.clamp(0, 1),
                      minHeight: 14,
                      backgroundColor: Colors.green.withOpacity(0.15),
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${(_score * 100).round()} / 100', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(_advice()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Линейный график баланса
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Баланс по дням (30 дней)'),
                  const SizedBox(height: 8),
                  _lineOrPlaceholder(),
                  const SizedBox(height: 8),
                  const Text('Советы Airi'),
                  const SizedBox(height: 6),
                  const _Tip(text: 'Раздели траты на 3–5 ключевых категорий, чтобы видеть, что растёт.'),
                  const _Tip(text: 'Выделяй фиксированный «фан-бюджет», чтобы не срываться.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;
  const _Tip({required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 18),
        const SizedBox(width: 6),
        Expanded(child: Text(text)),
      ],
    );
  }
}
