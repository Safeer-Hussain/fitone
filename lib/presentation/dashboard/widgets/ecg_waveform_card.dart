import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_typography.dart';

class EcgWaveformCard extends StatelessWidget {
  final List<double> ecgBuffer;
  final int heartRate;
  final int spo2;
  final double skinTempDelta;
  final int signalQuality;
  final bool isCompact;

  const EcgWaveformCard({
    super.key,
    required this.ecgBuffer,
    required this.heartRate,
    required this.spo2,
    required this.skinTempDelta,
    required this.signalQuality,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final spots = List<FlSpot>.generate(
      ecgBuffer.length,
      (index) => FlSpot(index.toDouble(), ecgBuffer[index]),
    );

    final maxX = ecgBuffer.length > 1 ? (ecgBuffer.length - 1).toDouble() : 1.0;

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 12 : 16,
                isCompact ? 10 : 16,
                isCompact ? 12 : 16,
                isCompact ? 6 : 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'LIVE PPG TELEMETRY',
                            style: TextStyle(
                              fontSize: isCompact ? 10 : 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Signal $signalQuality%',
                        style: TextStyle(
                          fontSize: isCompact ? 10 : 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 6 : 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$heartRate',
                        style: isCompact
                            ? TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colorScheme.onSurface)
                            : AppTypography.metricLarge.copyWith(color: colorScheme.onSurface),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: isCompact ? 4.0 : 8.0, left: 6),
                        child: Text(
                          'BPM',
                          style: TextStyle(
                            fontSize: isCompact ? 11 : 13,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _TelemetryTag(label: 'SpO2', value: '$spo2%', isCompact: isCompact),
                      const SizedBox(width: 8),
                      _TelemetryTag(
                        label: 'Skin Temp',
                        value: '${skinTempDelta >= 0 ? "+" : ""}${skinTempDelta.toStringAsFixed(1)}C',
                        isCompact: isCompact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: isCompact ? 75 : 95,
              child: spots.isEmpty
                  ? Center(
                      child: Text(
                        'Synchronizing waveform stream...',
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: maxX,
                        minY: -1.0,
                        maxY: 1.8,
                        clipData: const FlClipData.all(),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(
                          show: false,
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, reservedSize: 0)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, reservedSize: 0)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, reservedSize: 0)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, reservedSize: 0)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: colorScheme.primary,
                            barWidth: 2.2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colorScheme.primary.withValues(alpha: 0.25),
                                  colorScheme.primary.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TelemetryTag extends StatelessWidget {
  final String label;
  final String value;
  final bool isCompact;

  const _TelemetryTag({required this.label, required this.value, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10, vertical: isCompact ? 4 : 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isCompact ? 9 : 10,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
