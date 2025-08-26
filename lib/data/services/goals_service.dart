import 'package:hive_flutter/hive_flutter.dart';

class GoalsService {
  static const _boxName = 'goals_box';

  Future<Box> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<void> setGoal(double amount) async {
    final box = await _box();
    await box.put('goal', amount);
  }

  Future<double> getGoal() async {
    final box = await _box();
    return (box.get('goal') as num?)?.toDouble() ?? 0.0;
  }

  Future<void> setProgress(double current) async {
    final box = await _box();
    await box.put('progress', current);
  }

  Future<double> getProgress() async {
    final box = await _box();
    return (box.get('progress') as num?)?.toDouble() ?? 0.0;
  }
}
