import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'transactions_service.dart';

enum BattleStatus { idle, running, finishedWin, finishedFail }

class ChallengesService {
  static const _box = 'challenge_box';
  final _tx = TransactionsService();

  Future<Box> _open() async {
    if (!Hive.isBoxOpen(_box)) {
      await Hive.openBox(_box);
    }
    return Hive.box(_box);
  }

  Future<BattleStatus> status() async {
    final b = await _open();
    final startMs = (b.get('start') as int?);
    if (startMs == null) return BattleStatus.idle;
    final limit = (b.get('limit') as num?)?.toDouble() ?? 0;
    final hours = (b.get('hours') as int?) ?? 24;
    final start = DateTime.fromMillisecondsSinceEpoch(startMs);
    final end = start.add(Duration(hours: hours));
    final now = DateTime.now();
    if (now.isBefore(end)) {
      // идёт
      final spent = await spentSinceStart();
      return spent > limit ? BattleStatus.finishedFail : BattleStatus.running;
    } else {
      // закончился
      final spent = await spentSinceStart();
      return spent <= limit ? BattleStatus.finishedWin : BattleStatus.finishedFail;
    }
  }

  Future<void> startBattle({required double dailyLimit, int hours = 24}) async {
    final b = await _open();
    await b.put('start', DateTime.now().millisecondsSinceEpoch);
    await b.put('limit', dailyLimit);
    await b.put('hours', hours);
  }

  Future<void> resetBattle() async {
    final b = await _open();
    await b.delete('start');
    await b.delete('limit');
    await b.delete('hours');
  }

  Future<double> limit() async {
    final b = await _open();
    return (b.get('limit') as num?)?.toDouble() ?? 0.0;
  }

  Future<Duration> timeLeft() async {
    final b = await _open();
    final startMs = (b.get('start') as int?);
    final hours = (b.get('hours') as int?) ?? 24;
    if (startMs == null) return Duration.zero;
    final start = DateTime.fromMillisecondsSinceEpoch(startMs);
    final end = start.add(Duration(hours: hours));
    final left = end.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  Future<double> spentSinceStart() async {
    final b = await _open();
    final startMs = (b.get('start') as int?);
    if (startMs == null) return 0.0;
    final start = DateTime.fromMillisecondsSinceEpoch(startMs);

    final items = await _tx.all();
    double sum = 0;
    for (final e in items) {
      final dt = DateTime.fromMillisecondsSinceEpoch(e['date'] as int);
      if (dt.isBefore(start)) continue;
      if (e['type'] == 'expense') sum += (e['amount'] as num).toDouble();
    }
    return sum;
  }

  /// Если время вышло — ничего не делаем (статус сам вычисляется),
  /// функция оставлена для совместимости с прежним кодом.
  Future<void> completeIfNeeded() async {}
}
