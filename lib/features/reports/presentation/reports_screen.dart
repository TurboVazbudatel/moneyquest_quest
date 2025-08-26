import 'package:flutter/material.dart';
import 'widgets/radar_income_expense.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Диаграммы')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          RadarIncomeExpense(),
        ],
      ),
    );
  }
}
