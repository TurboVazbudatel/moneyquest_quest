import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/profile_service.dart';
import 'package:moneyquest_quest/widgets/airi_emotion.dart';

class AiriGreetingBanner extends StatefulWidget {
  const AiriGreetingBanner({super.key});

  @override
  State<AiriGreetingBanner> createState() => _AiriGreetingBannerState();
}

class _AiriGreetingBannerState extends State<AiriGreetingBanner> {
  String _name = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await ProfileService().getName();
    if (!mounted) return;
    setState(() {
      _name = (n ?? '').trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greet = _name.isEmpty ? 'Привет! Я Airi 💚' : 'Привет, $_name! Я Airi 💚';
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const AiriEmotion(mood: AiriMood.wave, isFull: false, height: 72),
            const SizedBox(width: 12),
            Expanded(child: Text(greet, style: theme.textTheme.titleMedium)),
          ],
        ),
      ),
    );
  }
}
