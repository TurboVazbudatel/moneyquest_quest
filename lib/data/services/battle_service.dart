import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum BattleStatus { idle, running, finishedWin, finishedFail }

class BattleService {
  static const _kBattle = 'battle_v1';

  Future<BattleStatus> status() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kBattle);
    if (raw == null) return BattleStatus.idle;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final end = DateTime.tryParse(data['end'] ?? '');
    if (end == null) return BattleStatus.idle;
    if (DateTime.now().isAfter(end)) return BattleStatus.finishedFail;
    return BattleStatus.running;
  }

  Future<int> limit() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kBattle);
    if (raw == null) return 0;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['limit'] as int?) ?? 0;
  }

  Future<int> spentSinceStart() async {
    return 0;
  }

  Future<Duration> timeLeft() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kBattle);
    if (raw == null) return Duration.zero;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final end = DateTime.tryParse(data['end'] ?? '');
    if (end == null) return Duration.zero;
    final d = end.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  Future<void> startBattle({required int dailyLimit, required int hours}) async {
    final p = await SharedPreferences.getInstance();
    final end = DateTime.now().add(Duration(hours: hours));
    final data = {
      'limit': dailyLimit,
      'end': end.toIso8601String(),
    };
    await p.setString(_kBattle, jsonEncode(data));
  }

  Future<void> resetBattle() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kBattle);
  }

  Future<void> completeIfNeeded() async {
    return;
  }
}
