import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../stores/dashboard_store.dart';
import '../widgets/device_manager_sheet.dart';
import '../widgets/ecg_waveform_card.dart';
import '../widgets/hrv_trend_card.dart';
import '../widgets/readiness_ring.dart';
import '../widgets/sleep_architecture_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardStore _store;

  @override
  void initState() {
    super.initState();
    _store = sl<DashboardStore>();
    _store.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final telemetry = _store.activeTelemetry;
        final connected = _store.connectedDevice;
        final hr = telemetry?.heartRate ?? 72;
        final spo2 = telemetry?.spo2 ?? 98;
        final hrv = telemetry?.hrv ?? 64;
        final tempDelta = telemetry?.skinTempDelta ?? 0.1;
        final signal = telemetry?.signalQuality ?? 99;
        final buffer = _store.ecgBuffer;
        final readiness = _store.readinessScore;

        return Scaffold(
          body: OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;

              if (isLandscape) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildDeviceHeader(connected),
                              const SizedBox(height: 12),
                              ReadinessRing(
                                score: readiness,
                                hrvMs: hrv,
                                restingHr: hr,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              EcgWaveformCard(
                                ecgBuffer: buffer,
                                heartRate: hr,
                                spo2: spo2,
                                skinTempDelta: tempDelta,
                                signalQuality: signal,
                              ),
                              const SizedBox(height: 12),
                              const SleepArchitectureCard(),
                              const SizedBox(height: 12),
                              const HrvTrendCard(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildDeviceHeader(connected),
                  const SizedBox(height: 14),
                  ReadinessRing(
                    score: readiness,
                    hrvMs: hrv,
                    restingHr: hr,
                  ),
                  const SizedBox(height: 14),
                  EcgWaveformCard(
                    ecgBuffer: buffer,
                    heartRate: hr,
                    spo2: spo2,
                    skinTempDelta: tempDelta,
                    signalQuality: signal,
                  ),
                  const SizedBox(height: 14),
                  const SleepArchitectureCard(),
                  const SizedBox(height: 14),
                  const HrvTrendCard(),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDeviceHeader(dynamic connected) {
    return GestureDetector(
      onTap: () => DeviceManagerSheet.show(context, _store),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.emeraldPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    connected != null ? connected.name : 'AuraRing Pro v2',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    connected != null
                        ? 'Connected via ${connected.sdk} • 99% packet fidelity'
                        : 'Connected via SDK_A • 99% packet fidelity',
                    style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.tune_rounded, size: 18, color: AppColors.emeraldPrimary),
          ],
        ),
      ),
    );
  }
}
