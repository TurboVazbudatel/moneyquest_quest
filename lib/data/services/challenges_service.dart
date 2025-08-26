import 'package:hive_flutter/hive_flutter.dart';
import 'transactions_service.dart';
import 'points_service.dart';
import 'achievements_service.dart';

enum BattleStatus { idle, running, finishedWin, finishedFail }

class ChallengesService {
  static const _boxName = 'battle_box';

  final _tx = TransactionsService();
  final _points = PointsService();
  final _ach = AchievementsService();

  Future<Box> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<void> startBattle({required double dailyLimit, int hours = 24}) async {
    final box = await _box();
    final now = DateTime.now();
    await box.put('status', 'running');
    await box.put('limit', dailyLimit);
    await box.put('startedAt', now.millisecondsSinceEpoch);
    await box.put('durationH', hours);
    // Снимок расходов на момент старта — чтобы считать чисто «за челлендж»
    final spentBefore = _totalExpenses();
    await box.put('spentBase', spentBefore);
  }

  Future<void> resetBattle() async {
    final box = await _box();
    await box.clear();
    await box.put('status', 'idle');
  }

  Future<BattleStatus> status() async {
    final box = await _box();
    final s = (box.get('status') as String?) ?? 'idle';
    switch (s) {
      case 'running': return BattleStatus.running;
      case 'finishedWin': return BattleStatus.finishedWin;
      case 'finishedFail': return BattleStatus.finishedFail;
      default: return BattleStatus.idle;
    }
  }

  Future<double> limit() async {
    final box = await _box();
    return (box.get('limit') as num?)?.toDouble() ?? 0.0;
  }

  Future<DateTime?> startedAt() async {
    final box = await _box();
    final ts = (box.get('startedAt') as int?);
    if (ts == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ts);
  }

  Future<int> durationHours() async {
    final box = await _box();
    return (box.get('durationH') as int?) ?? 24;
  }

  double _totalExpenses() {
    double totalExp = 0;
    for (final e in _tx.all()) {
      if (e['type'] == 'expense') {
        totalExp += (e['amount'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return totalExp;
  }

  Future<double> spentSinceStart() async {
    final box = await _box();
    final base = (box.get('spentBase') as num?)?.toDouble() ?? 0.0;
    final nowTotal = _totalExpenses();
    final delta = nowTotal - base;
    return delta < 0 ? 0.0 : delta;
  }

  Future<Duration> timeLeft() async {
    final start = await startedAt();
    final durH = await durationHours();
    if (start == null) return Duration.zero;
    final end = start.add(Duration(hours: durH));
    final left = end.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  Future<void> completeIfNeeded() async {
    final st = await status();
    if (st != BattleStatus.running) return;

    final left = await timeLeft();
    final lim = await limit();
    final spent = await spentSinceStart();

    if (left == Duration.zero) {
      final box = await _box();
      if (spent <= lim) {
        await box.put('status', 'finishedWin');
        await _points.addPoints(reason: 'BudgetBattle: победа', amount: 100);
        await _ach.unlock('battle_win');
      } else {
        await box.put('status', 'finishedFail');
      }
    }
  }
}
