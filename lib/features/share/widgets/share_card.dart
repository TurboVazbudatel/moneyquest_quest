import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ShareCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> bullets;
  final bool win;
  final String footer;

  const ShareCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.win,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = win
        ? const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF10B981)])
        : const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFFF87171)]);

    return Container(
      width: 1080,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 96, height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                alignment: Alignment.center,
                child: const Text('Airi', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bullets.map((b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white.withValues(alpha: 0.9), size: 24),
                    const SizedBox(width: 10),
                    Expanded(child: Text(b, style: const TextStyle(color: Colors.white, fontSize: 28))),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Icon(win ? Icons.emoji_events : Icons.flag, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                win ? 'Победа!' : 'Попробую ещё раз',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                footer,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 26, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ShareRenderer {
  final GlobalKey repaintKey = GlobalKey();

  Widget wrap(Widget child) {
    return RepaintBoundary(
      key: repaintKey,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      ),
    );
  }

  Future<String> renderToPngFile({double pixelRatio = 2.5, String fileName = 'moneyquest_share.png'}) async {
    final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('ShareRenderer: boundary not ready');
    }
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(pngBytes);
    return file.path;
  }
}
