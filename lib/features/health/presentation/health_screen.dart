import 'package:flutter/material.dart';
import '../../../data/services/budgets_service.dart';
import 'widgets/health_trend_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _svc = BudgetsService();
  double? _income;
  double? _expense;
  List<FlSpot> _spots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final inc = await _svc.totalIncome();
    final exp = await _svc.totalExpense();
    final trend = await _svc.cumulativeTrend(); // List<(DateTime,double)>
    // Переведём в FlSpot (x = порядковый индекс, y = накопленный баланс)
    final spots = <FlSpot>[];
    for (var i = 0; i < trend.length; i++) {
      final (_, val) = trend[i];
      spots.add(FlSpot(i.toDouble(), val));
    }
    if (!mounted) return;
    setState(() {
      _income = inc;
      _expense = exp;
      _spots = spots;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inc = _income ?? 0;
    final exp = _expense ?? 0;
    final bal = inc - exp;
    final ratio = (inc > 0) ? (bal / inc).clamp(-1.0, 1.0) : 0.0;
    final isPositive = ratio >= 0;

    String msg;
    if (ratio >= 0.3) {
      msg = 'Отличный баланс 👌. Доходы значительно превышают расходы.';
    } else if (ratio >= 0.0) {
      msg = 'Ты в плюсе, но баланс небольшой. Будь внимательнее к тратам.';
    } else {
      msg = 'Расходы превышают доходы. Совет Airi: снизь траты или увеличь доход.';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ФинЗдоровье')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Финансовое здоровье', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  // Новый плавный график с градиентом в стиле референса
                  HealthTrendChart(spots: _spots, isPositive: isPositive),
                  const SizedBox(height: 12),
                  Text(msg, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _tile(Icons.attach_money, 'Доход', inc)),
                      const SizedBox(width: 8),
                      Expanded(child: _tile(Icons.money_off, 'Расход', exp)),
                      const SizedBox(width: 8),
                      Expanded(child: _tile(Icons.account_balance, 'Баланс', bal)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _tile(IconData ic, String title, double v) {
    return Card(
      child: ListTile(
        leading: Icon(ic),
        title: Text(title),
        subtitle: Text('${v.toStringAsFixed(0)} ₽'),
      ),
    );
  }
}
