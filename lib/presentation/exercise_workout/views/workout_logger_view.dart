import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
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
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.emeraldPrimary),
                ),
              ),
              IconButton(
                onPressed: () => OneRmCalculatorSheet.show(context),
                icon: const Icon(Icons.calculate_outlined, color: AppColors.cyanAccent),
                tooltip: '1RM Calculator',
              ),
            ],
          ),
          body: OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;

              if (isLandscape) {
                return Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSummaryCard(session),
                            const SizedBox(height: 12),
                            _buildInputCard(currentExercise, exercises, unit),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(color: AppColors.darkBorder),
                    Expanded(
                      flex: 5,
                      child: _buildSetsList(session),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildSummaryCard(session),
                  _buildInputCard(currentExercise, exercises, unit),
                  const Divider(color: AppColors.darkBorder, height: 1),
                  Expanded(child: _buildSetsList(session)),
                  _buildBottomBar(context, isRestRunning, restRemaining),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(dynamic session) {
    final volume = session?.totalVolumeKg ?? 0.0;
    final setsCount = session?.completedSets ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.darkSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'Total Volume', value: '${volume.toStringAsFixed(0)} kg'),
          Container(width: 1, height: 30, color: AppColors.darkBorder),
          _Stat(label: 'Sets Done', value: '$setsCount'),
          Container(width: 1, height: 30, color: AppColors.darkBorder),
          const _Stat(label: 'Est. Cal', value: '380 kcal'),
        ],
      ),
    );
  }

  Widget _buildInputCard(dynamic currentExercise, List<dynamic> exercises, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.darkBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedExerciseId,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  dropdownColor: AppColors.darkSurface,
                  items: exercises.map((e) {
                    return DropdownMenuItem<String>(
                      value: e.id,
                      child: Text(e.name, style: const TextStyle(fontSize: 13, color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedExerciseId = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight ($unit): ${_inputWeight.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary)),
                    Slider(
                      value: _inputWeight,
                      min: 10,
                      max: 200,
                      divisions: 38,
                      activeColor: AppColors.emeraldPrimary,
                      inactiveColor: AppColors.darkSurfaceElevated,
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
                    Text('Reps: $_inputReps', style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary)),
                    Slider(
                      value: _inputReps.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      activeColor: AppColors.cyanAccent,
                      inactiveColor: AppColors.darkSurfaceElevated,
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
                  backgroundColor: AppColors.emeraldPrimary,
                  foregroundColor: Colors.black,
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

  Widget _buildSetsList(dynamic session) {
    final sets = session?.sets ?? [];
    if (sets.isEmpty) {
      return const Center(
        child: Text('No sets logged yet. Adjust weight and tap Log Set.', style: TextStyle(color: AppColors.darkTextMuted)),
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
            color: AppColors.redAccent.withOpacity(0.3),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: AppColors.redAccent),
          ),
          onDismissed: (_) => _loggerStore.removeSet(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: set.isCompleted ? AppColors.emeraldPrimary.withOpacity(0.4) : AppColors.darkBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${set.setNumber}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex?.name ?? 'Compound Lift', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                      Text('${set.weightKg.toStringAsFixed(1)} kg × ${set.reps} reps • RPE ${set.rpe.toStringAsFixed(1)} • 1RM: ${set.oneRepMaxEpley.toStringAsFixed(0)}kg',
                          style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _loggerStore.toggleSetCompletion(index),
                  icon: Icon(
                    set.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: set.isCompleted ? AppColors.emeraldPrimary : AppColors.darkTextMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isRestRunning, int restRemaining) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
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
                    color: AppColors.emeraldPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.emeraldPrimary.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: AppColors.emeraldPrimary),
                      const SizedBox(width: 6),
                      Text('Rest: ${restRemaining}s', style: const TextStyle(color: AppColors.emeraldPrimary, fontWeight: FontWeight.w700)),
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
                  foregroundColor: AppColors.darkTextPrimary,
                  side: const BorderSide(color: AppColors.darkBorder),
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
                    const SnackBar(
                      content: Text('Workout session saved to local SQLite database.'),
                      backgroundColor: AppColors.emeraldDark,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Finish Workout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldPrimary,
                foregroundColor: Colors.black,
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

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }
}
