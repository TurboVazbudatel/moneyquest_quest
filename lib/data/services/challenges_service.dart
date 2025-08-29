import 'package:shared_preferences/shared_preferences.dart';
import 'points_service.dart';
import 'package:moneyquest_quest/features/challenges/domain/challenge.dart';

enum ChallengeStatus { idle, active, completed }

class ChallengesService {
  static const _kActiveKey = 'ch_active_v1';
  static const _kActiveLimit = 'ch_active_limit_v1';
  static const _kActiveStartedAt = 'ch_active_started_v1';
  static const _kCompletedPrefix = 'ch_done_';

  final List<Challenge> _all = const [
    Challenge(
      key: 'first_tx',
      title: 'Первая транзакция',
      description: 'Добавь первую запись и получи награду',
      reward: 50,
    ),
    Challenge(
      key: 'first_budget',
      title: 'Первый бюджет',
      description: 'Создай бюджет и получи награду',
      reward: 100,
    ),
    Challenge(
      key: 'limit_week',
      title: 'Лимит на неделю',
      description: 'Потрать меньше лимита за 7 дней',
      reward: 150,
    ),
  ];

  List<Challenge> get all => _all;

  Future<ChallengeStatus> status(String key) async {
    final p = await SharedPreferences.getInstance();
    if (p.getBool('$_kCompletedPrefix$key') ?? false) return ChallengeStatus.completed;
    final active = p.getString(_kActiveKey);
    if (active == key) return ChallengeStatus.active;
    return ChallengeStatus.idle;
  }

  Future<void> startLimitWeek({required int rubLimit}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kActiveKey, 'limit_week');
    await p.setInt(_kActiveLimit, rubLimit);
    await p.setString(_kActiveStartedAt, DateTime.now().toIso8601String());
  }

  Future<int?> activeLimit() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kActiveLimit);
  }

  Future<DateTime?> activeStartedAt() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_kActiveStartedAt);
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  Future<void> resetActive() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kActiveKey);
    await p.remove(_kActiveLimit);
    await p.remove(_kActiveStartedAt);
  }

  Future<bool> isCompleted(String key) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('$_kCompletedPrefix$key') ?? false;
  }

  Future<void> complete(String key, {int reward = 100}) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('$_kCompletedPrefix$key', true);
    await PointsService().awardOnce('$_kCompletedPrefix$key', reward, reason: 'Челлендж: $key');
    if ((p.getString(_kActiveKey) ?? '') == key) {
      await resetActive();
    }
  }
}
