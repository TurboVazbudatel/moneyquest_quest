import 'package:flutter/material.dart';
import '../../../data/services/achievements_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _svc = AchievementsService();
  List<String> _unlocked = [];

  final _all = const [
    {'id': 'first_tx', 'title': 'Первая транзакция', 'icon': Icons.add_card},
    {'id': 'goal_reached', 'title': 'Достигнута цель', 'icon': Icons.flag},
    {'id': 'week_budget', 'title': 'Неделя без перерасхода', 'icon': Icons.check_circle},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await _svc.unlocked();
    if (!mounted) return;
    setState(() => _unlocked = u);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Достижения')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: _all.map((a) {
          final id = a['id'] as String;
          final unlocked = _unlocked.contains(id);
          return Card(
            color: unlocked ? Colors.green.shade100 : Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(a['icon'] as IconData, size: 48, color: unlocked ? Colors.green : Colors.grey),
                const SizedBox(height: 8),
                Text(a['title'] as String, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(unlocked ? 'Открыто' : 'Закрыто',
                    style: TextStyle(color: unlocked ? Colors.green : Colors.grey)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
