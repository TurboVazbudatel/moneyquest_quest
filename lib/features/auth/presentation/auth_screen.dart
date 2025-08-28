import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  void _todo(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider: функция в разработке')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Вход в аккаунт')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Text('Выберите способ входа', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _todo(context, 'Google Sign-In'),
              icon: const Icon(Icons.login),
              label: const Text('Войти через Google'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _todo(context, 'Telegram Login'),
              icon: const Icon(Icons.send),
              label: const Text('Войти через Telegram'),
            ),
            const Spacer(),
            Text(
              'Можно продолжить как гость в онбординге.\nПремиум-функции доступны после авторизации.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
