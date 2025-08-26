import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/services/transactions_service.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = TransactionsService();
    final series = svc.cumulativeByDay(days: 8);
    final spots = <FlSpot>[];
    for (int i=0; i<series.length; i++) {
      spots.add(FlSpot(i.toDouble(), series[i].$2));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Финансовое здоровье', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 260,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: spots.isEmpty ? [const FlSpot(0,0)] : spots,
                      barWidth: 4,
                      color: const Color(0xFF34D399),
                      belowBarData: BarAreaData(show: true, color: Color(0xFF34D399).withOpacity(0.28)),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Рекомендации Airi', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('• Если удержишь траты на текущем уровне 2 недели — дойдёшь до цели быстрее.'),
                SizedBox(height: 6),
                Text('• Проверь подписки: часто там прячутся регулярные траты.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
