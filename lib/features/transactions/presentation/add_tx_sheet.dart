import 'package:flutter/material.dart';
import '../../../data/services/transactions_service.dart';

class AddTxSheet extends StatefulWidget {
  final Map<String, dynamic>? initial;
  final dynamic itemKey;

  const AddTxSheet({super.key, this.initial, this.itemKey});

  @override
  State<AddTxSheet> createState() => _AddTxSheetState();
}

class _AddTxSheetState extends State<AddTxSheet> {
  final _svc = TransactionsService();

  late TxType _type;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  late String _category;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final e = widget.initial!;
      _type = (e['type'] == 'income') ? TxType.income : TxType.expense;
      _amountCtrl.text = ((e['amount'] as num?)?.toString() ?? '');
      _noteCtrl.text = (e['note'] as String?) ?? '';
      _category = (e['category'] as String?) ?? 'Другое';
      final ms = (e['date'] as int?) ?? DateTime.now().millisecondsSinceEpoch;
      _date = DateTime.fromMillisecondsSinceEpoch(ms);
    } else {
      _type = TxType.expense;
      _category = TransactionsService.defaultExpenseCats.first;
    }
    final cats = _cats;
    if (!cats.contains(_category)) cats.add(_category);
  }

  List<String> get _cats => _type == TxType.income
      ? List.of(TransactionsService.defaultIncomeCats)
      : List.of(TransactionsService.defaultExpenseCats);

  List<double> get _presets => _type == TxType.income
      ? <double>[1000, 5000, 10000, 20000]
      : <double>[100, 300, 500, 1000, 2000];

  double _currentAmount() =>
      double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;

  void _applyPreset(double v) {
    _amountCtrl.text =
        v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
    setState(() {});
  }

  void _bump(double delta) {
    final v = (_currentAmount() + delta);
    if (v <= 0) return;
    _amountCtrl.text =
        v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
    setState(() {});
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount = _currentAmount();
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите сумму больше 0')),
      );
      return;
    }
    if (widget.itemKey != null) {
      await _svc.update(
        key: widget.itemKey,
        amount: amount,
        type: _type,
        category: _category,
        date: _date,
        note: _noteCtrl.text.trim(),
      );
    } else {
      await _svc.add(
        amount: amount,
        type: _type,
        category: _category,
        date: _date,
        note: _noteCtrl.text.trim(),
      );
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    if (widget.itemKey == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить транзакцию?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (ok == true) {
      await _svc.remove(widget.itemKey);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == TxType.income;
    final title = widget.itemKey != null ? 'Редактировать' : 'Новая операция';
    final cats = _cats;
    if (!cats.contains(_category)) cats.add(_category);

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (widget.itemKey != null)
                IconButton(
                  tooltip: 'Удалить',
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<TxType>(
            segments: const [
              ButtonSegment(value: TxType.expense, label: Text('Расход'), icon: Icon(Icons.remove_circle_outline)),
              ButtonSegment(value: TxType.income, label: Text('Доход'), icon: Icon(Icons.add_circle_outline)),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() {
              _type = s.first;
              _category = _cats.first;
            }),
          ),
          const SizedBox(height: 12),

          // Пресеты сумм
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in _presets)
                  OutlinedButton(
                    onPressed: () => _applyPreset(v),
                    child: Text((isIncome ? '+ ' : '- ') + v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Поле суммы + быстрые корректировки
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Сумма',
                    prefixText: isIncome ? '+ ' : '- ',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => _bump(50),
                      child: const Text('+50'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => _bump(-50),
                      child: const Text('-50'),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => _bump(10),
                      child: const Text('+10'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => _bump(-10),
                      child: const Text('-10'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: const InputDecoration(
              labelText: 'Категория',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Заметка (необязательно)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event),
                label: Text('${_date.day}.${_date.month}.${_date.year}'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Сохранить'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
