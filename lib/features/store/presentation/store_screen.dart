import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/points_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _svc = PointsService();
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await _svc.total();
    if (!mounted) return;
    setState(() => _total = t);
  }

  Future<void> _buy(String title, int cost) async {
    if (_total < cost) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Недостаточно баллов')));
      return;
    }
    await _svc.spendPoints(cost, reason: 'Покупка: $title');
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Куплено: $title')));
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final items = const [
      ('Стикер-пак Airi', 120),
      ('Расширенный анализ недели', 200),
      ('Уникальная реплика Airi', 80),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Магазин')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded),
                  const SizedBox(width: 12),
                  Text('Баланс: $_total', style: th.textTheme.titleLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((e) => Card(
            child: ListTile(
              title: Text(e.$1),
              trailing: FilledButton(
                onPressed: () => _buy(e.$1, e.$2),
                child: Text('-${e.$2}'),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
