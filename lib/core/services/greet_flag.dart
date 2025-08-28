import 'package:shared_preferences/shared_preferences.dart';

class GreetFlag {
  static const _k = 'greeted_v1';
  Future<bool> needGreet() async {
    final p = await SharedPreferences.getInstance();
    return !(p.getBool(_k) ?? false);
  }
  Future<void> markGreeted() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_k, true);
  }
}
