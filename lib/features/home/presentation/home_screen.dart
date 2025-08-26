import 'package:flutter/material.dart';
import '../../../data/services/transactions_service.dart';
import '../../../data/services/points_service.dart';
import '../../../data/services/airi_advice.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _svc = TransactionsService();
  final _points = PointsService();
  final _advice = AiriAdviceService();

  int _totalPoints = 0;
  List<String> _tips = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await _points.total();
    final tips = await _advice.getAdvice();
    if (!mounted) return;
    setState(() {
      _totalPoints = t;
      _tips = tips;
    });
  }

  Future<void> _addTx(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    String category = 'Еда';
    TxType type = TxType.expense;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              runSpacing: 12,
              children: [
                Text('Новая транзакция', style: Theme.of(ctx).textTheme.titleMedium),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Расход'),
                      selected: type == TxType.expense,
                      onSelected: (_) => setState(() => type = TxType.expense),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Доход'),
                      selected: type == TxType.income,
                      onSelected: (_) => setState(() => type = TxType.income),
                    ),
                  ],
                ),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Сумма'),
                  validator: (v) {
                    final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                    if (x == null || x <= 0) return 'Введите сумму > 0';
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: const [
                    DropdownMenuItem(value: 'Еда', child: Text('Еда')),
                    DropdownMenuItem(value: 'Транспорт', child: Text('Транспорт')),
                    DropdownMenuItem(value: 'Дом', child: Text('Дом')),
                    DropdownMenuItem(value: 'Развлеч.', child: Text('Развлеч.')),
                    DropdownMenuItem(value: 'Подписки', child: Text('Подписки')),
                    DropdownMenuItem(value: 'Другое', child: Text('Другое')),
                  ],
                  onChanged: (v) => category = v ?? 'Еда',
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final amt = double.parse(amountCtrl.text.replaceAll(',', '.'));
                    await _svc.add(amount: amt, type: type, category: category);
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    await _load();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Сохранено')),
                    );
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _svc.currentBalance();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Добро пожаловать в MoneyQuest!', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Текущий баланс'),
              subtitle: Text(balance.toStringAsFixed(2)),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline),
                  SizedBox(width: 12),
                  Expanded(child: Text('Подсказка: добавь первую транзакцию — диаграммы сразу обновятся.')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.military_tech_outlined),
              title: const Text('Баллы'),
              subtitle: Text('$_totalPoints'),
              trailing: IconButton(
                onPressed: () async {
                  await _points.addPoints(reason: 'Ежедневный бонус', amount: 5);
                  await _load();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('+5 баллов (ежедневный бонус)')),
                  );
                },
                icon: const Icon(Icons.add),
                tooltip: 'Получить +5',
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_tips.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.person_outline),
                      title: Text('Airi совет'),
                      subtitle: Text('Ниже — быстрые рекомендации по твоему бюджету'),
                    ),
                    for (final t in _tips.take(3)) ...[
                      const SizedBox(height: 4),
                      Text('• $t'),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTx(context),
        icon: const Icon(Icons.add),
        label: const Text('Транзакция'),
      ),
    );
  }
}
