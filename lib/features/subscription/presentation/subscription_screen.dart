import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _svc = SubscriptionService();
  bool _loading = true;
  bool _active = false;
  String? _plan;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final a = await _svc.isPremium();
    final p = await _svc.currentPlan();
    if (!mounted) return;
    setState(() {
      _active = a;
      _plan = p;
      _loading = false;
    });
  }

  Future<void> _buyMonthly() async {
    setState(() => _loading = true);
    await _svc.buyMonthly();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium активирован: 199 ₽/мес')));
  }

  Future<void> _buyYearly() async {
    setState(() => _loading = true);
    await _svc.buyYearly();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium активирован: 99 ₽/мес при оплате за год')));
  }

  Future<void> _cancel() async {
    setState(() => _loading = true);
    await _svc.cancel();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Подписка отменена')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Подписка Premium')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Free', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text('• Учёт доходов и трат\n• Базовые диаграммы\n• Челленджи и баллы'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Premium', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text('• Советы Airi\n• Расширенные отчёты\n• Приоритетные челенджи'),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Chip(label: Text('199 ₽/мес')),
                            SizedBox(width: 8),
                            Chip(label: Text('99 ₽/мес при оплате за год')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (!_active) ...[
                          FilledButton(
                            onPressed: _buyMonthly,
                            child: const Text('Оформить 199 ₽/мес'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _buyYearly,
                            child: const Text('Годовой: 99 ₽/мес'),
                          ),
                        ] else ...[
                          Text('Активно: ${_plan == 'yearly' ? 'Premium годовой' : 'Premium месячный'}'),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _cancel,
                            icon: const Icon(Icons.cancel),
                            label: const Text('Отменить подписку'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
