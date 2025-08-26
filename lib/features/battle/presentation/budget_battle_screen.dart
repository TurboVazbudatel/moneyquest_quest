import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/services/challenges_service.dart';
import '../../../data/services/transactions_service.dart';
import 'package:share_plus/share_plus.dart';

class BudgetBattleScreen extends StatefulWidget {
  const BudgetBattleScreen({super.key});

  @override
  State<BudgetBattleScreen> createState() => _BudgetBattleScreenState();
}

class _BudgetBattleScreenState extends State<BudgetBattleScreen> {
  final _svc = ChallengesService();
  final _tx = TransactionsService();

  final _ctrl = TextEditingController(text: '500'); // дефолтный дневной лимит
  Timer? _timer;

  BattleStatus _status = BattleStatus.idle;
  double _limit = 0;
  double _spent = 0;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _tick() async {
    await _svc.completeIfNeeded();
    await _refresh();
  }

  Future<void> _refresh() async {
    final st = await _svc.status();
    final lim = await _svc.limit();
    final sp = await _svc.spentSinceStart();
    final tl = await _svc.timeLeft();
    if (!mounted) return;
    setState(() {
      _status = st;
      _limit = lim;
      _spent = sp;
      _left = tl;
    });
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  Future<void> _start() async {
    final lim = double.tryParse(_ctrl.text.replaceAll(',', '.')) ?? 0;
    if (lim <= 0) return;
    await _svc.startBattle(dailyLimit: lim, hours: 24);
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Челлендж запущен: лимит ${lim.toStringAsFixed(2)} ₽ на 24ч')),
    );
  }

  Future<void> _reset() async {
    await _svc.resetBattle();
    await _refresh();
  }

  Future<void> _shareResult() async {
    final ok = _status == BattleStatus.finishedWin;
    final text = ok
        ? 'Я прошёл BudgetBattle! 🏆 Уложился в лимит ${_limit.toStringAsFixed(0)} ₽ за 24 часа. #MoneyQuest'
        : 'Я участвовал в BudgetBattle. В следующий раз точно уложусь! #MoneyQuest';
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final running = _status == BattleStatus.running;
    final finished = _status == BattleStatus.finishedWin || _status == BattleStatus.finishedFail;
    final over = _limit > 0 && _spent > _limit;
    final progress = _limit > 0 ? (_spent / _limit).clamp(0.0, 1.0) as double : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('BudgetBattle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!running && !finished)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Запусти свой челлендж на 24 часа'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ctrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Дневной лимит (₽)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _start,
                      icon: const Icon(Icons.sports_esports_outlined),
                      label: const Text('Старт'),
                    ),
                  ],
                ),
              ),
            ),
          if (running || finished)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(running ? 'Челлендж активен' : (_status == BattleStatus.finishedWin ? 'Победа! 🏆' : 'Увы, лимит превышен')),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined),
                        const SizedBox(width: 8),
                        Text('Осталось: ${_fmt(_left)}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade300,
                      color: over ? Colors.red : Colors.green,
                    ),
                    const SizedBox(height: 8),
                    Text('Потрачено за челлендж: ${_spent.toStringAsFixed(2)} ₽ из ${_limit.toStringAsFixed(2)} ₽'),
                    if (over)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Airi: Лимит превышен — попробуй завтра ещё раз!'),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Сбросить'),
                        ),
                        const SizedBox(width: 12),
                        if (finished)
                          OutlinedButton.icon(
                            onPressed: _shareResult,
                            icon: const Icon(Icons.share),
                            label: const Text('Поделиться'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Совет Airi'),
              subtitle: Text('Планируй покупки заранее — импульсивные траты чаще всего рушат челлендж.'),
            ),
          ),
        ],
      ),
    );
  }
}
