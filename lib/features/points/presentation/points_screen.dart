import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/points_service.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});
  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  final _svc = PointsService();
  int _total = 0;
  List<Map<String, dynamic>> _hist = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await _svc.total();
    final h = await _svc.history();
    if (!mounted) return;
    setState(() { _total = t; _hist = h; });
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Баллы Airi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, size: 28),
                  const SizedBox(width: 12),
                  Text('Ваш баланс: $_total', style: th.textTheme.titleLarge),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      await _svc.addPoints(10, reason: 'Тестовое начисление');
                      await _load();
                    },
                    child: const Text('+10'),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('История', style: th.textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._hist.map((e) {
            final dt = e['when'] as DateTime;
            final what = e['what'] as String;
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(what),
              subtitle: Text('${dt.day.toString().padLeft(2,'0')}.${dt.month.toString().padLeft(2,'0')}.${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}'),
            );
          }).toList(),
        ],
      ),
    );
  }
}
