import 'package:flutter/material.dart';
import '../stores/nutrition_store.dart';

class HydrationTrackerCard extends StatelessWidget {
  final NutritionStore store;

  const HydrationTrackerCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = store.dailySummary;
    final consumedMl = summary?.consumedWaterMl ?? 0;
    final targetMl = summary?.targetWaterMl ?? 3000;
    final progress = summary?.waterProgress ?? 0.0;
    final streak = store.waterStreakDays;

    return Card(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
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
                    Icon(Icons.water_drop_rounded, size: 16, color: colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'HYDRATION ENGINE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '$streak Day Streak',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$consumedMl ml',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                    ),
                    Text(
                      'Target $targetMl ml per day',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colorScheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(colorScheme.secondary),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _WaterButton(label: '+250ml', onTap: () => store.logWater(250), colorScheme: colorScheme),
                const SizedBox(width: 8),
                _WaterButton(label: '+500ml', onTap: () => store.logWater(500), colorScheme: colorScheme),
                const SizedBox(width: 8),
                _WaterButton(label: '+750ml', onTap: () => store.logWater(750), colorScheme: colorScheme),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => store.resetHydration(),
                  icon: Icon(Icons.refresh_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                  tooltip: 'Reset Day Hydration',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _WaterButton({required this.label, required this.onTap, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
