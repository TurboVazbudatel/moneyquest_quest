import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/profile_service.dart';
import 'package:moneyquest_quest/widgets/airi_emotion.dart';

class AiriGreetingBanner extends StatefulWidget {
  const AiriGreetingBanner({super.key});

  @override
  State<AiriGreetingBanner> createState() => _AiriGreetingBannerState();
}

class _AiriGreetingBannerState extends State<AiriGreetingBanner> {
  final _profile = ProfileService();
  String _name = '';
  bool _hidden = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await _profile.getName();
    if (!mounted) return;
    setState(() => _name = (n ?? '').trim());
  }

  @override
  Widget build(BuildContext context) {
    if (_hidden) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final greet = _name.isEmpty ? 'Привет! Я Airi 💚' : 'Привет, $_name! Я Airi 💚';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          AiriEmotion(mood: AiriMood.wave, isFull: false, height: 72),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$greet\nГотов(а) улучшать финздоровье?',
              style: theme.textTheme.bodyLarge,
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _hidden = true),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Скрыть',
          ),
        ],
      ),
    );
  }
}
