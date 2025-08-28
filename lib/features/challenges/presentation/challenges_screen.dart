import 'package:flutter/material.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Челленджи')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.rocket_launch),
            title: Text('Стартовые цели'),
            subtitle: Text('Заглушка. Скоро добавим реальные челленджи.'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.savings),
            title: Text('Неделя без лишних трат'),
            subtitle: Text('Заглушка. Трекинг и баллы подключим позже.'),
          ),
        ],
      ),
    );
  }
}
