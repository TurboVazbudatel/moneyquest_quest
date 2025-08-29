import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/challenges_service.dart';
import 'package:moneyquest_quest/features/challenges/domain/challenge.dart';

class ChallengesListScreen extends StatefulWidget {
  const ChallengesListScreen({super.key});
  @override
  State<ChallengesListScreen> createState() => _ChallengesListScreenState();
}

class _ChallengesListScreenState extends State<ChallengesListScreen> {
  final _svc = ChallengesService();
  late final List<Challenge> _items;
  final Map<String, ChallengeStatus> _statuses = {};
  int? _limitValue;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    _items = _svc.all;
    _load();
  }

  Future<void> _load() async {
    for (final ch in _items) {
      _statuses[ch.key] = await _svc.status(ch.key);
    }
    _limitValue = await _svc.activeLimit();
    _startedAt = await _svc.activeStartedAt();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startLimitWeek() async {
    final c = TextEditingController(text: '2000');
    final v = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Недельный лимит, ₽'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(int.tryParse(c.text)), child: const Text('Начать')),
        ],
      ),
    );
    if (v == null) return;
    await _svc.startLimitWeek(rubLimit: v);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Челлендж запущен')));
  }

  Future<void> _complete(String key, int reward) async {
    await _svc.complete(key, reward: reward);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Готово: +$reward баллов')));
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
          final st = _statuses[ch.key] ?? ChallengeStatus.idle;
          Widget trailing;
          if (ch.key == 'limit_week') {
            if (st == ChallengeStatus.idle) {
              trailing = FilledButton(onPressed: _startLimitWeek, child: const Text('Начать'));
            } else if (st == ChallengeStatus.active) {
              trailing = FilledButton.tonal(onPressed: () => _complete(ch.key, ch.reward), child: const Text('Сдать'));
            } else {
              trailing = const Icon(Icons.check_circle, color: Colors.green);
            }
          } else {
            trailing = Icon(st == ChallengeStatus.completed ? Icons.check_circle : Icons.info_outline,
                color: st == ChallengeStatus.completed ? Colors.green : th.colorScheme.onSurfaceVariant);
          }
          final sub = ch.key == 'limit_week' && st == ChallengeStatus.active
              ? 'Активен • лимит: ${_limitValue ?? 0} ₽ • c ${_fmtDate(_startedAt)}'
              : ch.description;
          return Container(
            decoration: BoxDecoration(
              color: th.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: th.colorScheme.primary.withOpacity(0.04), blurRadius: 10, offset: const Offset(0,4))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(ch.title, style: th.textTheme.titleMedium),
              subtitle: Text(sub),
              trailing: trailing,
            ),
          );
        },
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd.$mm.$yy';
  }
}
