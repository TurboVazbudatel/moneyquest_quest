class PremiumReportsService {
  Future<Map<String, double>> topCategoriesExpense() async {
    return {'Еда': 3200, 'Развлечения': 1800, 'Подписки': 900};
  }

  Future<Map<String, double>> topCategoriesIncome() async {
    return {'Зарплата': 45000, 'Фриланс': 8000};
  }

  Future<List<(DateTime, double)>> incomeTrend() async {
    final now = DateTime.now();
    final out = <(DateTime, double)>[];
    for (int i = 0; i < 30; i++) {
      out.add((now.subtract(Duration(days: 29 - i)), (1200 + i * 40).toDouble()));
    }
    return out;
  }

  Future<List<(DateTime, double)>> expenseTrend() async {
    final now = DateTime.now();
    final out = <(DateTime, double)>[];
    for (int i = 0; i < 30; i++) {
      out.add((now.subtract(Duration(days: 29 - i)), (800 + (i % 7) * 55).toDouble()));
    }
    return out;
  }
}
