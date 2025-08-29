import 'dart:math';

class AiriAdviceService {
  Future<String> advice({required double income, required double expense, double goal = 0}) async {
    final bal = income - expense;
    if (income <= 0 && expense <= 0) return 'Начни с малого: запиши первый доход и одну трату.';
    if (income > 0 && expense == 0) return 'Отличный старт! Добавь категории трат, чтобы видеть картину.';
    if (bal < 0) return 'Расходы выше дохода. Выбери 1–2 категории для сокращения на 10%.';
    final saveRate = income == 0 ? 0 : (bal / income);
    if (saveRate < 0.1) return 'Откладывай 10% автоматически: настрой цель и регулярный перевод.';
    if (goal > 0 && bal > 0 && bal < goal / 6) return 'Хороший темп, но медленно к цели. Увеличь вклад на 5%.';
    final tips = [
      'Проверь подписки: отмени те, что не радуют.',
      'Определи лимит на «кафе» на неделю.',
      'Добавь категорию «непредвиденные» 5% от дохода.',
      'Сделай «неделю без покупок» ради челленджа.',
    ];
    return tips[Random().nextInt(tips.length)];
  }
}
