import 'package:flutter/material.dart';
import '../stores/gps_running_store.dart';

class RunningMetricsOverlay extends StatelessWidget {
  final GpsRunningStore store;

  const RunningMetricsOverlay({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      store.isSimulating ? 'SIMULATING GPS (LAHORE)' : 'GPS ACTIVE (ACCURACY 3M)',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  store.hrZone,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colorScheme.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(label: 'TIME', value: store.formattedDuration, colorScheme: colorScheme),
              _MetricItem(label: 'DISTANCE', value: '${store.distanceKm.toStringAsFixed(2)} km', colorScheme: colorScheme),
              _MetricItem(label: 'PACE', value: store.formattedPace, colorScheme: colorScheme),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SubMetric(
                label: 'Smart-Ring HR',
                value: '${store.currentHeartRate} BPM',
                icon: Icons.favorite_rounded,
                color: colorScheme.error,
                colorScheme: colorScheme,
              ),
              _SubMetric(
                label: 'Elevation Gain',
                value: '${store.elevationGainM.toStringAsFixed(1)} m',
                icon: Icons.terrain_rounded,
                color: colorScheme.secondary,
                colorScheme: colorScheme,
              ),
              _SubMetric(
                label: 'Energy Burned',
                value: '${store.caloriesBurned.toStringAsFixed(0)} kcal',
                icon: Icons.local_fire_department_rounded,
                color: colorScheme.tertiary,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _MetricItem({required this.label, required this.value, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colorScheme.onSurface),
        ),
      ],
    );
  }
}

class _SubMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ColorScheme colorScheme;

  const _SubMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
            ),
          ],
        ),
      ],
    );
  }
}
