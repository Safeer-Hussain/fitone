import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SleepArchitectureCard extends StatelessWidget {
  final int sleepScore;
  final String currentStage;

  const SleepArchitectureCard({
    super.key,
    this.sleepScore = 88,
    this.currentStage = 'DEEP',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SLEEP ARCHITECTURE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.purpleAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.purpleAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Score $sleepScore',
                    style: const TextStyle(
                      color: AppColors.purpleAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Duration', style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13)),
                Text('7h 48m (91% Efficiency)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 14),
            // Multi-segment stacked sleep bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 18,
                child: Row(
                  children: [
                    Expanded(flex: 24, child: Container(color: const Color(0xFF6366F1))), // Deep
                    Expanded(flex: 22, child: Container(color: const Color(0xFF8B5CF6))), // REM
                    Expanded(flex: 46, child: Container(color: const Color(0xFF38BDF8))), // Light
                    Expanded(flex: 8, child: Container(color: const Color(0xFFF43F5E))),  // Awake
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
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
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkTextSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
