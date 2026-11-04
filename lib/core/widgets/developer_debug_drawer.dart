import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../constants/app_colors.dart';
import '../database/app_database.dart';
import '../network/network_monitor.dart';

class DeveloperDebugDrawer extends StatelessWidget {
  const DeveloperDebugDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final monitor = NetworkMonitor.instance;

    return Drawer(
      backgroundColor: AppColors.darkBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.terminal_rounded, color: AppColors.emeraldPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Developer & Recruiter Hub',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Telemetry, Latency & Error Injection',
                          style: TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'NETWORK SIMULATION',
                    style: TextStyle(
                      color: AppColors.emeraldPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Observer(
                    builder: (_) => SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Force API Error (503)', style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Tests Dio interceptor error handling & retry UI', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                      value: monitor.forceApiError,
                      activeColor: AppColors.redAccent,
                      onChanged: (val) => monitor.setForceApiError(val),
                    ),
                  ),
                  const Divider(color: AppColors.darkBorder),
                  Observer(
                    builder: (_) => SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Simulate Offline Mode', style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Forces local SQLite database cache usage', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                      value: !monitor.isOnline,
                      activeColor: AppColors.orangeAccent,
                      onChanged: (val) => monitor.setManualOnlineState(!val),
                    ),
                  ),
                  const Divider(color: AppColors.darkBorder),
                  const SizedBox(height: 12),
                  Observer(
                    builder: (_) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Simulated Network Latency', style: TextStyle(fontSize: 14)),
                            Text('${monitor.simulatedLatencyMs} ms', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.emeraldPrimary)),
                          ],
                        ),
                        Slider(
                          value: monitor.simulatedLatencyMs.toDouble(),
                          min: 0,
                          max: 2000,
                          divisions: 20,
                          activeColor: AppColors.emeraldPrimary,
                          inactiveColor: AppColors.darkSurfaceElevated,
                          onChanged: (val) => monitor.setSimulatedLatency(val.toInt()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'WEARABLE TELEMETRY RATE',
                    style: TextStyle(
                      color: AppColors.emeraldPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Observer(
                    builder: (_) => Row(
                      children: [
                        _TelemetryChip(
                          label: '500ms (High)',
                          isSelected: monitor.telemetryIntervalMs == 500,
                          onTap: () => monitor.setTelemetryInterval(500),
                        ),
                        const SizedBox(width: 8),
                        _TelemetryChip(
                          label: '2000ms (Std)',
                          isSelected: monitor.telemetryIntervalMs == 2000,
                          onTap: () => monitor.setTelemetryInterval(2000),
                        ),
                        const SizedBox(width: 8),
                        _TelemetryChip(
                          label: '5000ms (Eco)',
                          isSelected: monitor.telemetryIntervalMs == 5000,
                          onTap: () => monitor.setTelemetryInterval(5000),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'DATABASE OPERATIONS',
                    style: TextStyle(
                      color: AppColors.emeraldPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final db = await AppDatabase.instance.database;
                      await db.delete('workouts');
                      await db.delete('workout_sets');
                      await db.delete('running_routes');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transient logs cleared. Seed tables retained.'),
                            backgroundColor: AppColors.darkSurfaceElevated,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                    label: const Text('Reset Temporary Run & Workout Logs'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkTextPrimary,
                      side: const BorderSide(color: AppColors.darkBorder),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TelemetryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TelemetryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.emeraldPrimary : AppColors.darkSurfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.emeraldPrimary : AppColors.darkBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.black : AppColors.darkTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
