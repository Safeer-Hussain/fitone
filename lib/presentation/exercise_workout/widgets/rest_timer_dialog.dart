import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../stores/workout_logger_store.dart';

class RestTimerDialog extends StatelessWidget {
  final WorkoutLoggerStore store;

  const RestTimerDialog({super.key, required this.store});

  static void show(BuildContext context, WorkoutLoggerStore store) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => RestTimerDialog(store: store),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Observer(
          builder: (_) {
            final remaining = store.restTimeRemaining;
            final total = store.restTimeTotal > 0 ? store.restTimeTotal : 90;
            final progress = (remaining / total).clamp(0.0, 1.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'INTRASESSION REST TIMER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.emeraldPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.darkSurfaceElevated,
                        valueColor: const AlwaysStoppedAnimation(AppColors.emeraldPrimary),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$remaining',
                            style: AppTypography.metricLarge.copyWith(color: Colors.white),
                          ),
                          const Text(
                            'SECONDS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.darkTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => store.startRestTimer(remaining + 30),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkTextPrimary,
                        side: const BorderSide(color: AppColors.darkBorder),
                      ),
                      child: const Text('+30s'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        store.stopRestTimer();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldPrimary,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Skip Rest'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
