import 'package:hive_flutter/hive_flutter.dart';
import 'transactions_service.dart';
import 'achievements_service.dart';

class BudgetsService {
  static const _boxName = 'budgets_box';
  final _tx = TransactionsService();
  final _ach = AchievementsService();

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

  /// Проверяем: были ли 7 дней подряд без перерасхода
  Future<void> checkWeeklyAchievement() async {
    final limit = await getBudget();
    if (limit <= 0) return;

    // Берём траты за 7 последних дней
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final days = _tx.cumulativeByDay(days: 7);

    // считаем дневные траты
    bool allOk = true;
    for (final d in days) {
      final balance = d.$2;
      if (balance < -limit) {
        allOk = false;
        break;
      }
    }

    if (allOk) {
      await _ach.unlock('week_budget');
    }
  }
}
