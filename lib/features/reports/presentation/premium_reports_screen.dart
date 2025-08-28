import 'package:flutter/material.dart';
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
  List<(DateTime, double)> _trend = [];

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
    final t = await _svc.monthlyTrend();
    if (!mounted) return;
    setState(() {
      _premium = true;
      _exp = e;
      _inc = i;
      _trend = t;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
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
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                },
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
          ..._trend.map((d) => ListTile(
                title: Text('${d.$1.day}.${d.$1.month}'),
                trailing: Text('${d.$2.toStringAsFixed(0)} ₽'),
              )),
        ],
      ),
    );
  }
}
