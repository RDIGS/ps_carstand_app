import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class BarChartEntry {
  const BarChartEntry({required this.label, required this.value});

  final String label;
  final double value;
}

/// Gráfico de barras simples e sem dependências exóticas da API do
/// fl_chart (secção 12.5 — "dashboard com gráficos, não só tabelas").
/// Rótulos curtos e sem rotação de propósito: nunca corrido contra o
/// Flutter SDK real, por isso evita a superfície de API mais instável
/// entre versões (títulos customizados/rotacionados).
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({super.key, required this.entries, this.color = AppColors.azulMatricula, this.height = 200});

  final List<BarChartEntry> entries;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final maxValue = entries.map((e) => e.value).fold<double>(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxValue <= 0 ? 1 : maxValue * 1.2,
          barGroups: [
            for (var i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value,
                    color: color,
                    width: 22,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) return const SizedBox.shrink();
                  final label = entries[index].label;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label.length > 10 ? '${label.substring(0, 9)}…' : label,
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                rod.toY.toStringAsFixed(0),
                AppTypography.numero(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
