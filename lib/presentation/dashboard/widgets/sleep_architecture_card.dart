import 'package:flutter/material.dart';

class SleepArchitectureCard extends StatelessWidget {
  final int sleepScore;
  final String currentStage;
  final bool isCompact;

  const SleepArchitectureCard({
    super.key,
    this.sleepScore = 88,
    this.currentStage = 'DEEP',
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const purpleAccent = Color(0xFFB388FF);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SLEEP ARCHITECTURE',
                  style: TextStyle(
                    fontSize: isCompact ? 10 : 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 8, vertical: isCompact ? 2 : 3),
                  decoration: BoxDecoration(
                    color: purpleAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: purpleAccent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Score $sleepScore',
                    style: const TextStyle(
                      color: purpleAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 8 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Duration',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: isCompact ? 11 : 13),
                ),
                Text(
                  '7h 48m (91% Efficiency)',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: isCompact ? 11 : 13,
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 8 : 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: isCompact ? 12 : 18,
                child: Row(
                  children: [
                    Expanded(flex: 24, child: Container(color: const Color(0xFF6366F1))),
                    Expanded(flex: 22, child: Container(color: const Color(0xFF8B5CF6))),
                    Expanded(flex: 46, child: Container(color: const Color(0xFF38BDF8))),
                    Expanded(flex: 8, child: Container(color: const Color(0xFFF43F5E))),
                  ],
                ),
              ),
            ),
            SizedBox(height: isCompact ? 8 : 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SleepStageLegend(color: Color(0xFF6366F1), label: 'Deep (1h 52m)'),
                _SleepStageLegend(color: Color(0xFF8B5CF6), label: 'REM (1h 43m)'),
                _SleepStageLegend(color: Color(0xFF38BDF8), label: 'Light (3h 35m)'),
                _SleepStageLegend(color: Color(0xFFF43F5E), label: 'Awake (38m)'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepStageLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _SleepStageLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
