import 'package:hive_flutter/hive_flutter.dart';

class BudgetsService {
  static const _boxName = 'budgets_box';

  Future<Box> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<void> setBudget(double amount) async {
    final box = await _box();
    await box.put('limit', amount);
  }

  Future<double> getBudget() async {
    final box = await _box();
    return (box.get('limit') as num?)?.toDouble() ?? 0.0;
  }

  Future<void> setSpent(double spent) async {
    final box = await _box();
    await box.put('spent', spent);
  }

  Future<double> getSpent() async {
    final box = await _box();
    return (box.get('spent') as num?)?.toDouble() ?? 0.0;
  }
}
