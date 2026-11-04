import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/run_record.dart';

class RunSummarySheet extends StatelessWidget {
  final RunRecord record;

  const RunSummarySheet({super.key, required this.record});

  static void show(BuildContext context, RunRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RunSummarySheet(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 2),
                    const Text('Saved to SQLite run telemetry logs', style: TextStyle(fontSize: 12, color: AppColors.emeraldPrimary)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: AppColors.emeraldPrimary, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryTile(label: 'Distance', value: '${record.distanceKm} km'),
                Container(width: 1, height: 36, color: AppColors.darkBorder),
                _SummaryTile(label: 'Duration', value: record.durationFormatted),
                Container(width: 1, height: 36, color: AppColors.darkBorder),
                _SummaryTile(label: 'Avg Pace', value: record.paceFormatted),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('KILOMETER SPLIT ANALYSIS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkTextSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Expanded(
            child: record.splits.isEmpty
                ? const Center(child: Text('Under 1 km - no full split data recorded', style: TextStyle(color: AppColors.darkTextMuted)))
                : ListView.builder(
                    itemCount: record.splits.length,
                    itemBuilder: (context, index) {
                      final split = record.splits[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('KM ${split.km}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                            Text('Pace: ${split.paceFormatted} /km', style: const TextStyle(fontSize: 12, color: AppColors.cyanAccent)),
                            Text('${split.avgHeartRate} BPM', style: const TextStyle(fontSize: 12, color: AppColors.redAccent, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Close Summary', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
      ],
    );
  }
}
