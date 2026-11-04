import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/theme_store.dart';
import '../stores/exercise_store.dart';
import '../stores/workout_logger_store.dart';
import '../widgets/one_rm_calculator_sheet.dart';
import '../widgets/rest_timer_dialog.dart';

class WorkoutLoggerView extends StatefulWidget {
  const WorkoutLoggerView({super.key});

  @override
  State<WorkoutLoggerView> createState() => _WorkoutLoggerViewState();
}

class _WorkoutLoggerViewState extends State<WorkoutLoggerView> {
  late final WorkoutLoggerStore _loggerStore;
  late final ExerciseStore _exerciseStore;
  final ThemeStore _themeStore = sl<ThemeStore>();

  double _inputWeight = 80.0;
  int _inputReps = 8;
  final double _inputRpe = 8.0;
  String _selectedExerciseId = 'ex_01';

  @override
  void initState() {
    super.initState();
    _loggerStore = sl<WorkoutLoggerStore>();
    _exerciseStore = sl<ExerciseStore>();
    if (!_loggerStore.isSessionActive) {
      _loggerStore.startWorkout(title: 'Upper Hypertrophy Session');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final _ = _themeStore.themeMode;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final session = _loggerStore.activeSession;
        final unit = _loggerStore.unit;
        final isRestRunning = _loggerStore.isRestTimerRunning;
        final restRemaining = _loggerStore.restTimeRemaining;
        final exercises = _exerciseStore.exercises;

        final currentExercise = exercises.where((e) => e.id == _selectedExerciseId).firstOrNull;

        return Scaffold(
          appBar: AppBar(
            title: Text(session?.title ?? 'Active Workout Logger'),
            actions: [
              TextButton(
                onPressed: () => _loggerStore.toggleUnit(),
                child: Text(
                  unit.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w800, color: colorScheme.primary),
                ),
              ),
              IconButton(
                onPressed: () => OneRmCalculatorSheet.show(context),
                icon: Icon(Icons.calculate_outlined, color: colorScheme.secondary),
                tooltip: '1RM Calculator',
              ),
            ],
          ),
          body: OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;

              if (isLandscape) {
                return SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            children: [
                              _buildSummaryCard(session, colorScheme),
                              const SizedBox(height: 8),
                              _buildInputCard(currentExercise, exercises, unit, colorScheme),
                              const SizedBox(height: 8),
                              _buildBottomBar(context, isRestRunning, restRemaining, colorScheme),
                            ],
                          ),
                        ),
                      ),
                      VerticalDivider(color: colorScheme.outlineVariant, width: 1),
                      Expanded(
                        flex: 5,
                        child: _buildSetsList(session, colorScheme),
                      ),
                    ],
                  ),
                );
              }

              return SafeArea(
                child: Column(
                  children: [
                    _buildSummaryCard(session, colorScheme),
                    _buildInputCard(currentExercise, exercises, unit, colorScheme),
                    Divider(color: colorScheme.outlineVariant, height: 1),
                    Expanded(child: _buildSetsList(session, colorScheme)),
                    _buildBottomBar(context, isRestRunning, restRemaining, colorScheme),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(dynamic session, ColorScheme colorScheme) {
    final volume = session?.totalVolumeKg ?? 0.0;
    final setsCount = session?.completedSets ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'Total Volume', value: '${volume.toStringAsFixed(0)} kg', colorScheme: colorScheme),
          Container(width: 1, height: 30, color: colorScheme.outlineVariant),
          _Stat(label: 'Sets Done', value: '$setsCount', colorScheme: colorScheme),
          Container(width: 1, height: 30, color: colorScheme.outlineVariant),
          _Stat(label: 'Est. Cal', value: '380 kcal', colorScheme: colorScheme),
        ],
      ),
    );
  }

  Widget _buildInputCard(
    dynamic currentExercise,
    List<dynamic> exercises,
    String unit,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedExerciseId,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            dropdownColor: colorScheme.surface,
            items: exercises.map((e) {
              return DropdownMenuItem<String>(
                value: e.id,
                child: Text(
                  e.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedExerciseId = val);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight ($unit): ${_inputWeight.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                    ),
                    Slider(
                      value: _inputWeight,
                      min: 10,
                      max: 200,
                      divisions: 38,
                      activeColor: colorScheme.primary,
                      inactiveColor: colorScheme.surfaceContainerHighest,
                      onChanged: (v) => setState(() => _inputWeight = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reps: $_inputReps',
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                    ),
                    Slider(
                      value: _inputReps.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      activeColor: colorScheme.secondary,
                      inactiveColor: colorScheme.surfaceContainerHighest,
                      onChanged: (v) => setState(() => _inputReps = v.toInt()),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _loggerStore.addSet(
                    exerciseId: _selectedExerciseId,
                    weight: _inputWeight,
                    reps: _inputReps,
                    rpe: _inputRpe,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Log Set', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetsList(dynamic session, ColorScheme colorScheme) {
    final sets = session?.sets ?? [];
    if (sets.isEmpty) {
      return Center(
        child: Text(
          'No sets logged yet. Adjust weight and tap Log Set.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets[index];
        final ex = _exerciseStore.exercises.where((e) => e.id == set.exerciseId).firstOrNull;

        return Dismissible(
          key: ValueKey(set.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: colorScheme.error.withValues(alpha: 0.3),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.delete_outline, color: colorScheme.error),
          ),
          onDismissed: (_) => _loggerStore.removeSet(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: set.isCompleted
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${set.setNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex?.name ?? 'Compound Lift',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: colorScheme.onSurface),
                      ),
                      Text(
                        '${set.weightKg.toStringAsFixed(1)} kg × ${set.reps} reps • RPE ${set.rpe.toStringAsFixed(1)} • 1RM: ${set.oneRepMaxEpley.toStringAsFixed(0)}kg',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _loggerStore.toggleSetCompletion(index),
                  icon: Icon(
                    set.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: set.isCompleted ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    bool isRestRunning,
    int restRemaining,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          if (isRestRunning)
            Expanded(
              child: GestureDetector(
                onTap: () => RestTimerDialog.show(context, _loggerStore),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Rest: ${restRemaining}s',
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => RestTimerDialog.show(context, _loggerStore),
                icon: const Icon(Icons.timer_outlined, size: 16),
                label: const Text('Rest Timer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await _loggerStore.finishWorkout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Workout session saved to local SQLite database.'),
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Finish Workout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _Stat({required this.label, required this.value, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
      ],
    );
  }
}
