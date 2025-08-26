import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Примерные данные динамики общего бюджета (учёт доходов и расходов)
    final points = <FlSpot>[
      const FlSpot(0, 22),
      const FlSpot(1, 24),
      const FlSpot(2, 19),
      const FlSpot(3, 27),
      const FlSpot(4, 30),
      const FlSpot(5, 33),
      const FlSpot(6, 29),
      const FlSpot(7, 36),
    ];

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
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: points,
                      barWidth: 4,
                      color: const Color(0xFF34D399), // мягко-зелёный
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF34D399).withOpacity(0.28),
                      ),
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
                Text('• В этом месяце рост трат в “Подписках”. Проверь активные подписки — возможно, часть не используешь.'),
                SizedBox(height: 6),
                Text('• Если удержишь траты на текущем уровне 2 недели — дойдёшь до цели на 3 дня раньше.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
