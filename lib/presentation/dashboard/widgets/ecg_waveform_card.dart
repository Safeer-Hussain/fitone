import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class EcgWaveformCard extends StatelessWidget {
  final List<double> ecgBuffer;
  final int heartRate;
  final int spo2;
  final double skinTempDelta;
  final int signalQuality;

  const EcgWaveformCard({
    super.key,
    required this.ecgBuffer,
    required this.heartRate,
    required this.spo2,
    required this.skinTempDelta,
    required this.signalQuality,
  });

  @override
  Widget build(BuildContext context) {
    final spots = List<FlSpot>.generate(
      ecgBuffer.length,
      (index) => FlSpot(index.toDouble(), ecgBuffer[index]),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.emeraldPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'LIVE PPG TELEMETRY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Signal $signalQuality%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emeraldPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$heartRate',
                  style: AppTypography.metricLarge.copyWith(color: Colors.white),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 6),
                  child: Text(
                    'BPM',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                _TelemetryTag(label: 'SpO2', value: '$spo2%'),
                const SizedBox(width: 12),
                _TelemetryTag(
                  label: 'Skin Temp',
                  value: '${skinTempDelta >= 0 ? "+" : ""}${skinTempDelta.toStringAsFixed(1)}C',
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 90,
              child: spots.isEmpty
                  ? const Center(child: Text('Synchronizing waveform stream...', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)))
                  : LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: (ecgBuffer.length - 1).toDouble().clamp(1.0, 50.0),
                        minY: -1.0,
                        maxY: 1.8,
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: AppColors.emeraldPrimary,
                            barWidth: 2.2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.emeraldPrimary.withOpacity(0.22),
                                  AppColors.emeraldPrimary.withOpacity(0.0),
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

  const _TelemetryTag({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
