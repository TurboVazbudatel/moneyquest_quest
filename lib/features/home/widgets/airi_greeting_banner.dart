import 'package:flutter/material.dart';
import 'package:moneyquest_quest/widgets/airi_assets.dart';

class AiriGreetingBanner extends StatelessWidget {
  final String name;
  final AiriMood mood;

  const AiriGreetingBanner({
    super.key,
    this.name = '',
    this.mood = AiriMood.wave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Используем по-поясной ассет, чтобы ничего не обрезалось
    final imgPath = AiriAssets.half[mood] ?? AiriAssets.half[AiriMood.wave]!;

    final greeting = name.isEmpty ? 'Привет! Я Airi' : 'Добрый день, $name! Я Airi';
    const sub = 'Рада помочь с бюджетом ✨';

    return Container(
      decoration: BoxDecoration(
        // мягкий градиент + скругления
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceVariant.withValues(alpha: 0.70),
            cs.surfaceVariant.withValues(alpha: 0.45),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // «Аватар» Airi по пояс с лёгким свечением
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // мягкое свечение позади
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.12),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                // сама Airi — чуть «выползает» вверх, чтобы не резало голову
                Positioned(
                  left: -6,
                  top: -10,
                  child: Image.asset(
                    imgPath,
                    width: 108,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                    alignment: Alignment.topLeft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Текст
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
