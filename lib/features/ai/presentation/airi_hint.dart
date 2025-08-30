import 'dart:math';
import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/points_service.dart';

class AiriHint extends StatefulWidget {
  const AiriHint({super.key});
  @override
  State<AiriHint> createState() => _AiriHintState();
}

class _AiriHintState extends State<AiriHint> {
  final _rng = Random();
  int _points = 0;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _points = await PointsService().total();
    if (!mounted) return;
    _text = _pick(_points);
    setState(() {});
  }

  String _pick(int pts) {
    final low = [
      'Давай начнём с небольшого лимита на неделю?',
      'Добавь первую транзакцию — так проще увидеть картину.',
      'Попробуем отложить 5% от следующего дохода.'
    ];
    final mid = [
      'Классный темп! Проверь категории с наибольшими тратами.',
      'Ещё шаг — создай бюджет на месяц.',
      'У тебя получается. Хочешь челлендж на неделю?'
    ];
    final high = [
      'Стабильно! Самое время цель «подушка безопасности».',
      'Проанализировать 3 «дорогие» категории за месяц?',
      'Готов к новому челленджу с наградой?'
    ];
    final pool = pts < 100 ? low : pts < 300 ? mid : high;
    return pool[_rng.nextInt(pool.length)];
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: th.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: th.colorScheme.primary.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0,4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chat_bubble_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_text, style: th.textTheme.bodyLarge?.copyWith(color: th.colorScheme.onPrimaryContainer)),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: _load,
            child: const Text('Ещё совет'),
          ),
        ],
      ),
    );
  }
}
