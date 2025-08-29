import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = const [
      ('Вы', 1240),
      ('Иван', 1180),
      ('Мария', 990),
      ('Алексей', 870),
      ('Наталья', 820),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Лидерборд')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final r = rows[i];
          final you = i == 0;
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0,4),
                )
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${i+1}'),
              ),
              title: Text(r.$1, style: you ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700) : null),
              trailing: Text('${r.$2} баллов', style: theme.textTheme.bodyLarge),
            ),
          );
        },
      ),
    );
  }
}
