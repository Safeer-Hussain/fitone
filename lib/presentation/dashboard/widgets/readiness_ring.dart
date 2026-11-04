import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_typography.dart';

class ReadinessRing extends StatelessWidget {
  final int score;
  final int hrvMs;
  final int restingHr;

  const ReadinessRing({
    super.key,
    required this.score,
    required this.hrvMs,
    required this.restingHr,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusText = score >= 85
        ? 'Optimal Readiness'
        : (score >= 70 ? 'Moderate Recovery' : 'Rest Advised');

    final statusColor = score >= 85
        ? colorScheme.primary
        : (score >= 70 ? colorScheme.secondary : const Color(0xFFFF9100));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECOVERY & READINESS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _ReadinessGaugePainter(
                  score: score,
                  primaryColor: statusColor,
                  trackColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: AppTypography.metricLarge.copyWith(color: colorScheme.onSurface),
                      ),
                      Text(
                        'SCORE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BiometricMetric(
                  label: 'HRV (ms)',
                  value: '$hrvMs',
                  sub: '+4ms vs 30d',
                  icon: Icons.graphic_eq_rounded,
                  accentColor: statusColor,
                ),
                Container(width: 1, height: 36, color: colorScheme.outlineVariant),
                _BiometricMetric(
                  label: 'Resting HR',
                  value: '$restingHr',
                  sub: 'BPM baseline',
                  icon: Icons.favorite_rounded,
                  accentColor: colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BiometricMetric extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color accentColor;

  const _BiometricMetric({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: accentColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.metricMedium.copyWith(color: colorScheme.onSurface),
        ),
        Text(
          sub,
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ReadinessGaugePainter extends CustomPainter {
  final int score;
  final Color primaryColor;
  final Color trackColor;

  _ReadinessGaugePainter({
    required this.score,
    required this.primaryColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;

    const startAngle = 0.75 * pi;
    const sweepAngle = 1.5 * pi;

    final backgroundPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    final progressSweep = (score / 100.0) * sweepAngle;
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [primaryColor.withValues(alpha: 0.4), primaryColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ReadinessGaugePainter oldDelegate) =>
      oldDelegate.score != score ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.trackColor != trackColor;
}
