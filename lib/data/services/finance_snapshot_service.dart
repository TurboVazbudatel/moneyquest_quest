import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';

class FinanceSnapshotService {
  static const _txBox = 'tx_box'; // ожидаем формат: {amount: double, type: 'income'|'expense', category: 'Food', date: int(ms)}
  Future<Box> _box() async {
    if (!Hive.isBoxOpen(_txBox)) {
      await Hive.openBox(_txBox);
    }
    return Hive.box(_txBox);
  }

  Future<(double income, double expense)> totals() async {
    final box = await _box();
    double inc = 0, exp = 0;
    for (final e in box.values) {
      if (e is Map) {
        final a = (e['amount'] as num?)?.toDouble() ?? 0.0;
        final t = (e['type'] as String?) ?? '';
        if (t == 'income') inc += a; else if (t == 'expense') exp += a;
      }
    }
    return (inc, exp);
  }

  /// Возвращает topN категорий по расходам и доходам
  Future<Map<String, (double income, double expense)>> byCategory({int topN = 6}) async {
    final box = await _box();
    final Map<String, (double income, double expense)> acc = {};
    for (final e in box.values) {
      if (e is Map) {
        final a = (e['amount'] as num?)?.toDouble() ?? 0.0;
        final t = (e['type'] as String?) ?? '';
        final c = (e['category'] as String?) ?? 'Other';
        final cur = acc[c] ?? (0.0, 0.0);
        if (t == 'income') {
          acc[c] = (cur.$1 + a, cur.$2);
        } else if (t == 'expense') {
          acc[c] = (cur.$1, cur.$2 + a);
        }
      }
    }
    // сортируем по сумме |income|+|expense| и берём топ
    final entries = acc.entries.toList()
      ..sort((a, b) => ((b.value.$1 + b.value.$2).compareTo(a.value.$1 + a.value.$2)));
    final Map<String, (double income, double expense)> top = {};
    for (final e in entries.take(topN)) {
      top[e.key] = e.value;
    }
    // если данных мало — добьём фиктивными осями, чтобы радар был симпатичный
    final names = ['Food','Transport','Shopping','Fun','Bills','Other'];
    for (final n in names) {
      top.putIfAbsent(n, () => (0.0, 0.0));
    }
    return top;
  }

  /// Дневной баланс за N дней (до сегодня включительно)
  Future<List<(DateTime day, double balance)>> dailyBalance({int days = 30}) async {
    final box = await _box();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days-1));
    final Map<String, double> map = {}; // 'yyyy-mm-dd' -> balance
    for (int i=0;i<days;i++) {
      final d = start.add(Duration(days: i));
      map[_key(d)] = 0.0;
    }
    for (final e in box.values) {
      if (e is Map) {
        final t = (e['type'] as String?) ?? '';
        final a = (e['amount'] as num?)?.toDouble() ?? 0.0;
        final ms = (e['date'] as num?)?.toInt();
        if (ms == null) continue;
        final d = DateTime.fromMillisecondsSinceEpoch(ms);
        if (d.isBefore(start)) continue;
        final k = _key(DateTime(d.year,d.month,d.day));
        if (!map.containsKey(k)) continue;
        map[k] = (map[k] ?? 0) + (t == 'income' ? a : -a);
      }
    }
    final List<(DateTime,double)> out = [];
    map.forEach((k,v){ out.add((_parse(k), v)); });
    out.sort((a,b)=>a.$1.compareTo(b.$1));
    return out;
  }

  /// 0..1 — здоровье бюджета: чем ближе к 1, тем лучше
  Future<double> healthScore() async {
    final (inc, exp) = await totals();
    if (inc <= 0) return 0.0;
    final surplus = (inc - exp) / inc; // может быть отрицательным
    return surplus.clamp(0.0, 1.0);
  }

  String _key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  DateTime _parse(String k) {
    final p = k.split('-').map(int.parse).toList();
    return DateTime(p[0],p[1],p[2]);
  }
}
