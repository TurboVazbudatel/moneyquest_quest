import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/airi_advice_service.dart';
import 'package:moneyquest_quest/data/services/subscription_service.dart';
import 'package:moneyquest_quest/features/subscription/presentation/subscription_screen.dart';

class AiriAdvicePanel extends StatefulWidget {
  const AiriAdvicePanel({super.key});

  @override
  State<AiriAdvicePanel> createState() => _AiriAdvicePanelState();
}

class _AiriAdvicePanelState extends State<AiriAdvicePanel> {
  final _advice = AiriAdviceService();
  final _sub = SubscriptionService();

  bool _loading = true;
  bool _premium = false;
  List<String> _tips = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final isPro = await _sub.isPremium();
    List<String> tips = const [];
    if (isPro) {
      tips = await _advice.suggestions();
    }
    if (!mounted) return;
    setState(() {
      _premium = isPro;
      _tips = tips;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_premium) {
      return Card(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.volunteer_activism_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Советы Airi — доступно в Premium', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    const Text('Персональные рекомендации по бюджету и расширенные отчёты.'),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                        },
                        child: const Text('Оформить Premium'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_tips.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Советы Airi', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._tips.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text(t)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
