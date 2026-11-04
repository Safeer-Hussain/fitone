import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../stores/gps_running_store.dart';
import '../widgets/run_summary_sheet.dart';
import '../widgets/running_metrics_overlay.dart';

class GpsRunningView extends StatefulWidget {
  const GpsRunningView({super.key});

  @override
  State<GpsRunningView> createState() => _GpsRunningViewState();
}

class _GpsRunningViewState extends State<GpsRunningView> {
  late final GpsRunningStore _store;
  final MapController _mapController = MapController();

  final LatLng _initialLahoreCenter = const LatLng(31.5204, 74.3587);

  @override
  void initState() {
    super.initState();
    _store = sl<GpsRunningStore>();
    _store.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Route Tracker'),
        actions: [
          IconButton(
            onPressed: () => _showHistorySheet(context),
            icon: const Icon(Icons.history_rounded, color: AppColors.emeraldPrimary),
            tooltip: 'Run History',
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          final isTracking = _store.isTracking;
          final isPaused = _store.isPaused;
          final coords = _store.coordinates;

          final polylinePoints = coords.map((c) => LatLng(c.lat, c.lng)).toList();
          final currentPos = polylinePoints.isNotEmpty ? polylinePoints.last : _initialLahoreCenter;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentPos,
                  initialZoom: 14.5,
                  minZoom: 10,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.safeer.fitone',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: polylinePoints,
                        strokeWidth: 4.5,
                        color: AppColors.emeraldPrimary,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      if (polylinePoints.isNotEmpty)
                        Marker(
                          point: polylinePoints.first,
                          width: 32,
                          height: 32,
                          child: const Icon(Icons.flag_circle_rounded, color: AppColors.cyanAccent, size: 28),
                        ),
                      Marker(
                        point: currentPos,
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.emeraldPrimary.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.navigation_rounded, color: AppColors.emeraldPrimary, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Top control chips
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    if (!isTracking) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _store.startSimulatedRun();
                            _mapController.move(_initialLahoreCenter, 15.0);
                          },
                          icon: const Icon(Icons.play_circle_filled_rounded, size: 18),
                          label: const Text('Simulate Run (Lahore)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emeraldPrimary,
                            foregroundColor: Colors.black,
                            elevation: 4,
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: RunningMetricsOverlay(store: _store),
                      ),
                    ],
                  ],
                ),
              ),
              // Bottom Floating action buttons
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isTracking) ...[
                      FloatingActionButton(
                        heroTag: 'pause_btn',
                        onPressed: isPaused ? () => _store.resumeRun() : () => _store.pauseRun(),
                        backgroundColor: AppColors.darkSurface,
                        foregroundColor: AppColors.emeraldPrimary,
                        child: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                      ),
                      const SizedBox(width: 24),
                      FloatingActionButton.extended(
                        heroTag: 'stop_btn',
                        onPressed: () async {
                          final record = await _store.finishAndSaveRun();
                          if (record != null && context.mounted) {
                            RunSummarySheet.show(context, record);
                          }
                        },
                        backgroundColor: AppColors.redAccent,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.stop_rounded),
                        label: const Text('Finish Run', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ] else ...[
                      FloatingActionButton.extended(
                        heroTag: 'start_run_btn',
                        onPressed: () {
                          _store.startSimulatedRun();
                        },
                        backgroundColor: AppColors.emeraldPrimary,
                        foregroundColor: Colors.black,
                        icon: const Icon(Icons.directions_run_rounded),
                        label: const Text('Start GPS Run', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.darkBorder)),
          ),
          padding: const EdgeInsets.all(20),
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
              const Text('Logged Outdoor Running Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 14),
              Expanded(
                child: Observer(
                  builder: (_) {
                    final runs = _store.pastRuns;
                    if (runs.isEmpty) {
                      return const Center(child: Text('No recorded running sessions yet.', style: TextStyle(color: AppColors.darkTextMuted)));
                    }

                    return ListView.builder(
                      itemCount: runs.length,
                      itemBuilder: (context, index) {
                        final r = runs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).pop();
                              RunSummarySheet.show(context, r);
                            },
                            title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
                            subtitle: Text('${r.distanceKm} km • ${r.durationFormatted} • Pace ${r.paceFormatted}', style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                            trailing: Text('${r.caloriesBurned.toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.orangeAccent)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
