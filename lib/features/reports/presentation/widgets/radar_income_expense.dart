import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Радар «Доход vs Расход» — гладкие волнистые линии + glow.
/// Показывается даже при нулевых данных (есть минимальная амплитуда),
/// чтобы диаграмма всегда была визуально заметной.
class RadarIncomeExpense extends StatelessWidget {
  final Map<String, double> incomeByCat;
  final Map<String, double> expenseByCat;
  final List<String> axes;
  final EdgeInsets padding;

  const RadarIncomeExpense({
    super.key,
    required this.incomeByCat,
    required this.expenseByCat,
    required this.axes,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    double maxVal = 0;
    var anyValue = false;
    for (final k in axes) {
      final i = (incomeByCat[k] ?? 0).toDouble();
      final e = (expenseByCat[k] ?? 0).toDouble();
      if (i != 0 || e != 0) anyValue = true;
      if (i > maxVal) maxVal = i;
      if (e > maxVal) maxVal = e;
    }
    if (maxVal <= 0) maxVal = 1; // чтобы нормировка не делила на 0

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: padding,
        child: CustomPaint(
          painter: _RadarPainter(
            axes: axes,
            getIncome: (k) => (incomeByCat[k] ?? 0).toDouble() / maxVal,
            getExpense: (k) => (expenseByCat[k] ?? 0).toDouble() / maxVal,
            anyValue: anyValue,
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<String> axes;
  final double Function(String) getIncome;
  final double Function(String) getExpense;
  final bool anyValue;

  _RadarPainter({
    required this.axes,
    required this.getIncome,
    required this.getExpense,
    required this.anyValue,
  });

  static const incomeColor = Color(0xFF32D74B);   // мягко-мятный зелёный
  static const expenseColor = Color(0xFFFF6B6B);  // мягко-красный

  // Минимальный визуальный радиус (чтобы было видно при 0)
  static const double _minVisual = 0.10; // 10% от R

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final R = math.min(cx, cy) * 0.86;

    // Сетка
    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.08);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.06);
    final spoke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.07);

    canvas.drawCircle(Offset(cx, cy), R, outer);
    for (final t in [0.25, 0.5, 0.75]) {
      canvas.drawCircle(Offset(cx, cy), R * t, ring);
    }
    for (int i = 0; i < axes.length; i++) {
      final a = _angle(i, axes.length);
      canvas.drawLine(Offset(cx, cy), Offset(cx + R * math.cos(a), cy + R * math.sin(a)), spoke);
    }

    // Значения -> точки (гарантируем минимум для видимости)
    List<Offset> points(double Function(String) src) {
      final pts = <Offset>[];
      for (int i = 0; i < axes.length; i++) {
        final a = _angle(i, axes.length);
        var v = src(axes[i]).clamp(0.0, 1.0);
        if (!anyValue) {
          // когда все нули — даём лёгкую волну, чтобы было красиво
          // базовая окружность + небольшая синусоида
          v = _minVisual + 0.02 * math.sin(i * 2 * math.pi / axes.length);
        } else if (v == 0.0) {
          v = _minVisual;
        } else if (v < _minVisual) {
          v = _minVisual + v * (1 - _minVisual); // сохраняем пропорцию, но не даём исчезнуть
        }
        final r = v * R;
        pts.add(Offset(cx + r * math.cos(a), cy + r * math.sin(a)));
      }
      pts.add(pts.first);
      return pts;
    }

    final incomePts = points(getIncome);
    final expensePts = points(getExpense);

    // Плавные кривые (квадратичные Безье)
    Path smooth(List<Offset> pts) {
      final path = Path();
      if (pts.length < 3) return path;
      path.moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length - 1; i++) {
        final p0 = pts[i - 1];
        final p1 = pts[i];
        final p2 = pts[i + 1];
        final ctrl = Offset((p0.dx + p2.dx) / 2, (p0.dy + p2.dy) / 2);
        path.quadraticBezierTo(ctrl.dx, ctrl.dy, p1.dx, p1.dy);
      }
      path.close();
      return path;
    }

    final incomePath = smooth(incomePts);
    final expensePath = smooth(expensePts);

    // Линия + свечение
    void strokeWithGlow(Path path, Color c) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = c.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..color = c.withValues(alpha: 0.95);
      canvas.drawPath(path, glow);
      canvas.drawPath(path, stroke);
    }

    strokeWithGlow(expensePath, expenseColor);
    strokeWithGlow(incomePath, incomeColor);

    // Подписи
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    for (int i = 0; i < axes.length; i++) {
      final a = _angle(i, axes.length);
      final rr = R * 1.05;
      final p = Offset(cx + rr * math.cos(a), cy + rr * math.sin(a));
      tp.text = const TextSpan(style: TextStyle(fontSize: 11, color: Color(0x99FFFFFF)));
      tp.text = TextSpan(text: axes[i], style: const TextStyle(fontSize: 11, color: Color(0x99FFFFFF)));
      tp.layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }
  }

  double _angle(int i, int n) => -math.pi / 2 + 2 * math.pi * (i / n);

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.axes != axes || old.getIncome != getIncome || old.getExpense != getExpense || old.anyValue != anyValue;
}
