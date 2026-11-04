import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../stores/dashboard_store.dart';

class DeviceManagerSheet extends StatelessWidget {
  final DashboardStore store;

  const DeviceManagerSheet({super.key, required this.store});

  static void show(BuildContext context, DashboardStore store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeviceManagerSheet(store: store),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wearable Ecosystem Hub',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Dual Native BLE Bridges (Kotlin / Swift)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => store.scanDevices(),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.emeraldPrimary),
                  tooltip: 'Rescan BLE Devices',
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.darkBorder),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'DISCOVERED SMART RINGS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.emeraldPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Observer(
                  builder: (_) {
                    final devices = store.scannedDevices;
                    if (devices.isEmpty) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Scanning for BLE advertisement packets...', style: TextStyle(color: AppColors.darkTextMuted)),
                      ));
                    }
                    return Column(
                      children: devices.map((device) {
                        final isAura = device.sdk == 'SDK_A';
                        final imagePath = isAura ? AppAssets.ringAura : AppAssets.ringKinetix;
                        final isConnected = store.connectedDevice?.id == device.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isConnected ? AppColors.emeraldPrimary : AppColors.darkBorder,
                              width: isConnected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  imagePath,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 64,
                                    height: 64,
                                    color: AppColors.darkSurfaceElevated,
                                    child: const Icon(Icons.ring_volume, color: AppColors.emeraldPrimary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          device.name,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                                        ),
                                        if (isConnected) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.emeraldPrimary.withOpacity(0.18),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text('ACTIVE', style: TextStyle(color: AppColors.emeraldPrimary, fontSize: 9, fontWeight: FontWeight.w800)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Protocol: ${device.sdk} • FW: ${device.firmware}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Battery: ${device.battery}% • RSSI: ${device.rssi} dBm',
                                      style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: isConnected
                                    ? () => store.disconnectDevice()
                                    : () => store.connectDevice(device.id, device.sdk),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isConnected ? AppColors.darkSurfaceElevated : AppColors.emeraldPrimary,
                                  foregroundColor: isConnected ? Colors.white : Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(isConnected ? 'Disconnect' : 'Connect', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HARDWARE DIAGNOSTICS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: AppColors.emeraldPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => store.runDiagnostics(),
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('Run Diagnostics', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Observer(
                  builder: (_) {
                    final diag = store.diagnostics;
                    if (diag == null) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: const Text('Tap Run Diagnostics to interrogate optical PPG, IMU, and BLE transceivers.', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Column(
                        children: [
                          _DiagRow(sensor: 'Optical PPG Array', result: diag.opticalPPG),
                          const Divider(color: AppColors.darkBorder, height: 16),
                          _DiagRow(sensor: 'Temperature Sensor', result: diag.temperatureSensor),
                          const Divider(color: AppColors.darkBorder, height: 16),
                          _DiagRow(sensor: '6-Axis IMU Sensor', result: diag.sixAxisIMU),
                          const Divider(color: AppColors.darkBorder, height: 16),
                          _DiagRow(sensor: 'BLE 5.3 Transceiver', result: diag.bleTransceiver),
                          const Divider(color: AppColors.darkBorder, height: 16),
                          _DiagRow(sensor: 'Battery Retained Cap.', result: diag.batteryHealth),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'EVENTCHANNEL NATIVE PACKET LOG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.emeraldPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Observer(
                  builder: (_) {
                    final packets = store.recentPackets;
                    if (packets.isEmpty) {
                      return const Text('Listening to native EventChannel stream...', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12));
                    }
                    return Column(
                      children: packets.take(5).map((p) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${p.packetId} • HR: ${p.heartRate} BPM • SpO2: ${p.spo2}%',
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.white),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldPrimary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('CRC: ${p.checksum}', style: const TextStyle(fontSize: 10, color: AppColors.emeraldPrimary, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagRow extends StatelessWidget {
  final String sensor;
  final String result;

  const _DiagRow({required this.sensor, required this.result});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(sensor, style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
        Text(result, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.emeraldPrimary)),
      ],
    );
  }
}
