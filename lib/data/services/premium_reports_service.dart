class PremiumReportsService {
  Future<Map<String, double>> topCategoriesExpense() async {
    // TODO: связать с транзакциями
    return {
      'Еда': 3200,
      'Развлечения': 1800,
      'Подписки': 900,
    };
  }

  Future<Map<String, double>> topCategoriesIncome() async {
    return {
      'Зарплата': 45000,
      'Фриланс': 8000,
    };
  }

  Future<List<(DateTime, double)>> monthlyTrend() async {
    final now = DateTime.now();
    final out = <(DateTime, double)>[];
    for (int i = 0; i < 30; i++) {
      out.add((now.subtract(Duration(days: 29 - i)), (1000 + i * 50).toDouble()));
    }
    return out;
  }
}
