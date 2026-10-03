// Рисует графики динамики обещаний для главного экрана и аналитики.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/tracked_person.dart';
import '../theme/app_colors.dart';

class MiniChartCard extends StatelessWidget {
  const MiniChartCard({super.key, required this.people});

  final List<TrackedPerson> people;

  @override
  Widget build(BuildContext context) {
    final totals = List<int>.generate(7, (day) {
      return people.fold(0, (sum, person) => sum + person.history[day]);
    });
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: Colors.white.withValues(alpha: .055)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Сорванные обещания',
                  style: TextStyle(fontSize: 12, color: Color(0xFFD8D5DE)),
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'неделя',
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 105,
            child: PromiseTrendChart(
              values: totals.map((value) => value.toDouble()).toList(),
              labels: days,
              color: AppColors.lime,
            ),
          ),
        ],
      ),
    );
  }
}

class PromiseTrendChart extends StatelessWidget {
  const PromiseTrendChart({super.key, 
    required this.values,
    required this.labels,
    required this.color,
    this.large = false,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final highestValue = values.fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = highestValue + 2 < 4 ? 4.0 : highestValue + 2;
    return RepaintBoundary(
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: large ? 2 : 3,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: .06),
              strokeWidth: 1,
              dashArray: [4, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[index],
                      style: const TextStyle(fontSize: 9, color: AppColors.muted),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: values
                  .asMap()
                  .entries
                  .map(
                    (entry) =>
                        FlSpot(entry.key.toDouble(), entry.value.toDouble()),
                  )
                  .toList(),
              isCurved: true,
              curveSmoothness: .34,
              color: color,
              barWidth: large ? 3 : 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: large,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 3.5,
                      color: color,
                      strokeWidth: 2,
                      strokeColor: AppColors.background,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: .09),
              ),
            ),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }
}
