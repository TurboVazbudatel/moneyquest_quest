import 'package:flutter/material.dart';
import '../../../data/services/transactions_service.dart';
import 'add_tx_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _svc = TransactionsService();
  List<Map<String, dynamic>> _items = [];

  Future<void> _load() async {
    final all = await _svc.all();
    if (!mounted) return;
    setState(() => _items = all);
  }

  Future<void> _add() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AddTxSheet(),
    );
    if (ok == true) await _load();
  }

  Future<void> _edit(Map<String, dynamic> e) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddTxSheet(initial: e, itemKey: e['key']),
    );
    if (ok == true) await _load();
  }

  Future<void> _repeat(Map<String, dynamic> e) async {
    // создаём новую операцию на основе существующей, но с сегодняшней датой и без key
    final init = <String, dynamic>{
      'type': e['type'],
      'amount': e['amount'],
      'category': e['category'],
      'note': e['note'],
      'date': DateTime.now().millisecondsSinceEpoch,
    };
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddTxSheet(initial: init), // itemKey не передаём — будет Add
    );
    if (ok == true) await _load();
  }

  Future<void> _remove(dynamic key) async {
    await _svc.remove(key);
    await _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Транзакции')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: _items.length,
          itemBuilder: (ctx, i) {
            final e = _items[i];
            final isInc = e['type'] == 'income';
            final dt = DateTime.fromMillisecondsSinceEpoch((e['date'] as int?) ?? 0);
            return Dismissible(
              key: ValueKey(e['key']),
              background: Container(color: Colors.redAccent),
              onDismissed: (_) => _remove(e['key']),
              child: ListTile(
                onTap: () => _edit(e),
                leading: CircleAvatar(
                  backgroundColor: (isInc ? Colors.green : Colors.red).withOpacity(0.15),
                  child: Icon(isInc ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isInc ? Colors.green : Colors.red),
                ),
                title: Text('${isInc ? '+' : '-'} ${(e['amount'] as num).toStringAsFixed(2)} ₽'),
                subtitle: Text('${e['category']} • ${dt.day}.${dt.month}.${dt.year}'
                    '${e['note'] != null ? ' • ${e['note']}' : ''}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') _edit(e);
                    if (v == 'repeat') _repeat(e);
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                    PopupMenuItem(value: 'repeat', child: Text('Повторить')),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
