import 'package:hive_flutter/hive_flutter.dart';
import 'transactions_service.dart';

/// Period: 'month' или 'week'
class Budget {
  final dynamic key; // hive key
  final String category;
  final double limit;
  final String period; // month | week
  final int createdMs;

  Budget({
    this.key,
    required this.category,
    required this.limit,
    required this.period,
    required this.createdMs,
  });

  Budget copyWith({dynamic key, String? category, double? limit, String? period, int? createdMs}) {
    return Budget(
      key: key ?? this.key,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      period: period ?? this.period,
      createdMs: createdMs ?? this.createdMs,
    );
  }

  Map<String, dynamic> toMap() => {
        'category': category,
        'limit': limit,
        'period': period,
        'createdMs': createdMs,
      };

  static Budget fromMap(dynamic key, Map map) => Budget(
        key: key,
        category: (map['category'] as String?) ?? 'Другое',
        limit: (map['limit'] as num?)?.toDouble() ?? 0.0,
        period: (map['period'] as String?) == 'week' ? 'week' : 'month',
        createdMs: (map['createdMs'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      );
}

class BudgetsService {
  static const _boxName = 'budgets_box';
  final _tx = TransactionsService();

  Future<Box> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  /// CRUD
  Future<List<Budget>> all() async {
    final box = await _box();
    final out = <Budget>[];
    for (final k in box.keys) {
      final v = box.get(k);
      if (v is Map) out.add(Budget.fromMap(k, v));
    }
    // Последние сверху
    out.sort((a, b) => b.createdMs.compareTo(a.createdMs));
    return out;
  }

  Future<void> add({required String category, required double limit, required String period}) async {
    final box = await _box();
    await box.add({
      'category': category,
      'limit': limit,
      'period': (period == 'week') ? 'week' : 'month',
      'createdMs': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> update(Budget b) async {
    final box = await _box();
    if (b.key != null && box.containsKey(b.key)) {
      await box.put(b.key, b.toMap());
    }
  }

  Future<void> remove(dynamic key) async {
    final box = await _box();
    if (box.containsKey(key)) await box.delete(key);
  }

  /// Периодические границы для текущего периода
  (DateTime start, DateTime end) _periodRange(String period) {
    final now = DateTime.now();
    if (period == 'week') {
      final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      final end = start.add(const Duration(days: 7));
      return (start, end);
    }
    // month (по умолчанию)
    final start = DateTime(now.year, now.month, 1);
    final nextMonth = (now.month == 12) ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
    return (start, nextMonth);
  }

  /// Потрачено по категории в пределах периода
  Future<double> spentFor(Budget b) async {
    final (start, end) = _periodRange(b.period);
    final items = await _tx.all();
    double sum = 0;
    for (final e in items) {
      if (e['type'] != 'expense') continue;
      if ((e['category'] as String?) != b.category) continue;
      final ms = (e['date'] as int?) ?? 0;
      final d = DateTime.fromMillisecondsSinceEpoch(ms);
      if (d.isBefore(start) || !d.isBefore(end)) continue;
      sum += (e['amount'] as num).toDouble();
    }
    return sum;
  }

  /// Прогресс: 0..1 (может быть >1 если лимит превышен)
  Future<double> progress(Budget b) async {
    final spent = await spentFor(b);
    if (b.limit <= 0) return 0;
    return spent / b.limit;
  }

  /// --- Метрики из предыдущего шага (оставлены для совместимости) ---
  Future<List<(DateTime, double)>> cumulativeTrend() async {
    final items = await _tx.cumulativeByDay();
    return items;
  }

  Future<double> totalExpense() async {
    final all = await _tx.all();
    double sum = 0;
    for (final e in all) {
      if (e['type'] == 'expense') sum += (e['amount'] as num).toDouble();
    }
    return sum;
  }

  Future<double> totalIncome() async {
    final all = await _tx.all();
    double sum = 0;
    for (final e in all) {
      if (e['type'] == 'income') sum += (e['amount'] as num).toDouble();
    }
    return sum;
  }
}
