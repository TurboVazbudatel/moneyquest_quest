import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _kName = 'profile_name_v1';
  static const _kGuest = 'profile_is_guest_v1';
  static const _kOnboarded = 'profile_onboarded_v1';

  Future<void> setName(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, name);
  }

  Future<String?> getName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kName);
  }

  Future<void> setGuest(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kGuest, value);
  }

  Future<bool> isGuest() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kGuest) ?? true;
  }

  Future<void> setOnboarded(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOnboarded, value);
  }

  Future<bool> isOnboarded() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kOnboarded) ?? false;
  }
}
