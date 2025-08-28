import 'package:flutter/material.dart';
import '../../../widgets/airi_emotion.dart';
import '../../../widgets/airi_assets.dart';

class AiriTestScreen extends StatelessWidget {
  const AiriTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Airi Test')),
      body: const Center(child: AiriEmotion(mood: AiriMood.wave, isFull: false, height: 220)),
    );
  }
}
