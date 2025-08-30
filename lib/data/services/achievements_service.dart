import 'package:shared_preferences/shared_preferences.dart';
import 'points_service.dart';

class Achievement {
  final String key;
  final String title;
  final String desc;
  final int reward;
  const Achievement(this.key, this.title, this.desc, this.reward);
}

class AchievementsService {
  static const _kDonePrefix = 'ach_done_';
  final List<Achievement> items = const [
        Achievement('goal_reached', 'Цель достигнута', 'Достигни целевую сумму', 120),
Achievement('first_tx', 'Первый шаг', 'Добавь первую транзакцию', 50),
    Achievement('first_budget', 'Планировщик', 'Создай первый бюджет', 100),
    Achievement('limit_week', 'Контроль', 'Заверши недельный лимит', 150),
  ];

  Future<bool> isUnlocked(String key) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('$_kDonePrefix$key') ?? false;
  }

  Future<void> unlock(String key, int reward, String reason) async {
    final p = await SharedPreferences.getInstance();
    if (await isUnlocked(key)) return;
    await p.setBool('$_kDonePrefix$key', true);
    await PointsService().awardOnce('ach_'+key, reward, reason: reason);
  }
}
