import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/challenges_service.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});
  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final svc = ChallengesService();
  ChallengeStatus _limitWeekStatus = ChallengeStatus.idle;
  int? _activeLimit;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _limitWeekStatus = await svc.status('limit_week');
    _activeLimit = await svc.activeLimit();
    _startedAt = await svc.activeStartedAt();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startLimitWeek() async {
    final ctrl = TextEditingController(text: '2000');
    final ok = await showDialog<int>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Недельный лимит, ₽'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.of(c).pop(int.tryParse(ctrl.text)), child: const Text('Начать')),
        ],
      ),
    );
    if (ok == null) return;
    await svc.startLimitWeek(rubLimit: ok);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Челлендж запущен')));
  }

  Future<void> _completeLimitWeek() async {
    await svc.complete('limit_week', reward: 150);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Челлендж выполнен: +150 баллов')));
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Челленджи')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            title: 'Недельный лимит расходов',
            subtitle: _limitWeekStatus == ChallengeStatus.active
                ? 'Активен • лимит: ${_activeLimit ?? 0} ₽ • c ${_fmtDate(_startedAt)}'
                : 'Потрать не больше установленной суммы за 7 дней',
            trailing: switch (_limitWeekStatus) {
              ChallengeStatus.idle => FilledButton(onPressed: _startLimitWeek, child: const Text('Начать')),
              ChallengeStatus.active => FilledButton.tonal(onPressed: _completeLimitWeek, child: const Text('Сдать результат')),
              ChallengeStatus.completed => const Icon(Icons.check_circle, color: Colors.green),
            },
            theme: th,
          ),
          const SizedBox(height: 12),
          _tile(
            title: 'Первая транзакция',
            subtitle: 'Добавь первую запись и получи +50 баллов',
            trailing: const Icon(Icons.info_outline_rounded),
            theme: th,
          ),
          const SizedBox(height: 12),
          _tile(
            title: 'Первый бюджет',
            subtitle: 'Создай бюджет и получи +100 баллов',
            trailing: const Icon(Icons.info_outline_rounded),
            theme: th,
          ),
        ],
      ),
    );
  }

  Widget _tile({required String title, required String subtitle, required Widget trailing, required ThemeData theme}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.04), blurRadius: 10, offset: const Offset(0,4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: trailing,
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
