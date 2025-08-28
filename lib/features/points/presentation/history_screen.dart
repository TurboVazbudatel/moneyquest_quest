import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyquest_quest/data/services/points_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = PointsService();
    final df = DateFormat('dd.MM.yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('История баллов')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: svc.history(),
        builder: (context, snap) {
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('Пока нет начислений'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, i) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final it = items[i];
              final ts = DateTime.tryParse('${it['ts']}');
              final date = ts != null ? df.format(ts) : '';
              final reason = '${it['reason'] ?? 'Начисление'}';
              final amount = it['amount'] ?? 0;
              final total = it['total'] ?? 0;
              return ListTile(
                leading: CircleAvatar(child: Text(amount.toString())),
                title: Text(reason),
                subtitle: Text(date),
                trailing: Text('Всего: $total'),
              );
            },
          );
        },
      ),
    );
  }
}
