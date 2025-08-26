import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Радар «Доход vs Расход» — стиль: гладкие волнистые линии + glow.
/// - Без собственного фона (используем фон приложения)
/// - Кольца + радиальные деления
/// - Income: 0xFF32D74B (мятно-зелёный), Expense: мягко-красный
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
    for (final k in axes) {
      maxVal = math.max(maxVal, (incomeByCat[k] ?? 0));
      maxVal = math.max(maxVal, (expenseByCat[k] ?? 0));
    }
    if (maxVal <= 0) maxVal = 1;

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: padding,
        child: CustomPaint(
          painter: _RadarPainter(
            axes: axes,
            getIncome: (k) => (incomeByCat[k] ?? 0) / maxVal,
            getExpense: (k) => (expenseByCat[k] ?? 0) / maxVal,
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

  _RadarPainter({
    required this.axes,
    required this.getIncome,
    required this.getExpense,
  });

  static const incomeColor = Color(0xFF32D74B);   // мягко-мятный зелёный
  static const expenseColor = Color(0xFFFF6B6B);  // мягко-красный

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final R = math.min(cx, cy) * 0.86;

    // ==== Сетка: внешнее кольцо + внутренние кольца + лучи
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
      final p2 = Offset(cx + R * math.cos(a), cy + R * math.sin(a));
      canvas.drawLine(Offset(cx, cy), p2, spoke);
    }

    // ==== Полярные точки (0..1) -> экранные координаты
    List<Offset> _points(double Function(String) source) {
      final pts = <Offset>[];
      for (int i = 0; i < axes.length; i++) {
        final a = _angle(i, axes.length);
        final r = (source(axes[i]).clamp(0.0, 1.0)) * R;
        pts.add(Offset(cx + r * math.cos(a), cy + r * math.sin(a)));
      }
      // замкнём для удобства интерполяции
      pts.add(pts.first);
      return pts;
    }

    final incomePts = _points(getIncome);
    final expensePts = _points(getExpense);

    // ==== Строим плавные кривые (Catmull-Rom через квадратичные Безье)
    Path _smoothPath(List<Offset> pts) {
      final path = Path();
      if (pts.length < 3) return path;
      path.moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length - 1; i++) {
        final p0 = pts[i - 1];
        final p1 = pts[i];
        final p2 = pts[i + 1];
        // контрольная точка посередине сегмента p0-p2 (даёт мягкую волну)
        final ctrl = Offset((p0.dx + p2.dx) / 2, (p0.dy + p2.dy) / 2);
        path.quadraticBezierTo(ctrl.dx, ctrl.dy, p1.dx, p1.dy);
      }
      path.close();
      return path;
    }

    final incomePath = _smoothPath(incomePts);
    final expensePath = _smoothPath(expensePts);

    // ==== Линия + «свечение» (без заливки)
    void _strokeWithGlow(Path path, Color c) {
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

    _strokeWithGlow(expensePath, expenseColor);
    _strokeWithGlow(incomePath, incomeColor);

    // ==== Подписи осей
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    for (int i = 0; i < axes.length; i++) {
      final a = _angle(i, axes.length);
      final rr = R * 1.05;
      final p = Offset(cx + rr * math.cos(a), cy + rr * math.sin(a));
      tp.text = TextSpan(text: axes[i], style: const TextStyle(fontSize: 11, color: Color(0x99FFFFFF)));
      tp.layout();
      final off = Offset(p.dx - tp.width / 2, p.dy - tp.height / 2);
      tp.paint(canvas, off);
    }
  }

  double _angle(int i, int n) => -math.pi / 2 + 2 * math.pi * (i / n);

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.axes != axes || old.getIncome != getIncome || old.getExpense != getExpense;
}
