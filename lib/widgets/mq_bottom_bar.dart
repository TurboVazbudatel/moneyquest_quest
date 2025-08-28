import 'package:flutter/material.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/budgets/presentation/budgets_screen.dart';
import '../features/health/presentation/health_screen.dart';

class MqBottomBar extends StatelessWidget {
  const MqBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: theme.colorScheme.surface,
      elevation: 6,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: 'Главная',
              icon: const Icon(Icons.home_rounded),
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
            IconButton(
              tooltip: 'Диаграммы',
              icon: const Icon(Icons.radar_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              ),
            ),
            const SizedBox(width: 40),
            IconButton(
              tooltip: 'Бюджеты',
              icon: const Icon(Icons.account_balance_wallet_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BudgetsScreen()),
              ),
            ),
            IconButton(
              tooltip: 'ФинЗдоровье',
              icon: const Icon(Icons.favorite_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HealthScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
