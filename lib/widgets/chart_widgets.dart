import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Pie chart widget showing category-wise expense breakdown.
class ExpensePieChart extends StatefulWidget {
  final Map<String, double> categoryTotals;
  const ExpensePieChart({super.key, required this.categoryTotals});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryTotals.isEmpty) {
      return _emptyState(Icons.pie_chart_outline_rounded, 'No expense data yet');
    }
    final total = widget.categoryTotals.values.fold(0.0, (a, b) => a + b);
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    _touchedIndex = -1;
                    return;
                  }
                  _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 3,
            centerSpaceRadius: 40,
            sections: _buildSections(total),
          )),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12, runSpacing: 8, alignment: WrapAlignment.center,
          children: widget.categoryTotals.entries.map((entry) {
            final catData = getCategoryData(entry.key);
            final pct = (entry.value / total * 100).toStringAsFixed(1);
            return _LegendItem(color: catData.color, label: '${entry.key} ($pct%)');
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    final entries = widget.categoryTotals.entries.toList();
    return List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final entry = entries[i];
      final catData = getCategoryData(entry.key);
      final pct = entry.value / total * 100;
      return PieChartSectionData(
        color: catData.color,
        value: entry.value,
        title: isTouched ? formatCompactCurrency(entry.value) : '${pct.toStringAsFixed(0)}%',
        radius: isTouched ? 65 : 55,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
        ),
      );
    });
  }
}

/// Bar chart widget showing weekly or monthly spending.
class SpendingBarChart extends StatelessWidget {
  final Map<int, double> data;
  final bool isWeekly;
  const SpendingBarChart({super.key, required this.data, this.isWeekly = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.values.every((v) => v == 0)) {
      return _emptyState(Icons.bar_chart_rounded, 'No spending data yet');
    }
    final maxVal = data.values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 200,
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(formatCompactCurrency(rod.toY),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13));
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final label = isWeekly ? getDayName(value.toInt()) : getMonthName(value.toInt());
              return Padding(padding: const EdgeInsets.only(top: 8),
                child: Text(label, style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 11)));
            },
          )),
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 50,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const SizedBox.shrink();
              return Text(formatCompactCurrency(value),
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 10));
            },
          )),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true, drawVerticalLine: false,
          horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.entries.map((entry) => BarChartGroupData(
          x: entry.key,
          barRods: [BarChartRodData(
            toY: entry.value,
            width: isWeekly ? 22 : 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: LinearGradient(
              colors: [const Color(0xFF7C4DFF), const Color(0xFF448AFF).withValues(alpha: 0.7)],
              begin: Alignment.bottomCenter, end: Alignment.topCenter),
          )],
        )).toList(),
      )),
    );
  }
}

Widget _emptyState(IconData icon, String msg) {
  return Center(child: Padding(padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 64, color: Colors.grey),
      const SizedBox(height: 16),
      Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 16)),
    ])));
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
    ]);
  }
}
