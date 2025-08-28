import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/profile_service.dart';
import '../../../widgets/airi_emotion.dart';
import '../../../widgets/airi_assets.dart';
import '../../home/presentation/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final _auth = AuthService();
  final _profile = ProfileService();
  final _nameCtrl = TextEditingController();

  late final AnimationController _ac;
  late final Animation<double> _fadeAiri;
  late final Animation<Offset> _slideAiri;
  late final Animation<double> _fadeText;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAiri = CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);
    _slideAiri = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutBack));
    _fadeText = CurvedAnimation(parent: _ac, curve: const Interval(0.3, 1, curve: Curves.easeOut));
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (r) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Добро пожаловать, ${name.isEmpty ? 'гость' : name}!')),
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

  void _soon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider — скоро')),
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
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAiri,
                child: SlideTransition(
                  position: _slideAiri,
                  child: const AiriEmotion(mood: AiriMood.wave, isFull: false, height: 180),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeText,
                child: Column(
                  children: [
                    Text('Привет! Меня зовут Airi, а тебя?', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Я помогу подружиться с бюджетом и сделать финансы понятными.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _soon('Google'),
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('Google'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _soon('Apple'),
                    icon: const Icon(Icons.apple),
                    label: const Text('Apple'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _soon('Telegram'),
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
