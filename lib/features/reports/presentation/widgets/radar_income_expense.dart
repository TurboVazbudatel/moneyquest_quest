import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../data/services/finance_snapshot_service.dart';

class RadarIncomeExpense extends StatelessWidget {
  const RadarIncomeExpense({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String,(double income,double expense)>>(
      future: FinanceSnapshotService().byCategory(),
      builder: (ctx, snap) {
        final data = snap.data ?? {};
        if (data.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 240,
                child: Center(
                  child: Text('Пока недостаточно данных для радара',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
            ),
          );
        }

        final labels = data.keys.toList();
        final maxVal = data.values.fold<double>(
          0.0,
          (m, e) => [m, e.$1, e.$2].reduce((a, b) => a > b ? a : b),
        );
        final double Function(double) norm =
            (v) => maxVal <= 0 ? 0.0 : (v / maxVal).clamp(0.0, 1.0).toDouble();

        final income = labels.map((k) => RadarEntry(value: norm(data[k]?.$1 ?? 0.0))).toList();
        final expense = labels.map((k) => RadarEntry(value: norm(data[k]?.$2 ?? 0.0))).toList();

        // Если все нули — показываем плейсхолдер
        final allZero = income.every((e) => e.value == 0) && expense.every((e) => e.value == 0);
        if (allZero) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 240,
                child: Center(
                  child: Text('Пока недостаточно данных для радара',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.radar),
                    const SizedBox(width: 8),
                    Text('Диаграмма: доходы vs траты', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 1.2,
                  child: RadarChart(
                    RadarChartData(
                      radarBorderData: const BorderSide(color: Colors.white24),
                      titleTextStyle: Theme.of(context).textTheme.labelSmall,
                      getTitle: (index, angle) => RadarChartTitle(text: labels[index]),
                      tickCount: 4,
                      ticksTextStyle: const TextStyle(color: Colors.transparent),
                      radarBackgroundColor: Colors.transparent,
                      dataSets: [
                        RadarDataSet(
                          fillColor: const Color(0x8832D74B), // мягко зелёный (доход)
                          borderColor: const Color(0xFF32D74B),
                          entryRadius: 1.5,
                          dataEntries: income,
                        ),
                        RadarDataSet(
                          fillColor: const Color(0x88FF453A), // мягко красный (расход)
                          borderColor: const Color(0xFFFF453A),
                          entryRadius: 1.5,
                          dataEntries: expense,
                        ),
                      ],
                      gridBorderData: const BorderSide(color: Colors.white10),
                    ),
                    duration: const Duration(milliseconds: 500),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _LegendDot(color: Color(0xFF32D74B), label: 'Доход'),
                    SizedBox(width: 16),
                    _LegendDot(color: Color(0xFFFF453A), label: 'Расход'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label),
    ]);
  }
}
