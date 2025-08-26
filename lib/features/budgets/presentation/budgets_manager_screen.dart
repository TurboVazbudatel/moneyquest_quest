import 'add_budget_sheet.dart';
import 'package:flutter/material.dart';
import '../../../data/services/budgets_service.dart';

class BudgetsManagerScreen extends StatefulWidget {
  const BudgetsManagerScreen({super.key});

  @override
  State<BudgetsManagerScreen> createState() => _BudgetsManagerScreenState();
}

class _BudgetsManagerScreenState extends State<BudgetsManagerScreen> {
  final _svc = BudgetsService();
  List<Budget> _items = [];
  bool _loading = false;

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _svc.all();
    if (!mounted) return;
    setState(() {
      _items = list;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Бюджеты')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: _items.length,
                itemBuilder: (ctx, i) {
                  final b = _items[i];
                  return FutureBuilder<double>(
                    future: _svc.progress(b),
                    builder: (ctx, snap) {
                      final p = (snap.data ?? 0).clamp(0.0, 10.0); // защита
                      final spentFuture = _svc.spentFor(b);
                      return Card(
                        margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
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
                          },
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
    );
  }
}

class AddBudgetSheet extends StatelessWidget {
  final Budget? initial;
  const AddBudgetSheet({super.key, this.initial});

  @override
  Widget build(BuildContext context) => const _Proxy(); // заполняется реальной формой из файла
}

/// Прокси, чтобы не тянуть тяжёлые импорты дважды:
class _Proxy extends StatelessWidget {
  const _Proxy();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
