import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class LineChartEntry {
  const LineChartEntry({required this.label, required this.value});

  final String label;
  final double value;
}

/// Gráfico de linha simples (1 série, sem eixos duplos) — mesmo espírito
/// minimalista do SimpleBarChart: sem dependências exóticas da API do
/// fl_chart, rótulos curtos, tooltip ao toque.
class SimpleLineChart extends StatelessWidget {
  const SimpleLineChart({super.key, required this.entries, this.color = AppColors.azulMatricula, this.height = 200});

  final List<LineChartEntry> entries;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final valores = entries.map((e) => e.value);
    final maxValue = valores.fold<double>(0, (a, b) => a > b ? a : b);
    final minValue = valores.fold<double>(0, (a, b) => a < b ? a : b);
    // Margem de 20% para o traço nunca colar aos limites do gráfico.
    final folga = ((maxValue - minValue).abs() * 0.2).clamp(1, double.infinity);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minValue - folga,
          maxY: maxValue + folga,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map(
                    (s) => LineTooltipItem(
                      s.y.toStringAsFixed(0),
                      AppTypography.numero(fontSize: 12, color: Colors.white),
                    ),
                  )
                  .toList(),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(entries[index].label, style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < entries.length; i++) FlSpot(i.toDouble(), entries[i].value)],
              isCurved: false,
              color: color,
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
            ),
          ],
        ),
      ),
    );
  }
}
