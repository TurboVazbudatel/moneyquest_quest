import 'package:hive_flutter/hive_flutter.dart';
import '../storage/hive_store.dart';

enum TxType { income, expense }

class TransactionsService {
  final Box _box = HiveStore.boxTx;

  Future<void> add({
    required double amount,
    required TxType type,
    required String category,
    DateTime? date,
    String? note,
  }) async {
    final now = date ?? DateTime.now();
    await _box.add({
      'amount': amount,
      'type': type == TxType.income ? 'income' : 'expense',
      'category': category,
      'ts': now.millisecondsSinceEpoch,
      'note': note ?? '',
    });
  }

  List<Map> all({DateTime? from, DateTime? to}) {
    final items = _box.values.whereType<Map>().toList();
    if (from == null && to == null) return items;
    final f = from?.millisecondsSinceEpoch ?? -1;
    final t = to?.millisecondsSinceEpoch ?? 9999999999999;
    return items.where((e) {
      final ts = (e['ts'] as int?) ?? 0;
      return ts >= f && ts <= t;
    }).toList();
  }

  Map<String, double> totalsByCategory({bool income = false}) {
    final res = <String,double>{};
    for (final e in _box.values.whereType<Map>()) {
      final isIncome = e['type'] == 'income';
      if (income != isIncome) continue;
      final cat = (e['category'] as String?) ?? 'Другое';
      final amt = (e['amount'] as num?)?.toDouble() ?? 0.0;
      res[cat] = (res[cat] ?? 0.0) + amt;
    }
    return res;
  }

  /// Баланс = сумма доходов - сумма расходов
  double currentBalance() {
    double inc = 0, exp = 0;
    for (final e in _box.values.whereType<Map>()) {
      final amt = (e['amount'] as num?)?.toDouble() ?? 0.0;
      if ((e['type'] as String?) == 'income') inc += amt; else exp += amt;
    }
    return inc - exp;
  }

  /// Ряд для графика "ФинЗдоровье": накопительный баланс по дням
  List<(DateTime,double)> cumulativeByDay({int days = 8}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days-1));
    final daily = <DateTime,double>{};
    for (int i=0;i<days;i++) {
      final d = DateTime(start.year, start.month, start.day).add(Duration(days: i));
      daily[d] = 0;
    }
    for (final e in _box.values.whereType<Map>()) {
      final dt = DateTime.fromMillisecondsSinceEpoch((e['ts'] as int?) ?? 0);
      final day = DateTime(dt.year, dt.month, dt.day);
      if (!daily.containsKey(day)) continue;
      final amt = (e['amount'] as num?)?.toDouble() ?? 0.0;
      daily[day] = (daily[day] ?? 0) + ((e['type'] == 'income') ? amt : -amt);
    }
    double acc = 0;
    final out = <(DateTime,double)>[];
    final keys = daily.keys.toList()..sort();
    for (final k in keys) {
      acc += daily[k] ?? 0;
      out.add((k, acc));
    }
    return out;
  }
}
