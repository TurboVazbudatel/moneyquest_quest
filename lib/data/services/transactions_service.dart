import 'package:hive_flutter/hive_flutter.dart';

enum TxType { income, expense }

class TransactionsService {
  static const _boxName = 'tx_box';

  Future<Box> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  static const defaultIncomeCats = [
    'Зарплата','Подработки','Проценты','Подарки','Другое'
  ];
  static const defaultExpenseCats = [
    'Еда','Транспорт','Покупки','Развлечения','Коммуналка','Другое'
  ];

  Future<List<Map<String, dynamic>>> all() async {
    final box = await _box();
    final List<Map<String, dynamic>> out = [];
    for (final key in box.keys) {
      final v = box.get(key);
      if (v is! Map) continue;
      final typeStr = (v['type'] as String?) ?? '';
      if (typeStr != 'income' && typeStr != 'expense') continue;
      final amount = (v['amount'] as num?)?.toDouble();
      if (amount == null) continue;
      final category = (v['category'] as String?) ?? 'Другое';
      final dateMs = (v['date'] as num?)?.toInt() ?? 0;
      out.add({
        'key': key,
        'type': typeStr,
        'amount': amount,
        'category': category,
        'date': dateMs,
        if (v['note'] != null) 'note': v['note'],
      });
    }
    out.sort((a, b) {
      final ai = (a['date'] as int? ?? 0);
      final bi = (b['date'] as int? ?? 0);
      return bi.compareTo(ai);
    });
    return out;
  }

  Future<void> add({
    required double amount,
    required TxType type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final box = await _box();
    await box.add({
      'amount': amount,
      'type': type == TxType.income ? 'income' : 'expense',
      'category': category,
      'date': date.millisecondsSinceEpoch,
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  Future<void> update({
    required dynamic key,
    required double amount,
    required TxType type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final box = await _box();
    if (!box.containsKey(key)) return;
    await box.put(key, {
      'amount': amount,
      'type': type == TxType.income ? 'income' : 'expense',
      'category': category,
      'date': date.millisecondsSinceEpoch,
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  Future<void> remove(dynamic key) async {
    final box = await _box();
    if (box.containsKey(key)) await box.delete(key);
  }

  Future<double> currentBalance() async {
    final items = await all();
    double bal = 0;
    for (final e in items) {
      final amt = (e['amount'] as num).toDouble();
      bal += (e['type'] == 'income') ? amt : -amt;
    }
    return bal;
  }

  Future<Map<String, double>> totalsByCategory() async {
    final items = await all();
    final Map<String, double> map = {};
    for (final e in items) {
      final cat = (e['category'] as String?) ?? 'Other';
      final amt = (e['amount'] as num).toDouble();
      map[cat] = (map[cat] ?? 0) + ((e['type'] == 'income') ? amt : -amt);
    }
    return map;
  }

  Future<List<(DateTime, double)>> cumulativeByDay() async {
    final items = await all();
    items.sort((a, b) {
      final ai = (a['date'] as int? ?? 0);
      final bi = (b['date'] as int? ?? 0);
      return ai.compareTo(bi);
    });
    double sum = 0;
    final out = <(DateTime, double)>[];
    for (final e in items) {
      final ms = (e['date'] as int? ?? 0);
      final d = DateTime.fromMillisecondsSinceEpoch(ms);
      final amt = (e['amount'] as num).toDouble();
      sum += (e['type'] == 'income') ? amt : -amt;
      out.add((DateTime(d.year, d.month, d.day), sum));
    }
    return out;
  }

  /// ==== Новое: топ-N категорий ====
  Future<List<String>> recentCategories({int top = 3}) async {
    final items = await all();
    final Map<String, int> counts = {};
    for (final e in items) {
      final cat = (e['category'] as String?) ?? 'Другое';
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(top).map((e) => e.key).toList();
  }
}
