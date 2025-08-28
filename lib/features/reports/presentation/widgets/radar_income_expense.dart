import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Радар «Доход vs Расход» в виде двух круговых волн:
/// r = r0 + value * rA, где r0=0.35R (база), rA=0.55R (амплитуда).
/// Гладкая замкнутая кривая через Catmull–Rom + мягкий glow.
/// Подписи категорий располагаем по окружности и делаем более заметными.
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
      if (i != 0 || e != 0) {
  anyValue = true;
}
      if (i > maxVal) {
  maxVal = i;
}
      if (e > maxVal) {
  maxVal = e;
}
    }
    if (maxVal <= 0) {
  maxVal = 1;
}

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

  static const incomeColor = Color(0xFF32D74B);   // мягко-мятный
  static const expenseColor = Color(0xFFFF6B6B);  // мягко-красный

  // База и амплитуда для круговой волны
  static const double r0Factor = 0.35; // 35% R — базовый круг
  static const double rAmp    = 0.55;  // до +55% R — выпуклость
  static const double vMin    = 0.05;  // минимальная видимость при нуле

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final R  = math.min(cx, cy) * 0.86;

    // Сетка: внешнее кольцо + внутренние + лучи
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

    // Значения -> радиусы по формуле r = r0 + v*rA (с минимальной амплитудой)
    double valueToRadius(double v) {
      var vv = v.clamp(0.0, 1.0);
      if (!anyValue) {
  vv = vMin;
}         // когда все нули — одинаковая тонкая волна
      else           vv = math.max(vv, vMin);
      final r0 = r0Factor * R;
      return r0 + vv * (rAmp * R);
    }

    // Полярные точки (замкнутые — для кривой)
    List<Offset> points(double Function(String) src) {
      final pts = <Offset>[];
      for (int i = 0; i < axes.length; i++) {
        final a = _angle(i, axes.length);
        final r = valueToRadius(src(axes[i]));
        pts.add(Offset(cx + r * math.cos(a), cy + r * math.sin(a)));
      }
      // замыкаем для Catmull–Rom
      pts.addAll([pts[0], pts[1]]);
      return pts;
    }

    final incomePts  = points(getIncome);
    final expensePts = points(getExpense);

    // Catmull–Rom замкнутая кривая (cubicTo)
    Path catmullRom(List<Offset> pts, {double tension = 0.5}) {
      // На входе: [..., p(n-1), p0, p1] (последние два — дубли для замыкания)
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length - 2; i++) {
        final p0 = pts[i - 1];
        final p1 = pts[i];
        final p2 = pts[i + 1];
        final p3 = pts[i + 2];

        final t = tension;
        final c1 = Offset(
          p1.dx + (p2.dx - p0.dx) * t / 6,
          p1.dy + (p2.dy - p0.dy) * t / 6,
        );
        final c2 = Offset(
          p2.dx - (p3.dx - p1.dx) * t / 6,
          p2.dy - (p3.dy - p1.dy) * t / 6,
        );
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
      }
      path.close();
      return path;
    }

    final incomePath  = catmullRom(incomePts,  tension: 0.8);
    final expensePath = catmullRom(expensePts, tension: 0.8);

    // Линия + glow
    void strokeWithGlow(Path p, Color c) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = c.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..color = c.withValues(alpha: 0.95);
      canvas.drawPath(p, glow);
      canvas.drawPath(p, stroke);
    }

    strokeWithGlow(expensePath, expenseColor);
    strokeWithGlow(incomePath,  incomeColor);

    // Подписи категорий по окружности (чуть ярче)
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    for (int i = 0; i < axes.length; i++) {
      final a  = _angle(i, axes.length);
      final rr = R * 1.06;
      final p  = Offset(cx + rr * math.cos(a), cy + rr * math.sin(a));
      tp.text  = TextSpan(text: axes[i], style: const TextStyle(fontSize: 12, color: Color(0xCCFFFFFF)));
      tp.layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }
  }

  double _angle(int i, int n) => -math.pi / 2 + 2 * math.pi * (i / n);

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.axes != axes || old.getIncome != getIncome || old.getExpense != getExpense || old.anyValue != anyValue;
}
