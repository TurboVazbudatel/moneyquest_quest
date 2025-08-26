import 'package:flutter/material.dart';
import '../../../data/services/goals_service.dart';
import '../../../data/services/achievements_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _svc = GoalsService();
  final _ach = AchievementsService();
  double _goal = 0;
  double _progress = 0;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final g = await _svc.getGoal();
    final p = await _svc.getProgress();
    setState(() {
      _goal = g;
      _progress = p;
    });

    if (_goal > 0 && _progress >= _goal) {
      await _ach.unlock('goal_reached');
    }
  }

  Future<void> _saveGoal() async {
    final amt = double.tryParse(_ctrl.text.replaceAll(',', '.')) ?? 0;
    if (amt <= 0) return;
    await _svc.setGoal(amt);
    await _svc.setProgress(0);
    _ctrl.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final double percent = _goal > 0 ? ((_progress / _goal).clamp(0.0, 1.0)).toDouble() : 0.0;

    final bool reached = _goal > 0 && percent >= 1.0;
    final bool almost = _goal > 0 && percent >= 0.8 && percent < 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Мои цели')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_goal == 0) const Text('Цель пока не установлена'),
          if (_goal > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Цель: ${_goal.toStringAsFixed(2)} ₽'),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.green,
                  minHeight: 12,
                ),
                const SizedBox(height: 8),
                Text('Прогресс: ${_progress.toStringAsFixed(2)} ₽'),
                if (almost)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Airi: Остался последний рывок — ты почти у цели!'),
                  ),
                if (reached)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Airi: Поздравляю! Цель достигнута 🎉 Достижение разблокировано!'),
                  ),
              ],
            ),
          const SizedBox(height: 24),
          TextField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Новая цель (₽)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveGoal,
            child: const Text('Сохранить цель'),
          ),
        ],
      ),
    );
  }
}
