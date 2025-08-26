import 'package:hive_flutter/hive_flutter.dart';

class PointsService {
  static const _boxName = 'points_box';

  Future<Box> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<int> total() async {
    final box = await _box();
    return (box.get('total') as int?) ?? 0;
  }

  Future<List<Map<String, dynamic>>> history() async {
    final box = await _box();
    final raw = (box.get('history') as List?) ?? const [];
    // Приводим каждый элемент к Map<String, dynamic>
    return raw.whereType<Map>().map((e) {
      return Map<String, dynamic>.from(e);
    }).toList();
  }

  Future<void> _saveHistory(List<Map<String, dynamic>> items) async {
    final box = await _box();
    await box.put('history', items);
  }

  /// Начислить баллы с причиной (reason) и количеством (amount)
  Future<int> addPoints({required String reason, required int amount}) async {
    final box = await _box();
    final current = (box.get('total') as int?) ?? 0;
    final next = current + amount;
    await box.put('total', next);

    final items = await history();
    items.insert(0, {
      'reason': reason,
      'amount': amount,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    await _saveHistory(items);
    return next;
  }
}
