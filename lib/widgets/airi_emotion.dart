import 'package:flutter/widgets.dart';

enum AiriMood { wave, happy, think, shy, inspire }

class AiriEmotion extends StatelessWidget {
  final AiriMood mood;
  final bool isFull;
  final double? height;
  final double? width;
  final String? overrideAsset;
  const AiriEmotion({
    super.key,
    required this.mood,
    this.isFull = false,
    this.height,
    this.width,
    this.overrideAsset,
  });

  String _assetFor(AiriMood m) {
    if (overrideAsset != null && overrideAsset!.isNotEmpty) return overrideAsset!;
    if (isFull) {
      switch (m) {
        case AiriMood.wave:
          return 'assets/airi/full/airi_full_wave.png';
        case AiriMood.think:
          return 'assets/airi/full/airi_full_think.png';
        case AiriMood.happy:
          return 'assets/airi/full/Airi_full_03_happy.png';
        case AiriMood.shy:
          return 'assets/airi/full/Airi_full_04_shy.png';
        case AiriMood.inspire:
          return 'assets/airi/full/Airi_full_05_inspire.png';
      }
    } else {
      switch (m) {
        case AiriMood.wave:
          return 'assets/airi/half/Airi_half_01_wave.png';
        case AiriMood.think:
          return 'assets/airi/half/Airi_half_02_think.png';
        case AiriMood.happy:
          return 'assets/airi/half/Airi_half_03_happy.png';
        case AiriMood.shy:
          return 'assets/airi/half/Airi_half_04_shy.png';
        case AiriMood.inspire:
          return 'assets/airi/half/Airi_half_05_inspire.png';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = _assetFor(mood);
    return SizedBox(
      height: height,
      width: width,
      child: Image.asset(path, fit: BoxFit.contain),
    );
  }
}
