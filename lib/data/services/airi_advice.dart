import 'transactions_service.dart';

class AiriAdvice {
  final TransactionsService tx = TransactionsService();

  /// Главный совет на базе баланса и крупнейших категорий
  Future<List<String>> tips() async {
    final balance = await tx.currentBalance();
    final byCat = await tx.totalsByCategory();

    // Найдём самую "тяжёлую" отрицательную категорию (расходы отрицательные)
    String? worstCat;
    double worstVal = 0;
    for (final e in byCat.entries) {
      if (e.value < worstVal) {
        worstVal = e.value;
        worstCat = e.key;
      }
    }

    final out = <String>[];
    if (balance < 0) {
      out.add('Баланс отрицательный. Предлагаю урезать ${worstCat ?? 'крупные расходы'} на 10–15% и задать недельный лимит.');
      out.add('Включи BudgetBattle на сутки — это поможет быстро сбить импульсивные траты.');
    } else if (balance < 5000) {
      out.add('Баланс положительный, но тонкий. Отложи 10% дохода на «подушку» и проверь платные подписки.');
    } else {
      out.add('Отличный темп! Зафиксируй правило 50/30/20 и направь часть излишка на цели.');
    }

    if (worstCat != null) {
      out.add('Самая тяжёлая категория сейчас: $worstCat. Попробуй заранее планировать покупки в этой категории.');
    }
    return out;
  }
}
