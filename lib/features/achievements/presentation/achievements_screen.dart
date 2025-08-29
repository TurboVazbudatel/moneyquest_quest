import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_Ach>[
      _Ach('Первый шаг', 'Добавь первую транзакцию', 50, true),
      _Ach('Планировщик', 'Создай первый бюджет', 100, true),
      _Ach('Контроль', 'Установи недельный лимит расходов', 120, false),
      _Ach('Подушка', 'Накопи 10% от месячного дохода', 200, false),
      _Ach('Аналитик', 'Посмотри отчёты за 7 дней подряд', 150, false),
      _Ach('Челленджер', 'Заверши 3 челленджа подряд', 250, false),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Достижения')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final a = items[i];
          final color = a.unlocked ? theme.colorScheme.primaryContainer : theme.colorScheme.surface;
          final onColor = a.unlocked ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant;
          return Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: a.unlocked ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                child: Icon(a.unlocked ? Icons.check_rounded : Icons.lock_rounded, color: a.unlocked ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant),
              ),
              title: Text(a.title, style: theme.textTheme.titleMedium?.copyWith(color: onColor, fontWeight: FontWeight.w700)),
              subtitle: Text(a.desc, style: theme.textTheme.bodyMedium?.copyWith(color: onColor)),
              trailing: Text('+${a.points}', style: theme.textTheme.titleMedium?.copyWith(color: onColor)),
            ),
          );
        },
      ),
    );
  }
}

class _Ach {
  final String title;
  final String desc;
  final int points;
  final bool unlocked;
  const _Ach(this.title, this.desc, this.points, this.unlocked);
}
