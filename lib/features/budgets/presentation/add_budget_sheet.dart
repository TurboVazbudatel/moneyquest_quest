import 'package:flutter/material.dart';
import '../../../data/services/budgets_service.dart';
import '../../../data/services/transactions_service.dart';

class AddBudgetSheet extends StatefulWidget {
  final Budget? initial;
  const AddBudgetSheet({super.key, this.initial});

  @override
  State<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<AddBudgetSheet> {
  final _svc = BudgetsService();
  final _tx = TransactionsService();

  final _limitCtrl = TextEditingController();
  String _category = 'Еда';
  String _period = 'month'; // month | week

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final b = widget.initial!;
      _category = b.category;
      _period = b.period;
      _limitCtrl.text = b.limit.toStringAsFixed(b.limit.truncateToDouble() == b.limit ? 0 : 2);
    } else {
      _category = TransactionsService.defaultExpenseCats.first;
      _period = 'month';
    }
  }

  Future<void> _save() async {
    final limit = double.tryParse(_limitCtrl.text.replaceAll(',', '.')) ?? 0;
    if (limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите лимит > 0')));
      return;
    }
    if (widget.initial == null) {
      await _svc.add(category: _category, limit: limit, period: _period);
    } else {
      await _svc.update(widget.initial!.copyWith(category: _category, limit: limit, period: _period));
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    if (widget.initial?.key == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить бюджет?'),
        content: Text('Категория: ${widget.initial!.category}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (ok == true) {
      await _svc.remove(widget.initial!.key);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = TransactionsService.defaultExpenseCats;
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
              Text(widget.initial == null ? 'Новый бюджет' : 'Редактировать бюджет',
                style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (widget.initial != null)
                IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: const InputDecoration(labelText: 'Категория', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _limitCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Лимит ₽', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'month', label: Text('Месяц'), icon: Icon(Icons.calendar_month)),
              ButtonSegment(value: 'week', label: Text('Неделя'), icon: Icon(Icons.date_range)),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
              FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: const Text('Сохранить')),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
