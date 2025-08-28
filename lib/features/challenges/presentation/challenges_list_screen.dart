import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/challenges_service.dart';

class ChallengesListScreen extends StatefulWidget {
  const ChallengesListScreen({super.key});
  @override
  State<ChallengesListScreen> createState() => _ChallengesListScreenState();
}

class _ChallengesListScreenState extends State<ChallengesListScreen> {
  final _svc = ChallengesService();
  late Future<List<(Challenge,bool)>> _load;

  @override
  void initState() {
    super.initState();
    _load = _fetch();
  }

  Future<List<(Challenge,bool)>> _fetch() async {
    final out = <(Challenge,bool)>[];
    for (final ch in ChallengesService.all) {
      final done = await _svc.isCompleted(ch.id);
      out.add((ch, done));
    }
    return out;
  }

  Future<void> _complete(Challenge ch) async {
    await _svc.complete(ch.id);
    if (!mounted) return;
    setState(() { _load = _fetch(); });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выполнено: ${ch.title} · +${ch.points} баллов')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Челленджи')),
      body: FutureBuilder<List<(Challenge,bool)>>(
        future: _load,
        builder: (context, snap) {
          final items = snap.data ?? const <(Challenge,bool)>[];
          if (items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (context, i) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final ch = items[i].$1;
              final done = items[i].$2;
              return ListTile(
                leading: CircleAvatar(child: Text(ch.points.toString())),
                title: Text(ch.title),
                subtitle: Text(ch.subtitle),
                trailing: done
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : FilledButton(
                        onPressed: () => _complete(ch),
                        child: const Text('Выполнить'),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
