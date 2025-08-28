import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PointsService {
  static const _kTotal = 'points_v1_total';
  static const _kHist  = 'points_v1_history';

  Future<int> total() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kTotal) ?? 0;
  }

  Future<List<Map<String, dynamic>>> history() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kHist);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final List data = jsonDecode(raw);
    return data.cast<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList();
  }

  Future<int> addPoints(int amount, {String? reason}) async {
    final p = await SharedPreferences.getInstance();
    final cur = p.getInt(_kTotal) ?? 0;
    final next = (cur + amount).clamp(0, 1000000000);
    await p.setInt(_kTotal, next);

    final now = DateTime.now().toIso8601String();
    final item = {
      'ts': now,
      'reason': reason ?? 'Челлендж',
      'amount': amount,
      'total': next,
    };
    final hist = await history();
    hist.insert(0, item);
    final trimmed = hist.take(200).toList();
    await p.setString(_kHist, jsonEncode(trimmed));
    return next;
  }

  Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kTotal);
    await p.remove(_kHist);
  }
}
