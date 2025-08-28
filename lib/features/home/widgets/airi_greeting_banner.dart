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

  (String, AiriMood) _greetingForNow() {
    final h = DateTime.now().hour;
    if (h >= 5 && h <= 11) {
      return ('Доброе утро', AiriMood.inspire);
    } else if (h >= 12 && h <= 17) {
      return ('Добрый день', AiriMood.happy);
    } else if (h >= 18 && h <= 22) {
      return ('Добрый вечер', AiriMood.think);
    } else {
      return ('Доброй ночи', AiriMood.shy);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final g = _greetingForNow();
    final title = _name.isEmpty ? '${g.$1}! Я Airi' : '${g.$1}, $_name! Я Airi';
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AiriEmotion(mood: g.$2, isFull: false, height: 72),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}
