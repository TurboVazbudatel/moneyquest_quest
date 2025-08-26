import 'package:hive_flutter/hive_flutter.dart';

class AchievementsService {
  static const _boxName = 'achievements_box';

  Future<Box> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<List<String>> unlocked() async {
    final box = await _box();
    return (box.get('unlocked') as List?)?.cast<String>() ?? [];
  }

  Future<void> unlock(String id) async {
    final box = await _box();
    final current = (box.get('unlocked') as List?)?.cast<String>() ?? [];
    if (!current.contains(id)) {
      current.add(id);
      await box.put('unlocked', current);
    }
  }

  bool isUnlockedSync(String id) {
    if (!Hive.isBoxOpen(_boxName)) return false;
    final box = Hive.box(_boxName);
    final current = (box.get('unlocked') as List?)?.cast<String>() ?? [];
    return current.contains(id);
  }
}
