import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../stores/gps_running_store.dart';

class RunningMetricsOverlay extends StatelessWidget {
  final GpsRunningStore store;

  const RunningMetricsOverlay({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
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
                  color: AppColors.emeraldPrimary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.emeraldPrimary, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      store.isSimulating ? 'SIMULATING GPS (LAHORE)' : 'GPS ACTIVE (ACCURACY 3M)',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.emeraldPrimary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  store.hrZone,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(label: 'TIME', value: store.formattedDuration),
              _MetricItem(label: 'DISTANCE', value: '${store.distanceKm.toStringAsFixed(2)} km'),
              _MetricItem(label: 'PACE', value: store.formattedPace),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.darkBorder),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SubMetric(label: 'Smart-Ring HR', value: '${store.currentHeartRate} BPM', icon: Icons.favorite_rounded, color: AppColors.redAccent),
              _SubMetric(label: 'Elevation Gain', value: '${store.elevationGainM.toStringAsFixed(1)} m', icon: Icons.terrain_rounded, color: AppColors.cyanAccent),
              _SubMetric(label: 'Energy Burned', value: '${store.caloriesBurned.toStringAsFixed(0)} kcal', icon: Icons.local_fire_department_rounded, color: AppColors.orangeAccent),
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

  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
      ],
    );
  }
}

class _SubMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SubMetric({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted)),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ],
    );
  }
}
