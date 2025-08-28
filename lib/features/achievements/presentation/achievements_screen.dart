import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/points_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = PointsService();
    return Scaffold(
      appBar: AppBar(title: const Text('Достижения')),
      body: FutureBuilder<int>(
        future: svc.total(),
        builder: (context, snap) {
          final pts = snap.data ?? 0;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Твои баллы: $pts', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              const ListTile(
                leading: Icon(Icons.emoji_events_rounded),
                title: Text('Первая кровь'),
                subtitle: Text('Заработай первые 50 баллов'),
              ),
              const ListTile(
                leading: Icon(Icons.local_fire_department_rounded),
                title: Text('Серия'),
                subtitle: Text('Выполняй челленджи 7 дней подряд'),
              ),
            ],
          );
        },
      ),
    );
  }
}
