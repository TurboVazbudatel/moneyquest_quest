import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Радар «Доход vs Расход»
/// - без собственного фона (использует стиль экрана/карточки)
/// - внешнее кольцо + внутренние кольца и лучи
/// - Доход: 0xFF32D74B, Расход: мягко-красный
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

  static const incomeMain = Color(0xFF32D74B);     // мягко-мятный зелёный
  static const expenseMain = Color(0xFFFF6B6B);    // мягко-красный

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final R = math.min(cx, cy) * 0.86;

    // Кольца
    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.08);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.06);

    canvas.drawCircle(Offset(cx, cy), R, outer);
    for (final t in [0.25, 0.5, 0.75]) {
      canvas.drawCircle(Offset(cx, cy), R * t, ring);
    }

    // Лучи
    final spoke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.07);
    for (int i = 0; i < axes.length; i++) {
      final ang = _angle(i, axes.length);
      final p2 = Offset(cx + R * math.cos(ang), cy + R * math.sin(ang));
      canvas.drawLine(Offset(cx, cy), p2, spoke);
    }

    // Полигоны
    final incomeFill = Paint()
      ..style = PaintingStyle.fill
      ..color = incomeMain.withValues(alpha: 0.16);
    final incomeStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..color = incomeMain.withValues(alpha: 0.9);

    final expenseFill = Paint()
      ..style = PaintingStyle.fill
      ..color = expenseMain.withValues(alpha: 0.16);
    final expenseStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..color = expenseMain.withValues(alpha: 0.9);

    final incomePath = Path();
    final expensePath = Path();
    for (int i = 0; i < axes.length; i++) {
      final ang = _angle(i, axes.length);
      final ri = (getIncome(axes[i]).clamp(0.0, 1.0)) * R;
      final re = (getExpense(axes[i]).clamp(0.0, 1.0)) * R;

      final pi = Offset(cx + ri * math.cos(ang), cy + ri * math.sin(ang));
      final pe = Offset(cx + re * math.cos(ang), cy + re * math.sin(ang));

      if (i == 0) {
        incomePath.moveTo(pi.dx, pi.dy);
        expensePath.moveTo(pe.dx, pe.dy);
      } else {
        incomePath.lineTo(pi.dx, pi.dy);
        expensePath.lineTo(pe.dx, pe.dy);
      }
    }
    incomePath.close();
    expensePath.close();

    // Мягкая тень под полигонами (без save/restore)
    final softShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(expensePath, softShadow);
    canvas.drawPath(incomePath, softShadow);

    canvas.drawPath(expensePath, expenseFill);
    canvas.drawPath(expensePath, expenseStroke);
    canvas.drawPath(incomePath, incomeFill);
    canvas.drawPath(incomePath, incomeStroke);

    // Подписи осей (без canvas.save/restore)
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    for (int i = 0; i < axes.length; i++) {
      final ang = _angle(i, axes.length);
      final rr = R * 1.05;
      final p = Offset(cx + rr * math.cos(ang), cy + rr * math.sin(ang));
      tp.text = TextSpan(
        text: axes[i],
        style: const TextStyle(fontSize: 11, color: Color(0x99FFFFFF)),
      );
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
