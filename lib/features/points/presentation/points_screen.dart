import 'package:flutter/material.dart';
import '../../../data/services/points_service.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  final _svc = PointsService();
  int _total = 0;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await _svc.total();
    final h = await _svc.history();
    setState(() {
      _total = t;
      _items = h;
    });
  }

  Future<void> _claimTestQuest() async {
    await _svc.addPoints(reason: 'Выполнен тестовый квест', amount: 10);
    _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('+10 баллов за квест')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Баллы')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.military_tech_outlined),
              title: const Text('Текущие баллы'),
              subtitle: Text('$_total'),
              trailing: ElevatedButton.icon(
                onPressed: _claimTestQuest,
                icon: const Icon(Icons.add),
                label: const Text('Квест +10'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('История', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_items.isEmpty)
            const Text('История пуста'),
          if (_items.isNotEmpty)
            ..._items.map((e) {
              final dt = DateTime.fromMillisecondsSinceEpoch((e['ts'] as int?) ?? 0);
              final reason = (e['reason'] as String?) ?? 'Событие';
              final amount = (e['amount'] as int?) ?? 0;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.star_border),
                  title: Text(reason),
                  subtitle: Text('${dt.toLocal()}'),
                  trailing: Text('+$amount'),
                ),
              );
            }),
        ],
      ),
    );
  }
}
