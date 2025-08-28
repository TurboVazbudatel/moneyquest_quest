import 'package:flutter/material.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Челленджи')),
      body: const Center(
        child: Text('Скоро тут будут челленджи 💪'),
      ),
    );
  }
}
