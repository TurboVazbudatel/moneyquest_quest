import 'package:moneyquest_quest/data/services/points_service.dart';

class AiriAdviceService {
  final PointsService _points = PointsService();

  Future<List<String>> suggestions() async {
    final pts = await _points.total();
    final tips = <String>[
      'Отмечай траты сразу — это повышает осознанность.',
      'Установи дневной лимит и держи в поле зрения.',
    ];
    if (pts < 50) {
      tips.addAll([
        'Начни с мини-цели: отложи 100 ₽ сегодня.',
        'Исключи один импульсный расход до завтра.',
      ]);
    } else if (pts < 200) {
      tips.addAll([
        'Выбери один челлендж на неделю и доведи до конца.',
        'Сформируй «подушку безопасности» 5–10% от дохода.',
      ]);
    } else {
      tips.addAll([
        'Оптимизируй 1 подписку или тариф — проверь, за что платишь.',
        'Перераспредели 10–15% трат в копилку целей.',
      ]);
    }
    return tips;
  }
}
