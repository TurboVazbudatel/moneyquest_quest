import 'dart:math';
import 'transactions_service.dart';
import 'budgets_service.dart';
import 'goals_service.dart';

class AiriAdviceService {
  final _tx = TransactionsService();
  final _budgets = BudgetsService();
  final _goals = GoalsService();

  /// Возвращает список коротких советов Airi по текущему состоянию
  Future<List<String>> getAdvice() async {
    final tips = <String>[];

    // 1) Баланс
    final balance = _tx.currentBalance();
    if (balance < 0) {
      tips.add('Баланс ушёл в минус. Давай на пару дней ограничим кафе и такси?');
    } else if (balance < 100) {
      tips.add('Баланс почти на нуле. Маленькие покупки сейчас имеют значение.');
    } else {
      tips.add('Баланс стабильный — так держать!');
    }

    // 2) Бюджет: лимит/траты
    final limit = await _budgets.getBudget();
    final spent = await _budgets.getSpent();
    if (limit == 0) {
      tips.add('Ты ещё не задал бюджет. Хочешь, помогу придумать лимит на месяц?');
    } else {
      final ratio = limit > 0 ? spent / limit : 0;
      if (ratio >= 1.0) {
        tips.add('Ты превысил бюджет. Посмотрим, где можно сократить траты?');
      } else if (ratio >= 0.9) {
        tips.add('Ты на финишной прямой по бюджету. Будь аккуратнее с покупками.');
      }
    }

    // 3) Цель: прогресс/мотивация
    final goal = await _goals.getGoal();
    final progress = await _goals.getProgress();
    if (goal <= 0) {
      tips.add('Давай поставим первую цель — так легче копить и радоваться прогрессу.');
    } else {
      final g = goal == 0 ? 0.0 : progress / goal;
      if (g >= 1.0) {
        tips.add('Поздравляю! Цель достигнута 🎉 Выбираем новую?');
      } else if (g >= 0.8) {
        tips.add('До цели рукой подать! Осталось совсем немного.');
      } else if (g < 0.2 && progress == 0) {
        tips.add('Начать всегда сложно. Давай отложим первую сумму сегодня?');
      }
    }

    // 4) Категория-лидер по расходам
    final expByCat = _tx.totalsByCategory(income: false);
    final totalExp = expByCat.values.fold<double>(0, (a, b) => a + b);
    if (totalExp > 0) {
      final top = expByCat.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      final share = top.value / max(0.01, totalExp);
      if (share >= 0.35) {
        tips.add('Категория "${top.key}" забирает ${ (share*100).toStringAsFixed(0)}% трат. Проверим, что там можно урезать?');
      }
    }

    // Ограничим 3–4 советами, чтобы не перегружать
    if (tips.length > 4) {
      return tips.take(4).toList();
    }
    return tips;
  }
}
