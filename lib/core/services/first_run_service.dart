import 'package:shared_preferences/shared_preferences.dart';

class FirstRunService {
  static const _kSeenOnboarding = 'seen_onboarding_v1';

  Future<bool> needOnboarding() async {
    final p = await SharedPreferences.getInstance();
    return !(p.getBool(_kSeenOnboarding) ?? false);
  }

  Future<void> markSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSeenOnboarding, true);
  }

  Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSeenOnboarding);
  }
}
