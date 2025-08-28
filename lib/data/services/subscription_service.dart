import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  static const _kPremium = 'premium_v1_active';
  static const _kPlan = 'premium_v1_plan';

  Future<bool> isPremium() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kPremium) ?? false;
  }

  Future<String?> currentPlan() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kPlan);
  }

  Future<void> buyMonthly() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPremium, true);
    await p.setString(_kPlan, 'monthly');
  }

  Future<void> buyYearly() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPremium, true);
    await p.setString(_kPlan, 'yearly');
  }

  Future<void> cancel() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPremium, false);
    await p.remove(_kPlan);
  }
}
