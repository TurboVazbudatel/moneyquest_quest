import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/services/transactions_service.dart';
import '../../../data/utils/categories.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = TransactionsService();
    final incMap = svc.totalsByCategory(income: true);
    final expMap = svc.totalsByCategory(income: false);

    List<double> valuesFor(List<String> cats, Map<String,double> m) =>
      cats.map((c) => (m[c] ?? 0).toDouble()).toList();

    final incomes  = valuesFor(kCategories, incMap);
    final expenses = valuesFor(kCategories, expMap);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Диаграммы', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: 1.1,
              child: RadarChart(
                RadarChartData(
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  tickBorderData: const BorderSide(color: Color(0x33838B9C)),
                  gridBorderData: const BorderSide(color: Color(0x33838B9C)),
                  titleTextStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                  getTitle: (i, _) => RadarChartTitle(text: kCategories[i]),
                  dataSets: [
                    RadarDataSet(
                      dataEntries: incomes.map((v) => RadarEntry(value: v)).toList(),
                      fillColor: const Color(0xFF34D399).withOpacity(0.45),
                      borderColor: const Color(0xFF34D399),
                      entryRadius: 2, borderWidth: 2,
                    ),
                    RadarDataSet(
                      dataEntries: expenses.map((v) => RadarEntry(value: v)).toList(),
                      fillColor: const Color(0xFFF87171).withOpacity(0.45),
                      borderColor: const Color(0xFFF87171),
                      entryRadius: 2, borderWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Подсказка Airi: там, где красный “выше” зелёного — траты доминируют.', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
