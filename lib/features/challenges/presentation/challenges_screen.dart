import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/points_service.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});
  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final _svc = PointsService();
  final _items = const [
    _Ch('add_first_tx', 'Первый шаг', 'Добавить первую транзакцию', 50),
    _Ch('create_budget', 'Планировщик', 'Создать первый бюджет', 100),
    _Ch('set_limit_week', 'Контроль', 'Задать недельный лимит', 120),
    _Ch('open_reports_7', 'Аналитик', 'Открывать отчёты 7 дней подряд', 150),
  ];
  Set<String> _claimed = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _claimed = await _svc.claimed();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _claim(_Ch ch) async {
    if (_claimed.contains(ch.key)) return;
    await _svc.addPoints(ch.points, reason: ch.title);
    await _svc.markClaimed(ch.key);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+${ch.points} за «${ch.title}»')));
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Челленджи')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final ch = _items[i];
          final done = _claimed.contains(ch.key);
          return Container(
            decoration: BoxDecoration(
              color: done ? th.colorScheme.primaryContainer : th.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Icon(done ? Icons.check_circle : Icons.flag_outlined,
                color: done ? th.colorScheme.primary : th.colorScheme.onSurfaceVariant),
              title: Text(ch.title, style: th.textTheme.titleMedium),
              subtitle: Text(ch.desc),
              trailing: done
                  ? const Icon(Icons.done_all)
                  : FilledButton(
                      onPressed: () => _claim(ch),
                      child: Text('+${ch.points}'),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _Ch {
  final String key;
  final String title;
  final String desc;
  final int points;
  const _Ch(this.key, this.title, this.desc, this.points);
}
