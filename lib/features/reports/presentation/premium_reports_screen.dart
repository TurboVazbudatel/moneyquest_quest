import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moneyquest_quest/data/services/premium_reports_service.dart';
import 'package:moneyquest_quest/data/services/subscription_service.dart';
import 'package:moneyquest_quest/features/subscription/presentation/subscription_screen.dart';

class PremiumReportsScreen extends StatefulWidget {
  const PremiumReportsScreen({super.key});
  @override
  State<PremiumReportsScreen> createState() => _PremiumReportsScreenState();
}

class _PremiumReportsScreenState extends State<PremiumReportsScreen> {
  final _svc = PremiumReportsService();
  final _sub = SubscriptionService();
  bool _loading = true;
  bool _premium = false;

  Map<String, double> _exp = {};
  Map<String, double> _inc = {};
  List<(DateTime, double)> _trendInc = [];
  List<(DateTime, double)> _trendExp = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final pro = await _sub.isPremium();
    if (!pro) {
      if (!mounted) return;
      setState(() {
        _premium = false;
        _loading = false;
      });
      return;
    }
    final e = await _svc.topCategoriesExpense();
    final i = await _svc.topCategoriesIncome();
    final ti = await _svc.incomeTrend();
    final te = await _svc.expenseTrend();
    if (!mounted) return;
    setState(() {
      _premium = true;
      _exp = e;
      _inc = i;
      _trendInc = ti;
      _trendExp = te;
      _loading = false;
    });
  }

  Widget _legend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendDot(color: Color(0xFF32D74B), label: 'Доход'),
        SizedBox(width: 16),
        _LegendDot(color: Color(0xFFEA5A5A), label: 'Расход'),
      ],
    );
  }

  Widget _lineChart(BuildContext context) {
    final maxLen = (_trendInc.length > _trendExp.length ? _trendInc.length : _trendExp.length).toDouble();
    final maxY = [
      ..._trendInc.map((e) => e.$2),
      ..._trendExp.map((e) => e.$2)
    ].fold<double>(0, (p, n) => n > p ? n : p);
    final minY = 0.0;
    final xsInc = List.generate(_trendInc.length, (i) => FlSpot(i.toDouble(), _trendInc[i].$2));
    final xsExp = List.generate(_trendExp.length, (i) => FlSpot(i.toDouble(), _trendExp[i].$2));
    return AspectRatio(
      aspectRatio: 1.6,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (maxLen > 0 ? maxLen - 1 : 0),
          minY: minY,
          maxY: maxY * 1.1 + 1,
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: (maxY/4).clamp(1, double.infinity)),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(enabled: true),
          lineBarsData: [
            LineChartBarData(
              spots: xsInc,
              isCurved: true,
              color: const Color(0xFF32D74B),
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: xsExp,
              isCurved: true,
              color: const Color(0xFFEA5A5A),
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_premium) {
      return Scaffold(
        appBar: AppBar(title: const Text('Premium отчёты')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Доступно только в Premium'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                child: const Text('Оформить Premium'),
              )
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Premium отчёты')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Топ категорий расходов', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ..._exp.entries.map((e) => ListTile(title: Text(e.key), trailing: Text('${e.value} ₽'))),
          const Divider(),
          const Text('Топ категорий доходов', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ..._inc.entries.map((e) => ListTile(title: Text(e.key), trailing: Text('${e.value} ₽'))),
          const Divider(),
          const Text('Динамика за месяц', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _legend(context),
          const SizedBox(height: 8),
          _lineChart(context),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
