import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/points_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = PointsService();
    return Scaffold(
      appBar: AppBar(title: const Text('Лидерборд')),
      body: FutureBuilder<int>(
        future: svc.total(),
        builder: (context, snap) {
          final pts = snap.data ?? 0;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const CircleAvatar(child: Text('1')),
                title: const Text('Ты'),
                trailing: Text('$pts баллов'),
              ),
              const Divider(),
              const ListTile(
                leading: CircleAvatar(child: Text('2')),
                title: Text('Alex'),
                trailing: Text('1200'),
              ),
              const ListTile(
                leading: CircleAvatar(child: Text('3')),
                title: Text('Mia'),
                trailing: Text('980'),
              ),
            ],
          );
        },
      ),
    );
  }
}
