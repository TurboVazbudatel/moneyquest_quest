import 'package:flutter/material.dart';
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Лидерборд')),
    body: const Center(child: Text('Лидерборд — скоро')),
  );
}
