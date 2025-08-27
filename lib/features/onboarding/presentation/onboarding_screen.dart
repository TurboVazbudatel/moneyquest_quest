import 'package:flutter/material.dart';
import "../../home/presentation/home_screen.dart";
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/profile_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _auth = AuthService();
  final _profile = ProfileService();
  final _nameCtrl = TextEditingController();

  late final AnimationController _ac;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
    _ac.forward();
    _prefillName();
  }

  Future<void> _prefillName() async {
    final n = await _profile.getName();
    if (!mounted) return;
    if ((n ?? '').isNotEmpty) _nameCtrl.text = n!;
  }

  @override
  void dispose() {
    _ac.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _continueAsGuest() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      await _profile.setName(name);
    }
    try {
      await _auth.signInAnonymously();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false); // закрываем онбординг и возвращаемся на Home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добро пожаловать! Вход как гость выполнен')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа: ${e.message ?? e.code}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _comingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider — скоро ✨')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            children: [
              // Кнопка закрыть
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Закрыть',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
              const SizedBox(height: 8),
              // Airi — анимация появления
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    children: [
                      // Аватар Airi (можно заменить на картинку позже)
                      Container(
                        width: 108,
                        height: 108,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF6FE1B2), Color(0xFF32D74B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Text('A', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Привет! Меня зовут Airi, а тебя?',
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Я помогу подружиться с бюджетом и сделать финансы понятными 💚',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Имя
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Твоё имя',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _continueAsGuest(),
              ),
              const SizedBox(height: 16),
              // Кнопка гостя
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _continueAsGuest,
                  icon: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.rocket_launch),
                  label: const Text('Войти как гость'),
                ),
              ),
              const SizedBox(height: 12),
              // Провайдеры (заглушки, чтобы не ломать сборку)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _comingSoon('Google'),
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('Google'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _comingSoon('Apple'),
                    icon: const Icon(Icons.apple),
                    label: const Text('Apple'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _comingSoon('Telegram'),
                    icon: const Icon(Icons.send),
                    label: const Text('Telegram'),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Продолжая, вы соглашаетесь с условиями сервиса',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
