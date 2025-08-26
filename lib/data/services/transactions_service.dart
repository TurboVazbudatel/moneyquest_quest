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
      if (v is Map) out.add({...v, 'key': key});
    }
    out.sort((a, b) => (b['date'] as int).compareTo(a['date'] as int));
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
    items.sort((a, b) => (a['date'] as int).compareTo(b['date'] as int));
    double sum = 0;
    final out = <(DateTime, double)>[];
    for (final e in items) {
      final d = DateTime.fromMillisecondsSinceEpoch(e['date'] as int);
      final amt = (e['amount'] as num).toDouble();
      sum += (e['type'] == 'income') ? amt : -amt;
      out.add((DateTime(d.year, d.month, d.day), sum));
    }
    return out;
  }
}
