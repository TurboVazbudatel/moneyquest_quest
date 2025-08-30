import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = const [
      _Rank('Вы', 1240),
      _Rank('Иван', 1180),
      _Rank('Мария', 990),
      _Rank('Алексей', 870),
      _Rank('Наталья', 820),
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
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(
                r.name,
                style: you
                    ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
                    : null,
              ),
              trailing: Text('${r.points} баллов', style: theme.textTheme.bodyLarge),
            ),
          );
        },
      ),
    );
  }
}

class _Rank {
  final String name;
  final int points;
  const _Rank(this.name, this.points);
}
