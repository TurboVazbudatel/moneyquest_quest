import 'package:flutter/material.dart';
import '../../../data/services/budgets_service.dart';
import 'add_budget_sheet.dart';

class BudgetsManagerScreen extends StatefulWidget {
  const BudgetsManagerScreen({super.key});

  @override
  State<BudgetsManagerScreen> createState() => _BudgetsManagerScreenState();
}

class _BudgetsManagerScreenState extends State<BudgetsManagerScreen> {
  final _svc = BudgetsService();
  List<Budget> _items = [];
  bool _loading = false;

  // Алёрты Airi для верхнего баннера
  List<_BudgetAlert> _alerts = [];
  bool _bannerDismissed = false;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _bannerDismissed = false; // показываем снова при новом заходе/обновлении
    });

    final list = await _svc.all();

    // Собираем алёрты по каждому бюджету
    final alerts = <_BudgetAlert>[];
    for (final b in list) {
      final p = await _svc.progress(b); // 0..1 (может быть >1)
      final spent = await _svc.spentFor(b);
      if (p >= 1.0) {
        alerts.add(_BudgetAlert(
          budget: b,
          progress: p,
          spent: spent,
          level: _AlertLevel.critical,
          message:
              'Лимит по «${b.category}» исчерпан: ${spent.toStringAsFixed(0)} / ${b.limit.toStringAsFixed(0)} ₽. '
              'Совет Airi: на этой неделе заморозь траты в этой категории и перенеси покупки.',
        ));
      } else if (p >= 0.8) {
        alerts.add(_BudgetAlert(
          budget: b,
          progress: p,
          spent: spent,
          level: _AlertLevel.warning,
          message:
              'Вы близки к лимиту по «${b.category}»: ${spent.toStringAsFixed(0)} / ${b.limit.toStringAsFixed(0)} ₽. '
              'Совет Airi: установи микро-лимит на 2–3 дня и воспользуйся пресетами расходов.',
        ));
      }
    }

    if (!mounted) return;
    setState(() {
      _items = list;
      _alerts = alerts;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Color _barColor(double progress) {
    if (progress < 0.8) return const Color(0xFF32D74B);
    if (progress <= 1.0) return const Color(0xFFFFD60A);
    return const Color(0xFFFF453A);
  }

  Widget _buildBanner() {
    if (_bannerDismissed || _alerts.isEmpty) return const SizedBox.shrink();

    // Сортируем: критичные сверху
    final sorted = [..._alerts]
      ..sort((a, b) => a.level.index.compareTo(b.level.index)); // critical(0) выше warning(1)

    // Покажем один самый важный + счётчик остальных
    final top = sorted.first;
    final rest = sorted.length - 1;
    final color = top.level == _AlertLevel.critical
        ? const Color(0xFFFFE5E3) // мягко-красный фон
        : const Color(0xFFFFF6DA); // мягко-жёлтый фон
    final iconColor = top.level == _AlertLevel.critical
        ? const Color(0xFFFF453A)
        : const Color(0xFFFF9F0A);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Airi: ${top.message}${rest > 0 ? '  •  И ещё $rest бюджет(а) требуют внимания.' : ''}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            tooltip: 'Скрыть',
            onPressed: () => setState(() => _bannerDismissed = true),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Future<void> _openAdd() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AddBudgetSheet(),
    );
    if (ok == true) _load();
  }

  Future<void> _openEdit(Budget b) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddBudgetSheet(initial: b),
    );
    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Бюджеты')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Баннер Airi
                _buildBanner(),
                // Список
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: _items.length,
                      itemBuilder: (ctx, i) {
                        final b = _items[i];
                        return FutureBuilder<double>(
                          future: _svc.progress(b),
                          builder: (ctx, snap) {
                            final p = (snap.data ?? 0).clamp(0.0, 10.0);
                            final spentFuture = _svc.spentFor(b);
                            return Card(
                              margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _openEdit(b),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.pie_chart_outline, color: _barColor(p)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${b.category} • ${b.period == "week" ? "Неделя" : "Месяц"}',
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                          ),
                                          FutureBuilder<double>(
                                            future: spentFuture,
                                            builder: (ctx, s2) {
                                              final spent = s2.data ?? 0;
                                              return Text(
                                                '${spent.toStringAsFixed(0)} / ${b.limit.toStringAsFixed(0)} ₽',
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: p > 1 ? 1 : p,
                                          minHeight: 10,
                                          backgroundColor: Colors.white12,
                                          valueColor: AlwaysStoppedAnimation<Color>(_barColor(p)),
                                        ),
                                      ),
                                      if (p > 1.0) ...[
                                        const SizedBox(height: 6),
                                        Text('Лимит превышен!',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFFF453A))),
                                      ] else if (p >= 0.8) ...[
                                        const SizedBox(height: 6),
                                        Text('Вы близки к лимиту',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFFFD60A))),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

enum _AlertLevel { critical, warning }

class _BudgetAlert {
  final Budget budget;
  final double progress;
  final double spent;
  final _AlertLevel level;
  final String message;

  _BudgetAlert({
    required this.budget,
    required this.progress,
    required this.spent,
    required this.level,
    required this.message,
  });
}
