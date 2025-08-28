import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moneyquest_quest/data/services/points_service.dart';

class Challenge {
  final String id;
  final String title;
  final String subtitle;
  final int points;
  const Challenge(this.id, this.title, this.subtitle, this.points);
}

class ChallengesService {
  static const _kDone = 'challenges_v1_done';

  static const List<Challenge> all = [
    Challenge('save_500_week', 'Сохрани 500 ₽ за неделю', 'Отложи по 70–80 ₽ в день', 50),
    Challenge('no_coffee_3d', 'Без кофе на вынос (3 дня)', 'Экономим на импульсных тратах', 30),
    Challenge('track_7d', 'Веди учёт 7 дней', 'Заносить доходы/траты ежедневно', 70),
    Challenge('cook_home', 'Готовим дома 3 дня', 'Без доставки', 40),
    Challenge('walk_free', 'Бесплатный досуг', 'День без покупок', 25),
  ];

  Future<Set<String>> _done() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kDone);
    if (raw == null) return <String>{};
    return (jsonDecode(raw) as List).cast<String>().toSet();
    }

  Future<bool> isCompleted(String id) async => (await _done()).contains(id);

  Future<void> complete(String id, {String? reason}) async {
    final p = await SharedPreferences.getInstance();
    final d = await _done();
    if (d.contains(id)) return;
    d.add(id);
    await p.setString(_kDone, jsonEncode(d.toList()));
    final ch = all.firstWhere((e) => e.id == id, orElse: () => const Challenge('custom','Челлендж','',10));
    await PointsService().addPoints(ch.points, reason: reason ?? ch.title);
  }
}
