import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/theme_store.dart';
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
  final ThemeStore _themeStore = sl<ThemeStore>();
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
    return Observer(
      builder: (_) {
        final _ = _themeStore.themeMode;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

        final isTracking = _store.isTracking;
        final isPaused = _store.isPaused;
        final coords = _store.coordinates;

        final polylinePoints = coords.map((c) => LatLng(c.lat, c.lng)).toList();
        final currentPos = polylinePoints.isNotEmpty ? polylinePoints.last : _initialLahoreCenter;

        Widget buildMapWidget() {
          return FlutterMap(
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
                    color: colorScheme.primary,
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
                      child: Icon(Icons.flag_circle_rounded, color: colorScheme.secondary, size: 28),
                    ),
                  Marker(
                    point: currentPos,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.navigation_rounded, color: colorScheme.primary, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        Widget buildControls() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isTracking) ...[
                FloatingActionButton.small(
                  heroTag: 'pause_btn',
                  onPressed: isPaused ? () => _store.resumeRun() : () => _store.pauseRun(),
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.primary,
                  child: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: 'stop_btn',
                  onPressed: () async {
                    final record = await _store.finishAndSaveRun();
                    if (record != null && context.mounted) {
                      RunSummarySheet.show(context, record);
                    }
                  },
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  icon: const Icon(Icons.stop_rounded, size: 18),
                  label: const Text('Finish Run', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ] else ...[
                FloatingActionButton.extended(
                  heroTag: 'start_run_btn',
                  onPressed: () {
                    _store.startSimulatedRun();
                  },
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  icon: const Icon(Icons.directions_run_rounded, size: 18),
                  label: const Text('Start GPS Run', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ],
          );
        }

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: isLandscape ? 36 : null,
            title: Text(
              'GPS Route Tracker',
              style: TextStyle(fontSize: isLandscape ? 13 : 16, fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                onPressed: () => _showHistorySheet(context, colorScheme),
                icon: Icon(Icons.history_rounded, color: colorScheme.primary, size: isLandscape ? 18 : 22),
                tooltip: 'Run History',
              ),
            ],
          ),
          body: isLandscape
              ? SafeArea(
                  child: Row(
                    children: [
                      // Left Pane (60% width): Interactive map canvas filling the height cleanly
                      Expanded(
                        flex: 60,
                        child: Stack(
                          children: [
                            buildMapWidget(),
                            if (!isTracking)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _store.startSimulatedRun();
                                    _mapController.move(_initialLahoreCenter, 15.0);
                                  },
                                  icon: const Icon(Icons.play_circle_filled_rounded, size: 16),
                                  label: const Text('Simulate Run (Lahore)', style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      VerticalDivider(color: colorScheme.outlineVariant, width: 1),
                      // Right Pane (40% width): Floating HUD card containing live pace, elapsed time, distance, and HR zone
                      Expanded(
                        flex: 40,
                        child: Container(
                          color: colorScheme.surface,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              children: [
                                RunningMetricsOverlay(store: _store, isCompact: true),
                                const SizedBox(height: 10),
                                buildControls(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    buildMapWidget(),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: isTracking
                          ? RunningMetricsOverlay(store: _store)
                          : ElevatedButton.icon(
                              onPressed: () {
                                _store.startSimulatedRun();
                                _mapController.move(_initialLahoreCenter, 15.0);
                              },
                              icon: const Icon(Icons.play_circle_filled_rounded, size: 18),
                              label: const Text('Simulate Run (Lahore)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 4,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 20,
                      right: 20,
                      child: buildControls(),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showHistorySheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Logged Outdoor Running Sessions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: Observer(
                      builder: (_) {
                        final runs = _store.pastRuns;
                        if (runs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'No recorded running sessions yet.',
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: runs.length,
                          itemBuilder: (context, index) {
                            final r = runs[index];
                            return Card(
                              color: colorScheme.surfaceContainer,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  RunSummarySheet.show(context, r);
                                },
                                title: Text(
                                  r.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  '${r.distanceKm} km • ${r.durationFormatted} • Pace ${r.paceFormatted}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                ),
                                trailing: Text(
                                  '${r.caloriesBurned.toStringAsFixed(0)} kcal',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.tertiary),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
