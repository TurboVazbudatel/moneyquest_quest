import 'package:flutter/material.dart';
import 'package:moneyquest_quest/core/services/first_run_service.dart';
import 'package:moneyquest_quest/core/services/greet_flag.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _resetOnboarding(BuildContext context) async {
    await FirstRunService().reset();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Онбординг будет показан заново')));
  }

  Future<void> _resetGreeting(BuildContext context) async {
    await GreetFlag().reset();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Приветствие Airi будет показано заново')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: const Text('Сбросить онбординг'),
            subtitle: const Text('Показать знакомство с приложением при следующем запуске'),
            onTap: () => _resetOnboarding(context),
          ),
          ListTile(
            leading: const Icon(Icons.waving_hand_rounded),
            title: const Text('Показать приветствие Airi заново'),
            subtitle: const Text('Вернуть приветственный баннер на главной'),
            onTap: () => _resetGreeting(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('О приложении'),
            subtitle: Text('MoneyQuest · ${String.fromEnvironment('BUILD_ENV', defaultValue: 'dev')}'),
            onTap: () {},
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
