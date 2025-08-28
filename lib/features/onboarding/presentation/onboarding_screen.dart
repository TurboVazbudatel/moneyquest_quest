import 'package:flutter/material.dart';
import 'package:moneyquest_quest/widgets/typing_text.dart';
import 'package:moneyquest_quest/widgets/airi_emotion.dart';
import 'package:moneyquest_quest/features/home/presentation/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _name = '';

  void _finish() {
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, v, _) => Opacity(
                    opacity: v,
                    child: AiriEmotion(
                      mood: _name.isEmpty ? AiriMood.wave : AiriMood.happy,
                      isFull: false,
                      height: 180,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _name.isEmpty
                    ? TypingText(
                        text: 'Привет! Меня зовут Airi, а тебя?',
                        style: titleStyle,
                      )
                    : Text(
                        'Рада познакомиться, $_name!',
                        style: titleStyle,
                      ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => setState(() => _name = v.trim()),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Введите ваше имя',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _finish,
                  child: const Text('Начать'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
