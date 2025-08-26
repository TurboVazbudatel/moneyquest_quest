import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Добро пожаловать в MoneyQuest!', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'Добавляй расходы/доходы, смотри диаграммы и следи за ФинЗдоровьем. '
          'Airi скоро подсказжет умные советы 😉',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline),
                const SizedBox(width: 12),
                Expanded(child: Text('Подсказка: внизу есть вкладки Диаграммы и ФинЗдоровье — это иконки без текстов.')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
