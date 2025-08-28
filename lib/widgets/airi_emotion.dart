import 'package:flutter/material.dart';
import 'airi_assets.dart';

class AiriEmotion extends StatelessWidget {
  final AiriMood mood;
  final bool isFull;
  final double height;

  const AiriEmotion({
    super.key,
    required this.mood,
    this.isFull = true,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final path = (isFull ? AiriAssets.full[mood] : AiriAssets.half[mood])!;
    return Image.asset(path, height: height, fit: BoxFit.contain);
  }
}
