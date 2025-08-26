import 'package:flutter/material.dart';
import '../../../data/services/transactions_service.dart';
import '../../../data/utils/categories.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _svc = TransactionsService();

  Future<void> _addTx(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    String category = kCategories.first;
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
                  items: kCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => category = v ?? kCategories.first,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final amt = double.parse(amountCtrl.text.replaceAll(',', '.'));
                    await _svc.add(amount: amt, type: type, category: category);
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    setState(() {});
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
              subtitle: Text('${balance.toStringAsFixed(2)}'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.lightbulb_outline),
                  SizedBox(width: 12),
                  Expanded(child: Text('Подсказка: добавь первую транзакцию — диаграммы сразу обновятся.')),
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
