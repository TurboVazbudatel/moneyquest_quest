import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadarIncomeExpense extends StatelessWidget {
  final Map<String, double> incomeByCat;  // категория -> сумма дохода (>=0)
  final Map<String, double> expenseByCat; // категория -> сумма расхода (>=0)
  final List<String> axes;                // порядок осей (категорий)
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
    // максимальное значение по всем осям, чтобы нормировать радиус
    double maxVal = 0;
    for (final k in axes) {
      maxVal = math.max(maxVal, (incomeByCat[k] ?? 0));
      maxVal = math.max(maxVal, (expenseByCat[k] ?? 0));
    }
    if (maxVal <= 0) maxVal = 1;

    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _RadarPainter(
          axes: axes,
          getIncome: (k) => (incomeByCat[k] ?? 0) / maxVal,
          getExpense: (k) => (expenseByCat[k] ?? 0) / maxVal,
        ),
        child: Padding(
          padding: padding,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<String> axes;
  final double levels; // сколько окружностей-сеток
  final double labelRadiusFactor; // радиус для подписи
  final double tickStroke;
  final Paint gridPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint incomePaintFill = Paint()
    ..style = PaintingStyle.fill;
  final Paint incomePaintStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint expensePaintFill = Paint()
    ..style = PaintingStyle.fill;
  final Paint expensePaintStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final double Function(String) getIncome;
  final double Function(String) getExpense;

  _RadarPainter({
    required this.axes,
    required this.getIncome,
    required this.getExpense,
    this.levels = 4,
    this.labelRadiusFactor = 1.08,
    this.tickStroke = 1,
  }) {
    // Мягкие цвета как просили: зелёный для дохода, красный для расходов
    final incomeColor = const Color(0xFF32D74B); // зелёный
    final expenseColor = const Color(0xFFFF453A); // красный
    incomePaintFill.color = incomeColor.withValues(alpha: 0.18);
    incomePaintStroke.color = incomeColor.withValues(alpha: 0.85);
    expensePaintFill.color = expenseColor.withValues(alpha: 0.18);
    expensePaintStroke.color = expenseColor.withValues(alpha: 0.85);
    gridPaint.color = Colors.white.withValues(alpha: 0.12);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) * 0.82;

    // сетка (концентрические полигоны)
    for (int l = 1; l <= levels; l++) {
      final t = l / levels;
      final path = _polygonPath(cx, cy, radius * t, axes.length);
      canvas.drawPath(path, gridPaint);
    }

    // лучи к подписям
    for (int i = 0; i < axes.length; i++) {
      final ang = _angleFor(i, axes.length);
      final p2 = Offset(
        cx + radius * math.cos(ang),
        cy + radius * math.sin(ang),
      );
      canvas.drawLine(Offset(cx, cy), p2, gridPaint);
    }

    // фигуры дохода и расхода
    final incomePath = Path();
    final expensePath = Path();
    for (int i = 0; i < axes.length; i++) {
      final ang = _angleFor(i, axes.length);
      final rInc = radius * getIncome(axes[i]);
      final rExp = radius * getExpense(axes[i]);

      final pi = Offset(cx + rInc * math.cos(ang), cy + rInc * math.sin(ang));
      final pe = Offset(cx + rExp * math.cos(ang), cy + rExp * math.sin(ang));

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

    canvas.drawPath(expensePath, expensePaintFill);
    canvas.drawPath(expensePath, expensePaintStroke);
    canvas.drawPath(incomePath, incomePaintFill);
    canvas.drawPath(incomePath, incomePaintStroke);

    // подписи осей
    final textPainter = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    for (int i = 0; i < axes.length; i++) {
      final ang = _angleFor(i, axes.length);
      final rp = radius * labelRadiusFactor;
      final p = Offset(cx + rp * math.cos(ang), cy + rp * math.sin(ang));

      final label = axes[i];
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(fontSize: 12),
      );
      textPainter.layout();
      final tp = Offset(
        p.dx - textPainter.width / 2,
        p.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, tp);
    }
  }

  Path _polygonPath(double cx, double cy, double r, int n) {
    final path = Path();
    for (int i = 0; i < n; i++) {
      final ang = _angleFor(i, n);
      final x = cx + r * math.cos(ang);
      final y = cy + r * math.sin(ang);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  // старт сверху и по часовой стрелке
  double _angleFor(int i, int n) => -math.pi / 2 + 2 * math.pi * (i / n);

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.axes != axes ||
        oldDelegate.getIncome != getIncome ||
        oldDelegate.getExpense != getExpense;
  }
}
