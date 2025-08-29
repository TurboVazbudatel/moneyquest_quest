import 'package:shared_preferences/shared_preferences.dart';

class PointsService {
  static const _kTotal = 'points_total_v1';
  static const _kHistoryWhen = 'points_hist_when_v1';
  static const _kHistoryWhat = 'points_hist_what_v1';
  static const _kClaimed = 'points_claimed_keys_v1';

  Future<int> total() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kTotal) ?? 0;
  }

  Future<List<Map<String, dynamic>>> history() async {
    final p = await SharedPreferences.getInstance();
    final when = p.getStringList(_kHistoryWhen) ?? const [];
    final what = p.getStringList(_kHistoryWhat) ?? const [];
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < when.length && i < what.length; i++) {
      out.add({'when': DateTime.tryParse(when[i]) ?? DateTime.now(), 'what': what[i]});
    }
    return out.reversed.toList();
  }

  Future<int> addPoints(int amount, {required String reason}) async {
    final p = await SharedPreferences.getInstance();
    final cur = p.getInt(_kTotal) ?? 0;
    final next = cur + amount;
    await p.setInt(_kTotal, next);
    final when = p.getStringList(_kHistoryWhen) ?? <String>[];
    final what = p.getStringList(_kHistoryWhat) ?? <String>[];
    when.add(DateTime.now().toIso8601String());
    what.add('+$amount: $reason');
    await p.setStringList(_kHistoryWhen, when);
    await p.setStringList(_kHistoryWhat, what);
    return next;
  }

  Future<Set<String>> claimed() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_kClaimed) ?? const <String>[]).toSet();
  }

  Future<void> markClaimed(String key) async {
    final p = await SharedPreferences.getInstance();
    final s = (p.getStringList(_kClaimed) ?? const <String>[]).toSet();
    s.add(key);
    await p.setStringList(_kClaimed, s.toList());
  }
}
