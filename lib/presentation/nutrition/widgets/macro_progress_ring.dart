import 'package:flutter/material.dart';
import '../../../domain/entities/nutrition_day.dart';

class MacroProgressRing extends StatelessWidget {
  final DailyNutritionSummary summary;
  final bool isCompact;

  const MacroProgressRing({super.key, required this.summary, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final caloriesRemaining = (summary.targetCalories - summary.consumedCalories).clamp(0.0, 9999.0);

    final ringSize = isCompact ? 80.0 : 120.0;
    final strokeWidth = isCompact ? 7.0 : 10.0;

    return Card(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DAILY ENERGY & MACROS',
                  style: TextStyle(
                    fontSize: isCompact ? 10 : 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${caloriesRemaining.toStringAsFixed(0)} kcal left',
                  style: TextStyle(
                    fontSize: isCompact ? 10 : 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 10 : 20),
            Row(
              children: [
                SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: summary.calorieProgress,
                        strokeWidth: strokeWidth,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            summary.consumedCalories.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: isCompact ? 16 : 22,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'KCAL',
                            style: TextStyle(
                              fontSize: isCompact ? 8 : 9,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isCompact ? 12 : 24),
                Expanded(
                  child: Column(
                    children: [
                      _MacroBar(
                        label: 'Protein',
                        consumed: summary.consumedProteinG,
                        target: summary.targetProteinG,
                        color: colorScheme.secondary,
                        isCompact: isCompact,
                      ),
                      SizedBox(height: isCompact ? 6 : 10),
                      _MacroBar(
                        label: 'Carbs',
                        consumed: summary.consumedCarbsG,
                        target: summary.targetCarbsG,
                        color: colorScheme.tertiary,
                        isCompact: isCompact,
                      ),
                      SizedBox(height: isCompact ? 6 : 10),
                      _MacroBar(
                        label: 'Fats',
                        consumed: summary.consumedFatG,
                        target: summary.targetFatG,
                        color: Colors.purpleAccent,
                        isCompact: isCompact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final Color color;
  final bool isCompact;

  const _MacroBar({
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: isCompact ? 10 : 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
            ),
            Text(
              '${consumed.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}g',
              style: TextStyle(fontSize: isCompact ? 9 : 11, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: isCompact ? 4 : 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
