import 'package:flutter/material.dart';
import 'package:moneyquest_quest/features/reports/presentation/reports_screen.dart';
import 'package:moneyquest_quest/features/budgets/presentation/budgets_screen.dart';
import 'package:moneyquest_quest/features/health/presentation/health_screen.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: theme.colorScheme.surface,
      elevation: 6,
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home_filled), onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
            IconButton(icon: const Icon(Icons.radar_rounded), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsScreen()))),
            IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () {}),
            IconButton(icon: const Icon(Icons.outbox_rounded), onPressed: () {}),
            IconButton(icon: const Icon(Icons.emoji_events_rounded), onPressed: () {}),
            IconButton(icon: const Icon(Icons.star_border_rounded), onPressed: () {}),
            IconButton(icon: const Icon(Icons.sports_esports_rounded), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
