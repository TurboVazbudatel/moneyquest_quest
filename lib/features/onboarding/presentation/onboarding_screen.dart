import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/profile_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  final _auth = AuthService();
  final _profile = ProfileService();
  final _nameCtrl = TextEditingController();

  Future<void> _afterLogin({bool guest = false}) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Познакомимся?'),
        content: TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Как тебя зовут?'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Пропустить')),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Продолжить')),
        ],
      ),
    );
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) await _profile.setName(name);
    await _profile.setOnboarded(true);
    await _profile.setGuest(guest);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/root');
  }

  Future<void> _loginGuest() async {
    await _auth.signInAnonymously();
    if (!mounted) return;
    await _afterLogin(guest: true);
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      ('Веди бюджет как игру', 'Получай баллы и открывай достижения.'),
      ('Челлендж BudgetBattle', 'Уложись в лимит за 24 часа и забирай +100 баллов.'),
      ('Airi — твой помощник', 'Советы по бюджету без воды и в человеческом стиле.'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: slides.length,
                itemBuilder: (_, i) {
                  final (title, text) = slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(text, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Center(
                            child: Icon(
                              i == 0 ? Icons.emoji_events_outlined : (i == 1 ? Icons.sports_esports_outlined : Icons.person_outline),
                              size: 120,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  FilledButton.icon(
                    onPressed: _loginGuest,
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Войти как гость'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google будет доступен в мобильных сборках')),
                    ),
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('Google (скоро)'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _openLink('https://t.me/'),
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Telegram (скоро)'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                  const SizedBox(height: 12),
                  Text('Нажимая вход, ты принимаешь Политику и Условия',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
