import 'package:hive_flutter/hive_flutter.dart';

class ProfileService {
  static const _boxName = 'profile_box';

  Future<Box> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<void> setName(String name) async {
    final box = await _box();
    await box.put('name', name);
  }

  Future<String?> getName() async {
    final box = await _box();
    return box.get('name') as String?;
  }

  Future<void> setOnboarded(bool v) async {
    final box = await _box();
    await box.put('onboarded', v);
  }

  Future<bool> isOnboarded() async {
    final box = await _box();
    return (box.get('onboarded') as bool?) ?? false;
  }

  Future<void> setGuest(bool v) async {
    final box = await _box();
    await box.put('guest', v);
  }

  Future<bool> isGuest() async {
    final box = await _box();
    return (box.get('guest') as bool?) ?? false;
  }
}
