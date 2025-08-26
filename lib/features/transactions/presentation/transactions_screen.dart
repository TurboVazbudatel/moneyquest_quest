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
  List<Map<String, dynamic>> _visible = [];

  // фильтры
  String _query = '';
  TxType? _typeFilter; // null = все, income/expense
  String? _categoryFilter;

  bool _searchMode = false;
  final _searchCtrl = TextEditingController();

  Future<void> _load() async {
    final all = await _svc.all();
    if (!mounted) return;
    setState(() {
      _items = all;
    });
    _applyFilters();
  }

  void _applyFilters() {
    var list = List<Map<String, dynamic>>.from(_items);

    // фильтр по типу
    if (_typeFilter != null) {
      final needIncome = _typeFilter == TxType.income;
      list = list.where((e) => (e['type'] == 'income') == needIncome).toList();
    }

    // фильтр по категории (точное совпадение)
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      list = list.where((e) => (e['category'] as String?) == _categoryFilter).toList();
    }

    // поиск по заметке/категории/сумме
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((e) {
        final note = (e['note'] as String?)?.toLowerCase() ?? '';
        final cat  = (e['category'] as String?)?.toLowerCase() ?? '';
        final amt  = (e['amount'] as num).toString();
        return note.contains(q) || cat.contains(q) || amt.contains(q);
      }).toList();
    }

    setState(() => _visible = list);
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
      builder: (_) => AddTxSheet(initial: init),
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
    final categories = {
      for (final e in _items) (e['category'] as String?) ?? 'Другое'
    }.toList();

    return Scaffold(
      appBar: AppBar(
        title: _searchMode
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Поиск: заметка, категория, сумма',
                  border: InputBorder.none,
                ),
                onChanged: (v) {
                  _query = v.trim();
                  _applyFilters();
                },
              )
            : const Text('Транзакции'),
        actions: [
          IconButton(
            tooltip: _searchMode ? 'Закрыть поиск' : 'Поиск',
            icon: Icon(_searchMode ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _searchMode = !_searchMode;
                if (!_searchMode) {
                  _searchCtrl.clear();
                  _query = '';
                  _applyFilters();
                }
              });
            },
          ),
          IconButton(
            tooltip: 'Сбросить фильтры',
            icon: const Icon(Icons.filter_alt_off_outlined),
            onPressed: () {
              setState(() {
                _typeFilter = null;
                _categoryFilter = null;
                _query = '';
                _searchCtrl.clear();
              });
              _applyFilters();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // панель фильтров
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Все'),
                  selected: _typeFilter == null,
                  onSelected: (_) {
                    setState(() => _typeFilter = null);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Расход'),
                  selected: _typeFilter == TxType.expense,
                  onSelected: (_) {
                    setState(() => _typeFilter = TxType.expense);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Доход'),
                  selected: _typeFilter == TxType.income,
                  onSelected: (_) {
                    setState(() => _typeFilter = TxType.income);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 12),
                // категории
                for (final c in categories) ...[
                  const SizedBox(width: 6),
                  FilterChip(
                    label: Text(c),
                    selected: _categoryFilter == c,
                    onSelected: (_) {
                      setState(() => _categoryFilter = _categoryFilter == c ? null : c);
                      _applyFilters();
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: _visible.length,
                itemBuilder: (ctx, i) {
                  final e = _visible[i];
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
          ),
        ],
      ),
    );
  }
}
