import 'dart:math';

class FinanceSnapshotService {
  Future<List<(DateTime, double)>> cumulativeByDay({int days = 30}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
    final out = <(DateTime, double)>[];
    double acc = 0.0;
    for (int i = 0; i < days; i++) {
      final d = DateTime(start.year, start.month, start.day).add(Duration(days: i));
      acc += 0.0;
      out.add((d, acc));
    }
    return out;
  }

  Future<Map<String, double>> totalsByCategory({required bool income}) async {
    return <String, double>{};
  }

  Future<(double, double)> totalsIncomeExpense() async {
    return (0.0, 0.0);
  }

  Future<List<(String, double)>> radarIncome() async {
    return <(String, double)>[];
  }

  Future<List<(String, double)>> radarExpense() async {
    return <(String, double)>[];
  }
}
