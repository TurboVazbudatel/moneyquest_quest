import 'transactions_service.dart';

class BudgetsService {
  final TransactionsService _tx = TransactionsService();

  /// Кумулятивный тренд баланса по дням (для графиков/виджетов)
  Future<List<(DateTime day, double balance)>> cumulativeTrend() async {
    final list = await _tx.cumulativeByDay(); // без параметра days
    // приведение к именованным кортежам для удобства
    return list.map<(DateTime,double)>((e) => (e.$1, e.$2)).toList();
  }

  /// Потрачено за весь период (по модулю расходов)
  Future<double> totalExpense() async {
    final all = await _tx.all();
    double sum = 0;
    for (final e in all) {
      if (e['type'] == 'expense') sum += (e['amount'] as num).toDouble();
    }
    return sum;
  }

  /// Доход за весь период
  Future<double> totalIncome() async {
    final all = await _tx.all();
    double sum = 0;
    for (final e in all) {
      if (e['type'] == 'income') sum += (e['amount'] as num).toDouble();
    }
    return sum;
  }
}
