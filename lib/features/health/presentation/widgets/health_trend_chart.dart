import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Точки: (xIndex, value). xIndex — порядковый номер дня/шагов.
class HealthTrendChart extends StatelessWidget {
  final List<FlSpot> spots;
  final bool isPositive;
  const HealthTrendChart({super.key, required this.spots, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    const lineStart = Color(0xFF6FE1B2);
    const lineEnd   = Color(0xFF32D74B);
    final areaGrad = [
      lineStart.withValues(alpha: 0.10),
      lineEnd.withValues(alpha: 0.18),
    ];

    if (spots.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text('Недостаточно данных',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60)),
        ),
      );
    }

    final minX = spots.first.x;
    final maxX = spots.last.x;
    double minY = spots.first.y, maxY = spots.first.y;
    for (final s in spots) {
      if (s.y < minY) minY = s.y;
      if (s.y > maxY) maxY = s.y;
    }
    if (minY == maxY) { minY -= 1; maxY += 1; }

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          minX: minX, maxX: maxX, minY: minY, maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.08),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: (maxY - minY) / 4,
                getTitlesWidget: (v, _) => Text(
                  v.toStringAsFixed(0),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxX - minX) / 4 == 0 ? 1 : (maxX - minX) / 4,
                getTitlesWidget: (v, _) => Text(
                  v.toStringAsFixed(0),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 10),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              // В 1.x нет tooltipRoundedRadius — используем доступные опции:
              getTooltipColor: (_)=> const Color(0xFF1F1A2E),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              tooltipMargin: 8,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (items) => items.map((it) {
                return LineTooltipItem(
                  'x=${it.x.toStringAsFixed(0)}  y=${it.y.toStringAsFixed(0)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 4,
              gradient: const LinearGradient(colors: [lineStart, lineEnd]),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: areaGrad,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                  radius: 3.5,
                  color: Colors.white,
                  strokeColor: const Color(0xFF2C2640),
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
