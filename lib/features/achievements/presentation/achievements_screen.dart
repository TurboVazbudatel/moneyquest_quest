import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/achievements_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final svc = AchievementsService();
  late final items = svc.items;
  Set<String> unlocked = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    unlocked.clear();
    for (final a in items) {
      if (await svc.isUnlocked(a.key)) {
        unlocked.add(a.key);
      }
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> _claim(Achievement a) async {
    await svc.unlock(a.key, a.reward, a.title);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+${a.reward} за «${a.title}»')));
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Достижения')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = items[i];
                final done = unlocked.contains(a.key);
                final color = done ? th.colorScheme.primaryContainer : th.colorScheme.surface;
                final on = done ? th.colorScheme.onPrimaryContainer : th.colorScheme.onSurface;
                return Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: th.colorScheme.primary.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0,4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: done ? th.colorScheme.primary : th.colorScheme.outlineVariant,
                      child: Icon(done ? Icons.emoji_events : Icons.lock_outline, color: done ? th.colorScheme.onPrimary : th.colorScheme.onSurfaceVariant),
                    ),
                    title: Text(a.title, style: th.textTheme.titleMedium?.copyWith(color: on, fontWeight: FontWeight.w700)),
                    subtitle: Text(a.desc, style: th.textTheme.bodyMedium?.copyWith(color: on)),
                    trailing: done ? const Icon(Icons.check_circle, color: Colors.green) : FilledButton(onPressed: () => _claim(a), child: Text('+${a.reward}')),
                  ),
                );
              },
            ),
    );
  }
}
