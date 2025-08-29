import 'package:flutter/material.dart';
import 'package:moneyquest_quest/widgets/typing_text.dart';
import 'package:moneyquest_quest/features/home/presentation/home_screen.dart';
import 'package:moneyquest_quest/data/services/profile_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _name = '';

  Future<void> _finish() async {
    if (!mounted) return;
    final nav = Navigator.of(context);
    await ProfileService().setOnboarded(true);
    if (_name.isNotEmpty) {
      await ProfileService().setName(_name);
    }
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _name.isEmpty
                      ? SizedBox(
                          key: const ValueKey('airi_wave_full'),
                          height: 280,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.asset(
                              'assets/airi/full/airi_full_wave.png',
                              filterQuality: FilterQuality.high,
                              gaplessPlayback: true,
                            ),
                          ),
                        )
                      : SizedBox(
                          key: const ValueKey('airi_happy_full'),
                          height: 280,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.asset(
                              'assets/airi/full/Airi_full_03_happy.png',
                              filterQuality: FilterQuality.high,
                              gaplessPlayback: true,
                            ),
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
