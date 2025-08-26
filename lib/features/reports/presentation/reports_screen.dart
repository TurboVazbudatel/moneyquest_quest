import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['Еда', 'Транспорт', 'Дом', 'Развлеч.', 'Подписки', 'Другое'];

    // Примерные данные (замени на реальные из хранилища)
    final incomes  = [40.0, 25.0, 20.0, 15.0, 10.0, 12.0];
    final expenses = [28.0, 18.0, 26.0, 22.0, 14.0, 16.0];

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
                  getTitle: (index, angle) => RadarChartTitle(text: categories[index]),
                  dataSets: [
                    // ДОХОД — мягко-зелёный
                    RadarDataSet(
                      dataEntries: incomes.map((v) => RadarEntry(value: v)).toList(),
                      fillColor: const Color(0xFF34D399).withOpacity(0.45),
                      borderColor: const Color(0xFF34D399),
                      entryRadius: 2,
                      borderWidth: 2,
                    ),
                    // РАСХОД — мягко-красный
                    RadarDataSet(
                      dataEntries: expenses.map((v) => RadarEntry(value: v)).toList(),
                      fillColor: const Color(0xFFF87171).withOpacity(0.45),
                      borderColor: const Color(0xFFF87171),
                      entryRadius: 2,
                      borderWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Подсказка Airi: сравни форму полигонов — там, где красный “выше” зелёного, категория трат доминирует.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
